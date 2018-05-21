{ config, pkgs, ... }:

{
  imports = [
    <nixpkgs/nixos/modules/profiles/headless.nix>
    ../../modules/common.nix
    ../../modules/ec2.nix
  ];

  networking.hostName = "helios";

  fileSystems."/" =
    { device = "/dev/xvda1";
      fsType = "ext4";
    };
  fileSystems."/home" =
    { device = "/dev/disk/by-label/nixos-home";
      fsType = "ext4";
    };
  fileSystems."/var/lib/docker" =
    { device = "/dev/disk/by-label/nixos-docker";
      fsType = "ext4";
    };

  nix.maxJobs = 4;

  environment.systemPackages = with pkgs; [
    awscli
    docker
    docker_compose
    jq
    ranger
    rustup
    terraform
    unzip
    w3m
  ];

  users.mutableUsers = false;
  users.users.ben = {
    uid = 1000;
    group = "ben";
    createHome = true;
    home = "/home/ben";
    useDefaultShell = true;
    extraGroups = [ "wheel" ];
    hashedPassword = "*";
    openssh.authorizedKeys.keyFiles = [
      ../../keys/cloud-dev.pub
      ../../keys/tablet-blink.pub
      ../../keys/phone-termux.pub
    ];
  };
  users.groups.ben = {
    gid = 1000;
  };

  security.sudo.wheelNeedsPassword = false;

  virtualisation.docker = {
    enable = true;
    storageDriver = "overlay2";
  };

  system.nixos.stateVersion = "18.09";
}
