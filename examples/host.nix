{ ... }:
{
  # ANCHOR: host-module
  mariner.host = {
    enable = true;
    # Optional features:
    graphics.enable = true; # runs waypipe client to open windows on host compositor
    network.enable = true; # creates br-microvm bridge
    network.exposeDNS = true; # allows VMs to reach host DNS
  };
  # ANCHOR_END: host-module

  # Stubbing a host system...
  networking.useDHCP = false;
  fileSystems."/".device = "/dev/disk/by-label/nixos";
  fileSystems."/".fsType = "ext4";
  boot.loader.grub.enable = false;
  system.stateVersion = "25.05";
}
