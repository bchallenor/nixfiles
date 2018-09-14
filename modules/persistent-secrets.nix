{ config, lib, pkgs, ... }:

{
  fileSystems."/secrets" =
    { device = "/dev/disk/by-label/${config.networking.hostName}-secrets";
      fsType = "ext4";
    };

  services.openssh.hostKeys = [
    { path = "/secrets/ssh/ssh_host_ed25519_key"; type = "ed25519"; }
    { path = "/secrets/ssh/ssh_host_rsa_key"; type = "rsa"; bits = 4096; }
  ];
}
