{
	hostname = "caddy-public";
	network = "tailscale";
	exitNode = "jumpbox-public";
	##
	passthrough = {self, private, ...}: {pkgs, config, ...}:
		{
			services.caddy = {
				enable = true;
				virtualHosts."${private.domains.jumpbox-public}".extraConfig = ''
					respond "If you can see this, ${private.domains.jumpbox-public} is working."
				'';
			};
		};
}
