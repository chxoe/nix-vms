{
	description = "System configuration helper";
	inputs = {
		nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable";
		private.url = "git+ssh://git@github.com/chxoe/nix-vms-private.git?ref=main";
		naersk.url = "github:nix-community/naersk";
		drive = { url = "git+ssh://git@github.com/chxoe/drive.git?ref=main"; flake = false; };
		aggregator.url = "git+ssh://git@github.com/chxoe/aggregator.git?ref=main";
	};
	outputs = { self, nixpkgs, private, naersk, drive, aggregator }@inputs:
		let
			system-from-config = machineConfig: machineConfig.system or "x86_64-linux";
			machine-pkgs-from-config = machineConfig:
				let system = system-from-config machineConfig;
				in import nixpkgs {
					system = system;
					config.allowUnfreePredicate = pkg: builtins.elem (nixpkgs.legacyPackages."${system}".lib.getName pkg) machineConfig.unfree or [];
				};
			rust-service = system: {source, executable}:
				let builtSource = naersk.outputs.lib."${system}".buildPackage { src = "${source}"; };
				in {
					enable = true;

					# Auto start the service on boot.
					wantedBy = [ "multi-user.target" ];

					# See man systemd.exec
					serviceConfig = {
						# Run the given executable, writing logs out to the log directory (see below).
						ExecStart = "${self}/util/systemd-exec.sh ${builtSource}/bin/${executable}";

						# For persistent data. Accessible via $STATE_DIRECTORY, location = /var/lib/${name}
						StateDirectory = "%N";

						# For logs, used by util/systemd-exec.sh. Accessible via $LOGS_DIRECTORY, location = /var/log/${name}
						LogsDirectory = "%N";

						# Use the location of the source code (read-only) in the Nix store as the working directory.
						WorkingDirectory = "${source}";

						# Allow services to bind to low # ports
						AmbientCapabilities = "cap_net_bind_service";
						CapabilityBoundingSet = "cap_net_bind_service";
					};
				};
			java-jar-service = pkgs: {source, jar}: {
					enable = true;
					wantedBy = [ "multi-user.target" ];
					serviceConfig = {
						ExecStart = "${self}/util/systemd-exec.sh '${nixpkgs.lib.getExe pkgs.jdk} -jar ${jar}'";
						StateDirectory = "%N";
						LogsDirectory = "%N";
						WorkingDirectory = "${source}";
						AmbientCapabilities = "cap_net_bind_service";
						CapabilityBoundingSet = "cap_net_bind_service";
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
								configDir = configDir;
								private = private;
								modules = {
									matrix-stack = import "${self}/modules/matrix-stack.nix";
								};
								rust-service = rust-service (system-from-config machineConfig);
								java-jar-service = java-jar-service (machinePkgs);
								drive = drive;
								aggregator = aggregator.outputs.defaultPackage.${system-from-config machineConfig};
							}) else ({...}:{}));
						inherit inputs;
					};
					modules = [
						"${self}/config/nixos.nix"
					];
				};
		in {
			nixosConfigurations = {

				# Local network only
				roon = system-from-name "roon";
				technitium = system-from-name "technitium";

				# Publicly associated with me (app names and details hidden for privacy)
				jumpbox-public = system-from-name "jumpbox-public";
					caddy-public = system-from-name "caddy-public";
						# auth-public = system-from-name "auth-public";
						aggregator = system-from-name "aggregator";
				matrix = system-from-name "matrix";

				# Everything in-between
				# jumpbox = system-from-name "jumpbox";
					caddy = system-from-name "caddy";
						zitadel = system-from-name "zitadel";
						misc-trusted = system-from-name "misc-trusted";

				# Never associated with me
				# jumpbox-private = system-from-name "jumpbox-private";
					# caddy-private = system-from-name "caddy-private";
						# mastodon-private = system-from-name "mastodon-private";
			};
		};
}
