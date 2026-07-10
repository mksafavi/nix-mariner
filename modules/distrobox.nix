{ config, pkgs, ... }:
{
  users.users.${config.mariner.username}.packages = with pkgs; [ distrobox ];
}
