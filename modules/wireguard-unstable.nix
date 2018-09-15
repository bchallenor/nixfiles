{ config, lib, pkgs, ... }:

{
  disabledModules = [
    "services/networking/wireguard.nix"
  ];

  nixpkgs.overlays = [
    (final: previous: {
      wireguard-tools = previous.callPackage <nixpkgs-unstable/pkgs/tools/networking/wireguard-tools> { };
      linuxPackages = previous.linuxPackages.extend(finalLinuxPackages: previousLinuxPackages: {
        wireguard = previousLinuxPackages.callPackage <nixpkgs-unstable/pkgs/os-specific/linux/wireguard> { };
      });
    })
  ];

  boot.extraModulePackages = [ pkgs.linuxPackages.wireguard ];
  environment.systemPackages = [ pkgs.wireguard-tools ];
}
