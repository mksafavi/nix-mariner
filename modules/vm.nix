{ config, ... }:
{
  networking.hostName = "vm";

  microvm.hypervisor = "qemu";

  microvm = {
    vcpu = 4;
    mem = 4096;
  };

  microvm.vsock.cid = 3;
}
