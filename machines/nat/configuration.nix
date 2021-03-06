{ config, pkgs, ... }:

{
  imports = [
    <nixpkgs/nixos/modules/profiles/headless.nix>
    ../../modules/common.nix
    ../../modules/ec2.nix
    ../../modules/persistent-secrets.nix
  ];

  networking.hostName = "nat";

  nix.maxJobs = 2;

  environment.systemPackages = with pkgs; [
  ];

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

  systemd.network = {
    enable = true;

    networks = {
      public = {
        enable = true;
        extraConfig = ''
          [Match]
          Name=ens5

          [Network]
          DHCP=ipv4
          IPForward=ipv4
        '';
      };

      private = {
        enable = true;
        extraConfig = ''
          [Match]
          Name=ens6

          [Network]
          DHCP=ipv4
          IPForward=ipv4
          IPMasquerade=yes
        '';
      };
    };
  };

  networking.dhcpcd.enable = false;
}
