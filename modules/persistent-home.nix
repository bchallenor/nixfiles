{ config, lib, pkgs, ... }:

{
  fileSystems."/home" =
    { device = "/dev/disk/by-label/${config.networking.hostName}-home";
      fsType = "ext4";
    };
}
