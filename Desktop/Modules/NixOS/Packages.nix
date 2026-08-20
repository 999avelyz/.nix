{ inputs, config, pkgs, ... }:

{

  environment.systemPackages = with pkgs; [
    xdg-utils
    slurp
    grim
    cloudflared
    wl-clipboard
    ddcutil
    glib
    jstest-gtk
    evtest
    gnome-disk-utility
    dualsensectl
    sshfs
    playerctl
    rofi
    google-cursor
    xdg-desktop-portal-wlr
    ffmpeg
    ffmpegthumbnailer
    mpvpaper
    mpv
    libwebp
    libjxl
    librsvg
    gst_all_1.gst-plugins-good
    gst_all_1.gst-plugins-bad
    gst_all_1.gst-plugins-ugly
    gst_all_1.gst-libav
    nil
    nixd
    ruff
  ];

  programs.appimage = {
    enable = true;
    binfmt = true;
  };

  programs.kdeconnect.enable = true;
}
