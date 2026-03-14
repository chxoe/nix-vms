{
	hostname = "caddy";
	network = "tailscale";
	exitNode = "jumpbox";
	##
	passthrough = {self, private, ...}: {pkgs, config, ...}:
		{
			services.caddy = {
				enable = true;
				virtualHosts."${private.domains.jumpbox}".extraConfig = ''
					respond "If you can see this, ${private.domains.jumpbox} is working."
				'';
				virtualHosts."${private.domains.zitadel}".extraConfig = ''
					reverse_proxy h2c://zitadel:8080
				'';
				virtualHosts."${private.domains.files}".extraConfig = ''
					reverse_proxy http://misc-trusted:80
				'';
			};
		};
}
