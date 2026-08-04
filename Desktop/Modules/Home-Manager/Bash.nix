{ pkgs, config, ... }:

{
  programs.bash = {
    enable = true;

    shellAliases = {
      ".nix-update" = "cd ~/.nix && sudo nix flake update && sudo nixos-rebuild switch --flake ~/.nix#Desktop";
      ".nix-packages" = "nvim ~/.nix/Desktop/Modules/Home-Manager/Packages.nix";
      ".nix-clear" = "sudo nix-collect-garbage -d && sudo nixos-rebuild boot --flake ~/.nix#Desktop";
    };

    initExtra = ''
      PS1='\[\e[38;5;39m\] \[\e[38;5;75m\]~ \[\e[38;5;213m\]''${USER^}\[\e[38;5;75m\] in \[\e[38;5;123m\]\w \[\e[38;5;213m\]➜ \[\e[0m\]'
    '';
  };
}
