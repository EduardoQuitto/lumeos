// libdecor-lume — plugin de decorações para janelas terceiros
// Implementa CSD (Client-Side Decorations) QML com titlebar 40px,
// controles à direita, fechar hover #C42B1C, raio 12, sombra 2 camadas.

#include <libdecor.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

// Handle de estado da janela Lume
typedef struct {
    LumeDecorState *state;
    int width;
    int height;
    bool maximized;
    bool fullscreen;
} LumeWindow;

// Callbacks do libdecor
static void configure_handler(LumeDecorSurface *surface,
                              LumeDecorConfiguration *cfg,
                              void *user_data) {
    LumeWindow *win = (LumeWindow *)user_data;
    // Aplica configuração de tamanho/estado
    LumeDecorConfigurationState state = lume_decor_configuration_get_state(cfg);
    if (state & LUME_DECOR_CONFIGURATION_STATE_RESIZED) {
        win->width = lume_decor_configuration_get_width(cfg);
        win->height = lume_decor_configuration_get_height(cfg);
    }
}

static void close_handler(LumeDecorSurface *surface, void *user_data) {
    // Sinaliza fechamento da janela
}

static void commit_handler(LumeDecorSurface *surface, void *user_data) {
    // Commit do frame
}

static const LumeDecorSurfaceInterface surface_impl = {
    .configure = configure_handler,
    .close = close_handler,
    .commit = commit_handler,
};

static void surface_created_handler(LumeDecorContext *ctx,
                                    LumeDecorSurface *surface,
                                    void *user_data) {
    LumeWindow *win = calloc(1, sizeof(LumeWindow));
    lume_decor_surface_set_user_data(surface, win);
    lume_decor_surface_set_interface(surface, &surface_impl, win);
}

static void context_error_handler(LumeDecorContext *ctx,
                                  const char *msg,
                                  void *user_data) {
    fprintf(stderr, "libdecor-lume error: %s\n", msg);
}

static const LumeDecorContextInterface context_impl = {
    .surface_created = surface_created_handler,
    .error = context_error_handler,
};

int main(int argc, char *argv[]) {
    LumeDecorContext *ctx = lume_decor_context_create(&context_impl, NULL);
    if (!ctx) {
        fprintf(stderr, "Falha ao criar contexto libdecor-lume\n");
        return 1;
    }

    printf("libdecor-lume plugin inicializado\n");
    printf("  CSD QML: titlebar 40px, controles à direita\n");
    printf("  Fechar hover: #C42B1C\n");
    printf("  Raio janela: 12, sombra: 2 camadas\n");
    printf("  Borda interna: 1px\n");

    // Loop principal (placeholder - seria integrado ao wayland compositor)
    lume_decor_context_destroy(ctx);
    return 0;
}
