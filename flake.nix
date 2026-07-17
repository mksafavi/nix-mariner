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
      pkgs = import nixpkgs { inherit system; };
    in
    {
      nixosModules = {
        default = {
          imports = [
            ./modules
            microvm.nixosModules.microvm
          ];
        };
        host = {
          imports = [
            ./modules/host.nix
            microvm.nixosModules.host
          ];
        };
      };

      nixosConfigurations.vm = nixpkgs.lib.nixosSystem {
        inherit system;
        modules = [
          self.nixosModules.default
          {
            mariner.cid = 3;
            mariner.ssh.authorizedKey = "ssh-ed25519 AAAA... user@host";
          }
        ];
      };

      nixosConfigurations.ubuntu = nixpkgs.lib.nixosSystem {
        inherit system;
        modules = [
          self.nixosModules.default
          {
            mariner.cid = 4;
            mariner.ssh.authorizedKey = "ssh-ed25519 AAAA... user@host";
            mariner.distrobox.enable = true;
          }
        ];
      };

      nixosConfigurations.android = nixpkgs.lib.nixosSystem {
        inherit system;
        modules = [
          self.nixosModules.default
          {
            mariner.cid = 5;
            mariner.waydroid.enable = true;
            mariner.waydroid.systemImage = "GAPPS";
            mariner.ssh.authorizedKey = "ssh-ed25519 AAAA... user@host";
          }
        ];
      };

      packages.${system}.docs = pkgs.callPackage ./pkgs/docs.nix {
        sourceInfo = {
          repo = "https://github.com/mksafavi/nix-mariner";
          rev = self.rev or null;
          ref = self.ref or "main";
        };
      };

      devShells.${system}.default =
        with import nixpkgs { inherit system; };
        mkShell {
          buildInputs = [
            nixfmt
            nixfmt-tree
            nix-fast-build
            mdbook
            deadnix
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
          docsAttrs = {
            "docs" = self.packages.${system}.docs;
          };
        in
        (systemsAttrs // devShellsAttrs // docsAttrs);
    };
}
