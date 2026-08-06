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
        # Lanzaboote reads this as the default for its own generated
        # loader.conf. systemd-boot only exposes text-mode "console-mode"
        # (0/1/2/auto/max/keep), not an explicit WxH@Hz. "max" grabbed a
        # non-16:9 GOP mode (letterboxed menu); "keep" inherited whatever
        # non-16:9 mode firmware happened to leave active. "auto" asks
        # firmware to pick a mode matching the actual display heuristically,
        # which is the closest to "declare 16:9" this option supports. There
        # is no refresh-rate control at this stage regardless.
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
        # Glob matching every "nixos-*" entry; among matches the loader
        # picks the newest generation (BLS sorts same sort-key entries by
        # decreasing version). Confirmed working: LoaderEntrySelected already
        # reports the latest generation after a hands-off boot.
        default = "nixos-*";
        # Disable systemd-boot's own auto-detection (Windows/macOS/EFI shell
        # scan) so it stops adding a second "Windows 11 (auto-windows)" entry
        # duplicating our static windows.conf below. Does not affect
        # "Reboot Into Firmware Interface" (that's auto-firmware, untouched).
        auto-entries = false;
      };
    };

    # Actual 1920x1080@144 (falls back to whatever the EDID's preferred mode
    # is, e.g. 60Hz, if 144 isn't reported) applies from kernel/KMS handoff
    # onward (early console, plymouth, greeter) — the connected output is
    # HDMI-A-1 on card1.
    #
    # usbhid.quirks: the ODDOR handbrake (ZSC, 1021:1888) enumerates over USB
    # but usbhid never binds a driver to it — no hid-generic line, no
    # /dev/input/jsX, no error in dmesg either, log just goes silent after
    # the device strings. NOGET (0x8) skips the GET_REPORT/SET_IDLE init
    # calls that cheap clone HID firmware like this tends to hang on.
    #
    # usbhid.mousepoll: forces a 1ms interrupt interval (1000Hz) on HID mice.
    # The default 0 means "honor the endpoint's own bInterval", and the
    # Logitech PRO 2 LIGHTSPEED receiver (046d:c54d) advertises bInterval=1,
    # which on a high-speed bus is one 125us microframe — 8000Hz. Windows
    # absorbs that fine, but here every report walks usbhid -> hid-logitech-dj
    # -> evdev -> libinput -> niri -> Xwayland -> Wine -> the game's input
    # thread, so a fast flick puts ~8000 wakeups/sec through the compositor
    # main loop that also has to present frames. That showed up as frame-pacing
    # hitches in Dead by Daylight in every window mode (it's the input path,
    # not the display path). 1000Hz is past the point of returns anyway.
    kernelParams = [
      "video=HDMI-A-1:1920x1080@144"
      "usbhid.quirks=0x1021:0x1888:0x8"
      "usbhid.mousepoll=1"
    ];

    kernelPackages = pkgs.cachyosKernels.linuxPackages-cachyos-latest-zen4;

    kernelModules = [ "v4l2loopback" "i2c-dev" ];

    extraModulePackages = with config.boot.kernelPackages; [
      v4l2loopback
    ];
    extraModprobeConfig = ''
      options v4l2loopback devices=1 video_nr=1 close_delay=0 card_label="OBS Virtual Camera" exclusive_caps=1
    '';

    kernel.sysctl = {
      "vm.max_map_count" = 2147483642;
    };
  };

  # Static BLS entry that replaces systemd-boot's auto-detected "Windows Boot
  # Manager" with our own sort-key (so it lists above the "lanza"-keyed NixOS
  # entries). lzbt only garbage-collects EFI/nixos and nixos-* files under
  # EFI/Linux, so it never touches loader/entries — safe across rebuilds.
  systemd.tmpfiles.rules = [
    "d /boot/efi/loader/entries 0755 root root -"
    "C+ /boot/efi/loader/entries/windows.conf 0644 root root - ${windowsLoaderEntry}"
  ];

  environment.systemPackages = [ pkgs.sbctl ];

  hardware.new-lg4ff.enable = true;

  hardware.i2c.enable = true;

  programs.appimage = {
    enable = true;
    binfmt = true;
  };

  services.scx = {
    enable = true;
    scheduler = "scx_lavd";
    extraArgs = [ "--performance" "--pinned-slice-us" "500" ];
  };

  services.udev.extraRules = ''
          KERNEL=="i2c-[0-9]*", GROUP="i2c", MODE="0660"
    '';
}
