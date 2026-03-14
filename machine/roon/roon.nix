{
	hostname = "roon";
	network = "local";
	staticIp = "10.0.0.201";
	##
	unfree = [ "roon-server-earlyaccess" ];
	passthrough = {self, ...}: {pkgs, config, ...}: {
		
		# For use as a build system... temporary!
		boot.binfmt.emulatedSystems = ["aarch64-linux"];
		# End temporary section.
		
		services.roon-server = {
			package = pkgs.callPackage "${self}/custom-package/roon-server-earlyaccess.nix" {};
			enable = true;
		};
	};
}
