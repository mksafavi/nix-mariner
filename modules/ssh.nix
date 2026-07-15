{
  config,
  lib,
  ...
}:
let
  vmUser = config.mariner.username;
  cfg = config.mariner.ssh;
in
{
  options.mariner.ssh.authorizedKey = lib.mkOption {
    type = lib.types.str;
    description = "SSH authorized public key for vm user and root";
  };

  config = {
    services.openssh = {
      enable = true;
      settings.PasswordAuthentication = false;
      hostKeys = [
        {
          path = "/persist/ssh/ssh_host_ed25519_key";
          type = "ed25519";
        }
      ];
    };

    users.users.${vmUser}.openssh.authorizedKeys.keys = [ cfg.authorizedKey ];

    users.users.root.openssh.authorizedKeys.keys = [ cfg.authorizedKey ];
  };
}
