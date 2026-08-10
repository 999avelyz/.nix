{ pkgs, config, ... }:

{
  programs.bash = {
    enable = true;

    shellAliases = {
      ".nix-packages" = "nvim ~/.nix/Desktop/Modules/Home-Manager/Packages.nix";
      ".nix-collect" = "sudo nix-collect-garbage -d";
      ".noctalia-update" = "rm -rf ~/.nix/Desktop/Modules/Home-Manager/Noctalia/Configuration.toml; noctalia config export full >> ~/.nix/Desktop/Modules/Home-Manager/Noctalia/Configuration.toml";
    };

    initExtra = ''
      .nix-upgrade() {
        local current_dir=$(pwd)
        cd ~/.nix
        sudo nix flake update
        sudo nixos-rebuild switch --flake ~/.nix#Desktop
        cd "$current_dir"
      }

      .nix-reload() {
        local current_dir=$(pwd)
        cd ~/.nix
        git add .
        sudo nixos-rebuild switch --flake ~/.nix#Desktop
        cd "$current_dir"
      }

      .nix-push() {
        local msg="''${1:-latest}"
        (cd ~/.nix && git add . && git commit -m "$msg" && git push)
      }

      PS1='\[\e[38;5;39m\] \[\e[38;5;75m\]~ \[\e[38;5;213m\]''${USER^}\[\e[38;5;75m\] in \[\e[38;5;123m\]\w \[\e[38;5;213m\]➜ \[\e[0m\]'
    '';
  };
}
