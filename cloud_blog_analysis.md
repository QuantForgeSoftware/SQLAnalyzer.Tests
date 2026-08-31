# Choosing the Right AI Model for SQL Code Analysis with Quant Forge Software SQLAnalyzer

Static analysis of SQL stored procedures is one of the hardest tasks to hand to a generative model. The code is dense, the rules are nuanced, and a single line can legitimately violate several rules at once. We used Quant Forge Software SQLAnalyzer to analyze `usp_TestProcedure.sql` from the WideWorldImporters sample database and asked a range of frontier models to flag every issue against a 96-finding reference set. This post compares how accurately each model performed and how many tokens it consumed doing so.

## What we measured

- **Correctness:** how many of the 96 expected findings each model reported, allowing a small line-number tolerance. A finding is only counted if the rule name matches and the reported line is within 5 lines of the expected line. We also tracked false positives (extra findings) and severity mismatches.
- **Token usage:** total prompt plus completion tokens. Because response times varied across hardware, speed is intentionally excluded; tokens are a fairer proxy for compute consumed and API cost.
- **Model availability:** `usp_TestProcedure.sql` and the SQLAnalyzer reference findings are only available as part of SQLAnalyzer, so the comparisons below directly reflect the quality you can expect when using the product.

## Accuracy leaderboard

| Rank | Model | Matched | Missing | Extra | Severity mismatches | Total tokens |
|---:|---|---:|---:|---:|---:|---:|
| 1 | qwen3.8-flash | 91 | 5 | 0 | 4 | 68133 |
| 2 | grok-4.6 | 91 | 5 | 7 | 6 | 18951 |
| 3 | deepseek-v4-flash | 90 | 6 | 0 | 3 | 55744 |
| 4 | qwen3.8-max-preview | 90 | 6 | 0 | 3 | — |
| 5 | qwen3.8-max | 89 | 7 | 0 | 5 | 56198 |
| 6 | grok-4.5 | 89 | 7 | 0 | 7 | 18500 |
| 7 | kimi-k2.7-code | 87 | 9 | 0 | 2 | 49953 |
| 8 | deepseek-v4-pro | 86 | 10 | 0 | 3 | 53599 |
| 9 | claude-opus-5 | 86 | 10 | 1 | 11 | 41022 |
| 10 | gpt-5.6-sol | 86 | 10 | 6 | 4 | 23072 |
| 11 | gpt-5.6-terra | 85 | 11 | 0 | 1 | 20504 |
| 12 | gemini-3.1-pro-preview | 85 | 11 | 0 | 4 | 19572 |
| 13 | kimi-k3 | 83 | 13 | 0 | 4 | 42625 |
| 14 | glm-5.3 | 83 | 13 | 0 | 4 | 51929 |
| 15 | glm-5.2 | 82 | 14 | 0 | 4 | 27280 |
| 16 | claude-fable-5 | 82 | 14 | 0 | 4 | 41637 |
| 17 | gpt-5.6-luna | 82 | 14 | 1 | 3 | 20693 |
| 18 | claude-sonnet-5 | 82 | 14 | 1 | 6 | 48652 |
| 19 | claude-opus-4-8 | 82 | 14 | 4 | 6 | 31755 |
| 20 | qwen3.7-max | 81 | 15 | 0 | 3 | 33077 |
| 21 | gemini-3.6-flash | 79 | 17 | 0 | 3 | 19049 |
| 22 | gemini-flash-latest | 79 | 17 | 0 | 7 | 18807 |
| 23 | glm-5.3-flash | 78 | 18 | 0 | 4 | 61814 |
| 24 | MiniMax M3 | 77 | 19 | 0 | 3 | 56044 |
| 25 | qwen3.7-plus | 70 | 26 | 0 | 3 | 32191 |
| 26 | gemini-3.7-flash | 68 | 28 | 0 | 6 | 18457 |
| 27 | gemini-3.1-flash-lite | 11 | 85 | 46 | 2 | 17705 |

A small cluster of models sits at the top: **qwen3.8-flash**, **grok-4.6**, and **deepseek-v4-flash** each report 90 or more of the 96 expected issues. qwen3.8-flash is the cleanest of the three because it produces zero extra findings and only four severity mismatches, while grok-4.6 produces seven extra findings and six severity mismatches. At the bottom, gemini-3.1-flash-lite is an outlier: it finds only 11 of the 96 expected issues and produces 46 extra findings, so it is not competitive for this task.

## Types of incorrect answers

We bucketed the failure modes into four categories:

1. **Misses.** The model simply fails to report an expected rule. The most common misses across the field are `SessionSettingChanged` (settings changed but not restored), `HardCodedLiteral` (embedded constants), and `SqlInjectionViaDynamicSql` when the dynamic SQL block is already flagged for concatenation or missing parameters. Many models report the primary issue on a line and then skip a co-located secondary issue.
2. **False positives / extras.** A few models invent findings that are not in the reference set. grok-4.6 has seven, gpt-5.6-sol has six, and claude-opus-4-8 has four. Extra findings are usually plausible-looking rules, but they still count as noise when the goal is a repeatable, auditable analysis.
3. **Severity mismatches.** The model detects the right issue but labels it `warning` when the reference labels it `error`. claude-opus-5 is the worst offender with 11 mismatches, while kimi-k2.7-code is the best with only 2. This matters because severity drives prioritization and CI gate behavior.
4. **Line drift.** Line numbers in the output can differ slightly from the reference. We allowed a tolerance of ±4 lines, so minor drift does not penalize a model. Most models stay within that window; the bigger issue is missing or misclassifying the rule entirely.

## Token efficiency

Raw accuracy is not the only consideration. Some models burn far more tokens than others to reach a similar result. The table below shows matches per million tokens, a simple efficiency score:

| Model | Matched | Total tokens | Matches per million tokens |
|---:|---:|---:|---:|
| grok-4.5 | 89 | 18500 | 4811 |
| grok-4.6 | 91 | 18951 | 4802 |
| gemini-3.1-pro-preview | 85 | 19572 | 4343 |
| gemini-flash-latest | 79 | 18807 | 4201 |
| gemini-3.6-flash | 79 | 19049 | 4147 |
| gpt-5.6-terra | 85 | 20504 | 4146 |
| gpt-5.6-luna | 82 | 20693 | 3963 |
| gpt-5.6-sol | 86 | 23072 | 3727 |
| gemini-3.7-flash | 68 | 18457 | 3684 |
| glm-5.2 | 82 | 27280 | 3006 |
| claude-opus-4-8 | 82 | 31755 | 2582 |
| qwen3.7-max | 81 | 33077 | 2449 |
| qwen3.7-plus | 70 | 32191 | 2175 |
| claude-opus-5 | 86 | 41022 | 2096 |
| claude-fable-5 | 82 | 41637 | 1969 |
| kimi-k3 | 83 | 42625 | 1947 |
| kimi-k2.7-code | 87 | 49953 | 1742 |
| claude-sonnet-5 | 82 | 48652 | 1685 |
| deepseek-v4-flash | 90 | 55744 | 1615 |
| deepseek-v4-pro | 86 | 53599 | 1605 |
| glm-5.3 | 83 | 51929 | 1598 |
| qwen3.8-max | 89 | 56198 | 1584 |
| MiniMax M3 | 77 | 56044 | 1374 |
| qwen3.8-flash | 91 | 68133 | 1336 |
| glm-5.3-flash | 78 | 61814 | 1262 |
| gemini-3.1-flash-lite | 11 | 17705 | 621 |

The most efficient runs are the Grok models: **grok-4.5** reaches 4,811 matches per million tokens, and **grok-4.6** reaches 4,802. They deliver near-top accuracy while using roughly one-third the tokens of qwen3.8-flash. Gemini-3.6-flash and gemini-flash-latest also look efficient, but they miss substantially more findings than the Grok pair, so their efficiency comes with an accuracy trade-off.

## The best model regardless of expense

If cost and token budget are not constraints, **qwen3.8-flash** is the strongest overall performer. It finds 91 of 96 expected issues, misses only 5, produces no extra findings, and keeps severity mismatches to 4. That combination of high recall and low noise makes it the safest choice for an analysis pipeline where the output will be reviewed by a DBA or fed into an automated gate.

**grok-4.6** is a close runner-up on pure accuracy (also 91 matched) but its seven extra findings and six severity mismatches mean downstream review costs are higher. **deepseek-v4-flash** (90 matched, 6 missing, 0 extras, 3 severity mismatches) is also excellent and uses fewer tokens than qwen3.8-flash, so it is a strong alternative if token budget matters.

## The best value

If you are optimizing for results per token, the choice changes. **grok-4.6** and **grok-4.5** deliver the highest accuracy-to-token ratio. They are the clear best value when you need broad coverage without paying a premium in prompt or completion tokens. The Gemini flash entries are token-cheap as well, but their miss rates are high enough that the savings may be undone by the manual review required to fill the gaps.

## Choices you need to make

- **Coverage versus noise.** Top models differ more in false positives and severity calibration than in raw coverage. If you route findings directly into tickets or CI gates, prefer qwen3.8-flash or deepseek-v4-flash. If you accept a small amount of noise in exchange for token savings, the Grok models are the better deal.
- **Severity trust.** Several models downgrade expected errors to warnings. If your workflow relies on severity to decide whether a build fails, you should expect to re-calibrate thresholds rather than trust model-assigned severity out of the box.
- **Token budget at scale.** The spread in token usage is large: qwen3.8-flash uses over 68,000 tokens, while grok-4.5 uses under 19,000. If you plan to analyze many procedures, that difference multiplies quickly.
- **Outlier avoidance.** gemini-3.1-flash-lite is not suitable for this task in its current form. It misses 85 of 96 expected findings and produces 46 extras, which is worse than random guessing on some rule categories.

## Bottom line

For SQLAnalyzer users, the data points to a clear hierarchy. **qwen3.8-flash** is the most accurate and disciplined model for SQL code analysis in this test. **deepseek-v4-flash** offers nearly the same quality with better token efficiency. **grok-4.6** and **grok-4.5** are the best value if you want high coverage at the lowest token cost and can tolerate a modest amount of extra output. Whichever model you choose, Quant Forge Software SQLAnalyzer gives you the reference findings, the test procedure, and the scoring framework to make the choice with real data rather than marketing claims.
