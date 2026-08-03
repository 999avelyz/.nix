{ inputs, pkgs, ... }:

{
  fonts.packages = with pkgs; [
    inputs.sf-fonts.packages.${pkgs.system}.default
    noto-fonts
    noto-fonts-cjk-sans
    noto-fonts-cjk-serif
    noto-fonts-color-emoji
    corefonts
    liberation_ttf
    dejavu_fonts
    font-awesome
    material-icons
    nerd-fonts.symbols-only
    cascadia-code
  ];

  fonts.fontconfig.defaultFonts = {
    serif = [ "SF Pro Text" ];
    sansSerif = [ "SF Pro Text" ];
    monospace = [ "SFMono Nerd Font Mono SemiBold" ];
    emoji = [ "Noto Color Emoji" ];
  };

  fonts.fontconfig.localConf = ''
    <match target="pattern">
      <test name="family"><string>SF Pro Text</string></test>
      <edit name="weight" mode="assign"><const>semibold</const></edit>
    </match>
  '';
}
