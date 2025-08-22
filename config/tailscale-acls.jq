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
			"src":    ["jumpbox-public"],
			"dst":    ["caddy-public:80,443"]
		},
		{
			"action": "accept",
			"src":    ["caddy"],
			"dst":    ["zitadel:8080"]
		},
		{
			"action": "accept",
			"src":    ["caddy"],
			"dst":    ["misc-trusted:80"]
		},
		{
			"action": "accept",
			"src":    ["caddy-public"],
			"dst":    ["aggregator:8081"]
		},
		{
			"action": "accept",
			"src":    ["*"],
			"dst":    ["autogroup:internet:*"]
		},
		{
			"action": "accept",
			"src": ["misc-trusted"],
			"dst": ["tag:ssh:*"]
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
		"jumpbox":      $jumpbox,
		"caddy":        $caddy,
		"host":         $host,
		"zitadel":      $zitadel,
		"aggregator":   $aggregator,
		"misc-trusted": $misc_trusted,
		"caddy-public": $caddy_public,
		"jumpbox-public": $jumpbox_public
	},
	"tagOwners": {
		"tag:ssh": ["autogroup:admin"]
	}
}
