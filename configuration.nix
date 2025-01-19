{ config, pkgs, ... }:

{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
      # ./home.nix
      ./vm.nix   
      # Link to unstable Cosmic
      # ./unstable.nix
    ];

  # Bootloader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  networking.hostName = "nixos"; # Define your hostname.

  # Enable networking
  networking.networkmanager.enable = true;
  systemd.services.NetworkManager-wait-online.enable = false; # Disable network wait, for ERRORS starting Wait

  # Set your time zone.
  time.timeZone = "America/New_York";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.UTF-8";

  i18n.extraLocaleSettings = {
    LC_ADDRESS = "en_US.UTF-8";
    LC_IDENTIFICATION = "en_US.UTF-8";
    LC_MEASUREMENT = "en_US.UTF-8";
    LC_MONETARY = "en_US.UTF-8";
    LC_NAME = "en_US.UTF-8";
    LC_NUMERIC = "en_US.UTF-8";
    LC_PAPER = "en_US.UTF-8";
    LC_TELEPHONE = "en_US.UTF-8";
    LC_TIME = "en_US.UTF-8";
  };

  # Enable Flakes
  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  # Enable Wayland
  services.displayManager.defaultSession = "plasmawayland";  

  # Enable the KDE Plasma Desktop Environment.
  services.displayManager.sddm.enable = true;
  services.xserver.desktopManager.plasma5.enable = true;
  
  # Configure Xserver and keymap in X11
  services.xserver = {
    enable = true;
    xkb = {
      layout = "us";
      variant = "";
    };  
  };

  # Enable CUPS to print documents.
  services.printing.enable = true;

  # Enable sound with PipeWire.
  services.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
  };

  # Enable touchpad support (enabled by default in most desktop managers).
  services.libinput.enable = true;

  # Enable Bluetooth
  hardware.bluetooth.enable = true;
  hardware.bluetooth.powerOnBoot = true;
  hardware.enableAllFirmware = true;

  # Enable Tailscale
  services.tailscale.enable = true;

  # Configure NFS
  fileSystems."/mnt/knox" = {
    device = "192.168.114.240:/mnt/Knox/media";
    fsType = "nfs";
  };

  #SSHD
  services.openssh = {
    enable = true;
    # require public key authentication for better security
    settings.PasswordAuthentication = false;
    settings.KbdInteractiveAuthentication = false;
    #settings.PermitRootLogin = "yes";
  };
  users.users."obi".openssh.authorizedKeys.keyFiles = [
    ./.ssh/authorized_keys
  ];

  # NixOS option
  environment.systemPackages = with pkgs; [
    neovim
    alacritty
    gcc
  ];

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.obi = {
    isNormalUser = true;
    description = "obi";
    extraGroups = [ "networkmanager" "wheel" "fuse" ];
    packages = with pkgs; [
      brave
      caffeine-ng
      calibre
      dig
      element-desktop
      filezilla
      firefox
      flameshot
      geany
      gimp
      git
      gns3-gui
      gparted
      htop
      inetutils
      inkscape-with-extensions
      iperf
      kate
      kontact
      krita
      libreoffice
      libsForQt5.ktouch
      logseq
      mtr
      mysql80
      neofetch
      nextcloud-client
      nfs-utils
      nmap
      obsidian
      openssh
      openvpn
      protonvpn-gui
      putty
      python3
      qflipper
      rar
      remmina
      rustc
      signal-desktop
      speedtest-cli
      spotify
      sshfs
      superTux
      tailscale
      telegram-desktop
      thunderbird
      tor
      transmission_4-qt
      vim
      vivaldi
      vlc
      vscode
      vscodium
      warp-terminal
      wayvnc
      wireshark
      xrdp
      yt-dlp
    ];
  };

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  # Permit insecure packages
  nixpkgs.config.permittedInsecurePackages = [
    "electron-27.3.11"
  ];

  # This value determines the NixOS release from which the default
  # settings for stateful data were taken.
  system.stateVersion = "24.05"; # Did you read the comment?
} 
