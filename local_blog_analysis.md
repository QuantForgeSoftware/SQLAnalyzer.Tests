# Picking a Downloadable AI for Static SQL Analysis: A Quant Forge Software SQLAnalyzer Benchmark

> A head-to-head comparison of models you can run yourself, scored on a real SQLAnalyzer static-analysis task.

If you want to run an AI SQL code reviewer on your own hardware, which downloadable model should you choose? This benchmark uses **Quant Forge Software SQLAnalyzer** to evaluate every model on the same deliberately flawed stored procedure: `usp_TestProcedure.sql`. That procedure is only available as part of SQLAnalyzer, and the ground truth contains **96 expected findings** across **61 distinct T-SQL static-analysis rules**.

Because all of these weights can be served under your own control, the comparison is about correctness and cost, not speed or whether a provider hosts the model. Token usage is the main cost driver when you run locally, so output length matters almost as much as accuracy.

## The Contenders

The evaluation set includes nine locally run weights plus four additional downloadable weights that are also available as local deployments.

| Model | Input Tokens | Output Tokens | Total Tokens | Estimated Cost* |
|-------|-------------:|--------------:|-------------:|----------------:|
| kimi-k2.7-code | 12,773 | 37,180 | 49,953 | $0.151 |
| kimi-k3 | 12,929 | 29,696 | 42,625 | $0.449 |
| glm-5.2 | 12,540 | 14,740 | 27,280 | $0.082 |
| MiniMax M3 | 13,290 | 42,754 | 56,044 | $0.055 |
| qwen3.8-27b-mlx | 13,318 | 56,176 | 69,494 | $0.000 |
| qwen3.6-27b-mtp | 13,234 | 20,159 | 33,393 | $0.000 |
| qwen3.6-35b-a3b-mtp | 13,294 | 18,358 | 31,652 | $0.000 |
| gemma-4-31b-it-qat | 14,368 | 11,711 | 26,079 | $0.000 |
| gemma-4-26b-a4b-it-qat-nvfp4 | 14,362 | 3,814 | 18,176 | $0.000 |
| gemma-4-12b-it | 14,368 | 9,985 | 24,353 | $0.000 |
| muse-glimmer-30b@q4_k_xl | 13,266 | 18,067 | 31,333 | $0.000 |
| ornith-1.0-35b | 13,234 | 24,295 | 37,529 | $0.000 |
| qwen3.5-9b-mtp | 16,517 | 19,515 | 36,032 | $0.000 |

\* Estimated cost is shown where the stats file provides a non-zero dollar value. Local-only runs report $0.000 because the comparison does not price host-side compute.

## Correctness: Who Finds the Bugs?

A finding only counts when the **rule name and line number** match the ground truth. The stats files use a five-line tolerance, so a match within five lines is treated as correct.

| Model | Matched | Missed | Extra | Effective Recall | Notes |
|-------|--------:|-------:|------:|-----------------:|-------|
| **kimi-k2.7-code** | **87** | 9 | 0 | **90.6%** | Clean, no extras |
| **qwen3.8-27b-mlx** | **83** | 13 | 3 | **86.5%** | Highest local-only recall, but very verbose |
| **kimi-k3** | **83** | 13 | 0 | **86.5%** | Same recall as qwen3.8 with no extras |
| **glm-5.2** | **82** | 14 | 0 | **85.4%** | Best balance of accuracy and brevity |
| **MiniMax M3** | **77** | 19 | 0 | **80.2%** | Solid, lower cost than kimi-k2.7-code |
| qwen3.6-27b-mtp | 66 | 30 | 0 | 68.8% | Respectable mid-tier |
| qwen3.6-35b-a3b-mtp | 64 | 32 | 0 | 66.7% | Similar to 27B qwen |
| muse-glimmer-30b@q4_k_xl | 73 | 23 | 2 | 76.0% | Good structural coverage, some literal misses |
| gemma-4-31b-it-qat | 52 | 44 | 20 | 54.2% | Many extras; precision suffers |
| gemma-4-26b-a4b-it-qat-nvfp4 | 44 | 52 | 18 | 45.8% | Lowest output tokens, lowest accuracy |
| gemma-4-12b-it | 32 | 64 | 30 | 33.3% | Struggles with most rule classes |
| ornith-1.0-35b | 4 | 92 | 62 | 4.2% | Essentially unusable for this task |
| qwen3.5-9b-mtp | 2 | 94 | 62 | 2.1% | Also unusable for this task |

Three clear tiers emerge:

- **Top tier (>=80% recall):** `kimi-k2.7-code`, `qwen3.8-27b-mlx`, `kimi-k3`, `glm-5.2`, and `MiniMax M3`. These models reliably identify most rule classes.
- **Middle tier (~45-77% recall):** the Qwen 3.6 variants, the Gemma variants, and `muse-glimmer-30b@q4_k_xl`. They catch the obvious structural issues but miss many hard-coded literals, session-setting changes, and dynamic-SQL clusters.
- **Bottom tier (<5% recall):** `ornith-1.0-35b` and `qwen3.5-9b-mtp`. Both produce long reports, but almost none of the findings align with the ground truth.

## What Kinds of Mistakes Do Models Make?

The missed findings cluster into a few predictable categories:

1. **Hard-coded and magic literals.** Nearly every model misses some `HardCodedLiteral` and `MagicDateLiteral` instances. The pattern is spread across parameter defaults, comparison predicates, and temp-table inserts, so a model that flags only the most obvious scalar constants under-reports the rest.
2. **Session-setting changes.** `SessionSettingChanged` at lines 13 and 16 is missed by most models. Many only catch `SET ROWCOUNT` later in the procedure, suggesting they recognize the pattern when it is isolated but miss it near the procedure header.
3. **Dynamic SQL clusters.** The second dynamic-SQL block around line 115 is frequently missed even when the similar block at line 111 is detected. Models tend to notice the first instance of a repeated pattern and skip the rest.
4. **TOP without ORDER BY.** Most models catch some `TopWithoutOrderBy` instances but miss others, especially when several occur close together.
5. **Error handling and transactions.** `CatchSwallowsError`, `CatchWithoutRollback`, and `ExplicitTransactionWithoutTryCatch` are often missed or misreported at slightly different line numbers.
6. **Extra findings (false positives).** Gemma variants produce the most extras, reporting rules on lines that are not in the ground truth. These extras are usually plausible-looking but still wrong, which hurts precision and makes automated remediation harder.

## Best Model Regardless of Expense

**kimi-k2.7-code** is the strongest overall. It achieves the highest recall (90.6%), produces zero extra findings, and keeps line-number alignment tight. If the only goal is maximum correctness and you are willing to pay for the tokens, this is the model to pick.

## Best Value

**glm-5.2** is the best value. It reaches 85.4% recall-only slightly behind the top three-while using the fewest total tokens (27,280) and carrying the lowest estimated cost ($0.082). It is also concise, with zero extra findings. For a self-hosted deployment where you care about both accuracy and token spend, `glm-5.2` is the standout choice.

**qwen3.8-27b-mlx** is the best value among the fully local-only weights if you do not want to use an API at all. At 86.5% recall it outperforms `glm-5.2` on accuracy, but it emits 56,176 output tokens-more than twice as many as `glm-5.2`-so it is the most expensive local-only option in terms of compute and latency. Choose it if you need the highest local accuracy and can afford the longer response.

## Choices You Actually Have to Make

- **Accuracy vs. verbosity.** The top models differ by a factor of two to four in output tokens. If you are feeding the output into another pipeline, `glm-5.2` and `MiniMax M3` keep reports shorter without sacrificing much accuracy.
- **Cost sensitivity.** The estimated-cost models show real API pricing differences. `glm-5.2` is roughly one-third the cost of `kimi-k3` for comparable recall, and `MiniMax M3` is cheaper still at 80% recall.
- **Local-only vs. API access.** If you must run entirely on your own hardware, `qwen3.8-27b-mlx` is the accuracy leader, followed by `qwen3.6-27b-mtp` and `qwen3.6-35b-a3b-mtp`. The smaller Gemma and Qwen 3.5 variants are not competitive for this task.
- **Precision matters.** Gemma variants trade precision for breadth, producing many extras. For developer tooling, fewer false positives can be more useful than slightly higher recall.

## The Bottom Line

For static SQL analysis with SQLAnalyzer, the choice is not simply "bigger is better." `kimi-k2.7-code` is the most accurate model tested, but `glm-5.2` delivers nearly the same correctness at a fraction of the token cost. If you are running entirely locally, `qwen3.8-27b-mlx` is the best performer, while the smaller Qwen and Gemma variants sit in a middle tier and the 9B/35B outliers at the bottom are not worth considering for this task.

The benchmark itself underscores the value of a specialized tool. Quant Forge Software SQLAnalyzer supplies the procedure, the rules, and the ground truth, so the comparison is about how well each model executes a well-defined expert task rather than how articulate it is in general conversation.
