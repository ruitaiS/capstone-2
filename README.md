# Chess Game Outcome Prediction:


TODO:
* Find synonyms for indicates
* Read over intro section; talk about analysis more maybe?

## Introduction:

The goal of this project to apply a machine learning model to predict the outcome of a chess match based only on player data and their opening moves. The starting data is a list of just over 20,000 matches from the online chess service Lichess. After trimming games without definitive wins and games not played for rating, the resulting dataset contained about 15,000 matches to develop our models on. Initial data analysis confirmed several well documented statistical peculiarities about chess, and also revealed some surprising results.

The predictive power of the rating system cannot be ignored, and is a very robust single-rule method of predicting a winner. However, when the rating difference between two players is minimal, this method's accuracy diminishes, approaching a mere 50%. In such close matches, switching to alternative prediction methods can yield better results. This project explored three methods aimed at improving prediction accuracy for this subset of closely matched players. The first method was a straightforward approach, predicting that the player with the white pieces would always win, leveraging white's very slight first move advantage. The second method involved predicting the outcome based on the average rating of both players in the match. The third was based on the players' opening strategies.

Each of these alternate prediction rules were tested in conjunction with the "higher rated player wins" rule, and a cutoff threshold determined at about 60 points in rating difference. When the rating difference is 60 points or greater, the model will predict based on which player is rated better. But when the rating difference between the two players is within this range, the model switches over to an alternative rule. Basing the outcome of these matches on the opening ECO code proved to be the most effective, and a hybrid approach combining these two methods yielded an accuracy of 0.6554404 on the holdout test set.

## Analysis:
A methods/analysis section that explains the process and techniques used, including data cleaning, data exploration and visualization, any insights gained, and your modeling approach. At least two different models or algorithms must be used, with at least one being more advanced than linear or logistic regression for prediction problems.

### Preprocessing:

The LiChess dataset used for this project contains games between several thousand players of varying skill ratings, from less than 1000 (beginner) to over 2400 (grandmaster). Each row in the dataset is a record of a single game. `white_id`, `white_rating`, `black_id`, and `black_rating` indicate the player ID and rating for the player on the white and black side. `victory_status` shows how the match ended, and can be `resign`, `mate`, `outoftime`, or `draw`. The `rated` column is somewhat misleading - the players involved still have ratings, but it indicates whether the match is rated (each player's ratings will be updated to reflect the outcome of the match) or casual (the outcome does not affect the player rating). `opening_eco`, `opening_name`, and `opening_ply` refer to the ECO category of the opening sequence, an English language name for the sequence, and the number of moves it took to complete. The `winner` column was recoded to use 1 if the winner was white, and 0 if the winner was black. `moves` was also recoded from a space seperated single string to a list of strings. These recodings allowed for easier processing later on.

Several metadata columns - `id`, `created_at`, `last_move_at`, `turns`, and `increment_code` - were removed. The first four provide unnecessary or redundant information, but `increment_code` is interesting because it indicates the time format of the game. For example, an increment code of `15+30` means that each player starts with a total of 15 minutes, and is granted 30 extra seconds each turn. The amount of time allotted certainly has an effect on the way that the game is played, but I ultimately decided to omit this column for the sake of simplicity.

For this project, I focused only on rated games that had a decisive outcome. Games which ended in stalemates (`victory_status == "draw"`) or which were unrated (`rated == false`) were removed from the dataset. After trimming, a dataset of 15,436 games remained. `createDataPartition` was applied to this dataset, with `p = 0.1` and the response vector set to the `winner` column, creating a training set of 13,892 games and a holdout test set of 1,544 games, with the proportion of winners equally distributed across both datasets.

A `players` dataframe was also created, with statistics for each inidual player:
* `player_id` - The player's in-game id
* `white_wins`, `black_wins` - The number of games won on each side
*  `white_games`, `black_games`, `total_games` - The number of games played on each side, as well as the total
*  `white_wr`, `black_wr`, `overall_wr` - The win rate on each side, as well as the overall win rate

### Data Analysis

#### First Move Advantage

It may be surprising to know that in chess, wins are not equally distributed between both sides. White always moves first, and there is quite a well documented [first move advantage](https://en.wikipedia.org/wiki/First-move_advantage_in_chess) in chess. We see this effect reflected in our training data, which shows that white wins approximately 52% of all games:

```
> mean(main_df$winner)
[1] 0.522387
```
The linked Wikipedia article also mentions that the first move advantage becomes more pronounced at higher skill levels, with white's win rate approaching 100% for games between top-level chess engines. We do not see this in our dataset, because our data is comprised of games between (presumably) human players, and because we don't have enough samples at each level of play to be able to discern a trend. In the graph below, the "Game Rating" is defined as the average rating of `white_rating` and `black_rating` for a game, and we can see no appreciable increase in white's win rate as the average rating between the two players increases:

<img src="/chess/graphs/white_wr_by_game_rating.png" align="center" alt="White Win Rate by Game Rating"
	title="White Win Rate by Game Rating"/>


For the most part, we will treat this first move advantage as a constant proportion, rather than a function of the combined skill level of the two players.

#### Opening Moves

A strong opener allows a player to establish board control and develop key pieces early on in the game; securing these initial advantages can significantly influence the final outcome of a match. Analysis of the density plot reveals that certain openings are used much more often than others, which raises the question of whether these openings are popular because they lead to a higher win rate.

<img src="/chess/graphs/openers_count_density.png" align="center" alt="Density Plot of Instances of Each Opener"
	title="Density Plot of Instances of Each Opener"/>

Each game in the dataset is tagged with an `opening_eco` code, which refers to the categorization system used by the Encyclopedia of Chess Openings to classify different opening sequences. `main_df` was aggregated along values in the `opening_eco` column to produce calculate the win rate and occurrence counts for each code. 

```
opening_eco opener_wr count
         A00 0.4107383   745
         C00 0.5281065   676
         D00 0.4874101   556
         B01 0.5174312   545
         C41 0.5928705   533
         C20 0.4842520   508
```

Let's take a closer look at what these ECO codes mean (from Chess Opening Theory - ECO Volumes [A](https://en.wikibooks.org/wiki/Chess_Opening_Theory/ECO_volume_A) [C](https://en.wikibooks.org/wiki/Chess_Opening_Theory/ECO_volume_C) and [D](https://en.wikibooks.org/wiki/Chess_Opening_Theory/ECO_volume_D) :
> A00: Uncommon Openings

> C00: French Defence, unusual White second moves

> D00: 1.d4 d5 unusual lines

It turns out these are actually unrelated, "uncommon" opening sequences. This reflects the fact that our dataset is from a free online chess service, and most players are beginners, with over 75% of them having 2 games or fewer recorded in our dataset.

```
> summary(players$total_games)
   Min. 1st Qu.  Median    Mean 3rd Qu.    Max. 
  1.000   1.000   1.000   2.362   2.000  82.000 
```

The high proportion of beginner players seems to make the machine learning task a little tricker - I was concerned that the outcome of these games would be much more chaotic than games between experienced players, who might have a more reasoned approach, and I wondered if the opening moves held any predictive power at all, given that they were more likely than not chosen at random.

<img src="/chess/graphs/wins_by_opener_top_25.png" align="center" alt="Win Comparison of the Top 25 Most Played Openers"
	title="Win Comparison of the Top 25 Most Played Openers"/>

It is interesting to note that the collection of unconventional opening moves by white, A00, is not only the most popular, but is also has an incredibly high win rate for black. Given that white always moves first and can choose any opening they prefer, it's puzzling why many players opt for openers that often lead to losses. What is behind this trend?

Additionally, [C41](https://en.wikipedia.org/wiki/Philidor_Defence), which has a very high win rate for white in our dataset, is actually considered a good defensive move for black.

<p align="center">
  <img src="/chess/graphs/C41.png" alt="C41 - Philidor Defense" title="C41 - Philidor Defense"/>
</p>

> Today, the Philidor is known as a solid but passive choice for Black, and is seldom seen in top-level play except as an alternative... It is considered a good opening for amateur players who seek a defensive strategy that is simpler and easier to understand

Could black's low win rate using this defense stem from its popularity among newer players who might have just only begun to memorize some set openings, and who have yet to develop a very sophisticated playbook? These two counter-intuitive findings led me to reconsider my approach. I started with the goal of finding the most advantageous opening moves used by experienced players as a way to predict wins, but the data seems to suggest that irregular opening moves used by novice players are just as powerful, if not more powerful, predictors of losses.

#### Player Rating

Lichess uses the Glicko 2 rating system, which starts players off with a rating of 1500, adjusting it as the players play more games and accumulate more wins and losses. Since it is a numerical representation of a player's skill level, it is, as one might expect, a very reliable predictor of the outcome of a match. (TODO: Left graph should show boundary line too)

<div style="display: flex; justify-content: space-between; width: 100%;">
    <img src="/chess/graphs/white_vs_black_ratings.png" style="width: 45%;" alt="White vs. Black Rating" title="White vs. Black Rating"/>
    <img src="/chess/graphs/wr_by_rating_diff_filtered_regline.png" style="width: 45%;" alt="Rating Difference Vs. Win Rate" title="Rating Difference Vs. Win Rate"/>
</div>

The graph on the left plots the winner of each match by color, with `white_rating` on the X axis and `black_rating` on the Y axis. There is a very distinct boundary, with matches above the Y = X line predominantly being in favor of black, and matches below the line in favor of white. The graph on the right shows white's win rate plotted against the rating difference between the white and black players. Again, there is a very clear linear relationship between rating advantage and the proportion of games won.

## Model Development

Please note that the models in this project are rule based, created from direct observations of general trends in the data, rather than being "trained" on it in the traditional sense. For this reason I chose not to seperate the main training data into training and validation sets, instead opting to use the entire training set as a whole. Smaller datasets lead to weaker generalizations, and would be more prone to sampling variance than using all the training data available. I believe this decision was justified, and I hope the details in the following sections will make the rationale behind it clear to the reader.

Randomly picking a winner results in an accuracy of about 50%. Picking white to win for every match yields a slightly improved 52% accuracy due to the first move advantage discussed previously. Always picking the higher rated player as the winner across the entire training set gives correct predictions about 65% of the time.

<div align = "center">

| Algorithm | Accuracy |
| :-: | :-: |
| Random Guess | 0.5014397 |
| White Always Wins | 0.5223870 |
| Higher Rated Wins | 0.6457673 |

</div>

"Higher rated wins" is a very good rule, but it can be improved. As we saw earlier, games with a larger rating gap have a higher proportion of wins in favor of the higher rated player. The graph below shows the effect on accuracy and dataset size if we only look at games where the rating difference is above some cutoff threshold:

<img src="/chess/graphs/cutoff_subsetting1.png" align="center" alt="Cutoff Subsetting"
	title="Cutoff Subsetting"/>

We see from the graph that we can arbitrarily increase the accuracy of "higher rated wins" by simply adding the stipulation "as long as the rating difference is greater than X." The tradeoff is that the rule will only be applicable to a correspondingly small subset of the data, indicated by the red line. "The higher rated player will win, as long as there is more than an 800 point rating advantage" may be true close to 100% of the time, but the proportion of games with such a large rating difference is so small that the rule is effectively useless. As shown by the green line, there is no point at which the accuracy gain outweighs the reduction in dataset size. The Accuracy * Percentage product shows the proportion of the full dataset our rule is able to make correct predictions on, and it strictly decreases as the rating advantage requirement increases.

However, the green line is slightly misleading, because it assumes that all predictions we make on the remainder of the data (eg. games where the rating difference is *less* than the threshold value) will be wrong. Even randomly guessing the outcome will be correct half of the time, so the green line is more correctly interpreted as a lower bound for our model's performance. Let's examine the data from the opposite perspective. Below is a chart showing the accuracy of "higher rated wins" when restricting the dataset to a *maximum* rating advantage cutoff:

<img src="/chess/graphs/cutoff_subsetting2.png" align="center" alt="Cutoff Subsetting"
	title="Cutoff Subsetting"/>

A high maximum allowed rating difference (the far left of the graph) will include most games in the dataset, so the rule performs similarly as when it is applied to all the data (the dashed blue line). But the more we decrease the maximum rating advantage, the worse the algorithm performs. For sets where there is very little difference in rating between the two players, the higher rated player is really only better on paper, and predicting the higher rated player to win in these cases is akin to picking a winner at random. In the gray portion of the graph, the 2% first mover advantage means that even "white always wins" (the dashed red line) has higher accuracy than "higher rated wins."

---

#### A Side Note for Clarity

As an aside, the dashed red line is the accuracy of "white always wins" calculated for the entire dataset, *not* the subsetted data. But remember that we take white's first move advantage to be a constant, and so, assuming that there is a constant skill (not rating) distribution across both sides in every subset, this should be a fair substitution. Below is a graph of the actual accuracy of "white always wins" on the same subsetted data as the chart above, shown as the solid red line, compared to the accuracy of "white always wins" when taken on the whole dataset, shown as the dashed red line. We see that it stays centered around the value calculated for the whole dataset, and we can attribute deviations from it to sampling variance, not to changes in white's advantage caused by restrictions in rating difference.

<img src="/chess/graphs/cutoff_subsetting2-white_wins.png" align="center" alt="Cutoff Subsetting"
	title="Cutoff Subsetting"/>

---

We can see from the output below that the transition occurs at around 55 points in rating difference. When there is more than a 55 point rating advantage in either direction, we can confidently predict in favor of the higher rated player. However, there are close to 5000 games for which this prediction method performs worse than guessing "white always wins", and for these games we should switch to a different rule.
```
> tuning_results_2[which(tuning_results_2$accuracy < by_majority_acc),]
      accuracy dataset_size cutoff
1236 0.5215301         4784     55
```

The following graph shows the performance of an hybrid model which switches between "white always wins" when the rating difference is below a certain threshold, and "higher rated player wins" when it is above the threshold.

<img src="/chess/graphs/cutoff_subsetting3_standard.png" align="center" alt="Cutoff Subsetting"
	title="Cutoff Subsetting"/>

 <img src="/chess/graphs/cutoff_subsetting3_zoomed.png" align="center" alt="Cutoff Subsetting"
	title="Cutoff Subsetting"/>

If we set the switch to occur at a very high cutoff (the left side of the top graph), we're predominantly using the "white always wins" rule, because almost all games have a rating difference of that value or lower. In these cases, the hybrid model performs similarly to using "white always wins" on all the data. At the extreme right, we set the switch to occur when the rating difference is 0, so the model uses "higher rated wins" for all games, and the accuracy matches the output of that rule exactly (the dashed blue line). But for the small, non-zero values on the right, shown zoomed in on the second graph, the ensemble switches over to "white always wins" just as "higher rated wins" loses its predictive power - when we set the switch to occur within this window, the ensemble model outperforms both of the individual "higher rated wins" and "white always wins" rules.

---

Finally let's try some better prediction rules than "white always wins" for the remaining subset. The graph below shows two alternatives. The first, `rating_bin_winner`, divides the dataset into rating bins. The bins start at 800, and increase in increments of 100 all the way up to 2400. Each match is placed into a rating bin, determined by the average rating of the two players. Instead of always guessing white for every match which falls below our rating advantage cutoff, we now look at which rating bin the match belongs to, and pick the side most likely to win for that bin. This shows a very slight improvement over `white_always_wins`, but not by much. As discussed earlier, the average rating of players in the match has little effect on whether white or black wins, so this improvement might be the result of slight overfitting to the training data.

<img src="/chess/graphs/cutoff_subsetting_combined.png" align="center" alt="Cutoff Subsetting"
	title="Cutoff Subsetting"/>

However, the `eco_winner` method does show a marked improvement over the two other methods. In an earlier section, we saw that some openings were very advantageous for white, and other openings advantageous for black. With this method, when one side's rating advantage falls below the cutoff, we look at the `opening_eco` code for the match, and we predict a winner based on which side is more likely to win given the opener that was used. This was the model which was picked going into the final analysis.


## Results:
A results section that presents the modeling results and discusses the model performance.

(TODO: Maybe broad overview of other methods used and their results)

The model which was used for final testing on the holdout set was the hydrid model consisting of picking the higher rated player to win when the rating difference was greater than a threshold, and picking the majority winner of the ECO group when the rating difference was below the threshold.

The final threshold value was decided as the average between the two values which gave the highest accuracy in the training set, 69 and 52.

```
> head(tuning_results_2[order(tuning_results_2$accuracy, decreasing = TRUE), ])
    accuracy cutoff
70 0.6601641     69
53 0.6600921     52
69 0.6599482     68
54 0.6596602     53
55 0.6595883     54
71 0.6595883     70
```

The final results are tallied below. The Higher Rated Wins / ECO Wins Hybrid model performed in line with the other hybrid models on the test set, which all outperformed the "White Always Wins" static model. However, it performed suprisingly poorly when compared to the single rule "Higher Rated Always Wins" on the final test set, and in general exhibited worse performance against the other hybrid models than I expected.

<div align = "center">

| Algorithm | Final Test Accuracy |
| :-: | :-: |
| White Always Wins | 0.5148964 |
| Higher Rated Always Wins | 0.6729275 |
| White Wins Hybrid | 0.6560881 |
| Rating Bin Hybrid | 0.6573834 |
| ECO Winner Hybrid | 0.6554404 |

</div>

I had a suspicion that this might be due to my choice of cutoff threshold, so I plotted the cutoffs against the accuracy in the final model, shown on the graph below. The dashed vertical line indicates the threshold value used for the final test.

<img src="/chess/graphs/final_hybrid.png" align="center" alt="Final Hybrid Model"
	title="Final Hybrid Model"/>

The graph reveals that ECO Winner Hybrid model actually does perform better than the other hybrid models for most cutoff values, and it's only towards the end that all the hybrid models compress together. That was a relief.

However, the final test set exhibits significantly different behavior than the training set. In the training set we saw a window in which the accuracy of always predicting the higher rated player would dip below a certain threshold, at which point it became more beneficial to switch over to another prediction rule. In the final test set, there was virtually no threshold value at which it becomes better to switch out of picking the higher rated player, indicated by the dashed blue line. It is almost always better to just pick the higher rated player.

<img src="/chess/graphs/final_hybrid_2.png" align="center" alt="Final Hybrid Model"
	title="Final Hybrid Model"/>

I tried with several seed values to create the holdout / training split. The above is the test repeated with `set.seed(100)`. ECO Winner consistently outperforms the other hybrid models in most cases, but the threshold value derived from the test set does not always fall within the optimum range. With different seed values, we do see regular occurrences where there is a window at which it is beneficial to switch prediction rules, but the position of this window shifts depending on the seed value.

The shift is so significant that cross validation would not have helped to alleviate this issue. Even if we ran the test several times with different splits, we still need to average down to one threshold value, and there is no guarantee that it would fall within the window. I believe the only way to overcome this is with a larger dataset, where the position of the window is less sensitive to changes in seed value. This way we would have confidence that the range in which to switch prediction rules is consistent across the training and test sets, and we would have a better idea of where to set the threshold value. Additional testing with a larger dataset is necessary to verify this theory.

## Conclusion:
A conclusion section that gives a brief summary of the report, its potential impact, its limitations, and future work.

The rating system holds such high predictive power that for the majority of matches, we don't need to look beyond which player has the higher rating. However, when the rating difference between two players is sufficiently small, the accuracy of simply guessing the higher rated player drops to around 50%, and we can make more accurate predictions by switching to an alternative method. Any method that gets more than half the predictions right on this subset would be an improvement. Three methods were tried in this project. The most basic was to guess that white will always win, motivated by the first mover advantage, which showed white winning slightly more than half of the time. The next was to predict the outcome based on the average rating of the two players in the match. This showed a minor improvement, but because our data analysis had indicated there was no discernible effect on the winning side as a function of the level of play, this improvement may be indicative of overfitting. The last method was to predict winners in this subset based on the effectiveness of their opening strategy, and this gave the most substantial improvement, resulting in a final accuracy of 0.6554404 on the holdout test set.

However, it became clear that the dataset size is a limiting factor in determining where the optimal switching window occurs. Depending on the seed value used for the test / train set split, the position of the window shifted dramatically, indicating that it was subject to significant sample variance due to small sample size. Further investigation with a larger dataset is warranted. LiChess has data for all the matches played on their service available for download, but these datasets are tens of gigabytes each for a single month's worth of matches, and therefore beyond the scope of this project.

## References:
https://www.kaggle.com/datasets/datasnaek/chess?resource=download

https://en.wikipedia.org/wiki/First-move_advantage_in_chess
https://en.wikipedia.org/wiki/Philidor_Defence
https://en.wikibooks.org/wiki/Chess_Opening_Theory/ECO_volume_A
https://en.wikibooks.org/wiki/Chess_Opening_Theory/ECO_volume_C
https://en.wikibooks.org/wiki/Chess_Opening_Theory/ECO_volume_D
