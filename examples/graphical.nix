{ pkgs, ... }:
{
  mariner.cid = 6;
  mariner.ssh.authorizedKeys = [ "ssh-ed25519 AAAA... user@host" ];
  mariner.graphics.enable = true;
  microvm.graphics.vulkan = "venus";
  microvm.graphics.hostmem = "8G";
  environment.systemPackages = with pkgs; [
    firefox
  ];
}
