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

  services.openssh.enable = true;

  programs.direnv = {
    enable = true;
    enableBashIntegration = true;
    nix-direnv.enable = true;
  };

  system.stateVersion = "26.05";
}
