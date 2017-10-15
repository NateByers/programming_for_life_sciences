# install ggplot2 if necessary and load
if(!require(ggplot2)) {
  install.packages("ggplot2")
}
library(ggplot2)

# read in the numbers.txt file and turn into a matrix
numbers <- as.matrix(read.delim("numbers.txt", header = FALSE))

# get all of the possible combinations of rows
combinations <- combn(1:nrow(numbers), 2)

# use apply on the combinations, by column, to get the combinations to subset 
# the numbers matrix by
tests <- apply(combinations, 2, function(columns, numbers) {
  
  # get the test objects
  t_test <- t.test(numbers[columns[1], ], numbers[columns[2], ])
  wilcox <- wilcox.test(numbers[columns[1], ], numbers[columns[2], ])
  
  # make a tidy data.frame showing, for each row_x and row_y, the t-test and 
  # wilcox test statistics and p-values
  data.frame(row_x = columns[1], row_y = columns[2],
             test = rep(c("t-test", "Wilcox"), each = 2),
             value_type = rep(c("statistic", "p-value"), 2),
             value = c(t_test$statistic, t_test$p.value,
                       wilcox$statistic, wilcox$p.value),
             stringsAsFactors = FALSE)
  
}, numbers = numbers)

# make a large data.frame of the test results
tests <- Reduce(rbind, tests)

tests

# make a tall data.frame of the row vectors
df <- data.frame(row = rep(as.factor(1:3), each = ncol(numbers)),
                 value = as.vector(t(numbers)))

# box-plot for each row
ggplot(df, aes(x = row, y = value)) + geom_boxplot()
