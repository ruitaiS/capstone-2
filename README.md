# Chess Game Outcome Prediction:


TODO:
* Find synonyms for indicates
* Read over intro section; talk about analysis more maybe?


### Stuff idk where it goes yet

Increasing the minimum rating advantage also increases the likelihood the higher rated player will win. However, the dataset also becomes more restricted, because there are fewer games with larger rating differences. We can pick as high of an accuracy of we want, all the way up to 100% accuracy, but the tradeoff is that the algorithm will only be applicable to a correspondingly small subset of the data (note that once the accuracy reaches 100% it never goes back down - this is because we're essentially saying "For all games of this rating difference or greater, the outcome of every game can be predicted by guessing the higher rated player." Increasing the rating cutoff past here only leads to an unnecessary reduction in the dataset size).

As the green line shows, the increase in accuracy never outstrips the decrease in dataset size. The Accuracy * Percentage product shows the proportion of the full dataset we're able to make correct predictions on. A cutoff that gives 100% accurate predictions but is only applicable to 50% of the dataset would be less valuable than a cutoff that gives 60% accurate predictions, but is applicable to the full dataset, because the former would only be able to make correct predictions for 50% of the data, while the latter would give correct predictions for 60%.

---


Linear model for white's win rate as predicted by the rating difference

```
> summary(lm_model)

Call:
lm(formula = wr ~ rating_diff, data = plot_df)

Residuals:
     Min       1Q   Median       3Q      Max 
-0.61550 -0.07892 -0.00039  0.08025  0.44467 

Coefficients:
             Estimate Std. Error t value Pr(>|t|)    
(Intercept) 5.174e-01  4.513e-03   114.7   <2e-16 ***
rating_diff 9.707e-04  1.911e-05    50.8   <2e-16 ***
---
Signif. codes:  0 ‘***’ 0.001 ‘**’ 0.01 ‘*’ 0.05 ‘.’ 0.1 ‘ ’ 1

Residual standard error: 0.1239 on 752 degrees of freedom
Multiple R-squared:  0.7743,	Adjusted R-squared:  0.774 
F-statistic:  2580 on 1 and 752 DF,  p-value: < 2.2e-16
```


---------
Finally I looked at the number of moves taken during the match. I didn't expect for this to be a good predictor of game outcome, but I was intereseted to know whether more moves would increase the likelihood of certain win conditions (eg. resignations), or whether the player's ranking would be predictive of the length of a match. The charts are shown below:

* Moves vs. victory status
* average player ranking vs. number of moves
* 

----

The early game in chess has been studied extensively. In comparison to the seemingly countless directions a match might go in, there are only a finite number of opening moves and sequences for the players to take at the beginning of the game.  but volumes have been written dedicated to the specific strengths and weaknesses of different opening moves. Even the advantage of white has been extensively analyzed.

Below 1200: Novice or Beginner
1200 - 1400: Beginner to Intermediate
1400 - 1600: Intermediate
1600 - 1800: Intermediate to Advanced Beginner
1800 - 2000: Advanced Beginner to Lower Intermediate
2000 - 2200: Lower Intermediate to Intermediate
2200 - 2400: Intermediate to Advanced
2400 and above: Advanced to Expert

unless otherwise specified (such as in the rating binning section), we will assume a constant skill distribution across players for every subset of the data, and so we model this advantage as a constant proportion centered on the mean across the dataset, attributing any deviation to random variance (especially pronounced for small sample sizes, as seen in the plot below)

<img src="/chess/graphs/cutoff_subsetting2-white_wins.png" align="center" alt="Cutoff Subsetting"
	title="Cutoff Subsetting"/>

## Introduction:
An introduction/overview/executive summary section that describes the dataset and variables, and summarizes the goal of the project and key steps that were performed.

The goal of this project to apply a machine learning model to predict the outcome of a chess match based only on player data and their opening moves.

For me chess is one of those things that I wish I was good at, but which I also can't justify spending the amount of time needed to actually learn properly. I understand some broad principles, like controlling the center of the board, maintaining good pawn structure, or developing your pieces to set yourself up in advantageous positions later on in the match, but I admit I know very little about specific opening sequences or the relative strengths and weaknesses of various opening tactics. If you are well versed in chess knowledge, this project most likely will not tell you anything you don't already know. It is really more of a backdrop (TODO Is this even the right word) to apply some of the data science techniques I learned in this course than it is an attempt to derive any meaningful insights about chess itself.

The final model is a hybrid approach. The rating difference between two players is the main predictor - when the rating difference is (TODO) points or larger, the model always favors the higher rated player to win. However, when the rating difference is small, it switches over to the (todo) "white always wins" model due to white's first move advantage. Some alternative methods were explored (rating binning, and grouping by first three opening moves), but neither showed improvement over "white wins." I believe this was largely due to an insufficiently large dataset size - only about (todo, check) 5000 games had players with ratings close enough that the rating difference was not overpowering (todo, rephrase), and further subdividing these games along the average rating of the two players and their opening moves created very small sample sizes that held little predictive power. This is definitely an avenue for further research and investigation.

In the end the hybrid model was able to predict games with an accuracy of (todo) on the test set, which is a very slight improvement over the (todo) given by predicting the higher rated player to win.

## Analysis:
A methods/analysis section that explains the process and techniques used, including data cleaning, data exploration and visualization, any insights gained, and your modeling approach. At least two different models or algorithms must be used, with at least one being more advanced than linear or logistic regression for prediction problems.

### Preprocessing:

The LiChess dataset used for this project contains games between several thousand players of varying skill ratings, from less than 1000 (beginner) to over 2400 (grandmaster). Each row in the dataset is a record of a single game. `white_id`, `white_rating`, `black_id`, and `black_rating` indicate the player ID and rating for the player on the white and black side. `victory_status` shows how the match ended, and can be `resign`, `mate`, `outoftime`, or `draw`. The `rated` column is somewhat misleading - the players involved still have ratings, but it indicates whether the match is rated (each player's ratings will be updated to reflect the outcome of the match) or casual (the outcome does not affect the player rating). `opening_eco`, `opening_name`, and `opening_ply` refer to the ECO category of the opening sequence, an English language name for the sequence, and the number of moves it took to complete. The `winner` column was recoded to use 1 if the winner was white, and 0 if the winner was black. `moves` was also recoded from a space seperated single string to a list of strings. These recodings allowed for easier processing later on.

Several metadata columns - `id`, `created_at`, `last_move_at`, `turns`, and `increment_code` - were removed. The first four provide unnecessary or redundant information, but `increment_code` is interesting because it indicates the time format of the game. For example, an increment code of `15+30` means that each player starts with a total of 15 minutes, and is granted 30 extra seconds each turn. The amount of time allotted certainly has an effect on the way that the game is played, but I ultimately decided to omit this column for the sake of simplicity.

For this project, I focused only on rated games that had a decisive outcome. Games which ended in stalemates (`victory_status == "draw"`) or which were unrated (`rated == false`) were removed from the dataset. After trimming, a dataset of 15,436 games remained. `createDataPartition` was applied to this dataset, with `p = 0.1` and the response vector set to the `winner` column, creating a training set of 13,892 games and a holdout test set of 1,544 games, with the proportion of winners equally distributed across both datasets.

A `players` dataframe was also created, with statistics for each individual player:
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



## Player Rating

Lichess uses the Glicko 2 rating system, which starts players off with a rating of 1500, adjusting it as the players play more games and accumulate more wins and losses. Since it is a numerical representation of a player's skill level, it is, as one might expect, a very reliable predictor of the outcome of a match. (TODO: Left graph should show boundary line too)

<div style="display: flex; justify-content: space-between; width: 100%;">
    <img src="/chess/graphs/white_vs_black_ratings.png" style="width: 45%;" alt="White vs. Black Rating" title="White vs. Black Rating"/>
    <img src="/chess/graphs/wr_by_rating_diff_filtered_regline.png" style="width: 45%;" alt="Rating Difference Vs. Win Rate" title="Rating Difference Vs. Win Rate"/>
</div>

The graph on the left plots the winner of each match by color, with `white_rating` on the X axis and `black_rating` on the Y axis. There is a very distinct boundary, with matches above the Y = X line predominantly being in favor of black, and matches below the line in favor of white. The graph on the right shows white's win rate plotted against the rating difference between the white and black players. Again, there is a very clear linear relationship between rating advantage and the proportion of games won.

## Model Development

(TODO: You say training a lot here)
Please note that the models in this project are rule based, created from direct observations of general trends in the data, rather than being "trained" on it in the traditional sense. For this reason I chose not to seperate the main training data into training and validation sets, instead opting to use the entire training set as a whole. Smaller datasets lead to weaker generalizations, and would be more prone to sampling variance than using all the training data available. I believe this decision is justified, and I hope the details in the following sections will make the rationale behind it clear to the reader.

Randomly picking a winner results in an accuracy of about 50%. Picking white to win for every match yields a slightly improved 52% accuracy due to the first move advantage discussed previously. Always picking the higher rated player as the winner across the entire training set gives correct predictions about 65% of the time.

| Algorithm | Accuracy |
| :-: | :-: |
| Random Guess | 0.5014397 |
| White Always Wins | 0.5223870 |
| Higher Rated Wins | 0.6457673 |

"Higher rated wins" is a very good rule, but it can be improved. As we saw earlier, games with a larger rating gap have a higher proportion of wins in favor of the higher rated player - there is a directly linear relationship between the predictive power of the rule and the rating advantage. The graph below shows the effect on accuracy and dataset size if we only look at games where the rating difference is above some cutoff threshold:

<img src="/chess/graphs/cutoff_subsetting1.png" align="center" alt="Cutoff Subsetting"
	title="Cutoff Subsetting"/>

We see from the graph that we can arbitrarily increase the accuracy of "higher rated wins" by simply adding the stipulation "as long as the rating difference is greater than X." The tradeoff is that the rule will only be applicable to a correspondingly small subset of the data, indicated by the red line. "The higher rated player will win, as long as there is more than an 800 point rating advantage" may be true close to 100% of the time, but the proportion of games with such a large rating difference is so small that the rule is effectively useless. As shown by the green line, there is no point at which the accuracy gain outweighs the reduction in dataset size. The Accuracy * Percentage product shows the proportion of the full dataset our rule is able to make correct predictions on, and it strictly decreases as the rating advantage requirement increases.

However, the green line is slightly misleading, because it assumes that all predictions we make on the remainder of the data (eg. games where the rating difference is *less* than the threshold value) will be wrong. Even randomly guessing the outcome will be correct half of the time, so the green line is more correctly interpreted as a lower bound for our model's performance. Let's examine the data from the opposite perspective. Below is a chart showing the accuracy of "higher rated wins" when restricting the dataset to a *maximum* rating advantage cutoff:

<img src="/chess/graphs/cutoff_subsetting2.png" align="center" alt="Cutoff Subsetting"
	title="Cutoff Subsetting"/>

A high maximum allowed rating difference (the far left of the graph) will include most games in the dataset, so the rule performs similarly as it would if we'd applied it to the entire dataset (the dashed blue line). But if we only look at games where there is a very small rating difference between the two players, 

 * For sets with very small maximum allowed differences (the gray portion of the graph), the difference in rating between the two players is largely an artifact of the way the rating system scores players, and the model performs similarly to picking a winner at random. At these minute rating differences, even the 2% first mover advantage (the dashed red line) overshadows the predictive power of the rating system.


Here, instead of looking at how well the algorithm performs when the rating difference is large, we're looking at how poorly the algorithm performs when the rating difference is small. 

However, the more we restrict the maximum rating advantage, the worse the algorithm performs. For sets where there is very little difference in rating between the two players, the higher rated player is really only better on paper, and predicting the higher rated player to win in these cases is akin to picking a winner at random. 

the model performs worse than guessing white wins every game, shown by the dashed red line (The actual performance of "white always wins" is not shown because white's win rate is assumed to be constant for all sets of games where skill between the two sides is equally distributed, as discussed earlier - TODO: Rephrase)



  We can see that the cutoff at which this occurs is 55. When there is more than a 55 point rating advantage in either direction, we should strictly predict in favor of the higher rated player. However, there is a dataset of close to 5000 games for which this prediction method performs worse than guessing "white always wins", and therefore should be switched out for another algorithm
```
> tuning_results_2[which(tuning_results_2$accuracy < by_majority_acc),]
      accuracy dataset_size cutoff
1236 0.5215301         4784     55
```

Let's start with the simplistic "white always wins." The next graph shows the performance of an ensemble model which switches between "white always wins" and "higher rated player wins" depending on whether the rating difference is below a certain threshold.

<img src="/chess/graphs/cutoff_subsetting3_standard.png" align="center" alt="Cutoff Subsetting"
	title="Cutoff Subsetting"/>

 <img src="/chess/graphs/cutoff_subsetting3_zoomed.png" align="center" alt="Cutoff Subsetting"
	title="Cutoff Subsetting"/>

 * For small rating difference cutoffs ( the right side, and zoomed in portion of the graph), this ensemble outperforms the "higher rated player wins" model.
 * For a rating difference cutoff of 0, the ensemble never switches out of "higher rated player wins" for any of the games and so it matches the output of that model (the dashed blue line).
 * For very large rating difference cutoffs (the left side of the graph), we're switching to "white always wins" for almost all the games, and so it matches the output of that model (the red dashed line)

We will now focus on improving performance over "white always wins" in this subsetted group where the rating difference is 55 points or lower. If it substantially outperforms, we may need to go back and revisit the transition cutoff out of "higher rated wins" to the new model.

 * Rating Bins for the players in this group
 * opening eco win rate for each group
 * something akin to a decision tree I think. What rating bin are they in; based on that rating bin, and the opening moves, what is the most likely outcome. If we haven't seen any games with those opening moves, then pick white.


## Results:
A results section that presents the modeling results and discusses the model performance.

## Conclusion:
A conclusion section that gives a brief summary of the report, its potential impact, its limitations, and future work.

## References:
A references section that lists sources for datasets and/or other resources used, if applicable.

### Grading Rubric (TODO: Remove)
* 0 points: The report is either not uploaded or contains very minimal information AND/OR the report is not written in English AND/OR the report appears to violate the terms of the edX Honor Code.

* 5 points: One or more required sections of the report are missing.

* 10 points: The report includes all required sections, but the report is significantly difficult to follow or missing significant supporting detail in multiple sections.

* 15 points: The report includes all required sections, but the report has flaws: it is difficult to follow and/or missing supporting detail in one section and/or has minor flaws in multiple sections and/or does not demonstrate mastery of the content.

* 15 points: The report is otherwise fine, but the project is a variation on the MovieLens project.

* 20 points: The report includes all required sections and is easy to follow, but with minor flaws in one section.

* 25 points: The report includes all required sections, is easy to follow with good supporting detail throughout, and is insightful and innovative.
