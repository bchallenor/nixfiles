{ config, pkgs, ... }:

let
  unstable = import <nixpkgs-unstable> {};
in

{
  imports = [
    <nixpkgs/nixos/modules/profiles/headless.nix>
    ../../modules/common.nix
    ../../modules/ec2.nix
    ../../modules/persistent-secrets.nix
    ../../modules/persistent-home.nix
  ];

  networking.hostName = "chaos";

  nix.maxJobs = 2;

  environment.systemPackages = (with pkgs; [
    awscli
    jq
    ranger
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
      ../../keys/tablet-blink.pub
    ];
  };
  users.groups.ben = {
    gid = 1000;
  };

  security.sudo.wheelNeedsPassword = false;
}
