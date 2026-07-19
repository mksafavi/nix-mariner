{
  mariner,
  nixpkgs,
  ...
}:
{
  microvm.vms = {
    vm-work = {
      specialArgs = { inherit nixpkgs; };
      config = {
        imports = [ mariner.nixosModules.default ];
        mariner.cid = 4;
        mariner.username = "work";
        mariner.ssh.authorizedKey = "ssh-ed25519 AAAA... your@host";
      };
    };

    vm-test = {
      specialArgs = { inherit nixpkgs; };
      config = {
        imports = [ mariner.nixosModules.default ];
        mariner.cid = 5;
        mariner.username = "user";
        mariner.ssh.authorizedKey = "ssh-ed25519 AAAA... your@host";
      };
    };
  };
}
