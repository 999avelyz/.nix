{ pkgs, ... }:

{
  # Registra Waterfox come gestore di default per http(s)/html, esattamente
  # come il "default browser" di Windows. Questo file (~/.config/mimeapps.list)
  # e' cio' che xdg-open (usato da winebrowser.exe dentro Wine/Proton) legge
  # per decidere quale browser aprire quando un'app clicca un link.
  xdg.mimeApps = {
    enable = true;
    defaultApplications = {
      "text/html" = "waterfox.desktop";
      "x-scheme-handler/http" = "waterfox.desktop";
      "x-scheme-handler/https" = "waterfox.desktop";
      "x-scheme-handler/about" = "waterfox.desktop";
      "x-scheme-handler/unknown" = "waterfox.desktop";
    };
  };

  # Molte app (anche alcune sotto Wine) rispettano $BROWSER come fallback.
  home.sessionVariables = {
    BROWSER = "waterfox";
  };

  # --- Direzione opposta: browser -> Content Manager ---
  # I link "acmanager://..." (es. quelli che acstuff.club/CM usano per
  # condividere setup, skin, patch CSP ecc.) sono un protocollo custom che
  # su Windows Content Manager registra da solo. Su Linux nessuno lo
  # registra di default, quindi cliccarli nel browser non fa nulla.
  #
  # NOTA: qui rilanciamo Content Manager tramite Steam (stesso metodo
  # usato dagli script della community, es. sihawido/assettocorsa-linux-
  # setup). Il limite noto e' che funziona solo se Assetto Corsa/Content
  # Manager NON e' gia' aperto: se lo e', Steam risponde "game already
  # running" e non inoltra il link. Un tentativo di bypassare Steam con
  # protontricks-launch per gestire anche quel caso NON funziona in modo
  # affidabile: protontricks-launch esegue l'exe fuori dal runtime
  # container che Steam fornisce normalmente a Proton (le librerie che
  # Proton impacchetta per l'ambiente grafico/COM), quindi Content Manager
  # puo' andare in crash silenzioso all'avvio invece di partire o inoltrare
  # il link. Meglio accettare il limite noto che avere qualcosa di rotto.
  #
  # 244210 e' l'AppID Steam di Assetto Corsa: se lo hai aggiunto come gioco
  # non-Steam, o se il tuo AppID e' diverso, sostituiscilo qui sotto.
  xdg.desktopEntries."content-manager-url-handler" = {
    name = "Content Manager (gestore link)";
    exec = "steam -applaunch 244210 %u";
    type = "Application";
    terminal = false;
    noDisplay = true;
    mimeType = [ "x-scheme-handler/acmanager" ];
  };

  xdg.mimeApps.defaultApplications."x-scheme-handler/acmanager" =
    "content-manager-url-handler.desktop";
}
