#!/bin/bash

EXEC="./procesar_omp"
IMAGES=("imagen1.jpg" "imagen2.jpg" "imagen3.jpg")
THREADS=(2 4 8)

OUT_CSV="tiempos_openmp.csv"

echo "metodo,imagen,hilos,tiempo" > $OUT_CSV

echo "====== EJECUCIÓN OPENMP ======"

for img in "${IMAGES[@]}"; do
    for t in "${THREADS[@]}"; do
        
        echo -e "\nProcesando $img con $t hilos"
        export OMP_NUM_THREADS=$t

        # Capturar COMPLETAMENTE la salida del programa
        OUTPUT=$($EXEC "$img")
        echo "$OUTPUT"

        # Buscar la línea que contiene Tiempo (ignorando mayúsculas)
        RESULT=$(echo "$OUTPUT" | grep -i "Tiempo")

        # Extraer número flotante
        TIME=$(echo "$RESULT" | grep -o '[0-9]*\.[0-9]*')

        echo "OpenMP,$img,$t,$TIME" >> $OUT_CSV
    done
done

echo "CSV generado: $OUT_CSV"