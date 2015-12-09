setwd("C:/Users/hung.pham/Google Drive/PHD/15Fall/CS5890 - Data Science/CS5890-Project/data")

library(jsonlite)
#convert json back to data frame
pizza.train <- fromJSON("train.json/train.json")
pizza.test <- fromJSON("test.json/test.json")

#write text to file
sink("requestTitleTextEditAware.txt")
#train data
for (i in 1:nrow(pizza.train)){
  cat(pizza.train$request_title[i])
  cat('\n')
  cat(pizza.train$request_text_edit_aware[i])
  cat('\n')
}
#test data
for (i in 1:nrow(pizza.test)){
  cat(pizza.test$request_title[i])
  cat('\n')
  cat(pizza.test$request_text_edit_aware[i])
  cat('\n')
}
sink()