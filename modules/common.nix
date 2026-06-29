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
    shell = pkgs.bash;
    packages = with pkgs; [
      git
      gh
      lf
      vim
    ];
    openssh.authorizedKeys.keys = [
      (lib.fileContents ../keys/host.pub)
    ];
  };

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

  nix.settings.experimental-features = [
    "nix-command"
    "flakes"
  ];

  virtualisation.docker.enable = true;

  system.stateVersion = "26.05";
}
