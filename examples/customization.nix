{ mariner, ... }:
{
  config =
    { config, pkgs, ... }: # this points to the vm config to access config.mariner
    {
      imports = [ mariner.nixosModules.default ];

      mariner.cid = 3;
      # Change user name:
      mariner.username = "user";
      mariner.ssh.authorizedKey = "ssh-ed25519 AAAA... your@host";
      # Set VM resources:
      microvm = {
        vcpu = 4;
        mem = 8 * 1024;
      };
      # Share a host directory with the VM:
      microvm.shares = [
        {
          source = "/home/you/work";
          mountPoint = "/work";
          tag = "work";
          proto = "virtiofs";
        }
      ];

      # Install more packages:
      users.users.${config.mariner.username}.packages = with pkgs; [ btop ];
    };
}
