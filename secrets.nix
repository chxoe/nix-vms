let
	keys = [
		"ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIICGvtbpmVRVRpQsIXwq9nE8SwN+XM+j3zYw1GTSoIw0 root@roon"
	];
in {
	"config/domains.age".publicKeys = keys;
}
