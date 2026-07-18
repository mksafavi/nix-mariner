# Host setup

In order to use nix-mariner, you need to import `mariner.nixosModules.host` module and configure the network options in your nixos system configuration.

You can use the `microvm` cli tool to create and manage VMs imperatively, instead of declaring them in your NixOS config.

See [`Preparing a NixOS host for declarative MicroVMs`](https://microvm-nix.github.io/microvm.nix/host.html) for more information

## NixOS microvm.nix module

Add mariner to your host NixOS flake inputs:
```nix
{{#include ../../examples/host_flake_inputs.nix}}
```

Alternatively, you could declare microvm directly in your inputs:
```nix
{{#include ../../examples/host_flake_following_inputs.nix}}
```

## Mariner host module additions

Importing `mariner.host` enables the `microvm.host` and defaults to on.
`mariner.host.graphics` option runs a `waypipe` client in the host Wayland session so VM windows render on host's Wayland compositor.
`mariner.host.network` sets up a bridge that each VM tap connects to on their own `10.0.0.0/24` subnet.

The VMs resolve DNS by `systemd-resolved` service.
If you want to allow the VMs to access DNS from the host machine,
enable `mariner.host.network.exposeDNS` and set the VM `mariner.network.dns` option to the bridge gateway address.
Enabling `exposeDNS` opens port `53` on the firewall.

The network options are a default, that might not match your network configurations. Keep it disabled and configure it yourself if it doesn't fit.

See [`A simple network setup`](https://microvm-nix.github.io/microvm.nix/simple-network.html) for more information.

```nix
{{#include ../../examples/host.nix:host-module}}
```

## Verify
After a `nixos-rebuild switch` you should have the following:
```bash
ls /dev/kvm                        # exists
ip addr show br-microvm            # has 10.0.0.1/24
ss -lntp | grep ':53'              # listening on 10.0.0.1:53
lsmod | grep vhost_vsock           # module loaded
```
