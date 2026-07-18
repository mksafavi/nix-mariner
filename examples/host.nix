{ ... }:
{
  # ANCHOR: host-module
  mariner.host = {
    enable = true;
    graphics.enable = true;
    network.enable = true;
    network.exposeDNS = true;
  };
  # ANCHOR_END: host-module

  # Stubbing a host system...
  networking.useDHCP = false;
  fileSystems."/".device = "/dev/disk/by-label/nixos";
  fileSystems."/".fsType = "ext4";
  boot.loader.grub.enable = false;
  system.stateVersion = "25.05";
}
