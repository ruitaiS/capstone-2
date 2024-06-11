# Split Along Fold (Pick New Index Each Run)
fold_index = 1

splits <- generate_splits(fold_index)
test_df <- splits[[1]]
train_df <- splits[[2]]
rm(splits)
