# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ lib, config, pkgs, ... }:

let
  my_obj_sid = "S-1-5-21-1139666126-4292851174-2664146837-2302";
in {
    imports =
        [ # Include the results of the hardware scan.
        ./hardware-configuration.nix
        ];

    nix = {
        package = pkgs.nixFlakes;
        extraOptions = ''
                    experimental-features = nix-command flakes
        '';
    };

    # Bootloader.
    boot.loader.grub.enable = true;
    boot.loader.grub.device = "/dev/sdb";
    boot.loader.grub.useOSProber = true;

    networking.hostName = "EVAA"; # Define your hostname.
    # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.

    # Configure network proxy if necessary
    # networking.proxy.default = "http://user:password@proxy:port/";
    # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

    # Enable networking
    networking.networkmanager.enable = true;

    # Set your time zone.
    time.timeZone = "America/Chicago";

    # Select internationalisation properties.
    i18n.defaultLocale = "en_US.utf8";

    # Enable the X11 windowing system.
    services.xserver.enable = true;

    # Enable the KDE Plasma Desktop Environment.
    services.xserver.displayManager.sddm.enable = true;
    services.xserver.desktopManager.plasma5.enable = true;

    # Configure keymap in X11
    services.xserver = {
        layout = "us";
        xkbVariant = "";
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

    # Enable touchpad support (enabled default in most desktopManager).
    # services.xserver.libinput.enable = true;

    # Define a user account. Don't forget to set a password with ‘passwd’.
    users.users.acm = {
        isNormalUser = true;
        description = "ACM";
        extraGroups = [ "networkmanager" "wheel" ];
    };
    users.ldap = {
        enable = true;
        base = "dc=acm,dc=cs";
        server = "ldap://ad.acm.cs";
        loginPam = true;
        nsswitch = true;
        bind.distinguishedName = "nslcduser@acm.cs";
        bind.passwordFile = "/root/binddn.passwd";
        daemon = {
        enable = true;
        extraConfig = ''
                bindpw SECRET_LOL
                pagesize 1000
                referrals off
                idle_timelimit 800
                filter passwd (&(objectClass=user)(objectClass=person)(!(objectClass=computer)))
                map    passwd uid           cn
                map    passwd uidNumber     objectSid:${my_obj_sid}
                map    passwd gidNumber     objectSid:${my_obj_sid}
                map    passwd homeDirectory "/home/$cn"
                map    passwd gecos         displayName
                map    passwd loginShell    "/run/current-system/sw/bin/bash"
                filter group (|(objectClass=group)(objectClass=person))
                map    group gidNumber      objectSid:${my_obj_sid}
            '';
        };

    };
    security.pam.services.sshd = {
        makeHomeDir = true;

        # see https://stackoverflow.com/a/47041843 for why this is required
        # text = lib.mkDefault (
        #   lib.mkBefore ''
        #         auth sufficient ${pkgs.pam_ldap}/lib/security/pam_ldap.so config=/etc/ldap.conf
        #         password sufficient ${pkgs.pam_ldap}/lib/security/pam_ldap.so config=/etc/ldap.conf
        #         session optional ${pkgs.pam_ldap}/lib/security/pam_ldap.so config=/etc/ldap.conf
        #         account sufficient ${pkgs.pam_ldap}/lib/security/pam_ldap.so config=/etc/ldap.conf

        #     ''
        # );
    };
    environment.etc.allowed_groups = {
        text = "ACMLanAdmins";
        mode = "0444";
    };
    systemd.tmpfiles.rules = [
        "L /bin/bash - - - - /run/current-system/sw/bin/bash"
    ];
    # Allow unfree packages
    nixpkgs.config.allowUnfree = true;

    # List packages installed in system profile. To search, run:
    # $ nix search wget
    environment.systemPackages = with pkgs; [
    #  vim # Do not forget to add an editor to edit configuration.nix! The Nano editor is also installed by default.
    #  wget
        firefox
        kate
        pam_ldap
    ];

    # Some programs need SUID wrappers, can be configured further or are
    # started in user sessions.
    # programs.mtr.enable = true;
    # programs.gnupg.agent = {
    #   enable = true;
    #   enableSSHSupport = true;
    # };

    # List services that you want to enable:

    # Enable the OpenSSH daemon.
    services.openssh.enable = true;
    services.openssh.permitRootLogin = "yes";

    services.avahi.enable = false;
    # Disable resolveconf, we're using Samba internal DNS backend
    systemd.services.resolvconf.enable = false;
    environment.etc = {
        resolvconf = {
        text = ''
            search ad.acm.cs
            nameserver 172.29.0.16
        '';
        };
    };

    networking.hosts = {
        "127.0.0.1" = ["evaa.acm.cs" "evaa"];
    };

    # Rebuild Samba with LDAP, MDNS and Domain Controller support
    nixpkgs.overlays = [ (self: super: {
        samba = super.samba.override {
        enableLDAP = true;
        enableMDNS = true;
        enableDomainController = true;
        };
    } ) ];

    # services.timesyncd = {
    #   enable = true;
    #   servers = ["dc1.acm.cs" "dc2.acm.cs"];
    # };
    # services.samba = {
    #   enable = true;
    #   enableWinbindd = true;
    #   securityType = "ADS";
    #   extraConfig = ''
    #                     workgroup = ACM
    #                     realm = acm.cs
    #                     idmap config * : backend = autorid
    #                     idmap config * : range = 10000-9999999
    #                     username map = /etc/smb.map

    #   '';
    # };
    # services.samba-wsdd = {
    #   enable = true;
    #   domain = "acm.cs";
    #   discovery = true;
    # };
    # krb5.libdefaults = {
    #   default_realm = "acm.cs";
    #   dns_lookup_realm = false;
    #   dns_lookup_kdc = true;
    #   clockskew = "3000";
    # };
    # Open ports in the firewall.
    # networking.firewall.allowedTCPPorts = [ ... ];
    # networking.firewall.allowedUDPPorts = [ ... ];
    # Or disable the firewall altogether.
    networking.firewall.enable = false;

    # This value determines the NixOS release from which the default
    # settings for stateful data, like file locations and database versions
    # on your system were taken. It‘s perfectly fine and recommended to leavecatenate(variables, "bootdev", bootdev)
    # this value at the release version of the first install of this system.
    # Before changing this value read the documentation for this option
    # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
    system.stateVersion = "22.05"; # Did you read the comment?


};
