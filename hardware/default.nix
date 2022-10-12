{
  config,
  pkgs,
  unstable,
  lib,
  useFlags,
  plymouth,
  hostname,
  username,
  ...
}: {
  imports = [
    ./hardware-configuration.nix
  ];

  # time.timeZone = "America/Chicago";

  # dual booting with windows boot loader mounted on /efi
  boot = {
    kernelPackages = pkgs.linuxPackages_xanmod_latest;
    kernelParams = ["intel_iommu=on" "quiet" "systemd.show_status=0" "loglevel=4" "rd.systemd.show_status=auto" "rd.udev.log-priority=3"];
    loader = {
      efi = {
        canTouchEfiVariables = true;
        efiSysMountPoint = "/efi";
      };
      # grub = {
      #   # enable = true;
      #   # version = 2;
      #   # device = "/dev/disk/by-uuid/444dd843-a3b1-4e59-9d47-c62cfab94d8b";
      #   useOSProber = true;
      # };
      systemd-boot = {
        enable = true;
      };
    };
    initrd = {
      verbose = false;
      systemd.enable = true;
      services.swraid.enable = false;
    };
    plymouth = {
      enable = true;
      themePackages = [pkgs.plymouth-themes-package];
      theme = plymouth.themeName;
    };
  };

  # makes plymouth wait 5 seconds while playing
  # systemd.services.plymouth-quit.serviceConfig.ExecStartPre = "${pkgs.coreutils-full}/bin/sleep 5";
  # programs.ssh.askPassword = pkgs.lib.mkForce "${pkgs.gnome.seahorse.out}/libexec/seahorse/ssh-askpass";
  desktops = {
    enable = true;
    # sway.enable = true;
    # awesome.enable = true;
    # ratpoison.enable = true;
    qtile.enable = true;
    i3gaps.enable = true;
    gnome.enable = true;
    # plasma.enable = true;
  };
  # choose display manager
  # services.xserver.desktopManager.plasma5.enable = true;
  services.xserver.displayManager.startx.enable = true;
  # services.xserver.displayManager.gdm.enable = true;
  # services.xserver.displayManager.sddm.enable = true;
  # services.xserver.displayManager.ly = {
  #   enable = true;
  #   defaultUsers = username;
  # };
  # environment.etc.issue = {
  #   source = pkgs.writeText "issue" ''
  #     testing..
  #   '';
  # };

  # virtualization
  users.users.${username}.extraGroups = ["docker"];
  users.extraUsers.${username} = {
    subUidRanges = [
      {
        startUid = 100000;
        count = 65536;
      }
    ];
    subGidRanges = [
      {
        startGid = 100000;
        count = 65536;
      }
    ];
  };
  virtualisation = {
    docker = {
      enable = true;
    };
    podman = {
      enable = true;

      # Required for containers under podman-compose to be able to talk to each other.
      defaultNetwork.dnsname.enable = true;

      extraPackages = [pkgs.podman-compose];
    };
  };

  services.greetd = {
    enable = false;
    settings = {
      terminal = {
        # only open the greeter on the first tty
        vt = 1;
      };
      default_session = {
        command = ''
          ${pkgs.greetd.tuigreet}/bin/tuigreet \
          --sessions ${pkgs.xorg.xinit}/bin/startx,${pkgs.sway}/bin/sway \
          --time \
          --issue \
          --remember \
          --remember-session \
          --asterisks \
        '';
        user = username;
      };
    };
  };

  # display -------------------------------------------------------------------
  hardware.opengl = {
    driSupport32Bit = false;
    driSupport = true;
    extraPackages = with pkgs; [
      intel-media-driver
    ];
    # extraPackages32 = with pkgs.pkgsi686Linux;
    #   [ libva vaapiIntel libvdpau-va-gl vaapiVdpau ]
    #   ++ lib.optionals config.services.pipewire.enable [ pipewire ];
  };

  #	services.xserver.videoDrivers = [ "intel" ];
  services.xserver = {
    videoDriver = "intel";

    config = ''
      Section "ServerFlags"
          Option      "AutoAddDevices"         "false"
      EndSection
    '';
  };

  # hardware ------------------------------------------------------------------
  hardware.openrazer.enable = true;

  # networking-----------------------------------------------------------------
  networking.hostName = hostname;
  networking.interfaces."wlp0s20f3" = {useDHCP = false;};
  networking.wireless.interfaces = ["wlp0s20f3"];
  networking.networkmanager.enable = true;
  networking.useDHCP = false;
  # networking.wireless.enable = true;

  # iphone tethering
  services.usbmuxd.enable = true;

  # bluetooth------------------------------------------------------------------
  hardware.bluetooth.enable = true;
  services.blueman.enable = true;

  # packages-------------------------------------------------------------------
  environment.systemPackages = with pkgs; [
    bluez
    bluez-alsa
    bluez-tools
    networkmanagerapplet
    libimobiledevice
    razergenie
  ];
}
