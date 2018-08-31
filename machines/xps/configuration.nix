{ config, pkgs, ... }:

{
  imports = [
    ./hardware-configuration.nix
    ../../modules/common.nix
  ];

  networking.hostName = "xps";

  hardware.cpu.intel.updateMicrocode = true;

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  boot.initrd.luks.devices."pool" =
    { device = "/dev/disk/by-partlabel/pool";
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
  fileSystems."/pool" =
    { device = "/dev/mapper/pool";
      fsType = "btrfs";
      options = [ "subvol=/" ];
    };

  services.snapper.configs = {
    "benfs" = {
      subvolume = "/pool/benfs";
      extraConfig = ''
        TIMELINE_CREATE="yes"
        TIMELINE_CLEANUP="yes"
      '';
    };
    "datafs" = {
      subvolume = "/pool/datafs";
      extraConfig = ''
        TIMELINE_CREATE="yes"
        TIMELINE_CLEANUP="yes"
      '';
    };
  };

  services.fstrim.enable = true;

  networking.networkmanager.enable = true;

  time.timeZone = "Europe/London";

  environment.systemPackages = with pkgs; [
    awscli
    chromium
    file
    firefox
    freerdp
    gitAndTools.git-annex
    gptfdisk
    imagemagick
    jq
    libjpeg # jpegtran
    pass
    poppler_utils # pdfimages
    ranger
    rmlint
    rxvt_unicode
    sxiv
    terraform
    unzip
    usbutils # lsusb
    vpnc
    watchexec
    xorg.xwininfo
    zathura
  ];

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

  services.printing.enable = true;

  sound.enable = true;
  hardware.pulseaudio.enable = true;

  services.xserver.libinput = {
    enable = true;
    tapping = false;
    clickMethod = "clickfinger";
    naturalScrolling = true;
  };

  # Workaround for broken middle mouse button
  # Disable middle button 2 and use side button 9 in its place
  services.xserver.config = ''
    Section "InputClass"
      Identifier "Logitech G602"
      Driver "libinput"
      MatchUSBID "046d:c537"
      Option "ButtonMapping" "1 0 3 4 5 6 7 8 2"
    EndSection
  '';

  services.redshift = {
    enable = true;
    provider = "geoclue2";
    temperature = {
      day = 6500;
      night = 3700;
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

  system.stateVersion = "18.03";
}
