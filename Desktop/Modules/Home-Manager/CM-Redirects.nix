{ pkgs, config, ... }:

let
  cmUrlHandler = pkgs.writeShellScriptBin "cm-url-handler" ''
    URL="$1"

    if pgrep -f -i "AssettoCorsa\.exe" > /dev/null || pgrep -f -i "ORIG\.exe" > /dev/null; then
        pkill -f -i "AssettoCorsa\.exe" || true
        pkill -f -i "ORIG\.exe" || true
        sleep 2
    fi

    ${pkgs.steam}/bin/steam -applaunch 244210 "$URL" &
  '';
in
{
  xdg.desktopEntries."content-manager-url-handler" = {
    name = "Content Manager";
    exec = "${cmUrlHandler}/bin/cm-url-handler %u";
    type = "Application";
    terminal = false;
    noDisplay = true;
    mimeType = [
      "x-scheme-handler/acmanager"
      "x-scheme-handler/acstuff"
      "x-scheme-handler/nohesi"
    ];
  };

  home.packages = with pkgs; [
    cmUrlHandler
  ];
}
