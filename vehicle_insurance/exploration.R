#lm_model <- lm(claim_paid ~ ., data = train_df)

#predictions <- predict(lm_model, newdata = test_df)
#mae <- mean(abs(predictions - test_df$claim_paid))
#mse <- mean((predictions - test_df$claim_paid)^2)
#rmse <- sqrt(mse)

#cat("Mean Absolute Error (MAE):", mae, "\n")
#cat("Mean Squared Error (MSE):", mse, "\n")
#cat("Root Mean Squared Error (RMSE):", rmse, "\n")

# First find the biasing effects of each of these categorical variables:
# sex
# insr_type
# seats_num
# carrying_capacity
# type_vehicle
# make
# usage

#effective_yr >> What is this? look more deeply

# Then reduce down to residuals, and perform LM or whatever on:
# insured time (insr_end - insr_begin) 
# ** Make sure you do data transform for policy renewals **
# I believe these are referenced by object_id
# insured_value
# premium >> what is this? Look more
# prod_year
# ccm_ton >> I think this is tonnage. Confirm