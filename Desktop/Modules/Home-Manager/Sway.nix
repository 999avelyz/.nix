{ config, lib, pkgs, ... }:

{
  wayland.windowManager.sway = {
    enable = true;
    systemd.enable = true;

    config = rec {
      modifier = "Mod4";
      terminal = "kitty";
      menu = "rofi -show drun";

      input = {
        "type:pointer" = {
          accel_profile = "flat";
          pointer_accel = "-0.7";
        };
      };

      floating = {
        modifier = "${modifier} normal";
      };

      keybindings = lib.mkOptionDefault {
        "${modifier}+t" = "exec ${terminal}";
        "${modifier}+c" = "kill";
        "${modifier}+r" = "exec ${menu}";
        "${modifier}+a" = "reload";
        "${modifier}+l" = "exec swaynag -t warning -m 'You pressed the exit shortcut. Do you really want to exit sway? This will end your Wayland session.' -B 'Yes, exit sway' 'swaymsg exit'";

        "${modifier}+Prior" = "exec playerctl next";
        "${modifier}+Next" = "exec playerctl previous";
        "${modifier}+Home" = "exec playerctl play-pause";
        "${modifier}+Delete" = "exec playerctl play-pause";

        "${modifier}+Left" = "focus left";
        "${modifier}+Down" = "focus down";
        "${modifier}+Up" = "focus up";
        "${modifier}+Right" = "focus right";

        "${modifier}+Shift+Left" = "move left";
        "${modifier}+Shift+Down" = "move down";
        "${modifier}+Shift+Up" = "move up";
        "${modifier}+Shift+Right" = "move right";

        "${modifier}+1" = "workspace number 1";
        "${modifier}+2" = "workspace number 2";
        "${modifier}+3" = "workspace number 3";
        "${modifier}+4" = "workspace number 4";
        "${modifier}+5" = "workspace number 5";
        "${modifier}+6" = "workspace number 6";
        "${modifier}+7" = "workspace number 7";
        "${modifier}+8" = "workspace number 8";
        "${modifier}+9" = "workspace number 9";
        "${modifier}+0" = "workspace number 10";

        "${modifier}+Ctrl+1" = "move container to workspace number 1";
        "${modifier}+Ctrl+2" = "move container to workspace number 2";
        "${modifier}+Ctrl+3" = "move container to workspace number 3";
        "${modifier}+Ctrl+4" = "move container to workspace number 4";
        "${modifier}+Ctrl+5" = "move container to workspace number 5";
        "${modifier}+Ctrl+6" = "move container to workspace number 6";
        "${modifier}+Ctrl+7" = "move container to workspace number 7";
        "${modifier}+Ctrl+8" = "move container to workspace number 8";
        "${modifier}+Ctrl+9" = "move container to workspace number 9";
        "${modifier}+Ctrl+0" = "move container to workspace number 10";

        "${modifier}+b" = "splith";
        "${modifier}+v" = "splitv";

        "${modifier}+f" = "fullscreen";
        "${modifier}+space" = "floating toggle";

        "${modifier}+Return" = "mode resize";

        "Print" = "exec grim ~/a.png";
      };

      modes = {
        resize = {
          "Left" = "resize shrink width 10px";
          "Down" = "resize grow height 10px";
          "Up" = "resize shrink height 10px";
          "Right" = "resize grow width 10px";

          "Return" = "mode default";
          "Escape" = "mode default";
        };
      };

      bars = [
        {
          position = "top";
          statusCommand = "while date +'%Y-%m-%d %X'; do sleep 1; done";
          colors = {
            statusline = "#ffffff";
            background = "#323232";
            inactiveWorkspace = {
              border = "#32323200";
              background = "#32323200";
              text = "#5c5c5c";
            };
          };
        }
      ];
    };

    # extraConfig viene unito alla fine del file generato, ottimo per costrutti speciali o complessi
    extraConfig = ''
      exec systemctl --user import-environment WAYLAND_DISPLAY XDG_CURRENT_DESKTOP
      exec dbus-update-activation-environment --systemd WAYLAND_DISPLAY XDG_CURRENT_DESKTOP=sway
      exec ${pkgs.polkit_gnome}/libexec/polkit-gnome-authentication-agent-1

      bindsym --locked XF86AudioMute exec pactl set-sink-mute \@DEFAULT_SINK@ toggle
      bindsym --locked XF86AudioLowerVolume exec pactl set-sink-volume \@DEFAULT_SINK@ -5%
      bindsym --locked XF86AudioRaiseVolume exec pactl set-sink-volume \@DEFAULT_SINK@ +5%

      bindsym --locked XF86MonBrightnessDown exec brightnessctl set 5%-
      bindsym --locked XF86MonBrightnessUp exec brightnessctl set 5%+

    '';
  };
}
