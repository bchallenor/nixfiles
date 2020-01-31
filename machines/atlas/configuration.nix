{ config, pkgs, ... }:

let
  unstable = import <nixpkgs-unstable> {};
in

{
  imports = [
    ../../modules/common.nix
    ../../modules/apu2.nix
    ../../modules/persistent-secrets.nix
    ../../modules/persistent-home.nix
  ];

  networking.hostName = "atlas";

  environment.systemPackages = (with pkgs; [
    jq
    ranger
  ]);

  users.mutableUsers = true;
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

  security.sudo.wheelNeedsPassword = true;

  services.udev.extraRules = ''
    ACTION=="add", SUBSYSTEM=="net", KERNELS=="0000:01:00.0", NAME:="lan1"
    ACTION=="add", SUBSYSTEM=="net", KERNELS=="0000:02:00.0", NAME:="lan2"
    ACTION=="add", SUBSYSTEM=="net", KERNELS=="0000:03:00.0", NAME:="wan"
  '';

  systemd.network = {
    enable = true;

    netdevs = {
      lan = {
        netdevConfig = {
          Name = "lan";
          Kind = "bridge";
        };
      };
    };

    networks = {
      wan = {
        # TODO Use DNSOverTLS once systemd #13528 is fixed
        extraConfig = ''
          [Match]
          Name=wan

          [Network]
          DHCP=ipv4
          DNS=1.1.1.1
          IPForward=ipv4

          [DHCPv4]
          UseRoutes=yes
          UseDNS=no
          UseHostname=no
          UseNTP=no
        '';
      };

      lan = {
        extraConfig = ''
          [Match]
          Name=lan

          [Link]
          RequiredForOnline=no

          [Network]
          Address=192.168.1.1/24
          DHCPServer=yes
          IPForward=ipv4
          IPMasquerade=yes

          [DHCPServer]
          PoolOffset=100
        '';
      };

      lanN = {
        extraConfig = ''
          [Match]
          Name=lan1 lan2

          [Link]
          RequiredForOnline=no

          [Network]
          Bridge=lan
        '';
      };
    };
  };

  services.resolved = {
    enable = true;
    dnssec = "false";
    extraConfig = ''
      FallbackDNS=
    '';
  };

  networking.dhcpcd.enable = false;

  # DHCP server
  networking.firewall.allowedUDPPorts = [ 67 ];
}
