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
