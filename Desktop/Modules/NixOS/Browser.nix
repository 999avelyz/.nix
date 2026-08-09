{ pkgs, ... }:

{
  # Steam su NixOS gira dentro un sandbox FHS (pressure-vessel), quindi di
  # default NON vede xdg-open del sistema. Senza xdg-open, winebrowser.exe
  # (il componente di Wine/Proton che intercetta ShellExecute("open", url))
  # non ha modo di inoltrare il link al browser Linux: e' esattamente il
  # motivo per cui i tasti/link in Assetto Corsa, Content Manager, ACStuff
  # Launcher, no hesi ecc. non fanno nulla quando li clicchi.
  programs.steam.extraPackages = with pkgs; [
    xdg-utils
  ];

  # xdg-utils disponibile anche a livello di sistema, utile per eventuali
  # prefissi Wine/Proton lanciati fuori da Steam (Lutris, Bottles, script
  # manuali, ecc.).
  environment.systemPackages = with pkgs; [
    xdg-utils
  ];

  # Proton/Wine possono passare dal portal freedesktop (org.freedesktop.
  # portal.OpenURI) per aprire i link invece che chiamare xdg-open a mano:
  # senza un backend attivo per quell'interfaccia la chiamata fallisce in
  # silenzio. Qui ci limitiamo ad abilitare il portale; il backend per Niri
  # e' gia' assegnato in Niri.nix (vedi la riga OpenURI aggiunta li').
  xdg.portal.enable = true;
}
