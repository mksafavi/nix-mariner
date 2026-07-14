{
  config,
  pkgs,
  lib,
  ...
}:

let
  vmUser = config.mariner.username;
in
{
  options.mariner.username = lib.mkOption {
    type = lib.types.str;
    default = "vm";
    description = "VM user account";
  };

  config.services.getty.autologinUser = vmUser;

  config.users.users.${vmUser} = {
    isNormalUser = true;
    description = vmUser;
    uid = 1000;
    linger = true;
    extraGroups = [
      "wheel"
      "docker"
      "video"
    ];
    shell = pkgs.bash;
    packages = with pkgs; [
      git
      lf
      vim
    ];
  };
}
