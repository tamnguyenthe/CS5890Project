#clear workspace
rm(list = ls())
cat("\014")  
#load
library(jsonlite)
library(caret)
library(e1071)
#convert json back to data frame
pizza <- fromJSON("data/train.json")
pizza$received <- ifelse(pizza$requester_received_pizza == TRUE,1, 0)
folds <- createFolds(1:length(pizza$request_id), k = 10)

# pizza.train$requester_received_pizza
# pizza.train$requester_account_age_in_days_at_request
# pizza.train$requester_number_of_comments_at_request
# pizza.train$requester_number_of_posts_at_request
# pizza.train$requester_number_of_subreddits_at_request
# pizza.train$requester_upvotes_plus_downvotes_at_request
# pizza.train$requester_upvotes_minus_downvotes_at_request

f.score <- list()
for (fold in folds) {
  pizza.train <- pizza[-fold, ]
  pizza.test <- pizza[fold, ]
  logistic.model <- glm(received ~requester_account_age_in_days_at_request + requester_number_of_comments_at_request
                        +requester_number_of_posts_at_request + requester_number_of_subreddits_at_request 
                        +requester_upvotes_plus_downvotes_at_request + requester_upvotes_minus_downvotes_at_request, 
                        data = pizza.train, family = binomial(link = "logit"))
  predicted.result <- predict(logistic.model, newdata=pizza.test)
  predicted <- ifelse(predicted.result >= 0.5,1, 0)
  print(table(predicted, pizza.test$received))
}

