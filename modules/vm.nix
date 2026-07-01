{
  lib,
  ...
}:
{
  networking.hostName = lib.mkDefault "vm";

  microvm.hypervisor = lib.mkDefault "qemu";

  microvm.vcpu = lib.mkDefault 4;
  microvm.mem = lib.mkDefault 4096;

  microvm.vsock.cid = lib.mkDefault 3;
}
