{ config, pkgs, ... }:

{
  home.packages = with pkgs; [
    # System
    fetch
    playerctl
    rofi
    wl-clipboard
    btop
    ddcutil
    xwayland-satellite
    nautilus

    # AI
    claude-code

    # Editor
    neovim
    zed-editor

    # Social
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

  programs.waterfox = {
    enable = true;
    policies.DisableTelemetry = true;
  };

  nixpkgs.config.allowUnfree = true;
}
