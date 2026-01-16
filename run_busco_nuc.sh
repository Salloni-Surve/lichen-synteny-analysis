#!/bin/bash

# Usage: ./run_busco_nuc.sh <input_folder> <lineage_path>
INPUT_DIR=${1:-"./genomes"}
LINEAGE=${2:-"./ascomycota_odb12"}
OUTPUT_DIR="./busco_results_nuc"

mkdir -p "$OUTPUT_DIR"

echo "--- Starting BUSCO Nucleotide Analysis ---"

for genome in "$INPUT_DIR"/*_genomic.fna; do
    species_name=$(basename "$genome" _genomic.fna)
    echo "Processing: $species_name"

    busco -i "$genome" \
          -m genome \
          -l "$LINEAGE" \
          -o "${species_name}_busco" \
          --out_path "$OUTPUT_DIR" \
          --cpu 8 \
          --offline
done

echo "Analysis complete. Results in $OUTPUT_DIR"