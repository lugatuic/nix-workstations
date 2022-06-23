{config, lib, pkgs, ...}:

{

  imports = [./system/hardware.nix];

  # Enable Flakes
  nix = {
    package = pkgs.nixFlakes;
    extraOptions = "experimental-features = nix-command flakes";
  };

  boot.loader.efi.canTouchEfiVariables = true;
  boot.loader.grub = {
    enable = true;
    efiSupport = true;
    device = "/dev/disk/by-label/esp";
  };
  users.motd = ''
    Hello random user, Welcome to LUG+ACM at UIC!\n
    Enjoy using this super cool Workstation powered by NixOS!\n\n
  '';
  users.users.lugnix = {
    isNormalUser = true;
    extraGroups = ["users" "wheel"];
    createHome = true;

    # Good luck hackers ;)
    hashedPassword = "$6$fPQXxMm0MLDIYVzm$v.yav/eptB0vvNGYSDdaDtuTAszZzB8UVGaXOA/fFfOWEol.wu7vYSZVmNipfiJPvScxDOeTERriH5A0r3hu1.";
  };

  # Enable the X11 windowing system.
  services.xserver.enable = true;


  # Enable the GNOME Desktop Environment.
  services.xserver.displayManager.gdm.enable = true;
  services.xserver.desktopManager.gnome.enable = true;

  networking.firewall.enable = false;

  environment.systemPackages = with pkgs; [
    vim
    emacs
    coreutils
    psmisc
    gcc
    firefox
    git
  ];

  environment.variables = {
    EDITOR = "vim";
  };

  services.openssh.enable = true;

  time.timeZone = "America/Chicago";

  services.fstrim.enable = true;

  sound.enable = true;
  hardware.pulseaudio.enable = true;

  system.stateVersion = "22.05";

}
