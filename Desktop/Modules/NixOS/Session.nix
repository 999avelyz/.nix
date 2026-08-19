{ config, pkgs, lib, ... }:

{
  services = {
    displayManager.sddm = {
      enable = true;
      wayland.enable = true;
    };
  };

  security.polkit.enable = true;
}
