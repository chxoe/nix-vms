{
	hostname = "caddy";
	network = "external";
	##
	passthrough = {self, private, ...}: {pkgs, config, ...}:
		in {
			services.caddy = {
				enable = true;
				virtualHosts."${private.domains.jumpbox}".extraConfig = ''
					respond "If you can see this, ${domains.jumpbox} is working."
				'';
				virtualHosts."${private.domains.zitadel}".extraConfig = ''
					reverse_proxy h2c://10.0.2.2:8080
				'';
				virtualHosts."${private.domains.files}".extraConfig = ''
					reverse_proxy http://10.0.2.2:12080
				'';
			};
			services.tailscale.enable = true;
			services.tailscale.useRoutingFeatures = "client";
			services.tailscale.extraSetFlags = [ "--exit-node=100.101.66.7" "--ssh" ];
		};
}
