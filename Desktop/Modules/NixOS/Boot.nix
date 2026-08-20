{ inputs, config, pkgs, lib, ... }:

let
  windowsLoaderEntry = pkgs.writeText "windows-loader-entry.conf" ''
    title    Windows 11
    sort-key 0-windows
    efi      /EFI/Microsoft/Boot/bootmgfw.efi
  '';
in
{
  nixpkgs.overlays = [
    inputs.nix-cachyos-kernel.overlays.pinned
  ];

  boot = {
    loader = {
      systemd-boot = {
        enable = lib.mkForce false;
        consoleMode = "auto";
      };
      efi = {
        canTouchEfiVariables = true;
        efiSysMountPoint = "/boot/efi";
      };
      timeout = 5;
    };

    lanzaboote = {
      enable = true;
      pkiBundle = "/var/lib/sbctl";
      settings = {
        default = "nixos-*";
        auto-entries = false;
      };
    };

    kernelParams = [
      "video=HDMI-A-1:1920x1080@144"
      "usbhid.quirks=0x1021:0x1888:0x8"
      "usbhid.mousepoll=1"
    ];

    kernelPackages = pkgs.cachyosKernels.linuxPackages-cachyos-latest-zen4;

    kernelModules = [ "v4l2loopback" "i2c-dev" "hid_apple" "hid-playstation" "xpad" "wireguard" ];

    extraModulePackages = with config.boot.kernelPackages; [
      v4l2loopback
    ];

    extraModprobeConfig = ''
      options v4l2loopback devices=1 video_nr=1 close_delay=0 card_label="OBS Virtual Camera" exclusive_caps=1
      options hid_apple fnmode=2
    '';

    kernel.sysctl = {
      "vm.max_map_count" = 2147483642;
    };
  };

  systemd.tmpfiles.rules = [
    "d /boot/efi/loader/entries 0755 root root -"
    "C+ /boot/efi/loader/entries/windows.conf 0644 root root - ${windowsLoaderEntry}"
  ];

  environment.systemPackages = [ pkgs.sbctl ];

  hardware.new-lg4ff.enable = true;

  hardware.i2c.enable = true;

  services.scx = {
    enable = true;
    scheduler = "scx_lavd";
    extraArgs = [ "--performance" "--pinned-slice-us" "500" ];
  };

  services.udev.extraRules = ''
    KERNEL=="i2c-[0-9]*", GROUP="i2c", MODE="0660"
  '';

  system.activationScripts.hidAppleFnmode = ''
    if [ -e /sys/module/hid_apple/parameters/fnmode ]; then
      echo 2 > /sys/module/hid_apple/parameters/fnmode
    fi
  '';
}
