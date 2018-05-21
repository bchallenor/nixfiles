{ config, pkgs, ... }:

{
  imports = [
    <nixpkgs/nixos/modules/profiles/headless.nix>
    ../../modules/common.nix
    ../../modules/ec2.nix
  ];

  networking.hostName = "eos";

  fileSystems."/" =
    { device = "/dev/xvda1";
      fsType = "ext4";
    };

  nix.maxJobs = 4;

  environment.systemPackages = with pkgs; [
  ];

  users.mutableUsers = false;
  users.users.nix = {
    uid = 1000;
    group = "nix";
    createHome = true;
    home = "/home/nix";
    useDefaultShell = true;
    extraGroups = [ "wheel" ];
    hashedPassword = "*";
    openssh.authorizedKeys.keyFiles = [
      ../../keys/cloud-dev.pub
    ];
  };
  users.groups.nix = {
    gid = 1000;
  };

  security.sudo.wheelNeedsPassword = false;


  nix.trustedUsers = [ "root" "nix" ];

  system.nixos.stateVersion = "18.09";
}
