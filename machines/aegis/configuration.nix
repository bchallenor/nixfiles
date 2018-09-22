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
    ../../modules/wireguard-unstable.nix
  ];

  networking.hostName = "aegis";

  # TODO: move to wireguard module
  networking.firewall.allowedUDPPorts = [ config.networking.wireguard.interfaces.wg0.listenPort ];

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

  networking.wireguard.interfaces = {
    wg0 = {
      ips = [ "fd00::1/64" ];
      listenPort = 51820;
      privateKeyFile = "/secrets/wg/privatekey";
      postSetup = ''
        ${pkgs.procps}/bin/sysctl net.ipv6.conf.all.forwarding=1
      '';
      postShutdown = ''
        ${pkgs.procps}/bin/sysctl net.ipv6.conf.all.forwarding=0
      '';
      peers = [{
        # xps
        allowedIPs = [ "fd00::2/128" ];
        publicKey = "FqhS4e0UeFFoctTXzww8G7g9qWOTvobttarIhc84jiE=";
      }];
    };
  };
}
