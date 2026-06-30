{
  pkgs,
  hostAuthorizedKey,
  ...
}:
{
  users.users.vm = {
    isNormalUser = true;
    description = "vm";
    extraGroups = [
      "wheel"
      "docker"
    ];
    shell = pkgs.bash;
    packages = with pkgs; [
      git
      gh
      lf
      vim
    ];
    openssh.authorizedKeys.keys = [
      hostAuthorizedKey
    ];
  };

  users.users.root.openssh.authorizedKeys.keys = [ hostAuthorizedKey ];
}
