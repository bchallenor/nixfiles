{ config, pkgs, ... }:

{
  imports = [
    <nixpkgs/nixos/modules/installer/cd-dvd/installation-cd-minimal.nix>
    ../modules/base-packages.nix
  ];

  boot.kernelPackages = pkgs.linuxPackages_latest;

  networking.wireless.enable = false;
  networking.wireless.iwd.enable = true;

  environment.systemPackages = with pkgs; [
    nvme-cli
  ];
}
