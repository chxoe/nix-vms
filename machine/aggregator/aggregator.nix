{
	hostname = "aggregator";
	network = "tailscale";
	exitNode = "jumpbox-public";
	##
	passthrough = {java-jar-service, aggregator, private, ...}: {pkgs, config, ...}: {
		systemd.services.aggregator = java-jar-service {
			source = aggregator;
			jar = "${private.aggregatorJarFile}";
		};
		services.postgresql = {
			enable = true;
			package = pkgs.postgresql_15;
			dataDir = "/postgresql/data";
			ensureUsers = [
				{
					name = "aggregator";
					ensureClauses = { superuser = true; };
				}
			];
			authentication = pkgs.lib.mkOverride 10 ''
				#type	db	user			method
				local	all	all			trust
				host	all	all	127.0.0.1/32	trust
				host	all	all	::1/128		trust
			'';
		};
	};
}
