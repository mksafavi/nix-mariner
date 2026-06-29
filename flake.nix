{
  inputs.nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
  inputs.microvm.url = "github:microvm-nix/microvm.nix";
  inputs.microvm.inputs.nixpkgs.follows = "nixpkgs";

  outputs =
    {
      self,
      nixpkgs,
      microvm,
    }:
    {
      nixosConfigurations.vm = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [
          microvm.nixosModules.microvm
          modules/common.nix
          modules/vm.nix
          {
            networking.hostName = "vm";
            microvm.hypervisor = "qemu";
          }
        ];
      };
    };
}
