{
	hostname = "technitium";
	staticIp = "10.0.0.202";
	network = "local";
	##
	passthrough = {self}: {pkgs, config, ...}: {
			services.technitium-dns-server = {
				enable = true;
				package = pkgs.callPackage "${self}/custom-package/technitium-dns-server-latest.nix" {
					technitium-dns-server-library = pkgs.callPackage "${self}/custom-package/technitium-dns-server-library-latest.nix" {};
				};
			};
	};
}
