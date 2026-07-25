{
  config,
  lib,
  ...
}:
let
  cfg = config.mariner.graphics;
in
{
  options.mariner.graphics = {
    enable = lib.mkEnableOption "Graphical desktop apps support";
  };

  config = lib.mkIf cfg.enable {
    warnings = lib.optional (config.microvm.hypervisor != "qemu") ''
      nix-mariner graphics is only verified with "qemu" hypervisor and might not work with "${config.microvm.hypervisor}"
    '';

    hardware.graphics.enable = true;

    microvm.graphics = {
      enable = true;
      backend = lib.mkDefault "headless";
    };

    security.polkit = lib.mkDefault {
      enable = true;
      enablePkexecWrapper = true;
      extraConfig = ''
        polkit.addRule(function(action, subject) {
          if (subject.isInGroup("wheel"))
            return polkit.Result.YES;
        });
      '';
    };
  };
}
