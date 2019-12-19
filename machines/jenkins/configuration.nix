{ config, lib, pkgs, ... }:

let
  unstable = import <nixpkgs-unstable> {};
in

{
  imports = [
    <nixpkgs/nixos/modules/profiles/headless.nix>
    ../../modules/common.nix
    ../../modules/ec2.nix
    ../../modules/persistent-secrets.nix
  ];

  networking.hostName = "jenkins";

  networking.firewall.allowedTCPPorts = [ config.services.jenkins.port ];

  fileSystems."${config.services.jenkins.home}" =
    { device = "/dev/disk/by-label/jenkins";
      fsType = "ext4";
    };

  boot.tmpOnTmpfs = lib.mkForce false;
  boot.cleanTmpDir = true;

  nix.maxJobs = 2;

  environment.systemPackages = with pkgs; [
  ];

  services.jenkins = {
    enable = true;
    port = 5365;
    package = unstable.jenkins;
    packages = with pkgs; [
      awscli
      coreutils
      curl
      git
      gnutar
      jq
      nix
      (python3.withPackages(ps: [ ps.boto3 ]))
      sbt
      skopeo
      xz
    ];
  };

  users.mutableUsers = false;
  users.users.admin = {
    uid = 1000;
    group = "admin";
    createHome = true;
    home = "/home/admin";
    useDefaultShell = true;
    extraGroups = [
      "wheel"
    ];
    hashedPassword = "*";
    openssh.authorizedKeys.keyFiles = [
      ../../keys/laptop.pub
      ../../keys/tablet-blink.pub
    ];
  };
  users.groups.admin = {
    gid = 1000;
  };

  security.sudo.wheelNeedsPassword = false;
}
