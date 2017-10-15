# create the tab-delimited file
writeLines("1\t2\t3\t4\t5\t6\t7\t8\n1\t1\t7\t4\t5\t7\t5\t13\n4\t5\t7\t7\t4\t6\t12\t9", 
           con = "numbers.txt")

# read in the tab-delimited file and multiply each value by 5
numbers <- read.delim("numbers.txt", header = FALSE) * 5

# write the multiplied values as a tab-delimited file
write.table(numbers, file = "numbers_multiplied.txt", row.names = FALSE,
            col.names = FALSE, sep = "\t")

