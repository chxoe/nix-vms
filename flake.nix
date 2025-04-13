{
	description = "System configuration helper";
	inputs = {
		nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable";
		private.url = "git+ssh://git@github.com/chxoe/nix-vms-private.git?ref=main";
		naersk.url = "github:nix-community/naersk";
		drive.url = "git+ssh://git@github.com:chxoe/drive.git?ref=main";
	};
	outputs = { self, nixpkgs, private, naersk, drive }@inputs:
		let
			system-from-config = machineConfig: machineConfig.system or "x86_64-linux";
			machine-pkgs-from-config = machineConfig:
				let system = system-from-config machineConfig;
				in import nixpkgs {
					system = system;
					config.allowUnfreePredicate = pkg: builtins.elem (nixpkgs.legacyPackages."${system}".lib.getName pkg) machineConfig.unfree or [];
				};
			rust-service = {system}: {name, source, executable}: {
				systemd.services."${name}" = let
					derivation = naersk.ouputs.lib."${system}".buildPackage { src = source; };
				in {
					enable = true;
					
					# Auto start the service on boot.
					wantedBy = [ "multi-user.target" ];
					
					# See man systemd.exec
					serviceConfig = {
						# Run the given executable, writing logs out to the log directory (see below). 
						ExecStart = "${self}/util/systemd-exec.sh ${derivation}/bin/${executable}";
						
						# For persistent data. Accessible via $STATE_DIRECTORY, location = /var/lib/${name}
						StateDirectory = name;
						
						# For logs, used by util/systemd-exec.sh. Accessible via $LOGS_DIRECTORY, location = /var/log/${name}
						LogsDirectory = name;
						
						# Use the location of the source code (read-only) in the Nix store as the working directory.
						WorkingDirectory = "${source}";
						
						# Allow services to bind to low # ports
						AmbientCapabilities = "cap_net_bind_service";
						CapabilityBoundingSet = "cap_net_bind_service";
					};
				};
			};
			system-from-name = machine: 
				let
					userConfig = import "${self}/config/user.nix";
					machineConfig = import "${self}/machine/${machine}/${machine}.nix";
					machinePkgs = machine-pkgs-from-config machineConfig;
					configDir = "${self}/machine/${machine}";
				in nixpkgs.lib.nixosSystem {
					specialArgs = {
						selfDir = self;
						configDir = configDir;
						machineConfig = machineConfig;
						userConfig = userConfig;
						passthrough = (if machineConfig?passthrough then (machineConfig.passthrough {
								self = self;
								private = private;
								rust-service = rust-service (system-from-config machineConfig);
								inherit drive;
							}) else ({...}:{}));
						inherit inputs;
					};
					modules = [
						"${self}/config/nixos.nix"
					];
				};
		in {
			nixosConfigurations = {
				roon = system-from-name "roon";
				technitium = system-from-name "technitium";
				caddy = system-from-name "caddy";
				zitadel = system-from-name "zitadel";
				misc-trusted = system-from-name "misc-trusted";
			};
		};
}
