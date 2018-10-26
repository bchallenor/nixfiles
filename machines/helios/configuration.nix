{ config, pkgs, ... }:

let
  unstable = import <nixpkgs-unstable> {};
in

{
  imports = [
    <nixpkgs/nixos/modules/profiles/headless.nix>
    ../../modules/common.nix
    ../../modules/ec2.nix
  ];

  networking.hostName = "helios";

  fileSystems."/home" =
    { device = "/dev/disk/by-label/nixos-home";
      fsType = "ext4";
    };

  nix.maxJobs = 2;

  environment.systemPackages = (with pkgs; [
    awscli
    docker
    docker_compose
    gitAndTools.git-annex
    jq
    ranger
    unzip
    w3m
    watchexec
  ]) ++ (with unstable.pkgs; [
    (terraform.withPlugins(ps: with ps; [
      archive
      aws
      external
      http
    ]))
  ]);

  users.mutableUsers = false;
  users.users.ben = {
    uid = 1000;
    group = "ben";
    createHome = true;
    home = "/home/ben";
    useDefaultShell = true;
    extraGroups = [
      "wheel"
    ];
    hashedPassword = "*";
    openssh.authorizedKeys.keyFiles = [
      ../../keys/laptop.pub
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
}
