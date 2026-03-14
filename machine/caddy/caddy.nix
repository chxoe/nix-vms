{
	hostname = "caddy";
	network = "external";
	##
	passthrough = pkgs: config:
		let domains = import "${config}/config/domains.nix";
		in {
			services.caddy = {
				enable = true;
				virtualHosts."${domains.jumpbox}".extraConfig = ''
					respond "If you can see this, ${domains.jumpbox} is working."
				'';
				virtualHosts."${domains.zitadel}".extraConfig = ''
					reverse_proxy h2c://10.0.2.2:8080
				'';
				virtualHosts."${domains.files}".extraConfig = ''
					reverse_proxy http://10.0.2.2:12080
				'';
			};
			services.tailscale.enable = true;
		};
	};
}
