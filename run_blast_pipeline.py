import itertools
import os
import subprocess
import sys

# --- Simple Path Setup ---
# This looks for folders in the same directory as the script
BASE_DIR = os.getcwd()
PROT_SEQ_DIR = os.path.join(BASE_DIR, "cleaned_proteins")
BLAST_DBS_DIR = os.path.join(BASE_DIR, "blast_dbs")
BLAST_OUT_DIR = os.path.join(BASE_DIR, "blast_out")
NAME_LIST_FILE = os.path.join(BASE_DIR, "species_list.txt") 

# Ensure output directory exists
if not os.path.exists(BLAST_OUT_DIR):
    os.makedirs(BLAST_OUT_DIR)

# Load species names
try:
    with open(NAME_LIST_FILE, 'r') as f:
        name_list = [line.strip() for line in f if line.strip()]
except FileNotFoundError:
    print(f"Error: {NAME_LIST_FILE} not found. Please create a text file with one species name per line.")
    sys.exit(1)

# Generate pairwise combinations (A vs B, B vs A, etc.)
combo_list = list(itertools.permutations(name_list, 2))
print(f"Found {len(name_list)} species. Total BLAST jobs to run: {len(combo_list)}")

# Run BLASTp commands
for query_sp, subject_sp in combo_list:
    query_path = os.path.join(PROT_SEQ_DIR, f"{query_sp}_protein.faa")
    db_path = os.path.join(BLAST_DBS_DIR, subject_sp) # Path to the BLAST database
    output_file = os.path.join(BLAST_OUT_DIR, f"{query_sp}_{subject_sp}.blast")

    # The BLASTp command used in your MSc Dissertation
    blast_cmd = [
        "blastp",
        "-query", query_path,
        "-db", db_path,
        "-out", output_file,
        "-evalue", "1e-10",        # Significance threshold 
        "-outfmt", "6",             # Tabular format required by MCScanX
        "-max_target_seqs", "5",
        "-num_threads", "4"         # Adjustable based on user computer
    ]

    print(f"Running: {query_sp} vs {subject_sp}...")
    
    # Run the command
    try:
        subprocess.check_call(blast_cmd)
    except subprocess.CalledProcessError:
        print(f"Failed to run BLAST for {query_sp} vs {subject_sp}")

# --- Concatenation Step ---
print("All BLAST jobs finished. Merging into master.blast...")
with open("master.blast", "w") as outfile:
    for filename in os.listdir(BLAST_OUT_DIR):
        if filename.endswith(".blast"):
            with open(os.path.join(BLAST_OUT_DIR, filename), "r") as infile:
                outfile.write(infile.read())
print("Master BLAST file created successfully!")