{
  nixpkgs,
  ...
}:
{
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

  programs.direnv = {
    enable = true;
    enableBashIntegration = true;
    nix-direnv.enable = true;
  };

  system.stateVersion = "26.05";
}
