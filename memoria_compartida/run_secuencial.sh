#!/bin/bash

EXEC="./procesar_sec"
IMAGES=("imagen1.jpg" "imagen2.jpg" "imagen3.jpg")

OUT_CSV="tiempos_secuencial.csv"

echo "metodo,imagen,hilos,tiempo" > $OUT_CSV

echo "====== EJECUCIÓN SECUENCIAL ======"

for img in "${IMAGES[@]}"; do
    echo -e "\nProcesando: $img"

    OUTPUT=$($EXEC "$img")
    echo "$OUTPUT"

    RESULT=$(echo "$OUTPUT" | grep "Tiempo")

    TIME=$(echo "$RESULT" | awk '{print $3}')

    echo "Secuencial,$img,1,$TIME" >> $OUT_CSV
done