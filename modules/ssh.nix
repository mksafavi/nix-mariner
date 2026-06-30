{
  config,
  hostAuthorizedKey,
  ...
}:
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

  users.users.vm.openssh.authorizedKeys.keys = [ hostAuthorizedKey ];

  users.users.root.openssh.authorizedKeys.keys = [ hostAuthorizedKey ];
}
