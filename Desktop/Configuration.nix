{ inputs, config, pkgs, ... }:

{
  imports = [
    inputs.home-manager.nixosModules.default
    inputs.lanzaboote.nixosModules.lanzaboote

    ./Drives.nix
    ./Modules/NixOS/AMD.nix
    ./Modules/NixOS/Boot.nix
    ./Modules/NixOS/Fonts.nix
    ./Modules/NixOS/Handbrake.nix
    ./Modules/NixOS/Home-Manager.nix
    ./Modules/NixOS/Locales.nix
    ./Modules/NixOS/Networking.nix
    ./Modules/NixOS/Packages.nix
    ./Modules/NixOS/Pipewire.nix
    ./Modules/NixOS/Polkit.nix
    ./Modules/NixOS/Portal.nix
    ./Modules/NixOS/Repositories.nix
    ./Modules/NixOS/Screenshooter.nix
    ./Modules/NixOS/Services.nix
    ./Modules/NixOS/Session.nix
    ./Modules/NixOS/Steam.nix
    ./Modules/NixOS/Tailscale.nix
    ./Modules/NixOS/Users.nix
    ./Modules/NixOS/X11.nix
    ./Modules/NixOS/Zram.nix
  ];

  fileSystems."/mnt/NVME" = {
    device = "/dev/disk/by-label/NVME";
    fsType = "btrfs";
    options = [
      "nofail"
      "noatime"
      "exec"
      "x-gvfs-show"
      "x-gvfs-name=NVME"
    ];
  };

  fileSystems."/mnt/SSD" = {
    device = "/dev/disk/by-label/SSD";
    fsType = "btrfs";
    options = [
      "nofail"
      "noatime"
      "exec"
      "x-gvfs-show"
      "x-gvfs-name=SSD"
    ];
  };

  programs.sway.enable = true;

  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  nixpkgs.config.allowUnfree = true;

  system.stateVersion = "26.05";
}
