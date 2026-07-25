{ pkgs, ... }:
{
  mariner.cid = 6;
  mariner.ssh.authorizedKeys = [ "ssh-ed25519 AAAA... user@host" ];
  mariner.graphics.enable = true;
  environment.systemPackages = with pkgs; [
    firefox
  ];
}
