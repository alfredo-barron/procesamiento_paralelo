#include <stdio.h>
#include <stdlib.h>
#include <time.h>
#include <omp.h>
#include <sched.h>

#define STB_IMAGE_IMPLEMENTATION
#include "stb_image.h"

#define STB_IMAGE_WRITE_IMPLEMENTATION
#include "stb_image_write.h"

int main(int argc, char *argv[]) {

    if (argc < 2) {
        printf("Uso: %s <imagen>\n", argv[0]);
        return 1;
    }

    char input_path[256];
    char output_path[256];

    snprintf(input_path, sizeof(input_path), "img_in/%s", argv[1]);
    snprintf(output_path, sizeof(output_path), "img_out/%s", argv[1]);

    int width, height, channels;
    unsigned char *img = stbi_load(input_path, &width, &height, &channels, 1);

    if (!img) {
        printf("Error cargando imagen: %s\n", input_path);
        return 1;
    }

    printf("Imagen cargada: %s (%dx%d)\n", input_path, width, height);

    long sum = 0;

    double start = omp_get_wtime();

    // Solo se imprime una vez por hilo
    #pragma omp parallel
    {
        int h = omp_get_thread_num();
        int n = sched_getcpu();

        #pragma omp critical
        printf("Hilo %d en núcleo %d\n", h, n);
    }

    // PARALLEL FOR CORRECTO
    #pragma omp parallel for reduction(+:sum)
    for (int i = 0; i < width * height; i++) {
        sum += img[i];
    }

    double end = omp_get_wtime();

    printf("Brillo total: %ld\n", sum);
    printf("Tiempo OpenMP: %.4f s\n", end - start);

    stbi_write_png(output_path, width, height, 1, img, width);

    stbi_image_free(img);
    return 0;
}