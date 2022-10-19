{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-22.05";
    nixpkgs-unstable.url = "github:nixos/nixpkgs?ref=nixos-unstable";

    master-config = {
      url = "github:the-argus/nixsys";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.nixpkgs-unstable.follows = "nixpkgs-unstable";
      inputs.banner.url = "github:the-argus/banner.nix";
    };
  };

  outputs = {
    self,
    nixpkgs,
    nixpkgs-unstable,
    master-config,
  } @ inputs: let
    supportedSystems = [
      "x86_64-linux"
      "aarch64-linux"
    ];
    genSystems = nixpkgs.lib.genAttrs supportedSystems;
    settings = import ./settings.nix {
      inherit nixpkgs nixpkgs-unstable master-config;
      this = self;
    };
  in {
    nixosConfigurations = master-config.createNixosConfiguration settings;
    homeConfigurations = {
      "${settings.username}" =
        master-config.createHomeConfigurations settings;
    };
    devShell."x86_64-linux" =
      (master-config.finalizeSettings settings).pkgs.mkShell {};

    formatter = genSystems (system: nixpkgs-unstable.legacyPackages.${system}.alejandra);
  };
}
