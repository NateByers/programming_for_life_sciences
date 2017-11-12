if(!require(dplyr)) {
  install.packages("dplyr")
}
if(!require(tidyr)) {
  install.packages("tidyr")
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
  dplyr::rename(category = V1, value = V2) 
  
name_tbl <- data.frame(name = c("gene", "locus_tag", "function", "translation"),
                       stringsAsFactors = FALSE)

x <- tbl %>%
  dplyr::mutate(equal = grepl("=", value),
                row_num = row_number()) %>%
  dplyr::group_by(row_num) %>%
  dplyr::mutate(name = ifelse(equal, strsplit(value, "=")[[1]][1], NA),
                name = sub("\\/", "", name),
                value = ifelse(equal, strsplit(value, "=")[[1]][2], value),
                value = gsub('^"|"$', "", value)) 



y <- x %>%
  ungroup() %>%
  dplyr::mutate(category = ifelse(!grepl("\\S", category), NA, category),
                location = ifelse(!is.na(category), value, NA)) %>%
  tidyr::fill(category, location) %>%
  dplyr::filter(category == "CDS", value != location) %>%
  tidyr::fill(name) %>%
  dplyr::semi_join(name_tbl, "name") %>%
  dplyr::group_by(location, name) %>%
  dplyr::mutate(value = ifelse(sum(!equal) == 1, value,
                               ifelse(name == "/translation",
                                      paste(value, collapse = ""),
                                      paste(value, collapse = " ")))) 
  
lapply()


