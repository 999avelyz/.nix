{
  description = "Avelyz NixOS Flake";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable";

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    noctalia.url = "github:noctalia-dev/noctalia";

    spicetify-nix.url = "github:Gerg-L/spicetify-nix";

    sf-fonts = {
      url = "github:999Avelyzzzz/SF-Fonts";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nix-cachyos-kernel.url = "github:xddxdd/nix-cachyos-kernel/release";
  };

  outputs = inputs@{ self, nixpkgs, ... }: {
    nixosConfigurations = {
      Desktop = nixpkgs.lib.nixosSystem {
        specialArgs = { inherit inputs; };
        modules = [
          { nixpkgs.hostPlatform = "x86_64-linux"; }
          ./Desktop/Configuration.nix
        ];
      };
    };
  };
}
