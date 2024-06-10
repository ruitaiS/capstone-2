# Chess Game Outcome Prediction:

## Introduction:
An introduction/overview/executive summary section that describes the dataset and variables, and summarizes the goal of the project and key steps that were performed.

## Methods / Analysis:
A methods/analysis section that explains the process and techniques used, including data cleaning, data exploration and visualization, any insights gained, and your modeling approach. At least two different models or algorithms must be used, with at least one being more advanced than linear or logistic regression for prediction problems.

* Data cleaning (no draws, rated games only, moves from string into list)
* Players dataframe
* Rating bins
* N-length opening sequence bins
* Opener ECO bins


The first thing I did was to compare the game outcomes with the player ratings. Lichess uses the Glicko 2 rating system, which starts players off with a rating of 1500, adjusting it as the players play more games and accumulate more wins and losses. Since it is a numerical representation of a player's skill level, it is, as one might expect, a very reliable predictor of the outcome of a match.

<div style="display: flex; justify-content: space-between; width: 100%;">
    <img src="/chess/graphs/white_vs_black_ratings.png" style="width: 45%;" alt="White vs. Black Rating" title="White vs. Black Rating"/>
    <img src="/chess/graphs/wr_by_rating_diff_filtered_regline.png" style="width: 45%;" alt="Rating Difference Vs. Win Rate" title="Rating Difference Vs. Win Rate"/>
</div>


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


Next I wanted to check the effect of various opening plays on the final outcome of a match. Looking at the density plot, some openers are much more frequently used than others, and I wanted to know whether it was because they were more consistently successful in securing a win.

<img src="/chess/graphs/openers_count_density.png" align="center" alt="Density Plot of Instances of Each Opener"
	title="Density Plot of Instances of Each Opener"/>

Common Opening ECO Codes:
```
opening_eco opener_wr count
         A00 0.4107383   745
         C00 0.5281065   676
         D00 0.4874101   556
         B01 0.5174312   545
         C41 0.5928705   533
         C20 0.4842520   508
```

I was curious what these openers were that seemed so popular, so I did some research.

From [Wikipedia](https://en.wikipedia.org/wiki/Irregular_chess_opening#Unusual_first_moves_by_White):
> The vast majority of high-level chess games begin with either 1.e4, 1.d4, 1.Nf3, or 1.c4. Also seen occasionally are 1.g3, 1.b3, and 1.f4. Other opening moves by White, along with a few non-transposing lines beginning 1.g3, are classified under the code "A00" by the Encyclopaedia of Chess Openings and described as "uncommon" or "irregular". Although they are classified under a single code, these openings are unrelated to each other.

From Chess Opening Theory - ECO Volumes [A](https://en.wikibooks.org/wiki/Chess_Opening_Theory/ECO_volume_A) [C](https://en.wikibooks.org/wiki/Chess_Opening_Theory/ECO_volume_C) and [D](https://en.wikibooks.org/wiki/Chess_Opening_Theory/ECO_volume_D) :
> A00: Uncommon Openings

> C00: French Defence, unusual White second moves

> D00: 1.d4 d5 unusual lines

It turns out these are actually collections of unrelated, "unsuual" opening sequences. This reflects the fact that our dataset is from a free online chess service, and most players are beginners, with over 75% of them having played 2 games or fewer recorded on the service.

```
> summary(players$total_games)
   Min. 1st Qu.  Median    Mean 3rd Qu.    Max. 
  1.000   1.000   1.000   2.362   2.000  82.000 
```

The high proportion of beginner players makes the machine learning task a little tricker - it seemed to me that the outcome of these games would be much more chaotic than games between experienced players, who might have a more reasoned approach, and I wondered if the opening moves held any predictive power at all, given that they were more likely than not chosen at random.

<img src="/chess/graphs/wins_by_opener_top_25.png" align="center" alt="Win Comparison of the Top 25 Most Played Openers"
	title="Win Comparison of the Top 25 Most Played Openers"/>

It's interesting to note that A00, the collection of unconventional opening moves by white, has a very high win rate for black. White is generally favored to win in chess because of the [first move advantage](https://en.wikipedia.org/wiki/First-move_advantage_in_chess), and our dataset shows this:

```
> mean(main_df$winner)
[1] 0.5220334
```

This got me thinking. I had initially approached this question from the perspective of finding the most advantageous opening moves used by experienced players as a way to predict wins, but the data seems to suggest that irregular opening moves used by novice players are just as powerful, if not more powerful, predictors of losses.

<div style="text-align:center;">
<img src="/chess/graphs/C41.png" align="center" alt="C41 - Philidor Defense" title="C41 - Philidor Defense"/>
</div>

Interestingly, [C41](https://en.wikipedia.org/wiki/Philidor_Defence), which has a very high win rate for white in our dataset, is actually considered a good defensive move for black.

> Today, the Philidor is known as a solid but passive choice for Black, and is seldom seen in top-level play except as an alternative to the heavily analysed openings that can ensue after the normal 2...Nc6. It is considered a good opening for amateur players who seek a defensive strategy that is simpler and easier to understand

Maybe this is because it is favored by newer players who might have just only begun to memorize some set openings, and who have yet to develop a very sophisticated playbook, but I can really only speculate; I don't personally know enough to say.

Finally I looked at the number of moves taken during the match. I didn't expect for this to be a good predictor of game outcome, but I was intereseted to know whether more moves would increase the likelihood of certain win conditions (eg. resignaions), or whether the player's ranking would be predictive of the length of a match. The charts are shown below:

* Moves vs. victory status
* average player ranking vs. number of moves
* 

### Simple Algorithms

(TODO: Write better) 
Like with the movielens project, I started out with some very basic prediction methods. Randomly picking a winner predictably results in an accuracy of (TODO), but what may be surprising is that picking white to win every game actually has a higher accuracy, at (TODO). One might assume that both sides are equally likely to win, but actually is not the case.



* Guessing the winner leads to around 50% correct rate

* Guessing white as the winner every match yields around 52% correct rate. This is caused by white's first move advantage[first move advantage](https://en.wikipedia.org/wiki/First-move_advantage_in_chess)
 
> Since 1851, compiled statistics support this view; White consistently wins slightly more often than Black, usually achieving a winning percentage between 52 and 56 percent.[nb 1] White's advantage is less significant in games ... between lower-level players, and becomes greater as the level of play rises... As the standard of play rises, all the way up to top engine level, the number of decisive games approaches zero, and the proportion of White wins among those decisive games approaches 100%

* Whites' first move advantage is more pronounced at higher skill levels, and less so at lower levels. For the most part, unless otherwise specified (such as in the rating binning section), we will assume a constant skill distribution across players for every subset of the data. 

<img src="/chess/graphs/cutoff_subsetting2-white_wins.png" align="center" alt="Cutoff Subsetting"
	title="Cutoff Subsetting"/>

 
* Always guess higher rated player
* 

### Ensembling Based On Rating Difference Cutoffs

Always predicting the higher rated player to win is a very good baseline algorithm, but we can improve on it. The graph below shows the effect on accuracy and dataset size if we confine the data to only rows where the rating difference is at a cutoff threshold or higher:

<img src="/chess/graphs/cutoff_subsetting1.png" align="center" alt="Cutoff Subsetting"
	title="Cutoff Subsetting"/>

Increasing the minimum rating advantage also increases the likelihood the higher rated player will win. However, the dataset also becomes more restricted, because there are fewer games with larger rating differences. We can pick as high of an accuracy of we want, all the way up to 100% accuracy, but the tradeoff is that the algorithm will only be applicable to a correspondingly small subset of the data (note that once the accuracy reaches 100% it never goes back down - this is because we're essentially saying "For all games of this rating difference or greater, the outcome of every game can be predicted by guessing the higher rated player." Increasing the rating cutoff past here only leads to an unnecessary reduction in the dataset size).

As the green line shows, the increase in accuracy never outstrips the decrease in dataset size. The Accuracy * Percentage product shows the proportion of the full dataset we're able to make correct predictions on. A cutoff that gives 100% accurate predictions but is only applicable to 50% of the dataset would be less valuable than a cutoff that gives 60% accurate predictions, but is applicable to the full dataset, because the former would only be able to make correct predictions for 50% of the data, while the latter would give correct predictions for 60%.

However, the green line is slightly misleading, because it assumes that whatever algorithm we use for the remainder of the data will always get the prediction wrong. It is more correctly interpreted as a lower bound for any ensemble algorithm we use with that cutoff - we already know that even if we always guess white for the remaining data, we should get slightly more than half of the remaining data correct.

Before we get into that, let's examine the data from the opposite perspective. Below is a chart showing the accuracy of the algorithm when restricting the dataset to a maximum rating advantage cutoff. Here, instead of looking at how well the algorithm performs when the rating difference is large, we're looking at how poorly the algorithm performs when the rating difference is small. When the maximum allowed rating advantage is very large, we have close to the full dataset, so the performance at larger cutoffs approximates the performance when applied to the full dataset, shown as the dashed blue line. However, the more we restrict the maximum rating advantage, the worse the algorithm performs. For sets where there is very little difference in rating between the two players, the higher rated player is really only better on paper, and predicting the higher rated player to win in these cases is akin to picking a winner at random. 

the model performs worse than guessing white wins every game, shown by the dashed red line (The actual performance of "white always wins" is not shown because white's win rate is assumed to be constant for all sets of games where skill between the two sides is equally distributed, as discussed earlier - TODO: Rephrase)

<img src="/chess/graphs/cutoff_subsetting2.png" align="center" alt="Cutoff Subsetting"
	title="Cutoff Subsetting"/>
 * Any set with large maximum allowed rating differences (the far left of the graph) includes most of the dataset, so the model performs similarly as it would if we'd applied it to the entire dataset (the dashed blue line)
 * Any set with very small maximum allowed differences (the gray portion of the graph), the difference in rating between the two players is largely an artefact of the way the rating system scores players, and the model performs similarly to picking a winner at random. At these minute rating differences, even the 2% first mover advantage overshadows the predictive power of the rating system.

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
