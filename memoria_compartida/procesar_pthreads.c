#include <stdio.h>
#include <stdlib.h>
#include <pthread.h>
#include <sched.h>   // Para sched_getcpu()
#include <time.h>

#define STB_IMAGE_IMPLEMENTATION
#include "stb_image.h"

#define STB_IMAGE_WRITE_IMPLEMENTATION
#include "stb_image_write.h"

unsigned char *img;
int width, height;
long global_sum = 0;
int NUM_THREADS;

pthread_mutex_t lock;

void* worker(void *arg) {
    int id = *(int*)arg;

    int start = id * (width * height / NUM_THREADS);
    int end   = (id+1) * (width * height / NUM_THREADS);

    long local_sum = 0;

    // Imprimir núcleo del CPU donde corre este thread
    int nucleo = sched_getcpu();
    printf("Pthreads → Hilo %d ejecutándose en núcleo %d\n", id, nucleo);

    for (int i = start; i < end; i++)
        local_sum += img[i];

    pthread_mutex_lock(&lock);
    global_sum += local_sum;
    pthread_mutex_unlock(&lock);

    pthread_exit(NULL);
}

int main(int argc, char *argv[]) {

    if (argc < 3) {
        printf("Uso: %s <imagen> <num_threads>\n", argv[0]);
        return 1;
    }

    char input_path[256];
    char output_path[256];

    snprintf(input_path, sizeof(input_path), "img_in/%s", argv[1]);
    snprintf(output_path, sizeof(output_path), "img_out/%s", argv[1]);

    NUM_THREADS = atoi(argv[2]);
    int channels;

    img = stbi_load(input_path, &width, &height, &channels, 1);

    if (!img) {
        printf("Error cargando imagen.\n");
        return 1;
    }

    printf("Imagen cargada: %s (%dx%d)\n", input_path, width, height);

    pthread_t threads[NUM_THREADS];
    int ids[NUM_THREADS];

    pthread_mutex_init(&lock, NULL);

    clock_t start = clock();

    for (int i = 0; i < NUM_THREADS; i++) {
        ids[i] = i;
        pthread_create(&threads[i], NULL, worker, &ids[i]);
    }

    for (int i = 0; i < NUM_THREADS; i++)
        pthread_join(threads[i], NULL);

    clock_t end = clock();

    printf("Brillo total: %ld\n", global_sum);
    printf("Tiempo Pthreads: %.4f s\n",
           (double)(end - start) / CLOCKS_PER_SEC);

    stbi_write_png(output_path, width, height, 1, img, width);
    printf("Imagen guardada en: %s\n", output_path);

    pthread_mutex_destroy(&lock);
    stbi_image_free(img);

    return 0;
}