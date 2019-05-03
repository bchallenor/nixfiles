{ config, pkgs, ... }:

let
  unstable = import <nixpkgs-unstable> {};
in

{
  imports = [
    ./hardware-configuration.nix
    ../../modules/common.nix
    ../../modules/wireguard-unstable.nix
    ../../modules/redshift.nix
  ];

  networking.hostName = "xps";

  hardware.cpu.intel.updateMicrocode = true;

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  boot.initrd.luks.devices."lvm" =
    { device = "/dev/disk/by-partlabel/lvm";
      allowDiscards = true;
    };
  boot.initrd.luks.reusePassphrases = false;

  fileSystems."/" =
    { device = "/dev/vg/nixos";
      fsType = "ext4";
    };
  fileSystems."/boot" =
    { device = "/dev/disk/by-partlabel/efi";
      fsType = "vfat";
    };
  fileSystems."/home/ben" =
    { device = "/dev/vg/ben";
      fsType = "btrfs";
      options = [ "subvol=/main" ];
    };
  fileSystems."/mnt/btrfs/ben" =
    { device = "/dev/vg/ben";
      fsType = "btrfs";
      options = [ "subvol=/" ];
    };
  fileSystems."/data" =
    { device = "/dev/vg/data";
      fsType = "btrfs";
      options = [ "subvol=/main" ];
    };
  fileSystems."/mnt/btrfs/data" =
    { device = "/dev/vg/data";
      fsType = "btrfs";
      options = [ "subvol=/" ];
    };
  fileSystems."/secrets" =
    { device = "/dev/vg/secrets";
      fsType = "ext4";
    };
  fileSystems."/mnt/annex" =
    { device = "/dev/vg/annex";
      fsType = "ext4";
    };
  fileSystems."/var/lib/docker" =
    { device = "/dev/vg/docker";
      fsType = "ext4";
    };
  fileSystems."/mnt/epool" =
    { device = "/dev/vg/epool";
      fsType = "ext4";
    };

  services.snapper.configs = {
    "ben" = {
      subvolume = "/mnt/btrfs/ben/main";
      extraConfig = ''
        TIMELINE_CREATE="yes"
        TIMELINE_CLEANUP="yes"
      '';
    };
    "data" = {
      subvolume = "/mnt/btrfs/data/main";
      extraConfig = ''
        TIMELINE_CREATE="yes"
        TIMELINE_CLEANUP="yes"
      '';
    };
  };

  services.fstrim.enable = true;

  networking.networkmanager.enable = true;

  time.timeZone = "Europe/London";

  environment.systemPackages = (with pkgs; [
    awscli
    chromium
    file
    firefox
    freerdp
    gitAndTools.git-annex
    gnupg
    gptfdisk
    imagemagick
    img2pdf
    jq
    libjpeg # jpegtran
    libxml2 # xmllint
    openjdk8
    pass
    poppler_utils # pdfimages
    python3
    python3.pkgs.black
    ranger
    rmlint
    rxvt_unicode
    shellcheck
    sxiv
    unzip
    usbutils # lsusb
    vpnc
    watchexec
    xorg.xwininfo
    zathura
  ]) ++ (with unstable.pkgs; [
    jetbrains.idea-community
    (terraform.withPlugins(ps: with ps; [
      archive
      aws
      external
      http
    ]))
  ]);

  fonts.fonts = with pkgs; [
    iosevka
    font-awesome_4
  ];

  programs.sway = {
    enable = true;

    extraPackages = with pkgs; [
      dmenu
      i3status
      jq
      swayidle
      swaylock
      xwayland
      xdotool
      xorg.xrdb
    ];

    extraSessionCommands = ''
      export _JAVA_AWT_WM_NONREPARENTING=1
    '';
  };

  services.printing = {
    enable = true;
    drivers = with pkgs; [
      hplip
    ];
  };

  hardware.bluetooth.enable = true;

  sound.enable = true;
  hardware.pulseaudio = {
    enable = true;
    package = pkgs.pulseaudio.override {
      bluetoothSupport = true;
    };
  };

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
      ../../keys/tablet-blink.pub
      ../../keys/phone-termux.pub
    ];
  };
  users.groups.ben = {
    gid = 1000;
  };

  security.sudo.wheelNeedsPassword = true;

  programs.ssh = {
    startAgent = true;
    agentTimeout = "1h";
  };

  virtualisation.docker = {
    enable = true;
    storageDriver = "overlay2";
  };

  networking.wireguard.interfaces = {
    wg0 = {
      ips = [ "fd00::2/128" ];
      privateKeyFile = "/secrets/wg/privatekey";
      peers = [{
        endpoint = "aegis.cloud.challenor.org:51820";
        allowedIPs = [
          "2a05:d018:ed3:1200::/56"
          "fd00::/64"
        ];
        publicKey = "F9rBC9avB9VPDL2UeFTr/NHySfB/YgGSNe9ve0xN6TI=";
      }];
    };
  };
}
