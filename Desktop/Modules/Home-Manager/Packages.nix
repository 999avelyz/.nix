{ inputs, config, pkgs, ... }:

{
  home.packages = with pkgs; [
    # System
    fetch
    playerctl
    rofi
    wl-clipboard
    ddcutil
    gpu-screen-recorder
    firefox
    xwayland-satellite
    nautilus
    glib # gdbus, needed by Noctalia's phone-connect (KDE Connect) plugin
    sshfs # phone-connect device file browsing

    # AI
    claude-code

    # Editor
    zed-editor

    # Social
    equibop
    materialgram

    # Gaming
    heroic
    supertuxkart

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

    # Libraries
    nil
    nixd
    ruff
  ];

  programs.waterfox = {
    enable = true;
    package = inputs.waterfox-flake.packages.${pkgs.stdenv.hostPlatform.system}.default;
    policies.DisableTelemetry = true;
  };

  nixpkgs.config.allowUnfree = true;

  
}
