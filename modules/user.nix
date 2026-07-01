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
  config.users.users.${vmUser} = {
    isNormalUser = true;
    description = vmUser;
    extraGroups = [
      "wheel"
      "docker"
    ];
    shell = pkgs.bash;
    packages = with pkgs; [
      git
      lf
      vim
    ];
  };
}
