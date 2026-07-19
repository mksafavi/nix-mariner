{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

    mariner.url = "github:mksafavi/nix-mariner";
    mariner.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs =
    {
      nixpkgs,
      mariner,
    }:
    {
      nixosConfigurations.machine = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [
          mariner.nixosModules.host # Also imports the microvm host module
        ];
      };
    };
}
