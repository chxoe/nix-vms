{
	hostname = "technitium";
	staticIp = "10.0.0.202";
	network = "local";
	##
	passthrough = pkgs: config:
		let
			customPkgs = pkgs // {
				technitium-dns-server-library = pkgs.callPackage "${config}/custom-package/technitium-dns-server-library-latest.nix" {};
			};
		in {
			services.technitium-dns-server = {
				enable = true;
				package = customPkgs.callPackage "${config}/custom-package/technitium-dns-server-latest.nix" {};
			};
		};
}
