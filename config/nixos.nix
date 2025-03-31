{ configDir, machineConfig, selfDir, userConfig, config, lib, pkgs, ... }:

# let userConfig = import "${config.age.secrets.user.path}";
# in 
{	
	imports = [ "${configDir}/hardware-configuration.nix" ];
	
	boot.loader.grub = { enable = true; device = "/dev/sda"; };
	
	networking.hostName = machineConfig.hostname or "nixos";
	networking.interfaces.ens3.ipv4.addresses = lib.mkIf (machineConfig.staticIp != null) [
		{ address = machineConfig.staticIp; prefixLength = 24; }
	];
	networking.defaultGateway = {
		"local" = { interface = "ens3"; address = "10.0.0.200"; };
	}."${machineConfig.network}";
	networking.nameservers = {
		"local" = [ "10.0.0.202" ];
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

