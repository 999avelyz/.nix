{ inputs, config, pkgs, ... }:

{
  imports = [
    inputs.home-manager.nixosModules.default
    inputs.noctalia.nixosModules.default
    ./Modules/NixOS/Steam.nix
    ./Modules/NixOS/FN-Mode.nix
    ./Modules/NixOS/Boot.nix
    ./Modules/NixOS/Limine/Menu-Layout.nix
    ./Modules/NixOS/Cups.nix
    ./Modules/NixOS/Fonts.nix
    ./Modules/NixOS/Home-Manager.nix
    ./Modules/NixOS/Locales.nix
    ./Modules/NixOS/Nautilus.nix
    ./Modules/NixOS/Networking.nix
    ./Modules/NixOS/Niri.nix
    ./Modules/NixOS/Noctalia.nix
    ./Modules/NixOS/AMD.nix
    ./Modules/NixOS/Pipewire.nix
    ./Modules/NixOS/Users.nix
    ./Modules/NixOS/X11.nix
    ./Modules/NixOS/Repositories.nix
    ./Modules/NixOS/KDE-Connect.nix
    ./Drives.nix
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

  nix.settings.experimental-features = [ "nix-command" "flakes" ];
  nixpkgs.config.allowUnfree = true;
  system.stateVersion = "26.05";
}
