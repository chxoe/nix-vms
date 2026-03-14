let
	keys = [
		"ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIICGvtbpmVRVRpQsIXwq9nE8SwN+XM+j3zYw1GTSoIw0 root@roon"
		"ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIGtLZNibBf9ImykRP/V71jjNkT/obctCh5N76Z0S0BvT root@technitium"
		"ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAILEQp9eG8q6NV/LWJsP9XaMO0SN14oBd5fPXUl772jMf root@caddy"
	];
in {
	"config/domains.age".publicKeys = keys;
}
