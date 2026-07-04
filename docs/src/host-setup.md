# Host setup

In order to use nix-mariner, you need to import `microvm.nixosModules.host` module and configure the networking options in your nixos system configuration.

You can use the `microvm` cli tool to create and manage VMs imperatively, instead of declaring them in your NixOS config.

See [`Preparing a NixOS host for declarative MicroVMs`](https://microvm-nix.github.io/microvm.nix/host.html) for more information

## NixOS microvm.nix module

```nix
# Host server flake.nix
{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

    mariner.url = "github:mksafavi/nix-mariner";
    mariner.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = { self, nixpkgs, mariner }: {
    nixosConfigurations.machine = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      modules = [
        # Include the microvm host module
        mariner.inputs.microvm.nixosModules.host
      ];
    };
  };
}
```

Alternatively, you could declare microvm directly in your inputs:
```nix
# Host server flake.nix
{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

    microvm.url = "github:microvm-nix/microvm.nix";
    microvm.inputs.nixpkgs.follows = "nixpkgs";

    mariner.url = "github:mksafavi/nix-mariner";
    mariner.inputs.microvm.follows = "microvm";
    mariner.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = { self, nixpkgs, mariner, microvm }: {
    nixosConfigurations.machine = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      modules = [
        # Include the microvm host module
        microvm.nixosModules.host
      ];
    };
  };
}
```

## NixOS networking additions

Adding the following network configuration should be enough to setup the networking.

See [`A simple network setup`](https://microvm-nix.github.io/microvm.nix/simple-network.html) for more information

This creates a network bridge that each VM tap connects to.
If you change the default bridge address `10.0.0.1`, you also need to set the network address accordingly in the virtual machine configuration.

```nix
{ config, lib, pkgs, inputs, ... }:
{
  # microvm requires systemd networkd. You can use it alongside NetworkManager without any issues.
  systemd.network.enable = true;

  # DNS on microvm bridge. This assumes you're already using systemd-resolved.
  services.resolved.settings.Resolve = {
    DNSStubListenerExtra = [ "10.0.0.1" ];
  };

  systemd.network.netdevs."br-microvm" = {
    netdevConfig = {
      Name = "br-microvm";
      Kind = "bridge";
    };
  };

  systemd.network.networks."10-br-microvm" = {
    matchConfig.Name = "br-microvm";
    networkConfig = {
      Address = [ "10.0.0.1/24" ];
      IPMasquerade = "ipv4";
      ConfigureWithoutCarrier = true;
    };
  };

  # Attach VM TAPs to the bridge automatically
  systemd.network.networks."10-microvm-tap" = {
    matchConfig.Name = "microvm-*";
    networkConfig.Bridge = "br-microvm";
  };

  # Trust the VM bridge so VMs can reach host DNS / SSH
  networking.firewall.trustedInterfaces = [
    "br-microvm"
  ];

  # NetworkManager shouldn't manage the microvm bridge. Skip if you don't use NetworkManager
  networking.networkmanager.unmanaged = [ "br-microvm" ];

  boot.kernel.sysctl."net.ipv4.ip_forward" = 1;
  boot.kernelModules = [ "vhost_vsock" ];
}
```

## Verify
After a `nixos-rebuild switch` you should have the following:
```bash
ls /dev/kvm                        # exists
ip addr show br-microvm            # has 10.0.0.1/24
ss -lntp | grep ':53'              # listening on 10.0.0.1:53
lsmod | grep vhost_vsock           # module loaded
```
