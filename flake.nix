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
    let
      system = "x86_64-linux";
      specialArgs = {
        inherit nixpkgs;
      };
    in
    {
      nixosModules = {
        common = modules/common.nix;
        vm = modules/vm.nix;
        storage = modules/storage.nix;
        network = modules/network.nix;
        user = modules/user.nix;
        ssh = modules/ssh.nix;
        nix = modules/nix.nix;
        microvm = microvm.nixosModules.microvm;
      };

      nixosConfigurations.vm = nixpkgs.lib.nixosSystem {
        inherit system;
        inherit specialArgs;
        modules = [
          {
            mariner.cid = 3;
            mariner.hostAuthorizedKey = nixpkgs.lib.fileContents ./keys/host.pub;
          }
        ]
        ++ builtins.attrValues self.nixosModules;
      };

      devShells.${system}.default =
        with import nixpkgs { inherit system; };
        mkShell {
          buildInputs = [
            nixfmt
            nixfmt-tree
            nix-fast-build
          ];
        };

      checks.${system} =
        let
          systemsAttrs = nixpkgs.lib.mapAttrs' (
            n: c: nixpkgs.lib.nameValuePair "microvm-${n}" c.config.microvm.runner.qemu
          ) self.nixosConfigurations;
          devShellsAttrs = nixpkgs.lib.mapAttrs' (
            n: nixpkgs.lib.nameValuePair "devShell-${n}"
          ) self.devShells.${system};
        in
        (systemsAttrs // devShellsAttrs);
    };
}
