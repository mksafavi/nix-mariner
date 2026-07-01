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
          (
            {
              config,
              pkgs,
              lib,
              ...
            }:
            {
              # nix-mariner Options:
              mariner = {
                cid = 11;
                # Your host public ssh key:
                hostAuthorizedKey = "ssh-ed25519 AAAA... user@host";
                username = "example";
              };

              # Change any of the microvm options:
              microvm = {
                vcpu = 4;
                mem = 4096;
              };

              # Configure nixos options, for example install more packages:
              users.users.${config.mariner.username}.packages = with pkgs; [ htop ];
            }
          )
        ];
      };
    };
}
