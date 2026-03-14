{
	hostname = "matrix";
	network = "local";
	staticIp = "10.0.0.203";
	##
	passthrough = {self, private, ...}: {pkgs, config, ...}: {
		
		networking.enableIPv6 = false;	
		networking.firewall.enable = pkgs.lib.mkForce true;
		networking.firewall.allowedTCPPorts = [ 80 443 ];
		services.postgresql = {
			enable = true;
			authentication = pkgs.lib.mkOverride 10 ''
				# type	database	DBuser	auth-method
				local	all		all	trust
			'';
		};
		
		security.acme.defaults.email = private.emails."matrix-acme";
		security.acme.acceptTerms = true;

		services.nginx = {
			enable = true;
			recommendedTlsSettings = true;
			recommendedOptimisation = true;
			recommendedGzipSettings = true;
			recommendedProxySettings = true;
			virtualHosts = {
				"${private.domains.matrix}" = {
					enableACME = true;
					forceSSL = true;
					locations."/".extraConfig = ''
						return 301 https://${private.domains.element}/;
					'';
					locations."= /.well-known/matrix/server".extraConfig = ''
						default_type application.json;
						add_header Access-Control-Allow-Origin *;
						return 200 '${builtins.toJSON {
							"m.server" = "${private.domains.matrix}:443";
						}}';
					'';
					locations."= /.well-known/matrix/client".extraConfig = ''
						default_type application.json;
						add_header Access-Control-Allow-Origin *;
						return 200 '${builtins.toJSON {
							"m.homeserver".base_url = "https://${private.domains.matrix}";
							"m.identity.server".base_url = "https://vector.im";
							"org.matrix.msc3575.proxy".url = "https://${private.domains.matrix}";
							"org.matrix.msc4143.rtc_foci" = [
								{
									type = "livekit";
									livekit_service_url = "https://${private.domains.matrix}/livekit/jwt";
								}
							];
						}}';
					'';
					locations."/_matrix".proxyPass = "http://127.0.0.1:8008";
					locations."/_synapse/client".proxyPass = "http://127.0.0.1:8008";
					locations."^~ /livekit/jwt/" = {
						priority = 400;
						proxyPass = "http://127.0.0.1:${toString config.services.lk-jwt-service.port}/";
					};
					locations."^~ /livekit/sfu" = {
						extraConfig = ''
							proxy_send_timeout 120;
							proxy_read_timeout 120;
							proxy_buffering off;
							
							proxy_set_header Accept-Encoding gzip;
							proxy_set_header Upgrade $http_upgrade;
							proxy_set_header Connection "upgrade";
						'';
						priority = 400;
						proxyPass = "http://127.0.0.1:${toString config.services.livekit.settings.port}/";
						proxyWebsockets = true;
					};
				};
			};
		};

		services.matrix-synapse = {
			enable = true;
			settings.server_name = "${private.domains.matrix}";
			settings.public_baseurl = "https://${private.domains.matrix}";
			settings.listeners = [
				{
					port = 8008;
					bind_addresses = [ "0.0.0.0" ];
					type = "http";
					tls = false;
					x_forwarded = true;
					resources = [
						{
							names = [
								"client"
								"federation"
							];
							compress = true;
						}
					];
				}
			];
			settings.registration_shared_secret = "${private.matrixRegistrationSecret}";
			settings.experimental_features.msc3266_enabled = true;
			settings.experimental_features.msc4222_enabled = true;
			settings.max_event_delay_duration = "24h";
			settings.rc_message.per_second = 0.5;
			settings.rc_message.burst_count = 30;
			settings.rc_delayed_event_mgmt.per_second = 1;
			settings.rc_delayed_event_mgmt.burst_count = 20;
		};
		services.livekit = {
			enable = true;
			openFirewall = true;
			settings.room.auto_create = false;
			keyFile = "/run/livekit.key";
		};
		services.lk-jwt-service = {
			enable = true;
			livekitUrl = "wss://${private.domains.matrix}/livekit/sfu";
			keyFile = "/run/livekit.key";
		};
		systemd.services.livekit-key = {
			before = [ "lk-jwt-service.service" "livekit.service" ];
			wantedBy = [ "multi-user.target" ];
			path = with pkgs; [ livekit coreutils gawk ];
			script = ''
				echo "Key missing: generating key..."
				echo "lk-jwt-service: $(livekit-server generate-keys | tail -1 | awk '{print $3}')" > "/run/livekit.key"
			'';
			serviceConfig.Type = "oneshot";
			unitConfig.ConditionPathExists = "!/run/livekit.key";
		};
		systemd.services.lk-jwt-service.environment.LIVEKIT_FULL_ACCESS_HOMESERVERS = "${private.domains.matrix}";
		services.nginx.virtualHosts."${private.domains.element}" = {
			enableACME = true;
			forceSSL = true;

			root = pkgs.element-web.override {
				conf = {
					default_server_config = {
						"m.homeserver".base_url = "https://${private.domains.matrix}";
					};
				};
			};
		};
	};
}
