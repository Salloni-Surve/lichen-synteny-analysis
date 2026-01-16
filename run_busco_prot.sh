#!/bin/bash

# Usage: ./run_busco_prot.sh <input_file_or_folder> <lineage_path>
INPUT=${1:-"./cleaned_proteins"}
LINEAGE=${2:-"./ascomycota_odb12"}
OUTPUT_DIR="./busco_results_prot"

mkdir -p "$OUTPUT_DIR"

echo "--- Starting BUSCO Protein Analysis ---"

# Check if input is a single file or a directory
if [ -f "$INPUT" ]; then
    files="$INPUT"
else
    files="$INPUT"/*.faa
fi

for prot_file in $files; do
    species_name=$(basename "$prot_file" .faa)
    echo "Assessing completeness for: $species_name"

    busco -i "$prot_file" \
          -m proteins \
          -l "$LINEAGE" \
          -o "${species_name}_prot_busco" \
          --out_path "$OUTPUT_DIR" \
          --cpu 8 \
          --offline
done