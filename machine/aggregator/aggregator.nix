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
	};
}
