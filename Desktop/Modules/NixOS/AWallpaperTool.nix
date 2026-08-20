{ config, pkgs, ... }:

let
  awallpapertoolC = pkgs.writeText "awallpapertool.c" ''
    #include <stdio.h>
    #include <stdlib.h>
    #include <string.h>
    #include <unistd.h>

    #define CONFIG_DIR ".config/awallpapertool"
    #define CONFIG_FILE ".config/awallpapertool/config.ini"

    void print_help() {
        printf("\n  \e[1mawallpapertool\e[0m — Native Wallpaper Engine\n\n");
        printf("  \e[36mUsage:\e[0m\n    awallpapertool [command] [args]\n\n");
        printf("  \e[36mCommands:\e[0m\n    set [path]  Set and apply wallpaper\n    start       Start saved wallpaper from config\n    stop        Stop wallpaper\n    help        Show this help\n\n");
    }

    void expand_and_normalize(const char *input, char *output) {
        char *home = getenv("HOME");
        if (strncmp(input, "~/", 2) == 0) snprintf(output, 1024, "%s/%s", home, input + 2);
        else if (strncmp(input, "$HOME/", 6) == 0) snprintf(output, 1024, "%s/%s", home, input + 6);
        else strcpy(output, input);
    }

    void get_wallpaper_from_cfg(char *out, size_t size) {
        char path[1024];
        snprintf(path, sizeof(path), "%s/%s", getenv("HOME"), CONFIG_FILE);
        FILE *f = fopen(path, "r");
        char line[1024];
        while (f && fgets(line, sizeof(line), f)) {
            if (strncmp(line, "wallpaper=", 10) == 0) {
                char *val = line + 10;
                val[strcspn(val, "\r\n")] = 0;
                strcpy(out, val);
                fclose(f);
                return;
            }
        }
        if (f) fclose(f);
        out[0] = '\0';
    }

    void save_wallpaper_to_cfg(const char *full_path) {
        char mkdir_cmd[1024];
        snprintf(mkdir_cmd, sizeof(mkdir_cmd), "mkdir -p %s/%s", getenv("HOME"), CONFIG_DIR);
        system(mkdir_cmd);
        char cfg_path[1024];
        snprintf(cfg_path, sizeof(cfg_path), "%s/%s", getenv("HOME"), CONFIG_FILE);
        FILE *f = fopen(cfg_path, "w");
        if (f) {
            fprintf(f, "wallpaper=%s\n", full_path);
            fclose(f);
        }
    }

    void apply_wallpaper(const char *full_path) {
        system("pkill mpvpaper");
        char cmd[2048];
        snprintf(cmd, sizeof(cmd), "mpvpaper '*' \"%s\" -o \"loop --no-audio\" >/dev/null 2>&1 &", full_path);
        system(cmd);
        printf("Wallpaper applied: %s\n", full_path);
    }

    int main(int argc, char *argv[]) {
        if (argc < 2 || strcmp(argv[1], "help") == 0 || strcmp(argv[1], "--help") == 0) {
            print_help();
            return 0;
        }

        if (strcmp(argv[1], "set") == 0 && argc == 3) {
            char full_path[1024];
            expand_and_normalize(argv[2], full_path);
            save_wallpaper_to_cfg(full_path);
            apply_wallpaper(full_path);
            return 0;
        }

        if (strcmp(argv[1], "start") == 0) {
            char full_path[1024];
            get_wallpaper_from_cfg(full_path, sizeof(full_path));
            if (strlen(full_path) > 0) {
                apply_wallpaper(full_path);
            } else {
                printf("No wallpaper found in config: ~/%s\n", CONFIG_FILE);
            }
            return 0;
        }

        if (strcmp(argv[1], "stop") == 0) {
            system("pkill mpvpaper");
            printf("Wallpaper stopped.\n");
            return 0;
        }

        print_help();
        return 0;
    }
  '';

  awallpapertoolPkg = pkgs.stdenv.mkDerivation {
    pname = "awallpapertool";
    version = "1.2";
    src = ./.;
    buildInputs = [ pkgs.gcc pkgs.mpvpaper ];
    buildCommand = "mkdir -p $out/bin && gcc -O3 ${awallpapertoolC} -o $out/bin/awallpapertool";
  };
in
{
  environment.systemPackages = [ awallpapertoolPkg pkgs.mpvpaper ];
}
