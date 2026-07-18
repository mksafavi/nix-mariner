# Host setup

In order to use nix-mariner, you need to import `mariner.nixosModules.host` module and configure the network options in your nixos system configuration.

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
        mariner.nixosModules.host # Also imports the microvm host module
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
        mariner.nixosModules.host # also imports the microvm host module
      ];
    };
  };
}
```

## Mariner host module additions

Importing `mariner.host` enables the `microvm.host` and defaults to on.
`mariner.host.graphics` option runs a `waypipe` client in the host Wayland session so VM windows render on host's Wayland compositor.
`mariner.host.network` sets up a bridge that each VM tap connects to on their own `10.0.0.0/24` subnet and allows VMs to access DNS from the host.
The network options are a default, that might not match your network configurations. Keep it disabled and configure it yourself if it doesn't fit.

See [`A simple network setup`](https://microvm-nix.github.io/microvm.nix/simple-network.html) for more information.

```nix
{ ... }:
{
  mariner = {
    host.enable = true;
    host.network.enable = true;
    host.graphics.enable = true;
  };
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
