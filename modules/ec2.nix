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

  boot.loader = {
    grub = {
      enable = true;
      version = 2;
      device = "/dev/xvda";
    };
    timeout = 0;
  };

  boot.kernelParams = [
    # ttyS0 is used by AWS System Log
    "console=ttyS0"
  ];

  # Grow root partition and filesystem on boot so that we can store smaller EBS snapshots
  boot.growPartition = true;
  fileSystems."/".autoResize = true;

  # Use the time server provided by Amazon Time Sync Service
  # https://aws.amazon.com/blogs/aws/keeping-time-with-amazon-time-sync-service/
  networking.timeServers = [ "169.254.169.123" ];

  time.timeZone = "UTC";
}
