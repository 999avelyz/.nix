{ config, pkgs, lib, ... }:

{
  services = {
    displayManager.sddm = {
      enable = false;
      wayland.enable = true;
    };
  };

  security.polkit.enable = true;
}
