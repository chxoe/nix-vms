{
	hostname = "roon";
	network = "local";
	staticIp = "10.0.0.201";
	RAM = "4G";
	CPUthreads = 4;
	LANports = [ 50000 ];
	unfree = [ "roon-server-earlyaccess" ];
	passthrough = {self, ...}: {pkgs, config, ...}: {
		services.roon-server = {
			package = pkgs.callPackage "${self}/custom-package/roon-server-earlyaccess.nix" {};
			enable = true;
		};
	};
	backupScript = ''
		$backupDirs /music /backup
	'';
}
