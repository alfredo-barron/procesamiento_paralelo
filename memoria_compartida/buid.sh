#!/bin/bash

# Nombre de los archivos fuente
SEC="procesar_sec.c"
OMP="procesar_omp.c"
PTH="procesar_pthreads.c"

# Verificar que los archivos existen
for f in $SEC $OMP $PTH; do
    if [[ ! -f "$f" ]]; then
        echo "ERROR: No se encuentra el archivo $f"
        exit 1
    fi
done

echo "===== COMPILANDO CÓDIGOS ====="

# Compilar versión secuencial
echo "Compilando versión secuencial..."
gcc $SEC -o procesar_sec -lm
if [[ $? -ne 0 ]]; then
    echo "ERROR al compilar procesar_sec"
    exit 1
fi

# Compilar versión OpenMP
echo "Compilando versión OpenMP..."
gcc $OMP -o procesar_omp -fopenmp -lm
if [[ $? -ne 0 ]]; then
    echo "ERROR al compilar procesar_omp"
    exit 1
fi

# Compilar versión Pthreads
echo "Compilando versión Pthreads..."
gcc $PTH -o procesar_pthreads -lpthread -lm
if [[ $? -ne 0 ]]; then
    echo "ERROR al compilar procesar_pthreads"
    exit 1
fi

echo "===== COMPILACIÓN COMPLETA ====="
echo "Ejecutables generados:"
echo "  ./procesar_sec"
echo "  ./procesar_omp"
echo "  ./procesar_pthreads"