{
  config,
  pkgs,
  lib,
  ...
}:
{
  security.sudo.wheelNeedsPassword = false;

  virtualisation.docker.enable = true;
}
