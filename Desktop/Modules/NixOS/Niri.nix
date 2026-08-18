{ config, pkgs, lib, ... }:

{
  services = {
    displayManager.sddm = {
      enable = true;
      wayland.enable = true;
    };
    desktopManager.plasma6 = {
      enable = true;
    };
    gnome.gnome-keyring.enable = true;
  };

  programs.niri.enable = true;

  services.displayManager.defaultSession = lib.mkForce null;

  security.polkit.enable = true;
}
