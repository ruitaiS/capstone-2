# Chess Game Outcome Prediction:

## Introduction:
An introduction/overview/executive summary section that describes the dataset and variables, and summarizes the goal of the project and key steps that were performed.

## Methods / Analysis:
A methods/analysis section that explains the process and techniques used, including data cleaning, data exploration and visualization, any insights gained, and your modeling approach. At least two different models or algorithms must be used, with at least one being more advanced than linear or logistic regression for prediction problems.

<img src="/chess/graphs/openers_count_density.png" align="center" alt="Density Plot of Instances of Each Opener"
	title="Density Plot of Instances of Each Opener"/>

<img src="/chess/graphs/white_vs_black_ratings.png" align="center" alt="White vs. Black Rating"
	title="White vs. Black Rating"/>

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

It's interesting to note that A00, the collection of unconventional opening moves by white, has a very high win rate for black. In constrast, white is generally favored to win in chess because of the [first move advantage](https://en.wikipedia.org/wiki/First-move_advantage_in_chess), and our dataset shows this:

```
> mean(main_df$winner)
[1] 0.5220334
```

I had initially approached this question from the perspective of finding the most advantageous opening moves used by experienced players as a way to predict wins, but it's clear that irregular opening moves used by novice players are just as powerful, if not more powerful, predictors of losses.

## Results:
A results section that presents the modeling results and discusses the model performance.

## Conclusion:
A conclusion section that gives a brief summary of the report, its potential impact, its limitations, and future work.

## References:
A references section that lists sources for datasets and/or other resources used, if applicable.

* https://www.kaggle.com/datasets/imtkaggleteam/vehicle-insurance-data - Vehicle Insurance Dataset
* https://arxiv.org/abs/2302.10612 - Tree-Based Machine Learning Methods For Vehicle Insurance Claims Size Prediction

### Grading Rubric (TODO: Remove)
* 0 points: The report is either not uploaded or contains very minimal information AND/OR the report is not written in English AND/OR the report appears to violate the terms of the edX Honor Code.

* 5 points: One or more required sections of the report are missing.

* 10 points: The report includes all required sections, but the report is significantly difficult to follow or missing significant supporting detail in multiple sections.

* 15 points: The report includes all required sections, but the report has flaws: it is difficult to follow and/or missing supporting detail in one section and/or has minor flaws in multiple sections and/or does not demonstrate mastery of the content.

* 15 points: The report is otherwise fine, but the project is a variation on the MovieLens project.

* 20 points: The report includes all required sections and is easy to follow, but with minor flaws in one section.

* 25 points: The report includes all required sections, is easy to follow with good supporting detail throughout, and is insightful and innovative.
