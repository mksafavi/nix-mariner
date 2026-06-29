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
      "docker"
    ];
    packages = with pkgs; [
    ];
  };

  security.sudo.wheelNeedsPassword = false;

  services.openssh.enable = true;

  programs.direnv = {
    enable = true;
    enableBashIntegration = true;
    nix-direnv.enable = true;
  };

  nix.settings.experimental-features = [
    "nix-command"
    "flakes"
  ];

  virtualisation.docker.enable = true;

  system.stateVersion = "26.05";
}
