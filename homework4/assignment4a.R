
ecoli <- read.table("ftp://ftp.ncbi.nlm.nih.gov/genomes/archive/old_genbank/Bacteria/Escherichia_coli_K_12_substr__MG1655_uid225/U00096.ptt",
                    header = TRUE, skip = 2, sep = "\t", stringsAsFactors = FALSE)

make_breaks <- function(x, bin_length = 100) {
  seq(from = 0, to = bin_length*ceiling(max(x, na.rm = TRUE)/bin_length),
      by = bin_length)
}

hist(ecoli$Length, breaks = make_breaks)
