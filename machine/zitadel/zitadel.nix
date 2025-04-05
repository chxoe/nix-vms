{
	hostname = "zitadel";
	network = "external";
	##
	passthrough = {self, private, ...}: {pkgs, config, ...}: {
		services.zitadel = {
			enable = true;
			masterKeyFile = "/zitadel/master-key";
			settings = {
				Port = 8080;
				ExternalPort = 443;
				ExternalDomain = private.domains.zitadel;
				ExternalSecure = true;
				Database = {
					postgres = {
						Host = "localhost";
						Port = 5432;
						Database = "zitadel";
						User = { Username = "zitadel"; Password = ""; SSL = { Mode = "disable"; }; };
						Admin = { Username = "postgres"; Password = ""; SSL = { Mode = "disable"; }; };
					};
				};
			};
			steps = {
				FirstInstance = {
					Skip = false;
					InstanceName = "ZITADEL";
					DefaultLanguage = "en";
					Org = {
						Name = "ZITADEL";
						Human = {
							UserName = "zitadel-admin";
							FirstName = "ZITADEL";
							LastName = "Admin";
							Email = {
								Verified = true;
							};
							PreferredLanguage = "en";
							Password = "Password1!";
							PasswordChangeRequired = true;
						};
					};
				};
			};
		};
		services.postgresql = {
			enable = true;
			package = pkgs.postgresql_15;
			dataDir = "/postgresql/data";
			ensureUsers = [
				{
					name = "zitadel";
					ensureClauses = { superuser = true; };
				}
			];
			authentication = pkgs.lib.mkOverride 10 ''
				#type	db	user			auth-method
				local	all	all			trust
				host	all	all	127.0.0.1/32	trust
				host	all	all	::1/128		trust
			'';
		};
	};
}
