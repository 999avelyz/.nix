{ inputs, config, pkgs, ... }:

{
  imports = [
    inputs.noctalia.homeModules.default
    inputs.waterfox-flake.homeManagerModules.default
    inputs.spicetify-nix.homeManagerModules.spicetify
    ./Modules/Home-Manager/GTK.nix
    ./Modules/Home-Manager/Niri.nix
    ./Modules/Home-Manager/Noctalia.nix
    ./Modules/Home-Manager/Packages.nix
    ./Modules/Home-Manager/Spicetify.nix
    ./Modules/Home-Manager/Git.nix
    ./Modules/Home-Manager/Kitty.nix
    ./Modules/Home-Manager/Btop.nix
  ];

  home = {
    username = "denis";
    homeDirectory = "/home/denis";
    stateVersion = "26.11";
  };

  programs.home-manager.enable = true;
}
