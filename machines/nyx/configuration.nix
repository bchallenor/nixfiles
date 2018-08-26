{ config, pkgs, ... }:

{
  imports = [
    <nixpkgs/nixos/modules/profiles/headless.nix>
    ../../modules/common.nix
    ../../modules/ec2.nix
  ];

  networking.hostName = "nyx";

  fileSystems."/" =
    { device = "/dev/xvda1";
      fsType = "ext4";
    };

  nix.maxJobs = 1;

  environment.systemPackages = with pkgs; [
    jq # used by i3 config
    rxvt_unicode
    tigervnc
  ];

  fonts.fonts = with pkgs; [
    font-awesome_4
  ];

  services.xserver = {
    enable = true;
    autorun = false;
    windowManager.i3.enable = true;
  };

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
      ../../keys/tablet-jump.pub
    ];
  };
  users.groups.ben = {
    gid = 1000;
  };

  security.sudo.wheelNeedsPassword = false;

  system.stateVersion = "18.09";
}
