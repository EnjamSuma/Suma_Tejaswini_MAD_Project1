# AI Feature: Lunch Lens

## 1. What it does

Lunch Lens suggests what a meal will probably cost next time, based on what the user actually paid before. It appears on the meal detail screen as "Lunch Lens (rule-based estimate)", with a one-line explanation such as "Mean of your last 3 purchases ($4.50, $6.00, $7.50), 2026-10-21 to 2026-10-27. Suggested, not guaranteed."

It is a **rule-based estimator**, not a trained machine-learning model. It is "AI" in the sense of a data-driven prediction from the user's own history, and the write-up says so plainly.

## 2. Method

Code: `estimateNextCost` in `lib/domain/lunch_lens.dart`.

1. Take the purchase history for one meal.
2. Keep only purchases that are **final** and have a **non-negative** price. If a `beforeDate` is given, keep only purchases before it, so a purchase can never predict itself.
3. Sort newest first. If two purchases have the same date, the one with the higher log id counts as newer.
4. If fewer than **3** purchases remain, return no estimate. The screen shows "Not enough history".
5. Otherwise take the last 3 and compute their mean, rounded to the nearest minor unit (cent) using integer arithmetic: `(2 * sum + 3) ~/ 6`, so halves round up.
6. Also return a **baseline**: the single most recent price.

Inputs: the prices (in minor units) and dates of earlier final purchases of that meal. Output: an estimate, the prices used, their date range and the baseline.

**Why 3?** A mean of the last three reacts to price changes quickly but smooths one-off noise a little. Using all history would be slower to follow price changes; using only the last price is the baseline we compare against. 

## 3. Alternatives considered

| Option | Why not chosen |
|---|---|
| Last price only (baseline) | Reacts to one-off spikes at once; kept as the comparison |
| Mean of all history | Slow to follow price changes |
| Trained model | Not enough data on a student's phone, and harder to explain |

## 4. Test cases

All in `test/lunch_lens_test.dart`. Each estimate is the mean of the last 3 purchases.

| Case | Input (oldest to newest) | Expected | Test name |
|---|---|---|---|
| Normal | 450, 600, 750 | Estimate 600 (1800 / 3) | "450, 600, 750 gives 600" |
| Beats the baseline | 450, 600, 750, then the next purchase is 650 | Lens error 50 (600 vs 650); last-price baseline error 100 (750 vs 650) | "error 50 vs last-price baseline error 100 when next is 650" |
| Input sensitivity | 450, 600, 900 | Estimate 650 (1950 / 3); changing the last input changes the estimate | "changing the last input to 900 gives 650" |
| Not enough history | 450, 600 (only 2) | No estimate; explanation is exactly "Not enough history" | "fewer than three purchases says not enough history" |
| Negative amount ignored | 450, 600 and a purchase of -100 | The negative price does not count, so only 2 valid purchases remain and there is no estimate | "negative amounts are ignored" |
| Same-date tie | 4 purchases on the same date, ids 1 to 4 (100, 200, 300, 400) | Higher id counts as newer: prices used 400, 300, 200; estimate 300; baseline 400 | "same-date tie is broken by the higher id" |
| Draft ignored | 450, 600 and a draft of 9999 | The draft does not count, so still no estimate | "draft and negative amounts are ignored" |
| Outlier (counterexample) | 450, 450, 1800 | Estimate 900, while the baseline says 1800; both miss a normal 450 | "outlier drags the mean up (counterexample)" |

The boundary of the rule is covered by the normal case (exactly 3 purchases gives an estimate) together with the not-enough-history case (2 purchases gives none).

Rounding: the code rounds the mean to the nearest minor unit with halves rounding up. The mean of three whole numbers is never exactly half a cent, so the "halves up" part is a safety rule and does not decide any result with a window of 3. A real rounding example is 450, 500, 600: 1550 / 3 = 516.67, which rounds to 517.

## 5. Held-out evaluation

Three price series (in cents, oldest to newest), each used to predict its 4th, 5th and 6th purchases from only the earlier ones, giving 9 cases. 

- A: 400, 450, 500, 600, 550, 500
- B: 700, 650, 750, 700, 1500, 720 (contains an outlier on purpose)
- C: 320, 300, 340, 310, 330, 350

| Series | Predicting | Last 3 | Lunch Lens | Baseline | Actual | Lens error | Baseline error | Closer |
|---|---|---|---|---|---|---|---|---|
| A | 4th | 400, 450, 500 | 450 | 500 | 600 | 150 | 100 | Baseline |
| A | 5th | 450, 500, 600 | 517 | 600 | 550 | 33 | 50 | Lens |
| A | 6th | 500, 600, 550 | 550 | 550 | 500 | 50 | 50 | Tie |
| B | 4th | 700, 650, 750 | 700 | 750 | 700 | 0 | 50 | Lens |
| B | 5th | 650, 750, 700 | 700 | 700 | 1500 | 800 | 800 | Tie |
| B | 6th | 750, 700, 1500 | 983 | 1500 | 720 | 263 | 780 | Lens |
| C | 4th | 320, 300, 340 | 320 | 340 | 310 | 10 | 30 | Lens |
| C | 5th | 300, 340, 310 | 317 | 310 | 330 | 13 | 20 | Lens |
| C | 6th | 340, 310, 330 | 327 | 330 | 350 | 23 | 20 | Baseline |

Printed by `flutter test test/lens_eval_test.dart`:

```
cases=9 lensMAE=149.11111111111111 baselineMAE=211.11111111111111 lensCloser=5
```

| Measure | Lunch Lens | Last-price baseline |
|---|---|---|
| Mean absolute error (cents) | 149.11 (about $1.49) | 211.11 (about $2.11) |
| Closer to the actual price | 5 of 9 cases | 2 of 9 cases (2 ties) |

## 6. Honest reading of the result

- Lunch Lens has the lower average error and was strictly closer in 5 of 9 cases. The baseline was closer in 2 and 2 were ties.
- **Most of the advantage comes from the outlier series B.** In case B 6th, the baseline predicted the spike price (1500) while the actual was 720, an error of 780 against 263 for the mean. Without series B, the six remaining cases give an error of 46.5 cents for Lunch Lens and 45.0 for the baseline, which is essentially a tie. So the evidence does not show that Lunch Lens is better on ordinary price histories.
- **Counterexample (outlier).** In case B 5th, the price suddenly jumps to 1500. Neither method can predict a one-off spike, and both are off by 800. After the spike, the mean stays inflated for the next three predictions (983 against an actual 720).
- **Where the baseline wins.** When prices trend steadily (series A, 4th), the mean of three lags behind the newest price.
- The sample is small (9 cases, 3 hand-written series, fictional data), so these numbers show the method works and where it fails. They are not evidence that it will generalise.

## 7. User control

- The estimate is advice only. It never fills in or overwrites the price the user enters; the planned price stays as typed.
- The explanation shows exactly which prices and dates were used.
- The wording says "Suggested, not guaranteed", and no confidence percentage is shown because none can be justified from this little data.

## 8. Offline use and privacy

The estimate is computed on the phone from the local SQLite history. It needs no network, sends no data anywhere and works in airplane mode.

## 9. Limits

- Needs at least 3 purchases of the same meal.
- Small, fictional evaluation sample.
- One outlier distorts the next three estimates.
- It does not know about the day of the week, the venue or price changes the user has not recorded.
