# nix-mariner

[![License: Apache 2.0](https://img.shields.io/badge/License-Apache%202.0-blue.svg)](https://opensource.org/licenses/Apache-2.0)
[![Documentation](https://img.shields.io/badge/Documentation-mdbook-brightgreen)](https://mksafavi.github.io/nix-mariner/)

NixOS microVM modules for creating development environments that isolated untrusted code from your host.

Built on [microvm.nix](https://github.com/microvm-nix/microvm.nix).

## What it does

- Provides NixOS modules importable as a flake input.
- Creates persistent microVM environments to isolate untrusted code away from the host.
- Preconfigured: SSH, Docker, direnv, shared `/nix/store`, persistent storage, bridge networking, etc.

## Quick start

Host prerequisites (one-time): follow [`docs/src/host-setup.md`](docs/src/host-setup.md) to add the bridge, DNS, and firewall settings that microvm.nix expects.

Add nix-mariner as a flake input and create a `nixosConfigurations.<vm>` derivation.

flake.nix for creating a VM called example:
```nix
{
  inputs.mariner.url = "github:mksafavi/nix-mariner";

  outputs =
    { self, mariner }:
    let
      nixpkgs = mariner.inputs.nixpkgs;
    in
    {
      nixosConfigurations.example = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        specialArgs = { inherit nixpkgs; };
        modules = builtins.attrValues mariner.nixosModules ++ [
          {
            mariner.cid = 4; # Unique per-VM CID that sets vsock number and IP address.
            mariner.hostAuthorizedKey = "ssh-ed25519 AAAA... your@host"; # Replace with your ssh public key
          }
        ];
      };
    };
}
```

Calling `microvm -c` builds the VM and creates the systemd service for booting it.

```shell
sudo microvm -c example -f path:$(pwd)
```

Verify that the vm is created:
```shell
microvm -l
```

Either start the service:
```shell
sudo systemctl start microvm@example.service
```
Or start it in foreground:
```shell
sudo microvm -r example
```

You can now ssh into it:
```shell
ssh vm@vsock%4
# or:
ssh vm@10.0.0.4
```

See [`examples/flake.nix`](examples/flake.nix) for a stand-alone flake example.

## Docs

- [`docs/src/host-setup.md`](docs/src/host-setup.md) — host NixOS additions
  (bridge, NAT, DNS, firewall). Set this up once.

## License
This project is licensed under the Apache License 2.0. See the LICENSE file for details.


<sub> [Mariner 1](https://science.nasa.gov/mission/mariner-1/), NASA's Venus flyby probe, destroyed at T+294.5s by a missing over-bar (R instead of R̅).</sub>
