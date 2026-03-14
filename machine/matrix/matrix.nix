{
	hostname = "matrix";
	network = "local";
	staticIp = "10.0.0.203";
	passthrough = {private, modules, ...}: {pkgs, lib, ...}@moduleInputs:
		lib.recursiveUpdate
			(modules.matrix-stack {
				nginx.acme-email = private.emails."matrix-acme";
				element.domain = private.domains.element;
				matrix = {
					domain = private.domains.matrix;
					registration-secret = private.matrixRegistrationSecret;
				};
			} moduleInputs)
			{
				networking.enableIPv6 = false;
				networking.firewall.enable = pkgs.lib.mkForce true;
			};
}
