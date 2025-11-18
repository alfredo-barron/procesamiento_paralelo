#!/bin/bash

# Ejecutables
SEC="./procesar_sec"
OMP="./procesar_omp"
PTH="./procesar_pthreads"

IMAGES=("imagen1.jpg" "imagen2.jpg" "imagen3.jpg")
THREADS=(1 2 4 8)

OUT_CSV="tiempos.csv"
SPEEDUP_CSV="speedup.csv"
EFICIENCIA_CSV="eficiencia.csv"
OVERHEAD_CSV="overhead.csv"

# Limpiar CSV anteriores
echo "imagen,version,hilos,tiempo" > $OUT_CSV
echo "imagen,version,hilos,speedup" > $SPEEDUP_CSV
echo "imagen,version,hilos,eficiencia" > $EFICIENCIA_CSV
echo "imagen,version,hilos,overhead" > $OVERHEAD_CSV

# =============== FUNCION: Ejecutar y capturar tiempo ==================
run_exec() {
    exe=$1
    img=$2
    h=$3

    if [[ "$exe" == "$SEC" ]]; then
        OUTPUT=$($exe "$img")
    else
        export OMP_NUM_THREADS=$h
        $exe "$img" > output_tmp.txt
        OUTPUT=$(cat output_tmp.txt)
    fi

    # Extraer el número decimal correctamente
    t=$( grep -o '[0-9]*\.[0-9]*' <<< "$OUTPUT" | head -n 1 )

    echo "$t"
}

echo "Iniciando pruebas..."

# ======================== PROCESAR ==============================
for img in "${IMAGES[@]}"; do
    echo "Procesando imagen: $img"

    # ---- Secuencial ----
    TSEQ=$(run_exec $SEC $img 1)
    echo "$img,secuencial,1,$TSEQ" >> $OUT_CSV

    # ---- OpenMP y Pthreads ----
    for h in "${THREADS[@]}"; do
        
        TOPM=$(run_exec $OMP $img $h)
        echo "$img,openmp,$h,$TOPM" >> $OUT_CSV

        TPTH=$(run_exec $PTH $img $h)
        echo "$img,pthreads,$h,$TPTH" >> $OUT_CSV
    done
done

echo "Cálculo de métricas…"

# copia segura
cp $OUT_CSV tmp_resultados.csv

# ================= GENERAR SPEEDUP, EFICIENCIA, OVERHEAD =================

while IFS=',' read -r img ver hilos tiempo; do

    # Saltar encabezado
    if [[ "$img" == "imagen" ]]; then continue; fi

    if [[ "$ver" == "openmp" || "$ver" == "pthreads" ]]; then
        
        # Buscar tiempo secuencial correspondiente
        TSEQ=$( grep "$img,secuencial" tmp_resultados.csv | awk -F',' '{print $4}' )

        SPEEDUP=$(echo "$TSEQ / $tiempo" | bc -l)
        EFICIENCIA=$(echo "$SPEEDUP / $hilos" | bc -l)
        OVERHEAD=$(echo "$hilos * $tiempo - $TSEQ" | bc -l)

        echo "$img,$ver,$hilos,$SPEEDUP" >> $SPEEDUP_CSV
        echo "$img,$ver,$hilos,$EFICIENCIA" >> $EFICIENCIA_CSV
        echo "$img,$ver,$hilos,$OVERHEAD" >> $OVERHEAD_CSV
    fi

done < tmp_resultados.csv

echo "=========================================="
echo "   Pruebas completadas correctamente"
echo "   Archivos generados:"
echo "   → $OUT_CSV"
echo "   → $SPEEDUP_CSV"
echo "   → $EFICIENCIA_CSV"
echo "   → $OVERHEAD_CSV"
echo "=========================================="