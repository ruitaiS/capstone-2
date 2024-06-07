# Split Along Fold (Pick New Index Each Run)
index = 1

splits <- generate_splits(index)
test_df <- splits[[1]]
train_df <- splits[[2]]
rm(splits)
