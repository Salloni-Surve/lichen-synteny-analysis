#!/bin/bash

# --- Simple Path Setup ---
# Put your master.blast and master.gff into a folder named 'data' 
# inside your MCScanX directory before running this.

MCSCANX_DIR="./MCScanX-master" # Path to your MCScanX folder
INPUT_PREFIX="master"          # Looks for master.blast and master.gff
OUTPUT_DIR="./results"

mkdir -p "$OUTPUT_DIR"

echo "--- Starting MCScanX Synteny Detection ---"

# 1. Run the core MCScanX command
# -k 3: Minimum 3 genes to call it a collinear block (from your report)
# -g 40: Max gap of 40 genes between anchors (from your report)
$MCSCANX_DIR/MCScanX $MCSCANX_DIR/data/$INPUT_PREFIX -k 3 -g 40

# 2. Move the results to a clean folder for your GitHub
if [ $? -eq 0 ]; then
    echo "MCScanX finished successfully. Moving files to $OUTPUT_DIR..."
    mv "$MCSCANX_DIR/data/$INPUT_PREFIX.collinearity" "$OUTPUT_DIR/"
    mv "$MCSCANX_DIR/data/$INPUT_PREFIX.tandem" "$OUTPUT_DIR/"
    echo "Done! Check the $OUTPUT_DIR folder for your results."
else
    echo "Error: MCScanX failed to run. Check if MCScanX is installed correctly."
fi