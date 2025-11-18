#!/bin/bash

EXEC="./procesar_pthreads"
IMAGES=("imagen1.jpg" "imagen2.jpg" "imagen3.jpg")
THREADS=(2 4 8)

OUT_CSV="tiempos_pthreads.csv"

echo "metodo,imagen,hilos,tiempo" > $OUT_CSV

echo "====== EJECUCIÓN PTHREADS ======"

for img in "${IMAGES[@]}"; do
    for t in "${THREADS[@]}"; do
        
        echo -e "\nProcesando $img con $t hilos"

        # Ejecutar y mostrar en pantalla
        OUTPUT=$($EXEC "$img" $t)
        echo "$OUTPUT"

        # Buscar línea que contenga Tiempo
        RESULT=$(echo "$OUTPUT" | grep -i "Tiempo")

        # Extraer número flotante
        TIME=$(echo "$RESULT" | grep -o '[0-9]*\.[0-9]*')

        echo "Pthreads,$img,$t,$TIME" >> $OUT_CSV

    done
done

echo "CSV generado: $OUT_CSV"