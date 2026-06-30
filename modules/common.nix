{
  config,
  pkgs,
  nixpkgs,
  lib,
  ...
}:
{

  security.sudo.wheelNeedsPassword = false;

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
