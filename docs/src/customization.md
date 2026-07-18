# Per-VM Customizations

You can change and override microvm.nix and nixos module configurations for each VM.
Overrides work the same in both imperative and declarative modes.

For more information, see [Mariner options](./mariner-options.md) and [microvm.nix Options](https://microvm-nix.github.io/microvm.nix/microvm-options.html).

```nix
{{#include ../../examples/customization.nix}}
```
