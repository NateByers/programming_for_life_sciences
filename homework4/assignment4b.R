# install packages 
install.packages("dplyr")
install.packages("tidyr")
library(dplyr)
library(tidyr)

download.file("ftp://ftp.ncbi.nlm.nih.gov/genomes/archive/old_genbank/Bacteria/Escherichia_coli_K_12_substr__MG1655_uid225/U00096.gbk",
              "U00096.gbk")

lines <- readLines("U00096.gbk")

# get the first CDS line
cds_line <- grep("^\\s+CDS", lines, value = TRUE)[1]
cds_line_comps <- strsplit(cds_line, "\\s")[[1]]
cds_line_comps <- cds_line_comps[cds_line_comps != ""]

# get locations to read in the file using fixed width
first_column_beginning <- regexec(cds_line_comps[1], cds_line)[[1]][1]
second_column_beginning <- regexec(cds_line_comps[2], cds_line)[[1]][1]
second_column_ending <- max(sapply(lines, nchar))

# create the widths vector
widths <- c(-(first_column_beginning - 1), 
            (second_column_beginning - 1) - first_column_beginning,
            max(sapply(lines, nchar)) - second_column_beginning)

# read in using fixed with logic
tbl <- read.fwf("ftp://ftp.ncbi.nlm.nih.gov/genomes/archive/old_genbank/Bacteria/Escherichia_coli_K_12_substr__MG1655_uid225/U00096.gbk",
                widths, skip = grep("^\\s+source", lines)[1] - 1, strip.white = TRUE,
                stringsAsFactors = FALSE) %>%
  dplyr::rename(category = V1, value = V2) 
  
# define the information we need
name_tbl <- data.frame(name = c("gene", "locus_tag", "function", "translation"),
                       stringsAsFactors = FALSE)

tbl <- tbl %>%
  dplyr::mutate(equal = grepl("=", value), # which columns are the beginning of a defined value
                row_num = row_number()) %>%
  dplyr::group_by(row_num) %>%
  dplyr::mutate(name = ifelse(equal, strsplit(value, "=")[[1]][1], NA), # if the line is a definition, split into two columns
                name = sub("\\/", "", name),
                value = ifelse(equal, strsplit(value, "=")[[1]][2], value),
                value = gsub('^"|"$', "", value)) %>%
  ungroup() %>%
  dplyr::mutate(category = ifelse(!grepl("\\S", category), NA, category), # fill in with NAs
                location = ifelse(!is.na(category), value, NA)) %>%
  tidyr::fill(category, location) %>% # fill in NAs with first non-NA value above it
  dplyr::filter(category == "CDS", value != location) %>% # drop the row with the location in the value
  tidyr::fill(name) %>% # fill in the NAs with the first non-NA value
  dplyr::semi_join(name_tbl, "name") %>% # filter down to the definitions we are interested in
  dplyr::group_by(location, name) %>% 
  dplyr::mutate(value = ifelse(sum(!equal) == 0, value, # for each location/name group, paste together multi-line values 
                               ifelse(name == "translation",
                                      paste(value, collapse = ""),
                                      paste(value, collapse = " ")))) %>%
  dplyr::filter(equal) %>% # get rid of the extra rows from multi-line values
  dplyr::select(location, name, value) %>%
  tidyr::spread(name, value, fill = "[missing]") %>% # spread out the names as columns
  dplyr::mutate(print = paste0(paste(location, gene, locus_tag, paste0('"', `function`, '"'), #create the column to print
                                     translation, sep = "\t"), "\n"))
  
for (i in tbl$print) {
  cat(i) 
  }


