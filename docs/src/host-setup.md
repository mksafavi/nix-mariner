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

`mariner.host` enables the microvm.nix `microvm.host` module and adds its own host-side options:

```nix
{{#include ../../examples/host.nix:host-module}}
```

- `mariner.host.graphics` runs a `waypipe` client so VMs can render windows on the host Wayland compositor.
- `mariner.host.network` sets up a bridge that each VM connects to. It's a default that might not match your setup. Keep it disabled and configure networking yourself if it doesn't fit. See microvm.nix's [`a simple network setup`](https://microvm-nix.github.io/microvm.nix/simple-network.html).

- `mariner.host.network.exposeDNS` allows the VM to use the host's DNS server. By default VMs resolve DNS themselves. If you enable this, you also need to set the VM `mariner.network.dns` option to the bridge gateway address.

See [host options](mariner-host-options.md) for more information.

## Verify
After a `nixos-rebuild switch` you should have the following:
```bash
ls /dev/kvm                        # exists
ip addr show br-microvm            # has 10.0.0.1/24
ss -lntp | grep ':53'              # listening on 10.0.0.1:53
lsmod | grep vhost_vsock           # module loaded
```
