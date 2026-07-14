# nix-mariner

[![License: Apache 2.0](https://img.shields.io/badge/License-Apache%202.0-blue.svg)](https://opensource.org/licenses/Apache-2.0)
[![Documentation](https://img.shields.io/badge/Documentation-mdbook-brightgreen)](https://mksafavi.github.io/nix-mariner/)

NixOS microVM modules for creating development environments that isolate untrusted code from the host.

Built on [microvm.nix](https://github.com/microvm-nix/microvm.nix).

## What it does

- Provides NixOS modules importable as a flake input.
- Creates persistent microVM environments for isolating untrusted code away from the host.
- Preconfigured: SSH, Docker, direnv, shared `/nix/store`, persistent storage, bridge networking, etc.

## Quick start

First, complete the one-time [host setup](docs/src/host-setup.md).

This configures the network bridge, DNS, and firewall settings that microvm.nix expects.

Then choose a workflow for creating virtual machines:
- [Imperative Virtual Machines](docs/src/imperative-vms.md)
- [Declarative Virtual Machines](docs/src/declarative-vms.md)

See [`examples/flake.nix`](examples/flake.nix) for a standalone imperative flake example.

## Documentation

Full documentation is available at https://mksafavi.github.io/nix-mariner/

## License
This project is licensed under the Apache License 2.0. See the [`LICENSE`](LICENSE) file for details.

## <!-- breaker -->

<sub> [Mariner 1](https://science.nasa.gov/mission/mariner-1/), NASA's Venus flyby probe, destroyed at T+294.5s by a missing over-bar (R instead of R̅).</sub>
