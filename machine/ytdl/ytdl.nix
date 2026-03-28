{
	hostname = "ytdl";
	network = "local";
	staticIp = "10.0.0.205";
	passthrough = {private, modules, ...}: {pkgs, lib, ...}@moduleInputs: {
		services.ytdl-sub.instances.default = {
			enable = true;
			schedule = "0/6:0";
			readWritePaths = [ "/videos" ];
			config = private.ytdl-sub.config;
			subscriptions = private.ytdl-sub.subscriptions;
		};
		services.jellyfin = {
			enable = true;
		};
		environment.systemPackages = [
			pkgs.jellyfin
			pkgs.jellyfin-web
			pkgs.jellyfin-ffmpeg
		];
	};
}
