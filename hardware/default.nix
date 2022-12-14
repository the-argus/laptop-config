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
  environment.variables.EDITOR = "nvim";

  services.printing.enable = true;
  services.avahi.enable = true;
  # for a WiFi printer
  services.avahi.openFirewall = true;

  time.timeZone = "America/Chicago";

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
      enable = false;
      themePackages = [pkgs.plymouth-themes-package];
      theme = plymouth.themeName;
    };
  };

  # makes plymouth wait 5 seconds while playing
  # systemd.services.plymouth-quit.serviceConfig.ExecStartPre = "${pkgs.coreutils-full}/bin/sleep 5";

  virtualization = {
    enable = true;
    containers = {
      docker.enable = false;
      podman.enable = true;
    };
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
