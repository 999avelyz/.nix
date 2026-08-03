{ pkgs, config, ... }:

{
  home.packages = [ pkgs.gh pkgs.git ];
  programs.git = {
    enable = true;
    settings = {
      user = {
        name = "999Avelyzzzz";
        email = "252095466+999Avelyzzzz@users.noreply.github.com";
      };
      credential."https://github.com".helper = "!${pkgs.gh}/bin/gh auth git-credential";
      credential."https://gist.github.com".helper = "!${pkgs.gh}/bin/gh auth git-credential";
    };
  };
}
