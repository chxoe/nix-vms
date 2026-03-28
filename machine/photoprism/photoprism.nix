{
	hostname = "photoprism";
	network = "local";
	staticIp = "10.0.0.204";
	##
	passthrough = {self, private, ...}: {pkgs, ...}: {
		services.photoprism = {
			enable = true;
			port = 2342;
			originalsPath = "/var/lib/private/photoprism/originals";
			address = "0.0.0.0";
			settings = {
				PHOTOPRISM_ADMIN_USER = "admin";
				PHOTOPRISM_ADMIN_PASSWORD = private.photoprism.password;
				PHOTOPRISM_DEFAULT_LOCALE = "en";
				PHOTOPRISM_DATABASE_DRIVER = "mysql";
				PHOTOPRISM_DATABASE_NAME = "photoprism";
				PHOTOPRISM_DATABASE_SERVER = "/run/mysqld/mysqld.sock";
				PHOTOPRISM_DATABASE_USER = "photoprism";
				PHOTOPRISM_SITE_URL = private.photoprism.url;
				PHOTOPRISM_SITE_TITLE = "PhotoPrism";
			};
		};
		services.mysql = {
			enable = true;
			dataDir = "/data/mysql";
			package = pkgs.mariadb;
			ensureDatabases = [ "photoprism" ];
			ensureUsers = [ {
				name = "photoprism";
				ensurePermissions."photoprism.*" = "ALL PRIVILEGES";
			} ];
		};
	};
}

