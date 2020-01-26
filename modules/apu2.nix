{ config, lib, pkgs, ... }:

{
  boot.initrd.availableKernelModules = [
    "ahci"
    "ehci_pci"
    "sd_mod"
    "sdhci_pci"
    "usb_storage"
    "xhci_pci"
  ];
  boot.initrd.kernelModules = [
    "dm-snapshot"
  ];
  boot.kernelModules = [
    "kvm-amd"
  ];

  boot.loader = {
    grub = {
      enable = true;
      version = 2;
      device = "/dev/sda";
    };
    timeout = 10;
  };

  boot.kernelParams = [
    "console=ttyS0,115200"
  ];

  fileSystems."/" =
    { device = "/dev/disk/by-label/nixos";
      fsType = "ext4";
    };
  fileSystems."/boot" =
    { device = "/dev/disk/by-label/boot";
      fsType = "ext4";
    };

  services.fstrim.enable = true;

  time.timeZone = "UTC";

  nix.maxJobs = lib.mkDefault 4;
}
