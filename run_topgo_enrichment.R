# ==============================================================
# GO Enrichment Analysis using topGO
# ==============================================================

# Check for required Bioconductor package
if (!requireNamespace("topGO", quietly = TRUE)) {
  if (!requireNamespace("BiocManager", quietly = TRUE)) install.packages("BiocManager")
  BiocManager::install("topGO")
}
library(topGO)

# --- 1. Dynamic Path Setup ---
# This script assumes files are in a folder named 'TopGO' in your current directory
input_dir <- "TopGO"
output_dir <- "results/enrichment"
if (!dir.exists(output_dir)) dir.create(output_dir, recursive = TRUE)

# Input files (adjust names to match your specific species)
go_map_file <- file.path(input_dir, "Lpus_GO_mapped.txt")         # All gene-to-GO mappings
interesting_file <- file.path(input_dir, "runC_interesting_genes.txt") # Syntenic genes identified by MCScanX

# --- 2. Data Loading & Normalization ---
geneID2GO <- readMappings(file = go_map_file)
all_genes <- names(geneID2GO)
interesting_genes <- readLines(interesting_file)

# Function to remove species prefixes (e.g., 'Lpus|' from 'Lpus|gene123')
normalize_ids <- function(ids) sub("^[^|]+\\|", "", ids)
all_genes_norm <- normalize_ids(all_genes)
interesting_genes_norm <- normalize_ids(interesting_genes)

# Create the factor list (1 = syntenic gene, 0 = background gene)
geneList <- factor(as.integer(all_genes_norm %in% interesting_genes_norm))
names(geneList) <- all_genes

# --- 3. The Enrichment Function ---
run_topGO_analysis <- function(ontology_code, ontology_name) {
  message(paste("Processing:", ontology_name))
  
  # Create topGO object
  # nodeSize = 10 removes very small, specific terms to improve statistical power
  GOdata <- new("topGOdata",
                ontology = ontology_code,
                allGenes = geneList,
                annot = annFUN.gene2GO,
                gene2GO = geneID2GO,
                nodeSize = 10)
  
  # Run the Fisher test with the 'elim' algorithm 
  # This is the more rigorous method mentioned in your MSc report
  resultFisher <- runTest(GOdata, algorithm = "elim", statistic = "fisher")
  
  # Generate results table
  allRes <- GenTable(GOdata,
                     Fisher = resultFisher,
                     orderBy = "Fisher",
                     topNodes = 20) # Showing top 20 significant terms
  
  write.table(allRes, file.path(output_dir, paste0("GO_results_", ontology_name, ".tsv")), 
              sep = "\t", row.names = FALSE, quote = FALSE)
  
  return(allRes)
}

# --- 4. Execution ---
res_BP <- run_topGO_analysis("BP", "Biological_Process")
res_MF <- run_topGO_analysis("MF", "Molecular_Function")
res_CC <- run_topGO_analysis("CC", "Cellular_Component")

message("Functional enrichment complete. Results saved in: ", output_dir)