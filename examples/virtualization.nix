{
  mariner,
  ...
}:
{
  microvm.vms = {
    vm-work = {
      config = {
        imports = [ mariner.nixosModules.default ];
        mariner.cid = 4;
        mariner.username = "work";
        mariner.ssh.authorizedKeys = [ "ssh-ed25519 AAAA... your@host" ];
      };
    };

    vm-test = {
      config = {
        imports = [ mariner.nixosModules.default ];
        mariner.cid = 5;
        mariner.username = "user";
        mariner.ssh.authorizedKeys = [ "ssh-ed25519 AAAA... your@host" ];
      };
    };
  };
}
