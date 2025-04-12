{
	hostname = "misc-trusted";
	network = "tailscale";
	##
	passthrough = {naersk, self, ...}: {pkgs, config, ...}: {
		systemd.services.drive = let
			driveSource = builtins.fetchGit { "url" = "git@github.com:chxoe/drive.git"; "ref" = "main"; "rev" = "1ddd9538dd89e820d1c23e2f7b870973d7bc5801"; };
			driveDerivation = naersk.buildPackage { src = "${driveSource}"; };
		in {
			enable = true;
			path = [ ];
			serviceConfig = {
				ExecStart = "${self}/util/systemd-exec.sh ${driveDerivation}/bin/server";
				AmbientCapabilities = "cap_net_bind_service";
				CapabilityBoundingSet = "cap_net_bind_service";
				StateDirectory = "drive";
				LogsDirectory = "drive";
				WorkingDirectory = "${driveSource}";
			};
			wantedBy = [ "multi-user.target" ];
		};
	};
}
