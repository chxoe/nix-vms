{
	description = "System configuration helper";
	inputs.nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable";
	inputs.agenix.url = "github:ryantm/agenix";
	outputs = { self, nixpkgs, agenix }@inputs:
		let
			system-from-config = machineConfig: machineConfig.system or "x86_64-linux";
			machine-pkgs-from-config = machineConfig:
				let system = system-from-config machineConfig;
				in import nixpkgs {
					system = system;
					config.allowUnfreePredicate = pkg: builtins.elem (nixpkgs.legacyPackages."${system}".lib.getName pkg) machineConfig.unfree or [];
				};
			system-from-name = machine: 
				let
					userConfig = import "${self}/config/user.nix";
					machineConfig = import "${self}/machine/${machine}/${machine}.nix";
					machinePkgs = machine-pkgs-from-config machineConfig;
					configDir = "${self}/machine/${machine}";
				in nixpkgs.lib.nixosSystem {
					specialArgs = {
						selfDir = "${self}";
						configDir = configDir;
						machineConfig = machineConfig;
						userConfig = userConfig;
						inherit inputs;
					};
					modules = [
						"${self}/config/nixos.nix"
						((machineConfig.passthrough or (pkgs: self: {})) machinePkgs self)
						agenix.nixosModules.default
						{ environment.systemPackages = [ agenix.packages.${system-from-config machineConfig}.default ]; }
						{ age.identityPaths = [ "/root/.ssh/id_ed25519" ]; age.secrets.domains.file = "${self}/config/domains.age"; }
					];
				};
		in {
			nixosConfigurations = {
				roon = system-from-name "roon";
				technitium = system-from-name "technitium";
				caddy = system-from-name "caddy";
			};
		};
}
