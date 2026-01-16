import os
import re
import sys

def generate_mcscanx_coords(cds_dir, prefix_file, output_dir):
    # Load prefix mappings (e.g., Species_Name -> Adau)
    prefix_map = {}
    with open(prefix_file, 'r') as f:
        for line in f:
            if line.strip() and not line.startswith('#'):
                parts = line.split()
                prefix_map[parts[0]] = parts[1]

    if not os.path.exists(output_dir):
        os.makedirs(output_dir)

    # Process each CDS file
    for filename in os.listdir(cds_dir):
        if filename.endswith(".fna") or filename.endswith(".fasta"):
            # Identify the species to get the prefix
            species_key = filename.split('.')[0] 
            prefix = prefix_map.get(species_key, "UNK")
            
            output_file = os.path.join(output_dir, f"{prefix}.gff")
            
            with open(os.path.join(cds_dir, filename), 'r') as infile, open(output_file, 'w') as outfile:
                for line in infile:
                    if line.startswith(">"):
                        # Extracting coordinates from the FASTA header
                        # Example: [location=scaffold_1:100-500]
                        try:
                            scaffold = re.search(r'location=([^:]+)', line).group(1)
                            coords = re.search(r':(\d+)\.\.(\d+)', line)
                            start, end = coords.group(1), coords.group(2)
                            gene_id = line.split()[0].replace(">", "")
                            
                            # Write in MCScanX format: scaffold, gene, start, end
                            outfile.write(f"{scaffold}\t{prefix}{gene_id}\t{start}\t{end}\n")
                        except AttributeError:
                            continue # Skip lines that don't match the location pattern

    print(f"Success: Coordinate files generated in {output_dir}")

if __name__ == "__main__":
    # Example usage for your README
    # python generate_mcscanx_coords.py ./cds_inputs ./species_map.txt ./mcscanx_gff
    generate_mcscanx_coords(sys.argv[1], sys.argv[2], sys.argv[3])