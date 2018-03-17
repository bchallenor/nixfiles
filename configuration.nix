{ config, pkgs, ... }:

{
  imports = [
    <nixpkgs/nixos/modules/profiles/headless.nix>
    ./hardware-configuration.nix
  ];

  boot.loader.grub.enable = true;
  boot.loader.grub.version = 2;
  boot.loader.grub.device = "/dev/xvda";
  boot.loader.timeout = 0;

  boot.kernelParams = [
    # ttyS0 is used by AWS System Log
    "console=ttyS0"
  ];

  boot.tmpOnTmpfs = true;

  # Grow root partition and filesystem on boot so that we can store smaller EBS snapshots
  boot.growPartition = true;
  fileSystems."/".autoResize = true;

  # Use the time server provided by Amazon Time Sync Service
  # https://aws.amazon.com/blogs/aws/keeping-time-with-amazon-time-sync-service/
  networking.timeServers = [ "169.254.169.123" ];

  i18n.defaultLocale = "en_US.UTF-8";

  time.timeZone = "UTC";

  environment.systemPackages = with pkgs; [
    awscli
    bind
    docker
    docker_compose
    git
    htop
    jq
    ncdu
    psmisc
    ranger
    ripgrep
    rsync
    stow
    strace
    terraform
    tig
    tmux
    tree
    unzip
    vim
  ];

  programs.bash.enableCompletion = true;

  users.mutableUsers = false;
  users.users.ben = {
    uid = 1000;
    group = "ben";
    createHome = true;
    home = "/home/ben";
    useDefaultShell = true;
    extraGroups = [ "wheel" ];
    hashedPassword = "*";
    openssh.authorizedKeys.keyFiles = [
      keys/tablet-blink.pub
    ];
  };
  users.groups.ben = {
    gid = 1000;
  };

  security.sudo.wheelNeedsPassword = false;

  services.openssh.enable = true;
  services.openssh.passwordAuthentication = false;
  services.openssh.challengeResponseAuthentication = false;
  services.openssh.permitRootLogin = "no";

  programs.mosh.enable = true;

  services.nscd.enable = false;
}
