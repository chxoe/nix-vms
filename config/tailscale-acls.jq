{
	"acls": [
		{
			"action": "accept",
			"src":    ["autogroup:member"],
			"dst":    ["tag:ssh:22"]
		},
		{
			"action": "accept",
			"src":    ["jumpbox"],
			"dst":    ["caddy:80,443"]
		},
		{
			"action": "accept",
			"src":    ["*"],
			"dst":    ["autogroup:internet:*"]
		}
	],
	"ssh": [
		{
			"action": "accept",
			"src":    ["autogroup:member"],
			"dst":    ["tag:ssh"],
			"users":  ["autogroup:nonroot"]
		}
	],
	"hosts": {
		"jumpbox": $jumpbox,
		"caddy":   $caddy,
		"host":    $host
	},
	"tagOwners": {
		"tag:ssh": ["autogroup:admin"]
	}
}
