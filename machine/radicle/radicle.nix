{
	hostname = "radicle";
	network = "local";
	staticIp = "10.0.0.206";
	##
	passthrough = {self, private, ...}: {pkgs, config, ...}:
		{
			services.radicle = {
				enable = true;
				httpd.enable = true;
				publicKey = "${private.radicle.publicKey}";
				privateKey = "/radicle-private-key";
				settings = {
					node = {
						alias = "${private.radicle.alias}";
						listen = [ "0.0.0.0:8776" ];
						externalAddresses = [ "${private.radicle.externalAddress}:8776" ];
						seedingPolicy = {
							default = "block";
							scope = "all";
						};	
					};
				};
			};
		};
}
