# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, ... }:

{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
      ./vm.nix
    ];

  # Bootloader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  networking.hostName = "nixos"; # Define your hostname.
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  # Enable networking
  networking.networkmanager.enable = true;

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

  # Enable the X11 windowing system.
  services.xserver.enable = true;
  # Enable Wayland
  services.xserver.displayManager.defaultSession = "plasmawayland";
  # Enable the KDE Plasma Desktop Environment.
  services.xserver.displayManager.sddm.enable = true;
  services.xserver.desktopManager.plasma5.enable = true;
  # Configure keymap in X11
  services.xserver = {
    layout = "us";
    xkbVariant = "";
  };
  # Configure NFS 
fileSystems."/mnt/knox" = {
    device = "192.168.114.240:/mnt/Knox/media";
    fsType = "nfs";
  };

  # Enable CUPS to print documents.
  services.printing.enable = true;

  # Enable sound with pipewire.
  sound.enable = true;
  hardware.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    # If you want to use JACK applications, uncomment this
    #jack.enable = true;

    # use the example session manager (no others are packaged yet so this is enabled by default,
    # no need to redefine it in your config for now)
    #media-session.enable = true;
  };
  # Enable Steam
  programs.steam = {
    enable = true;
    remotePlay.openFirewall = true; # Open ports in the firewall for Steam Remote Play
    dedicatedServer.openFirewall = true; # Open ports in the firewall for Source Dedicated Server
};
  # Enable touchpad support (enabled default in most desktopManager).
  # services.xserver.libinput.enable = true;
  # Enable BBR congestion control
  boot.kernelModules = [ "tcp_bbr" ];
  boot.kernel.sysctl."net.ipv4.tcp_congestion_control" = "bbr";
  boot.kernel.sysctl."net.core.default_qdisc" = "fq"; # see https://news.ycombinator.com/item?id=14814530

  # Increase TCP window sizes for high-bandwidth WAN connections, assuming
  # 10 GBit/s Internet over 200ms latency as worst case.
  #
  # Choice of value:
  #     BPP         = 10000 MBit/s / 8 Bit/Byte * 0.2 s = 250 MB
  #     Buffer size = BPP * 4 (for BBR)                 = 1 GB
  # Explanation:
  # * According to http://ce.sc.edu/cyberinfra/workshops/Material/NTP/Lab%208.pdf
  #   and other sources, "Linux assumes that half of the send/receive TCP buffers
  #   are used for internal structures", so the "administrator must configure
  #   the buffer size equals to twice" (2x) the BPP.
  # * The article's section 1.3 explains that with moderate to high packet loss
  #   while using BBR congestion control, the factor to choose is 4x.
  #
  # Note that the `tcp` options override the `core` options unless `SO_RCVBUF`
  # is set manually, see:
  # * https://stackoverflow.com/questions/31546835/tcp-receiving-window-size-higher-than-net-core-rmem-max
  # * https://bugzilla.kernel.org/show_bug.cgi?id=209327
  # There is an unanswered question in there about what happens if the `core`
  # option is larger than the `tcp` option; to avoid uncertainty, we set them
  # equally.
  boot.kernel.sysctl."net.core.wmem_max" = 1073741824; # 1 GiB
  boot.kernel.sysctl."net.core.rmem_max" = 1073741824; # 1 GiB
  boot.kernel.sysctl."net.ipv4.tcp_rmem" = "4096 87380 1073741824"; # 1 GiB max
  boot.kernel.sysctl."net.ipv4.tcp_wmem" = "4096 87380 1073741824"; # 1 GiB max
  # We do not need to adjust `net.ipv4.tcp_mem` (which limits the total
  # system-wide amount of memory to use for TCP, counted in pages) because
  # the kernel sets that to a high default of ~9% of system memory, see:
  # * https://github.com/torvalds/linux/blob/a1d21081a60dfb7fddf4a38b66d9cef603b317a9/net/ipv4/tcp.c#L4116
  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.obi = {
    isNormalUser = true;
    description = "obi";
    extraGroups = [ "networkmanager" "wheel" ];
    packages = with pkgs; [
brave 
caffeine-ng
dig 
element-desktop
filezilla 
firefox
flameshot
geany
gimp
git
gparted
htop
inetutils
iperf 
kate
libreoffice 
libsForQt5.ktouch
neofetch
nextcloud-client
nfs-utils
openssh
pciutils
protonvpn-gui
python3 
rar
remmina
signal-desktop
speedtest-cli
spotify
tailscale
thunderbird
transmission-gtk 
virtualbox 
vivaldi 
vlc 
vscode
wireshark
    ];
  };

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
  #  vim # Do not forget to add an editor to edit configuration.nix! The Nano editor is also installed by default.
  #  wget
  ];

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  # programs.gnupg.agent = {
  #   enable = true;
  #   enableSSHSupport = true;
  # };

  # List services that you want to enable:
  # Enable Bluetooth
  hardware.bluetooth.enable = true;
  hardware.bluetooth.powerOnBoot = true;
  hardware.enableAllFirmware = true; 
  # Enable Tailscale
  services.tailscale.enable = true;
  # Enable the OpenSSH daemon.
  # services.openssh.enable = true;

  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "23.05"; # Did you read the comment?

}
