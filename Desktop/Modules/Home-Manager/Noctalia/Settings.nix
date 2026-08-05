{ config, ... }:

{
  programs.noctalia = {
    enable = true;
    settings = ./Configuration.toml;
  };
}
