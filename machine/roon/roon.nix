{
	hostname = "roon";
	network = "local";
	staticIp = "10.0.0.201";
	##
	unfree = [ "roon-server-earlyaccess" ];
	passthrough = {self}: {pkgs, config, ...}: {
		services.roon-server = {
			package = pkgs.callPackage "${self}/custom-package/roon-server-earlyaccess.nix" {};
			enable = true;
		};
	};
}
