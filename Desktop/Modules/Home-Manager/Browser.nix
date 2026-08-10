{ pkgs, config, ... }:

{
  xdg.mimeApps = {
    enable = true;
    defaultApplications = {
      "text/html" = "waterfox.desktop";
      "x-scheme-handler/http" = "waterfox.desktop";
      "x-scheme-handler/https" = "waterfox.desktop";
      "x-scheme-handler/about" = "waterfox.desktop";
      "x-scheme-handler/unknown" = "waterfox.desktop";
      "x-scheme-handler/acmanager" = "content-manager-url-handler.desktop";
      "x-scheme-handler/acstuff" = "content-manager-url-handler.desktop";
      "x-scheme-handler/nohesi" = "content-manager-url-handler.desktop";
    };
  };

  home.sessionVariables = {
    BROWSER = "waterfox";
  };
}
