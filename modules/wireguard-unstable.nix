{ config, lib, pkgs, ... }:

{
  disabledModules = [
    "services/networking/wireguard.nix"
  ];

  imports = [
    <nixpkgs-unstable/nixos/modules/services/networking/wireguard.nix>
  ];

  nixpkgs.overlays = [
    (final: previous: {
      wireguard-tools = previous.callPackage <nixpkgs-unstable/pkgs/tools/networking/wireguard-tools> { };
      linuxPackages = previous.linuxPackages.extend(finalLinuxPackages: previousLinuxPackages: {
        wireguard = previousLinuxPackages.callPackage <nixpkgs-unstable/pkgs/os-specific/linux/wireguard> { };
      });
    })
  ];

  systemd.services.wireguard-wg0 = {
    after = [ "secrets.mount" ];
    requires = [ "secrets.mount" ];
  };

  assertions = [
    {
      assertion = config.fileSystems ? "/secrets";
      message = "wireguard requires /secrets mount";
    }
  ];
}
