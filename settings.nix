{
  this,
  nixpkgs,
  nixpkgs-unstable,
  master-config,
  ...
}: let
  override = nixpkgs.lib.attrsets.recursiveUpdate;
in rec {
  # theme = "nordicWithGtkNix";
  # theme = "drifter";
  # theme = "gruvbox";
  system = "x86_64-linux";
  username = "argus";
  hostname = "evil";
  terminal = "kitty";
  useDvorak = false;
  # unfree packages that i explicitly use
  allowedUnfree = [
    "spotify-unwrapped"
    "reaper"
    "slack"
    "discord"
    "ue4"
  ];
  allowBroken = true;
  plymouth = let
    name = "seal";
  in {
    themeName = name;
    themePath = "pack_4/${name}";
  };
  extraExtraSpecialArgs = {};
  extraSpecialArgs = {};
  additionalModules = [./shared];
  additionalOverlays = [];
  packageSelections = {
    # packages to override with their unstable versions
    # all of these are things that i might want to move
    # to remotebuild at some point (so theyre FOSS)
    unstable = [
      "alejandra"
      "wl-color-picker"
      "heroic"
      "solo2-cli"
      "ani-cli"
      "ungoogled-chromium"
      "firefox"
      "OVMFFull"
      {
        set1 = "linuxKernel";
        set2 = "kernels";
        set3 = "linux_xanmod_latest";
      }
    ];
    localbuild = [
      # "xorg"
      "gnome-shell"
      "gdm"
      "qtile"
      "zsh"
      "zplug"
      # "neovim" I want to build from source but its in unstable
      "kitty"
      "starship"
    ];
    # packages to build remotely
    remotebuild = let
      mkXorg = xorgPkg: {
        set1 = "xorg";
        set2 = xorgPkg;
      };
    in [
      "dash"
      "grub"
      "plymouth"
      "coreutils-full"
    ];
  };

  additionalUserPackages = [
    #"steam"
    "libreoffice-fresh"
    {
      set = "unstable";
      package = "godot_4";
    }
    "python310Packages.gdtoolkit"
    "aseprite"
    "cool-retro-term"
    "cage"
    "screen"
    "fbterm"
    "nodePackages.prettier_d_slim"
    "quick-lint-js"
    "virt-viewer"
    "blender"
    # {
    #   set = "unstable";
    #   package = "ue4";
    # }
  ]; # will be evaluated later
  hardwareConfiguration = [./hardware ./shared];
  usesWireless = true; # install and autostart nm-applet
  usesBluetooth = true; # install and autostart blueman applet
  usesMouse = false; # enables xmousepasteblock for middle click
  hasBattery = true; # battery widget in tiling WMs
  usesEthernet = false;
  optimization = {
    arch = "tigerlake";
    useMusl = false; # use musl instead of glibc
    useFlags = false; # use USE
    useClang = false; # cland stdenv
    useNative = false; # native march
    # what optimizations to use (check https://github.com/fortuneteller2k/nixpkgs-f2k/blob/ca75dc2c9d41590ca29555cddfc86cf950432d5e/flake.nix#L237-L289)
    USE = [
      "-O3"
      # "-O2"
      "-pipe"
      "-ffloat-store"
      "-fexcess-precision=fast"
      "-ffast-math"
      "-fno-rounding-math"
      "-fno-signaling-nans"
      "-fno-math-errno"
      "-funsafe-math-optimizations"
      "-fassociative-math"
      "-freciprocal-math"
      "-ffinite-math-only"
      "-fno-signed-zeros"
      "-fno-trapping-math"
      "-frounding-math"
      "-fsingle-precision-constant"
      # not supported on clang 14 yet, and isn't ignored
      # "-fcx-limited-range"
      # "-fcx-fortran-rules"
    ];
  };
  nix = {
    distributedBuilds = true;
    buildMachines = [
      {
        hostName = "rpmc.duckdns.org";
        systems = ["aarch64-linux"];
        sshUser = "servers";
        sshKey = "/home/argus/.ssh/id_ed25519";
        supportedFeatures = ["big-parallel"];
        maxJobs = 4;
        speedFactor = 2;
      }
    ];
  };
  additionalSystemPackages = [];
  name = "pkgs";
  remotebuildOverrides = {
    optimization = {
      useMusl = true;
      useFlags = true;
      useClang = true;
    };
    name = "remotebuild";
  };
  unstableOverrides = {
    name = "unstable";
    additionalOverlays = let
      kernel = import ./hardware/kernels/lib/kernel-overlay.nix {
        inherit override hostname;
        baseKernelSuffix = "xanmod_latest";
        kernelConfig = ./hardware/kernels/5_19.nix;
      };
    in [
      # kernel
    ];
  };
  localbuildOverrides = override remotebuildOverrides {
    # optimization.useMusl = false;
    name = "localbuild";
  };
}
