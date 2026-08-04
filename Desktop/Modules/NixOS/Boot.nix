{ inputs, config, pkgs, ... }:

{
  nixpkgs.overlays = [
    inputs.nix-cachyos-kernel.overlays.pinned
  ];

  boot = {
    loader = {
      efi = {
        canTouchEfiVariables = true;
        efiSysMountPoint = "/boot/efi";
      };
      limine = {
        enable = true;
        efiSupport = true;
        biosSupport = false;
        extraEntries = ''
          /Windows 11
              protocol: efi_chainload
              image_path: uuid(D80F-4C1B):/EFI/Microsoft/Boot/bootmgfw.efi
        '';
        secureBoot = {
          enable = true;
          autoGenerateKeys = true;
          autoEnrollKeys.enable = true;
        };
        style = {
          wallpapers = [ ];
          graphicalTerminal.background = "00000000";
        };
      };
    };

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
