{ config, pkgs, lib, ... }:

let
  cfg = config.boot.loader.limine;
  efi = config.boot.loader.efi;

  # Mirrors nixpkgs' nixos/modules/system/boot/loader/limine/limine.nix
  # install-config JSON, so the patched script below sees the exact same
  # inputs the upstream script would.
  limineInstallConfig = pkgs.writeText "limine-install.json" (
    builtins.toJSON {
      inherit (config.system.nixos) distroName;
      nixPath = config.nix.package;
      efiBootMgrPath = pkgs.efibootmgr;
      liminePath = cfg.package;
      efiMountPoint = efi.efiSysMountPoint;
      fileSystems = config.fileSystems;
      luksDevices = builtins.attrNames config.boot.initrd.luks.devices;
      canTouchEfiVariables = efi.canTouchEfiVariables;
      efiSupport = cfg.efiSupport;
      efiRemovable = cfg.efiInstallAsRemovable;
      secureBoot = cfg.secureBoot;
      biosSupport = cfg.biosSupport;
      biosDevice = cfg.biosDevice;
      partitionIndex = cfg.partitionIndex;
      force = cfg.force;
      enrollConfig = cfg.enrollConfig;
      style = cfg.style;
      resolution = cfg.resolution;
      maxGenerations = if cfg.maxGenerations == null then 0 else cfg.maxGenerations;
      hostArchitecture = pkgs.stdenv.hostPlatform.parsed.cpu;
      timeout = if config.boot.loader.timeout == null then "no" else config.boot.loader.timeout;
      enableEditor = cfg.enableEditor;
      extraConfig = cfg.extraConfig;
      extraEntries = cfg.extraEntries;
      additionalFiles = cfg.additionalFiles;
      validateChecksums = cfg.validateChecksums;
      panicOnChecksumMismatch = cfg.panicOnChecksumMismatch;
    }
  );
in
{
  # Replaces the upstream limine-install.py with a patched copy so the
  # latest NixOS generation shows up as its own top-level entry (instead
  # of nested inside the generations folder), sitting above the
  # `extraEntries` (Windows 11) and above a "NixOS Old Generations" folder
  # holding every older generation. Every other Limine option (secure
  # boot, style, extraEntries, ...) still comes from `boot.loader.limine`
  # untouched.
  #
  # This must be kept in sync by hand with nixpkgs' own limine-install.py
  # if that script changes upstream.
  config = lib.mkIf cfg.enable {
    system.build.installBootLoader = lib.mkForce (
      let
        install = pkgs.replaceVarsWith {
          src = ./limine-install.py;
          isExecutable = true;
          replacements = {
            python3 = pkgs.python3.withPackages (python-packages: [ python-packages.psutil ]);
            configPath = limineInstallConfig;
          };
        };
      in
      pkgs.writeScript "limine-install.sh" ''
        #!${pkgs.runtimeShell}
        set -euo pipefail
        ${install} "$@"
        ${cfg.extraInstallCommands}
      ''
    );
  };
}
