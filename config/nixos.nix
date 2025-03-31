{ configDir, machineConfig, selfDir, userConfig, config, lib, pkgs, ... }: {	
	imports = [ "${configDir}/hardware-configuration.nix" ];
	boot.loader.grub = { enable = true; device = "/dev/sda"; };
	networking.hostName = machineConfig.hostname or "nixos";
	networking.interfaces.ens3.ipv4.addresses = lib.mkIf (machineConfig.staticIp != null) [
		{ address = machineConfig.staticIp; prefixLength = 24; }
	];
	networking.defaultGateway = {
		"local" = { interface = "ens3"; address = "10.0.0.200"; };
		"external" = null;
	}."${machineConfig.network}";
	networking.nameservers = {
		"local" = [ (import "${selfDir}/machine/technitium/technitium.nix").staticIp ];
		"external" = [ ];
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
	services.openssh.enable = true;
	system.stateVersion = "24.11";
}
