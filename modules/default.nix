{ ... }: {
  imports = [
    ./common.nix
    ./vm.nix
    ./storage.nix
    ./network.nix
    ./user.nix
    ./ssh.nix
    ./nix.nix
    ./distrobox.nix
    ./waydroid.nix
    ./graphics.nix
    ./docker.nix
  ];
}
