{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-22.11";
    nixpkgs-unstable.url = "github:nixos/nixpkgs?ref=nixos-unstable";

    master-config = {
      url = "github:the-argus/nixsys";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.nixpkgs-unstable.follows = "nixpkgs-unstable";
      inputs.nvim-config.url = "github:the-argus/nvim-config";
    };
  };

  outputs = {
    self,
    nixpkgs,
    nixpkgs-unstable,
    master-config,
  }: let
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
