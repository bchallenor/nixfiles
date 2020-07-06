{ config, lib, pkgs, ... }:

{
  systemd.services.wireguard-wg0 = {
    after = [ "secrets.mount" ];
    requires = [ "secrets.mount" ];
  };

  assertions = [
    {
      assertion = lib.versionAtLeast config.boot.kernelPackages.kernel.version "5.6";
      message = "wireguard requires kernel >= 5.6";
    }
    {
      assertion = config.fileSystems ? "/secrets";
      message = "wireguard requires /secrets mount";
    }
  ];
}
