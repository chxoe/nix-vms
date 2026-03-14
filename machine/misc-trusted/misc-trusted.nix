{
	hostname = "misc-trusted";
	network = "tailscale";
	##
	passthrough = {naersk, ...}: {pkgs, config, ...}: {
		systemd.services.drive = let
			drive = builtins.fetchGit { "url" = "git@github.com:chxoe/drive.git"; "ref" = "main"; "rev" = "683975d11b5cb3e8b4eda36f4a06c00efeffe5fb"; };
			driveDerivation = naersk.buildPackage {src=drive.outPath;};
		in {
			enable = true;
			path = [ ];
			serviceConfig = {
				ExecStart = "${driveDerivation}/server";
				AmbientCapabilities = "cap_net_bind_service";
				CapabilityBoundingSet = "cap_net_bind_service";
				WorkingDirectory = "/drive";
			};
		};
	};
}
