{ config, pkgs, ... }:

let
  ascreentoolC = pkgs.writeText "ascreentool.c" ''
    #include <stdio.h>
    #include <stdlib.h>
    #include <string.h>
    #include <unistd.h>
    #include <time.h>
    #include <sys/stat.h>

    #define CONFIG_DIR ".config/ascreentool"
    #define CONFIG_FILE ".config/ascreentool/config.ini"

    void print_help() {
        printf("\n  \e[1mascreentool\e[0m — Capture & Record for Wayland\n\n");
        printf("  \e[36mUsage:\e[0m\n    ascreentool [command]\n\n");
        printf("  \e[36mCapture:\e[0m\n    region      Capture area\n    output      Capture screen\n    window      Capture active window\n\n");
        printf("  \e[36mRecord:\e[0m\n    record-reg  Record area\n    record-out  Record screen\n    record-win  Record window\n    stop        Stop and save\n\n");
        printf("  \e[36mConfig:\e[0m\n    path [type] [path]  Set folder path\n\n");
    }

    void expand_and_normalize(const char *input, char *output) {
        char *home = getenv("HOME");
        if (strncmp(input, "~/", 2) == 0) snprintf(output, 1024, "%s/%s", home, input + 2);
        else if (strncmp(input, "$HOME/", 6) == 0) snprintf(output, 1024, "%s/%s", home, input + 6);
        else strcpy(output, input);
        size_t len = strlen(output);
        if (len > 1 && output[len - 1] == '/') output[len - 1] = '\0';
    }

    void get_cfg(const char *key, char *out) {
        char path[1024];
        snprintf(path, sizeof(path), "%s/%s", getenv("HOME"), CONFIG_FILE);
        FILE *f = fopen(path, "r");
        char line[1024];
        while (f && fgets(line, sizeof(line), f)) {
            if (strncmp(line, key, strlen(key)) == 0) {
                char *val = strchr(line, '=') + 1;
                val[strcspn(val, "\r\n")] = 0;
                strcpy(out, val); fclose(f); return;
            }
        }
        if (f) fclose(f);
        snprintf(out, 1024, "%s/%s", getenv("HOME"), (strcmp(key, "screenshots") == 0) ? "Pictures" : "Videos");
    }

    void save_cfg(const char *key, const char *val) {
        char s[1024], v[1024], path[1024], full_val[1024];
        expand_and_normalize(val, full_val);
        get_cfg("screenshots", s); get_cfg("videos", v);
        if (strcmp(key, "screenshots") == 0) strcpy(s, full_val); else strcpy(v, full_val);
        char mkdir_cmd[1024];
        snprintf(mkdir_cmd, sizeof(mkdir_cmd), "mkdir -p %s/%s", getenv("HOME"), CONFIG_DIR);
        system(mkdir_cmd);
        snprintf(path, sizeof(path), "%s/%s", getenv("HOME"), CONFIG_FILE);
        FILE *f = fopen(path, "w");
        fprintf(f, "screenshots=%s\n", s); fprintf(f, "videos=%s\n", v); fclose(f);
        printf("Path for %s set to: %s\n", key, (strcmp(key, "screenshots") == 0) ? s : v);
    }

    void get_filename(char *dest, size_t size, const char *key, const char *prefix, const char *ext) {
        char base[1024];
        get_cfg(key, base);
        time_t n = time(NULL); struct tm *t = localtime(&n);
        char *mon[] = {"Jan","Feb","Mar","Apr","May","Jun","Jul","Aug","Sep","Oct","Nov","Dec"};
        snprintf(dest, size, "%s/%s_%02d-%02d_%s_%02d.%s", base, prefix, t->tm_hour, t->tm_min, mon[t->tm_mon], t->tm_mday, ext);
    }

    int main(int argc, char *argv[]) {
        if (argc < 2 || strcmp(argv[1], "help") == 0 || strcmp(argv[1], "--help") == 0) { print_help(); return 0; }
        if (strcmp(argv[1], "path") == 0) {
            if(argc == 4) save_cfg(argv[2], argv[3]);
            else printf("Usage: ascreentool path [screenshots|videos] [path]\n");
            return 0;
        }

        char cmd[2048], fp[1024];
        if (strcmp(argv[1], "region") == 0) { get_filename(fp, sizeof(fp), "screenshots", "RegionScreenshot", "png");
            snprintf(cmd, sizeof(cmd), "grim -g \"$(slurp)\" - | tee \"%s\" | wl-copy --type image/png", fp); system(cmd); }
        else if (strcmp(argv[1], "output") == 0) { get_filename(fp, sizeof(fp), "screenshots", "OutputScreenshot", "png");
            snprintf(cmd, sizeof(cmd), "grim - | tee \"%s\" | wl-copy --type image/png", fp); system(cmd); }
        else if (strcmp(argv[1], "window") == 0) { get_filename(fp, sizeof(fp), "screenshots", "WindowScreenshot", "png");
            snprintf(cmd, sizeof(cmd), "grim -g \"$(swaymsg -t get_tree | jq -r '.. | select(.focused? == true) | .rect | \"\\(.x),\\(.y) \\(.width)x\\(.height)\"')\" - | tee \"%s\" | wl-copy --type image/png", fp);
            int ret = system(cmd); if(ret!=0){ snprintf(cmd, 2048, "grim -g \"$(slurp)\" - | tee \"%s\" | wl-copy --type image/png", fp); system(cmd); } }
        else if (strcmp(argv[1], "record-reg") == 0) { get_filename(fp, sizeof(fp), "videos", "RegionVideo", "mp4");
            FILE *f = fopen("/tmp/as.txt", "w"); fprintf(f, "%s", fp); fclose(f);
            snprintf(cmd, sizeof(cmd), "wf-recorder -g \"$(slurp)\" -f \"%s\" >/dev/null 2>&1 &", fp); system(cmd); }
        else if (strcmp(argv[1], "record-out") == 0) { get_filename(fp, sizeof(fp), "videos", "OutputVideo", "mp4");
            FILE *f = fopen("/tmp/as.txt", "w"); fprintf(f, "%s", fp); fclose(f);
            snprintf(cmd, sizeof(cmd), "wf-recorder -f \"%s\" >/dev/null 2>&1 &", fp); system(cmd); }
        else if (strcmp(argv[1], "record-win") == 0) { get_filename(fp, sizeof(fp), "videos", "WindowVideo", "mp4");
            FILE *f = fopen("/tmp/as.txt", "w"); fprintf(f, "%s", fp); fclose(f);
            snprintf(cmd, sizeof(cmd), "wf-recorder -g \"$(swaymsg -t get_tree | jq -r '.. | select(.focused? == true) | .rect | \"\\(.x),\\(.y) \\(.width)x\\(.height)\"')\" -f \"%s\" >/dev/null 2>&1 &", fp);
            system(cmd); }
        else if (strcmp(argv[1], "stop") == 0) { system("pkill -INT wf-recorder");
            FILE *f = fopen("/tmp/as.txt", "r"); if(f && fgets(fp, 1024, f)){ printf("Saved: %s\n", fp);
            char cpy[2048]; snprintf(cpy, 2048, "echo -n \"%s\" | wl-copy", fp); system(cpy); fclose(f); } }
        else { print_help(); }
        return 0;
    }
  '';

  ascreentoolPkg = pkgs.stdenv.mkDerivation {
    pname = "ascreentool";
    version = "3.6";
    src = ./.;
    buildInputs = [ pkgs.gcc pkgs.grim pkgs.slurp pkgs.wl-clipboard pkgs.wf-recorder pkgs.jq ];
    buildCommand = "mkdir -p $out/bin && gcc -O3 ${ascreentoolC} -o $out/bin/ascreentool";
  };
in
{
  environment.systemPackages = [ ascreentoolPkg pkgs.grim pkgs.slurp pkgs.wl-clipboard pkgs.wf-recorder pkgs.jq ];
}
