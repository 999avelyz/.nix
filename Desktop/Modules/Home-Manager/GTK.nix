{ pkgs, ... }:

{
  gtk = {
    enable = true;

    theme = {
      name = "adw-gtk3-dark";
      package = pkgs.adw-gtk3;
    };

    iconTheme = {
      name = "Papirus";
      package = pkgs.papirus-icon-theme;
    };

    cursorTheme = {
      name = "GoogleDot-White";
      package = pkgs.google-cursor;
      size = 24;
    };

    font = {
      name = "SF Pro Text";
      size = 11;
    };
  };
}
