{
  config,
  pkgs,
  lib,
  ...
}:
{
  users.users.vm = {
    isNormalUser = true;
    description = "vm";
    extraGroups = [
      "wheel"
    ];
    packages = with pkgs; [
    ];
  };

  system.stateVersion = "26.05";
}
