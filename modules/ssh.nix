{
  config,
  hostAuthorizedKey,
  ...
}:
let
  vmUser = config.mariner.username;
in
{
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
}
