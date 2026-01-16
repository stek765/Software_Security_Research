#!/bin/bash

# --- CONFIGURAZIONE ---
export TIGRESS_HOME=/usr/local/bin/tigresspkg/4.0.11
TIGRESS_BIN="/usr/local/bin/tigress"

# Controlliamo che tigress.h ci sia
if [ ! -f "tigress.h" ]; then
    echo "ERRORE: tigress.h mancante! Esegui: cp \$TIGRESS_HOME/tigress.h ."
    exit 1
fi

# --- CREAZIONE CARTELLE ---
echo "--- Creazione cartelle... ---"
mkdir -p 1_Virtualization
mkdir -p 2_Flattening
mkdir -p 3_Arithmetic  # <--- Nuova cartella per il terzo metodo

# --- CICLO SU TUTTI I FILE .c ---
for file in *.c; do
    
    # Ignora file di sistema o già offuscati
    if [[ "$file" == "tigress.h" ]] || [[ "$file" == *"_"* ]]; then
        continue
    fi

    filename=$(basename -- "$file")
    name="${filename%.*}"
    echo "Processing: $file ..."

    # 1. VIRTUALIZATION (Interprete virtuale)
    $TIGRESS_BIN \
        --Environment=x86_64:Linux:Gcc:5.1 \
        --Transform=Virtualize \
        --Functions=main \
        --out=1_Virtualization/${name}_virt.c \
        "$file"

    # 2. FLATTENING (Appiattimento del flusso)
    $TIGRESS_BIN \
        --Environment=x86_64:Linux:Gcc:5.1 \
        --Transform=Flatten \
        --Functions=main \
        --out=2_Flattening/${name}_flat.c \
        "$file"

    # 3. ARITHMETIC ENCODING (Matematica complessa)
    # Sostituisce il Jitting rotto. Trasforma i calcoli in algebra offuscata.
    $TIGRESS_BIN \
        --Environment=x86_64:Linux:Gcc:5.1 \
        --Transform=EncodeArithmetic \
        --Functions=main \
        --out=3_Arithmetic/${name}_arith.c \
        "$file"

done

echo "---"
echo "TUTTO FATTO! Ora hai le 3 cartelle piene."
