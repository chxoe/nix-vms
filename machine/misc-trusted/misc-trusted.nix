{
	hostname = "misc-trusted";
	network = "tailscale";
	exitNode = "jumpbox";
	##
	passthrough = {rust-service, drive, ...}: {pkgs, config, ...}: {
		systemd.services.drive = rust-service {
			source = drive;
			executable = "server";
		};
	};
}
