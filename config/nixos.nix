{ configDir, machineConfig, selfDir, userConfig, config, lib, pkgs, private, passthrough, ... }: {
	imports = [ 
		"${configDir}/hardware-configuration.nix"
		passthrough
	];
	boot.loader.grub = { enable = true; device = "/dev/sda"; };
	networking.hostName = machineConfig.hostname or "nixos";
	networking.interfaces.ens3.ipv4.addresses = lib.mkIf (machineConfig?staticIp) [
		{ address = machineConfig.staticIp; prefixLength = 24; }
	];
	networking.defaultGateway = {
		"local" = { interface = "ens3"; address = "10.0.0.200"; };
		"external" = null;
		"tailscale" = null;
	}."${machineConfig.network}";
	networking.nameservers = {
		"local" = [ (import "${selfDir}/machine/technitium/technitium.nix").staticIp ];
		"external" = [ ];
		"tailscale" = [ ];
	}."${machineConfig.network}";
	networking.networkmanager.enable = true;
	networking.firewall.enable = false;
	users.users."${userConfig.username}" = {
		home = "/home/${userConfig.username}";
		isNormalUser = true;
		extraGroups = [ "wheel" ];
		shell = pkgs.bash;
		openssh.authorizedKeys.keys = userConfig.publicKeys; 
	};
	environment.systemPackages = with pkgs; [ vim wget git curl ];
	nixpkgs.config.allowUnfreePredicate = pkg: builtins.elem (lib.getName pkg) machineConfig.unfree or [];
	nix.extraOptions = ''
		experimental-features = nix-command flakes
	'';
	services.openssh.enable = true;
	services.tailscale = lib.mkIf (machineConfig.network == "tailscale") {
		enable = true;
		useRoutingFeatures = "client";
		extraSetFlags = [ "--exit-node=jumpbox" "--ssh" ]
	};
	system.stateVersion = "24.11";
}
