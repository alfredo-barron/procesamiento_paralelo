#include <stdio.h>
#include <stdlib.h>
#include <time.h>

// Librerías de stb
#define STB_IMAGE_IMPLEMENTATION
#include "stb_image.h"

#define STB_IMAGE_WRITE_IMPLEMENTATION
#include "stb_image_write.h"

int main(int argc, char *argv[]) {

    if (argc < 2) {
        printf("Uso: %s <nombre_imagen>\n", argv[0]);
        printf("Ejemplo: %s imagen.png\n", argv[0]);
        return 1;
    }

    char input_path[256];
    char output_path[256];

    // Construir rutas automáticas
    snprintf(input_path, sizeof(input_path), "img_in/%s", argv[1]);
    snprintf(output_path, sizeof(output_path), "img_out/%s", argv[1]);

    int width, height, channels;

    // ---- Cargar imagen ----
    unsigned char *img = stbi_load(input_path, &width, &height, &channels, 1);

    if (img == NULL) {
        printf("Error cargando la imagen: %s\n", input_path);
        return 1;
    }

    printf("Imagen cargada: %s (%dx%d)\n", input_path, width, height);

    long sum = 0;
    clock_t start = clock();

    // ---- Procesamiento (ej. brillo total o conversión a gris) ----
    for (int i = 0; i < width * height; i++) {
        sum += img[i];  // Calcular brillo total
    }

    clock_t end = clock();

    printf("Brillo total: %ld\n", sum);
    printf("Tiempo secuencial: %.4f s\n",
        (double)(end - start) / CLOCKS_PER_SEC);

    // ---- Guardar imagen procesada ----
    if (stbi_write_png(output_path, width, height, 1, img, width) == 0) {
        printf("Error guardando la imagen procesada.\n");
        stbi_image_free(img);
        return 1;
    }

    printf("Imagen procesada guardada en: %s\n", output_path);

    stbi_image_free(img);
    return 0;
}