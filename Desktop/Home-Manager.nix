{ inputs, config, pkgs, ... }:

{
  imports = [
    inputs.waterfox-flake.homeManagerModules.default
    inputs.spicetify-nix.homeManagerModules.spicetify
    ./Modules/Home-Manager/Noctalia/Settings.nix
    ./Modules/Home-Manager/Browser.nix
    ./Modules/Home-Manager/GTK.nix
    ./Modules/Home-Manager/CM-Redirects.nix
    ./Modules/Home-Manager/Niri.nix
    ./Modules/Home-Manager/Packages.nix
    ./Modules/Home-Manager/Spicetify.nix
    ./Modules/Home-Manager/Git.nix
    ./Modules/Home-Manager/Kitty.nix
    ./Modules/Home-Manager/Btop.nix
    ./Modules/Home-Manager/NeoVim.nix
    ./Modules/Home-Manager/Sway.nix
    ./Modules/Home-Manager/Bash.nix
  ];

  home = {
    username = "denis";
    homeDirectory = "/home/denis";
    stateVersion = "26.11";
  };

  programs.home-manager.enable = true;
}
