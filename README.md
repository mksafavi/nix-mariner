# nix-mariner

[![License: Apache 2.0](https://img.shields.io/badge/License-Apache%202.0-blue.svg)](https://opensource.org/licenses/Apache-2.0)
[![Documentation](https://img.shields.io/badge/Documentation-mdbook-brightgreen)](https://mksafavi.github.io/nix-mariner/)

NixOS microVM modules for creating development environments that isolate untrusted code from the host.

Built on [microvm.nix](https://github.com/microvm-nix/microvm.nix).

## What it does

- Provides NixOS modules importable as a flake input.
- Creates persistent microVM environments for isolating untrusted code away from the host.
- Preconfigured with SSH, Docker, direnv, shared `/nix/store`, persistent storage, bridge networking.
- Optional userlands inside the VM:
  - Ubuntu via [distrobox](docs/src/distrobox.md), SSH logins directly into Ubuntu.
  - Android via [Waydroid](docs/src/waydroid.md), opens a window on your host desktop.

## Quick start

First, complete the one-time [host setup](docs/src/host-setup.md) to import `inputs.mariner.nixosModules.host` and configure the network bridge, DNS, and firewall settings that microvm.nix expects.

Then choose a workflow for creating virtual machines. Create VMs [Imperatively](docs/src/imperative-vms.md) or [Declaratively](docs/src/declarative-vms.md). To use nix-mariner as a flake input:

```nix
{
  imports = [ inputs.mariner.nixosModules.default ];
  mariner = {
    cid = 3;
    ssh.authorizedKey = "ssh-ed25519 AAAA... user@host";
  };
}
```

## Questions & Support

- Feel free to start a discussion on [Discussions](https://github.com/mksafavi/nix-mariner/discussions)
- Report bugs and feature requests at [Issues](https://github.com/mksafavi/nix-mariner/issues)

## Documentation

Full documentation is available at https://mksafavi.github.io/nix-mariner/

## License
This project is licensed under the Apache License 2.0. See the [`LICENSE`](LICENSE) file for details.

## <!-- breaker -->

<sub> [Mariner 1](https://science.nasa.gov/mission/mariner-1/), NASA's Venus flyby probe, destroyed at T+294.5s by a missing over-bar (R instead of R̅).</sub>
