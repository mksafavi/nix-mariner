{
  config,
  pkgs,
  nixpkgs,
  lib,
  ...
}:
{

  security.sudo.wheelNeedsPassword = false;

  programs.direnv = {
    enable = true;
    enableBashIntegration = true;
    nix-direnv.enable = true;
  };

  nix = {
    enable = true;
    registry.nixpkgs.flake = nixpkgs;
    nixPath = [
      "nixpkgs=flake:${nixpkgs}"
    ];
    settings = {
      experimental-features = [
        "nix-command"
        "flakes"
      ];
    };
  };

  nixpkgs.config.allowUnfree = true;

  virtualisation.docker.enable = true;

  system.stateVersion = "26.05";
}
