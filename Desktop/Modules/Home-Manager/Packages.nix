{ inputs, config, pkgs, ... }:

{
  home.packages = with pkgs; [
    # System
    fetch
    kdePackages.filelight
    firefox
    nautilus

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
    lunar-client

    # Media
    feishin
  ];

  programs.waterfox = {
    enable = true;
    package = inputs.waterfox-flake.packages.${pkgs.stdenv.hostPlatform.system}.default;
    policies.DisableTelemetry = true;
  };

  nixpkgs.config.allowUnfree = true;
}
