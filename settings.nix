{
  audio-plugins,
  nixpkgs,
  nixpkgs-unstable,
  master-config,
  ...
}: {
  # theme = "nordicWithGtkNix";
  system = "x86_64-linux";
  username = "argus";
  hostname = "evil";
  terminal = "kitty";
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
  extraExtraSpecialArgs = {inherit (audio-plugins) mpkgs;};
  extraSpecialArgs = {};
  additionalModules = [audio-plugins.homeManagerModule];
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
    ];
    # packages to build remotely
    remotebuild = [
      "linuxPackages_latest"
      "linuxPackages_zen"
      "linuxPackages_xanmod_latest"
      # "qtile"
      # "neovim"
      "grub"
      "plymouth"
      # this causes system breakages
      # "zsh"
      # none of these work (ie they dont apply, these packages wont build
      # from source like this
      "kitty" "starship"
    ];
  };

  additionalUserPackages = [
    #"steam"
    "libreoffice-fresh"
    # {
    #   set = "unstable";
    #   package = "ue4";
    # }
  ]; # will be evaluated later
  hardwareConfiguration = [./hardware];
  usesWireless = true; # install and autostart nm-applet
  usesBluetooth = true; # install and autostart blueman applet
  usesMouse = false; # enables xmousepasteblock for middle click
  hasBattery = true; # battery widget in tiling WMs
  optimization = {
    arch = "tigerlake";
    useMusl = false; # use musl instead of glibc
    useFlags = false; # use USE
    useClang = false; # cland stdenv
    useNative = false; # native march
    # what optimizations to use (check https://github.com/fortuneteller2k/nixpkgs-f2k/blob/ca75dc2c9d41590ca29555cddfc86cf950432d5e/flake.nix#L237-L289)
    USE = [
      # "-O3"
      "-O2"
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
  remotebuildOverrides = {
    optimization = {
      useMusl = true;
      useFlags = true;
      useClang = true;
    };
  };
  unstableOverrides = {};
}
