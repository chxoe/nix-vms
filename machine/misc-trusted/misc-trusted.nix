{
	hostname = "misc-trusted";
	network = "tailscale";
	##
	passthrough = {rust-service, drive, ...}: {pkgs, config, ...}: {
		inherit rust-service {
			name = "drive";
			source = ${drive};
			executable = "server";
		};
	};
}
