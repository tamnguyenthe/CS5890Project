#clear workspace
rm(list = ls())
#load
library(jsonlite)
#convert json back to data frame
pizza.train <- fromJSON("train.json/train.json")
pizza.test <- fromJSON("test.json/test.json")

remove_outliers <- function(x, na.rm = TRUE, ...) {
  qnt <- quantile(x, probs=c(.25, .75), na.rm = na.rm, ...)
  H <- 1.5 * IQR(x, na.rm = na.rm)
  y <- x
  y[x < (qnt[1] - H)] <- NA
  y[x > (qnt[2] + H)] <- NA
  y
}

upvote.minus.downvote <- pizza.train$requester_upvotes_minus_downvotes_at_request
upvote.plus.downvote <- pizza.train$requester_upvotes_plus_downvotes_at_request
upvote <- (upvote.plus.downvote + upvote.minus.downvote)/2
downvote <- (upvote.plus.downvote - upvote.minus.downvote)/2

pizza.train$upvotes <- upvote
pizza.train$downvotes <- downvote

pizza.train.true <- pizza.train[pizza.train$requester_received_pizza == TRUE, ]
pizza.train.false <- pizza.train[pizza.train$requester_received_pizza == FALSE, ]

analysis.fields <- c(5, 6, 7, 8, 9, 10, 11, 13, 14)
for (i in analysis.fields) {
  pdf(paste(names(pizza.test)[i], ".pdf", sep = ""), width = 3, height = 6)
  boxplot(remove_outliers(pizza.train.true[[names(pizza.test)[i]]]), 
          remove_outliers(pizza.train.false[[names(pizza.test)[i]]]), 
          names = c("TRUE", "FALSE"), 
          ylab = names(pizza.test)[i]
  )
  dev.off()
}

updown <- c("upvotes", "downvotes")

for (i in updown) {
  pdf(paste(i, ".pdf", sep = ""), width = 3, height = 6)
  boxplot(remove_outliers(pizza.train.true[[i]]), 
          remove_outliers(pizza.train.false[[i]]), 
          names = c("TRUE", "FALSE"), 
          ylab = i
  )
  dev.off()
}






