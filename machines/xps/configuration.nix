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

  # - iwd for layer 2
  # - networkd for layer 3
  # - openresolv for nameservers
  networking.wireless.iwd.enable = true;
  systemd.network = {
    enable = true;
    networks = {
      wlan = {
        extraConfig = ''
          [Match]
          Type=wlan

          [Network]
          DHCP=ipv4

          [DHCPv4]
          UseRoutes=yes
          UseDNS=no
          UseHostname=no
          UseNTP=no
        '';
      };
    };
  };
  services.resolved.enable = false;
  networking.dhcpcd.enable = false;
  networking.resolvconf.enable = true;
  networking.nameservers = [ "1.1.1.1" ];

  time.timeZone = "Europe/London";

  boot.kernel.sysctl = {
    # Defaults to 8192. Each uses about 1kB.
    "fs.inotify.max_user_watches" = 64 * 1024;
  };

  boot.kernelPackages = pkgs.linuxPackages_latest;

  environment.systemPackages = (with pkgs; [
    awscli
    chromium
    diffoscope
    emacs
    evince
    file
    firefox
    freerdp
    gitAndTools.git-annex
    gnupg
    gptfdisk
    graphviz
    imagemagick
    img2pdf
    jq
    libjpeg # jpegtran
    libreoffice
    libxml2 # xmllint
    (linkFarm "openjdk" [
      { name = "lib/openjdk/8" ; path = openjdk8  + /lib/openjdk; }
      { name = "lib/openjdk/11"; path = openjdk11 + /lib/openjdk; }
    ])
    pass
    poppler_utils # pdfimages
    pwgen
    python3
    python3.pkgs.black
    qrencode
    ranger
    rmlint
    rxvt_unicode
    sbt
    shellcheck
    skopeo
    sxiv
    unzip
    usbutils # lsusb
    vpnc
    watchexec
    xorg.xwininfo
    xsv
    zathura
    zip
  ]) ++ (with unstable.pkgs; [
    (jetbrains.idea-community.override {
      jdk = openjdk11;
    })
    (terraform.withPlugins(ps: with ps; [
      archive
      aws
      external
      http
    ]))
  ]);

  fonts.fonts = with pkgs; [
    iosevka
    noto-fonts
    noto-fonts-extra
    noto-fonts-cjk
    noto-fonts-emoji
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
      "dialout" # for /dev/ttyUSB0
    ];
    hashedPassword = "*";
    openssh.authorizedKeys.keyFiles = [
      ../../keys/tablet-blink.pub
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
