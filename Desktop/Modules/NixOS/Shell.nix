{ config, pkgs, ... }:

let
  shellC = pkgs.writeText "shell.c" ''
    #include <gtk/gtk.h>
    #include <gtk4-layer-shell.h>
    #include <time.h>
    #include <glib.h>
    #include <dirent.h>

    typedef struct {
        char *name;
        char *exec;
    } AppEntry;

    GPtrArray *apps = NULL;
    GtkWidget *launcher_window = NULL;
    GtkWidget *list_box = NULL;
    GtkWidget *search_entry = NULL;

    static gboolean update_clock(gpointer label) {
        time_t rawtime;
        struct tm *timeinfo;
        char buffer[80];

        time(&rawtime);
        timeinfo = localtime(&rawtime);
        strftime(buffer, sizeof(buffer), "%Y-%m-%d %H:%M:%S", timeinfo);

        gtk_label_set_text(GTK_LABEL(label), buffer);
        return G_SOURCE_CONTINUE;
    }

    void load_applications() {
        if (apps) return;
        apps = g_ptr_array_new_with_free_func((GDestroyNotify)g_free);

        const char *dirs[] = {
            "/usr/share/applications",
            "/run/current-system/sw/share/applications",
            NULL
        };

        for (int i = 0; dirs[i] != NULL; i++) {
            DIR *d = opendir(dirs[i]);
            if (!d) continue;
            struct dirent *dir;
            while ((dir = readdir(d)) != NULL) {
                if (g_str_has_suffix(dir->d_name, ".desktop")) {
                    char path[1024];
                    snprintf(path, sizeof(path), "%s/%s", dirs[i], dir->d_name);
                    
                    GKeyFile *key_file = g_key_file_new();
                    if (g_key_file_load_from_file(key_file, path, G_KEY_FILE_NONE, NULL)) {
                        if (g_key_file_get_boolean(key_file, "Desktop Entry", "NoDisplay", NULL)) {
                            g_key_file_free(key_file);
                            continue;
                        }
                        char *name = g_key_file_get_string(key_file, "Desktop Entry", "Name", NULL);
                        char *exec = g_key_file_get_string(key_file, "Desktop Entry", "Exec", NULL);
                        
                        if (name && exec) {
                            AppEntry *app = g_malloc(sizeof(AppEntry));
                            app->name = g_strdup(name);
                            char *p = strstr(exec, " %");
                            if (p) *p = '\0';
                            app->exec = g_strdup(exec);
                            g_ptr_array_add(apps, app);
                        }
                        g_free(name);
                        g_free(exec);
                    }
                    g_key_file_free(key_file);
                }
            }
            closedir(d);
        }
    }

    void on_app_activated(GtkListBox *box, GtkListBoxRow *row, gpointer user_data) {
        int index = gtk_list_box_row_get_index(row);
        AppEntry *app = g_ptr_array_index(apps, index);
        if (app && app->exec) {
            char cmd[2048];
            snprintf(cmd, sizeof(cmd), "%s >/dev/null 2>&1 &", app->exec);
            system(cmd);
            gtk_window_destroy(GTK_WINDOW(launcher_window));
            launcher_window = NULL;
        }
    }

    void populate_list(const char *filter) {
        GtkWidget *child = gtk_widget_get_first_child(list_box);
        while (child != NULL) {
            GtkWidget *next = gtk_widget_get_next_sibling(child);
            gtk_list_box_remove(GTK_LIST_BOX(list_box), child);
            child = next;
        }

        for (guint i = 0; i < apps->len; i++) {
            AppEntry *app = g_ptr_array_index(apps, i);
            if (!filter || filter[0] == '\0' || g_str_match_string(filter, app->name, TRUE)) {
                GtkWidget *row_label = gtk_label_new(app->name);
                gtk_widget_set_halign(row_label, GTK_ALIGN_START);
                gtk_widget_set_margin_start(row_label, 10);
                gtk_widget_set_margin_top(row_label, 8);
                gtk_widget_set_margin_bottom(row_label, 8);
                gtk_list_box_append(GTK_LIST_BOX(list_box), row_label);
            }
        }
    }

    static void on_search_changed(GtkSearchEntry *entry, gpointer user_data) {
        const char *text = gtk_editable_get_text(GTK_EDITABLE(entry));
        populate_list(text);
    }

    static void toggle_launcher(GtkButton *btn, gpointer user_data) {
        if (launcher_window) {
            gtk_window_destroy(GTK_WINDOW(launcher_window));
            launcher_window = NULL;
            return;
        }

        load_applications();

        launcher_window = gtk_window_new();
        gtk_window_set_title(GTK_WINDOW(launcher_window), "App Launcher");
        gtk_window_set_default_size(GTK_WINDOW(launcher_window), 400, 500);
        gtk_window_set_decorated(GTK_WINDOW(launcher_window), FALSE);

        gtk_layer_init_for_window(GTK_WINDOW(launcher_window));
        gtk_layer_set_layer(GTK_WINDOW(launcher_window), GTK_LAYER_SHELL_LAYER_OVERLAY);
        gtk_layer_set_keyboard_mode(GTK_WINDOW(launcher_window), GTK_LAYER_SHELL_KEYBOARD_MODE_ON_DEMAND);
        /* No edges are anchored, so the compositor floats this surface centered on the output */

        GtkWidget *box = gtk_box_new(GTK_ORIENTATION_VERTICAL, 10);
        gtk_widget_set_margin_start(box, 15);
        gtk_widget_set_margin_end(box, 15);
        gtk_widget_set_margin_top(box, 15);
        gtk_widget_set_margin_bottom(box, 15);

        search_entry = gtk_search_entry_new();
        gtk_widget_set_vexpand(search_entry, FALSE);
        g_signal_connect(search_entry, "search-changed", G_CALLBACK(on_search_changed), NULL);
        gtk_box_append(GTK_BOX(box), search_entry);

        GtkWidget *scrolled = gtk_scrolled_window_new();
        gtk_widget_set_vexpand(scrolled, TRUE);
        
        list_box = gtk_list_box_new();
        g_signal_connect(list_box, "row-activated", G_CALLBACK(on_app_activated), NULL);
        gtk_scrolled_window_set_child(GTK_SCROLLED_WINDOW(scrolled), list_box);
        gtk_box_append(GTK_BOX(box), scrolled);

        gtk_window_set_child(GTK_WINDOW(launcher_window), box);
        populate_list(NULL);
        
        gtk_window_present(GTK_WINDOW(launcher_window));
    }

    static void activate(GtkApplication *app, gpointer user_data) {
        GtkWidget *window = gtk_application_window_new(app);
        
        gtk_layer_init_for_window(GTK_WINDOW(window));
        gtk_layer_set_layer(GTK_WINDOW(window), GTK_LAYER_SHELL_LAYER_TOP);
        gtk_layer_set_anchor(GTK_WINDOW(window), GTK_LAYER_SHELL_EDGE_TOP, TRUE);
        gtk_layer_set_anchor(GTK_WINDOW(window), GTK_LAYER_SHELL_EDGE_LEFT, TRUE);
        gtk_layer_set_anchor(GTK_WINDOW(window), GTK_LAYER_SHELL_EDGE_RIGHT, TRUE);
        gtk_layer_auto_exclusive_zone_enable(GTK_WINDOW(window));

        GtkWidget *bar_box = gtk_box_new(GTK_ORIENTATION_HORIZONTAL, 10);
        gtk_widget_set_margin_start(bar_box, 15);
        gtk_widget_set_margin_end(bar_box, 15);
        gtk_widget_set_margin_top(bar_box, 5);
        gtk_widget_set_margin_bottom(bar_box, 5);

        GtkWidget *launcher_btn = gtk_button_new_with_label(" Apps");
        g_signal_connect(launcher_btn, "clicked", G_CALLBACK(toggle_launcher), NULL);
        gtk_box_append(GTK_BOX(bar_box), launcher_btn);

        GtkWidget *spacer = gtk_box_new(GTK_ORIENTATION_HORIZONTAL, 0);
        gtk_widget_set_hexpand(spacer, TRUE);
        gtk_box_append(GTK_BOX(bar_box), spacer);

        GtkWidget *clock_label = gtk_label_new("");
        gtk_box_append(GTK_BOX(bar_box), clock_label);
        g_timeout_add_seconds(1, update_clock, clock_label);

        gtk_window_set_child(GTK_WINDOW(window), bar_box);
        gtk_window_present(GTK_WINDOW(window));
    }

    int main(int argc, char **argv) {
        GtkApplication *app = gtk_application_new("com.denis.shell", G_APPLICATION_DEFAULT_FLAGS);
        g_signal_connect(app, "activate", G_CALLBACK(activate), NULL);
        int status = g_application_run(G_APPLICATION(app), argc, argv);
        g_object_unref(app);
        return status;
    }
  '';

  shellPkg = pkgs.stdenv.mkDerivation {
    pname = "shell";
    version = "1.0";
    dontUnpack = true;
    
    buildInputs = [ 
      pkgs.gtk4.dev 
      pkgs.gtk4-layer-shell.dev 
      pkgs.glib.dev 
      pkgs.pango.dev 
      pkgs.harfbuzz.dev 
      pkgs.cairo.dev 
      pkgs.fribidi.dev 
      pkgs.gdk-pixbuf.dev 
      pkgs.vulkan-loader.dev 
      pkgs.vulkan-headers 
      pkgs.graphene.dev
    ];
    nativeBuildInputs = [ pkgs.pkg-config ];

    buildPhase = ''
      cp ${shellC} shell.c
      
      # Sfruttiamo l'hook automatico di pkg-config fornito da nativeBuildInputs
      gcc shell.c -o shell $(pkg-config --cflags --libs gtk4 gtk4-layer-shell-0 glib-2.0) -O3
    '';

    installPhase = ''
      mkdir -p $out/bin
      cp shell $out/bin/shell
    '';
  };
in
{
  environment.systemPackages = [ shellPkg pkgs.gtk4 pkgs.gtk4-layer-shell ];
}
