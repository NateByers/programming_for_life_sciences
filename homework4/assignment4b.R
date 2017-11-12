if(!require(dplyr)) {
  install.packages("dplyr")
}
library(dplyr)

download.file("ftp://ftp.ncbi.nlm.nih.gov/genomes/archive/old_genbank/Bacteria/Escherichia_coli_K_12_substr__MG1655_uid225/U00096.gbk",
              "U00096.gbk")

lines <- readLines("U00096.gbk")

cds_line <- grep("^\\s+CDS", lines, value = TRUE)[1]
cds_line_comps <- strsplit(cds_line, "\\s")[[1]]
cds_line_comps <- cds_line_comps[cds_line_comps != ""]


first_column_beginning <- regexec(cds_line_comps[1], cds_line)[[1]][1]
second_column_beginning <- regexec(cds_line_comps[2], cds_line)[[1]][1]
second_column_ending <- max(sapply(lines, nchar))

widths <- c(-(first_column_beginning - 1), 
            (second_column_beginning - 1) - first_column_beginning,
            max(sapply(lines, nchar)) - second_column_beginning)

tbl <- read.fwf("ftp://ftp.ncbi.nlm.nih.gov/genomes/archive/old_genbank/Bacteria/Escherichia_coli_K_12_substr__MG1655_uid225/U00096.gbk",
                widths, skip = grep("^\\s+source", lines)[1] - 1, strip.white = TRUE,
                stringsAsFactors = FALSE) %>%
  rename(category = V1, value = V2)


