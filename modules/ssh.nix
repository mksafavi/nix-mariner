{
  config,
  lib,
  ...
}:
let
  vmUser = config.mariner.username;
  hostAuthorizedKey = config.mariner.hostAuthorizedKey;
in
{
  options.mariner.hostAuthorizedKey = lib.mkOption {
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

    users.users.${vmUser}.openssh.authorizedKeys.keys = [ hostAuthorizedKey ];

    users.users.root.openssh.authorizedKeys.keys = [ hostAuthorizedKey ];
  };
}
