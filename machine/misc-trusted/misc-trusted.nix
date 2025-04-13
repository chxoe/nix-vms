{
	hostname = "misc-trusted";
	network = "tailscale";
	##
	passthrough = {rust-service, drive, ...}: {pkgs, config, ...}: {
		systemd.services.drive = rust-service {
			source = drive;
			executable = "server";
		};
	};
}
