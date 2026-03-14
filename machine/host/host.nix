## TODO: Completely untested!
{
	hostname = "server";
	# TODO: ... does "local" do anything that will get in the way?
	network = "local";
	staticIp = "10.0.0.200";
	##
	interface = "enp6s0";
	##
	passthrough = {self, private, ...}: {pkgs, config, ...}: {
		
		# For use as a build system
		## TODO: Automatically add all systems output for this flake
		boot.binfmt.emulatedSystems = ["aarch64-linux"];
		
		# Example VM
		## TODO: Automatically iterate over VMs based on flake.nix output // host...?
		let
			roon = import "${self}/machine/roon/roon.nix";
		in systemd.services.vm-roon = {
			enable = true;
			wantedBy = [ "multi-user.target" ];
			serviceConfig = {
				Type = "oneshot";
				Restart = "on-failure";
				RestartSec = 30;
			};
			script = ''
				## TODO: Generate based on "${roon}.LANports"
				${pkgs.iptables} -t nat -A PREROUTING -j DNAT -i br0 -p tcp --dport 50000 --to-destination ${roon.staticIp}
				${pkgs.iptables} -t nat -A POSTROUTING -j MASQUERADE -d ${roon.staticIp} -p tcp --dport 50000
				## TODO: Generate /vm/roon.qcow2 if it doesn't already exist!
				## TODO: Use "${roon}.RAM" and "${roon}.vCPUs", and arch from "${roon.system}"
				${pkgs.qemu}/bin/qemu-system-x86_64
					-m 32G
					-smp 16
					-drive file=/vm/room.qcow2,format=qcow2
					-net nic,model=virtio,macaddr=52:54:00:12:35:56
					-net bridge,br=br0
			'';
		};
		## TODO: Schedule a task to backup the VM
		
		# "network = local" networking
		boot.kernel.sysctl."net.ipv4.ip_forward" = 1;
		let
			host = import "${self}/machine/host/host.nix";
		in {
			networking.networkmanager = {
				enable = true;
				ensureProfiles.profiles = {
					bridge-br0 = {
						connection = {
							id = "bridge-br0";
							type = "bridge";
							interface-name = "br0";
						};
						ethernet = {};
						bridge.stp = false;
						ipv4 = {
							address1 = "${host.staticIp}/32";
							dns = "1.1.1.1";
							method = "auto";
						};
						ipv6 = {
							addr-gen-mode = "default";
							method = "auto";
						};
						proxy = {};
					};
					"bridge-slave-${interface}" = {
						connection = {
							id = "bridge-slave-${host.interface}";
							type = "ethernet";
							controller = "br0";
							interface-name = "${host.interface}";
						};
						ethernet = {};
						bridge-port = {};
					};
				};
			};
			systemd.services.vm-network = {
				enable = true;
				after = [ "network.target" ];
				serviceConfig = {
					Type = "oneshot";
					Restart = "on-failure";
					RestartSec = 30;
				};
				script = ''
					${pkgs.iptables} -t nat -A POSTROUTING -o ${host.interface} -j MASQUERADE
					${pkgs.iptables} -A FORWARD -m conntrack -i br0 -o ${host.interface} --ctstate RELATED,ESTABLISHED -j ACCEPT
					${pkgs.iptables} -A FORWARD -i br0 -o ${host.interface} -j ACCEPT
				'';
			};
		};
		## TODO: Schedule a task to backup the host
		## TODO: Shell scripts: restore host, restore VM, nixos-rebuild host, nixos-rebuild VM
		## TODO: SSH config to access VMs by name
		## TODO: Set up a development environment for this repo (on the host?)
		## TODO: Tailscale config, incl auto-generating and applying tailscale ACLs based on VMs
		## TODO: Automatic jumpbox setup using a cloud provider based on ${private.domains}
	};
}
