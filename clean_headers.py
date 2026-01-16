import os
import sys

def process_fasta(input_path):
    # Setup paths relative to where the script is run
    base_name = os.path.basename(input_path)
    output_dir = "cleaned_proteins"
    output_path = os.path.join(output_dir, base_name.replace(".faa", "_clean.faa"))

    MAX_ID_LENGTH = 50  # Maximum allowed ID length for BLAST

    if not os.path.exists(output_dir):
        os.makedirs(output_dir)

    print(f"--- Processing: {base_name} ---")

    try:
        with open(input_path, 'r') as infile, open(output_path, 'w') as outfile:
            keep_sequence = False
            for line in infile:
                if line.startswith(">"):
                    # Extract ID and filter for primary transcripts (mRNA-1)
                    if "-mRNA-1" in line:
                        # Clean ID: take everything before the first space and keep it short
                        clean_id = line.split()[0].replace(">", "")
                        short_id = clean_id[:MAX_ID_LENGTH]
                        outfile.write(f">{short_id}\n")
                        keep_sequence = True
                    else:
                        keep_sequence = False
                else:
                    if keep_sequence:
                        outfile.write(line)
        
        print(f"Done! Cleaned file saved to: {output_path}")

    except FileNotFoundError:
        print(f"Error: {input_path} not found.")

if __name__ == "__main__":
    if len(sys.argv) < 2:
        print("Usage: python clean_headers.py <your_fasta_file.faa>")
    else:
        process_fasta(sys.argv[1])