{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.mariner.host;
in
{
  options.mariner.host = {
    enable = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = ''
        Whether to enable nix-mariner host module.
      '';
    };

    graphics = {
      enable = lib.mkEnableOption "host graphics";
    };

    network = {
      enable = lib.mkEnableOption "nix-mariner host network options";

      address = lib.mkOption {
        type = lib.types.str;
        default = "10.0.0.1";
        description = "Static IPv4 address assigned to the host bridge";
      };
    };
  };

  config = lib.mkIf cfg.enable (
    lib.mkMerge [
      {
        microvm.host.enable = true;
        boot.kernelModules = [ "vhost_vsock" ];
      }
      (lib.mkIf cfg.graphics.enable {
        systemd.user.services.mariner-waypipe-client = {
          description = "Start waypipe client";
          wantedBy = [ "graphical-session.target" ];
          after = [ "graphical-session.target" ];
          partOf = [ "graphical-session.target" ];
          serviceConfig = {
            Restart = "always";
            RestartSec = "10s";
          };
          script = ''
            ${pkgs.waypipe}/bin/waypipe --vsock -s 2:6000 client
          '';
        };
      })
      (lib.mkIf cfg.network.enable {

        boot.kernel.sysctl."net.ipv4.ip_forward" = 1;

        systemd.network.enable = lib.mkDefault true;

        services.resolved.settings.Resolve = lib.mkDefault {
          DNSStubListenerExtra = [ cfg.network.address ];
        };

        networking.networkmanager.unmanaged = lib.mkDefault [ "br-microvm" ];

        networking.firewall.interfaces."br-microvm".allowedUDPPorts = lib.mkDefault [ 53 ];

        systemd.network.netdevs."br-microvm" = lib.mkDefault {
          netdevConfig = {
            Name = "br-microvm";
            Kind = "bridge";
          };
        };

        systemd.network.networks."10-br-microvm" = lib.mkDefault {
          matchConfig.Name = "br-microvm";
          networkConfig = {
            Address = [ "${cfg.network.address}/24" ];
            IPMasquerade = "ipv4";
            ConfigureWithoutCarrier = true;
          };
        };

        systemd.network.networks."10-microvm-tap" = lib.mkDefault {
          matchConfig.Name = "microvm-*";
          networkConfig.Bridge = "br-microvm";
        };
      })
    ]
  );
}
