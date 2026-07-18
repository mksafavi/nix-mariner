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
        modules = [
          {
            imports = [ mariner.nixosModules.default ];
            mariner.cid = 4; # Unique per-VM CID that sets vsock number and IP address.
            mariner.ssh.authorizedKey = "ssh-ed25519 AAAA... your@host"; # Replace with your ssh public key
          }
        ];
      };
    };
}
