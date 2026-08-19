{ config, ... }:

{
  services.gvfs.enable = true;
  services.udisks2.enable = true;
  services.printing.enable = true;
  services.gnome.gnome-keyring.enable = true;
  programs.dconf.enable = true;

  services.avahi = {
    enable = true;
    nssmdns4 = true;
    openFirewall = true;
  };

  services.samba-wsdd = {
    enable = true;
    openFirewall = true;
  };
}
