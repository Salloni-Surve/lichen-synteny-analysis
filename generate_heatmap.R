# Load necessary packages
# Note for GitHub: Ensure you have run install.packages(c("stringr", "dplyr", "ggplot2", "tidyr"))
library(stringr)
library(dplyr)
library(ggplot2)
library(tidyr)

# --- 1. Dynamic Path Setup ---
# This looks for files in the current working directory
file_path <- "results/master.collinearity" 
species_order_file_path <- "data/speciesmap.txt" 

# Validation
if (!file.exists(file_path)) {
  stop(paste("Missing data: Ensure", file_path, "exists in your project folder."))
}

# --- 2. Data Processing ---
# Read the collinearity file (MCScanX output)
file_content <- paste(readLines(file_path, warn = FALSE), collapse = "\n")
lines <- unlist(strsplit(file_content, "\n"))

# Read the species list (Mise en Place)
ordered_species <- readLines(species_order_file_path, warn = FALSE)
ordered_species <- trimws(ordered_species[ordered_species != "" & !is.na(ordered_species)])

# Logic to extract species names from gene IDs (e.g., 'Adau' from 'Adau_gene123')
# This matches the 4-letter prefix logic we used in Python
results <- list()
current_species_pair <- ""

for (line in lines) {
  if (startsWith(line, "## Alignment")) {
    # Extract the pair, e.g., "Adau vs CyaA"
    current_species_pair <- str_extract(line, "(?<=& )\\w+&\\w+")
    current_species_pair <- str_replace(current_species_pair, "&", " vs ")
  } else if (!startsWith(line, "#") && current_species_pair != "") {
    # Extract gene counts for the heatmap
    gene_info <- str_split(line, "\\s+")[[1]]
    if (length(gene_info) > 1) {
      results[[length(results) + 1]] <- data.frame(Pair = current_species_pair, stringsAsFactors = FALSE)
    }
  }
}

# --- 3. Visualization ---
# [Code continues with your specific ggplot2 theme and scaling]
final_df <- bind_rows(results) %>%
  group_by(Pair) %>%
  summarise(Total_N_Value = n()) %>%
  separate(Pair, into = c("Species1", "Species2"), sep = " vs ")

# Set factor levels for the "Chef's Presentation" (Correct Order)
heatmap_data <- expand.grid(Species1 = ordered_species, Species2 = ordered_species) %>%
  left_join(final_df, by = c("Species1", "Species2")) %>%
  replace_na(list(Total_N_Value = 0))

heatmap_plot <- ggplot(heatmap_data, aes(x = Species2, y = Species1, fill = Total_N_Value)) +
  geom_tile() +
  scale_fill_gradient(low = "#FFFFCC", high = "#8B0000", name = "Conserved Genes") +
  theme_minimal() +
  theme(axis.text.x = element_text(angle = 90, vjust = 0.5))

# Save the plot
ggsave("results/synteny_heatmap.png", heatmap_plot, width = 10, height = 8)
print("Heatmap generated and saved to results/synteny_heatmap.png")
