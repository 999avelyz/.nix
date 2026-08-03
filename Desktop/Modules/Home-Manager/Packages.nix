{ config, pkgs, ... }:

{
  home.packages = with pkgs; [
    # System
    git
    fetch
    playerctl
    rofi
    wl-clipboard
    xwayland-satellite
    nautilus

    # AI
    claude-code

    # Editor
    neovim
    zed-editor

    # Browser & Social
    firefox
    equibop
    materialgram

    # Gaming
    heroic

    # Media
    feishin

    # VideoThumbnail
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
  ];

  nixpkgs.config.allowUnfree = true;
}
