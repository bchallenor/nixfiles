{ config, lib, pkgs, ... }:

{
  boot.initrd.availableKernelModules = [
    "ata_piix"
    "ena"
    "nvme"
    "xen_blkfront"
  ];

  boot.extraModulePackages = [
    config.boot.kernelPackages.ena
  ];
}
