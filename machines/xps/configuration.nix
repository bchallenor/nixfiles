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

  boot.initrd.luks.devices."pool" =
    { device = "/dev/disk/by-partlabel/pool";
      allowDiscards = true;
    };
  boot.initrd.luks.devices."epool" =
    { device = "/dev/disk/by-partlabel/epool";
      allowDiscards = true;
    };

  fileSystems."/" =
    { device = "/dev/mapper/pool";
      fsType = "btrfs";
      options = [ "subvol=/nixfs" ];
    };
  fileSystems."/boot" =
    { device = "/dev/disk/by-partlabel/efi";
      fsType = "vfat";
    };
  fileSystems."/home/ben" =
    { device = "/dev/mapper/pool";
      fsType = "btrfs";
      options = [ "subvol=/benfs" ];
    };
  fileSystems."/data" =
    { device = "/dev/mapper/pool";
      fsType = "btrfs";
      options = [ "subvol=/datafs" ];
    };
  fileSystems."/secrets" =
    { device = "/dev/mapper/pool";
      fsType = "btrfs";
      options = [ "subvol=/secretsfs" ];
    };
  fileSystems."/mnt/pool" =
    { device = "/dev/mapper/pool";
      fsType = "btrfs";
      options = [ "subvol=/" ];
    };
  fileSystems."/mnt/epool" =
    { device = "/dev/mapper/epool";
      fsType = "ext4";
    };

  services.snapper.configs = {
    "benfs" = {
      subvolume = "/mnt/pool/benfs";
      extraConfig = ''
        TIMELINE_CREATE="yes"
        TIMELINE_CLEANUP="yes"
      '';
    };
    "datafs" = {
      subvolume = "/mnt/pool/datafs";
      extraConfig = ''
        TIMELINE_CREATE="yes"
        TIMELINE_CLEANUP="yes"
      '';
    };
    "secretsfs" = {
      subvolume = "/mnt/pool/secretsfs";
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

  services.xserver = {
    enable = true;
    autorun = true;

    displayManager.lightdm.enable = true;

    desktopManager.xterm.enable = false;

    windowManager.i3 = {
      enable = true;
      extraPackages = with pkgs; [
        dmenu
        i3lock
        i3status
        jq
        xorg.xbacklight
        xss-lock
      ];
    };
  };

  services.printing = {
    enable = true;
    drivers = with pkgs; [
      hplip
    ];
  };

  sound.enable = true;
  hardware.pulseaudio.enable = true;

  services.xserver.libinput = {
    enable = true;
    tapping = false;
    clickMethod = "clickfinger";
    naturalScrolling = true;
  };

  services.xserver.config = ''
    # Internal keyboard has a right ctrl but no right win
    # Swap them, because having a right win is more useful for i3
    Section "InputClass"
      Identifier "Internal Keyboard"
      Driver "libinput"
      MatchProduct "AT Translated Set 2 keyboard"
      Option "XkbOptions" "ctrl:swap_rwin_rctl"
    EndSection

    # Workaround for broken middle mouse button
    # Disable middle button 2 and use side button 9 in its place
    Section "InputClass"
      Identifier "Logitech G602"
      Driver "libinput"
      MatchUSBID "046d:c537"
      Option "ButtonMapping" "1 0 3 4 5 6 7 8 2"
    EndSection
  '';

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
