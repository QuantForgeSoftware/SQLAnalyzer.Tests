# Picking a Downloadable AI for Static SQL Analysis: A Quant Forge Software SQLAnalyzer Benchmark

> A head-to-head comparison of eighteen models you can run on your own hardware, scored on a real SQLAnalyzer static-analysis task.

If you want an AI SQL code reviewer that you control, which downloadable model should you choose? This benchmark uses **Quant Forge Software SQLAnalyzer** to evaluate every model on the same deliberately flawed stored procedure: `usp_TestProcedure.sql`. That procedure is only available as part of SQLAnalyzer, and its ground truth contains **96 expected findings** across **61 distinct T-SQL static-analysis rules**.

Every model received the same prompt and the same procedure, so the comparison is about correctness, cost, and speed. Token usage is included, because output length drives compute cost and how much text a reviewer has to read.

## The Contenders

| Model | Input Tokens | Output Tokens | Total Tokens | Estimated Cost* | Time |
|-------|-------------:|--------------:|-------------:|----------------:|-----:|
| kimi-k2.7-code | 12,773 | 37,180 | 49,953 | $0.151 | 8:55 |
| kimi-k3 | 12,929 | 29,696 | 42,625 | $0.449 | 12:42 |
| glm-5.2 | 12,540 | 14,740 | 27,280 | $0.082 | 2:52 |
| qwen3.8-27b-mlx | 13,318 | 56,176 | 69,494 | $0.000 | 40:55 |
| MiniMax M3 | 13,290 | 42,754 | 56,044 | $0.055 | 4:21 |
| thinkingcap-qwen3.8-27b | 13,541 | 40,936 | 54,477 | $0.000 | 30:54 |
| muse-glimmer-30b@q4_k_xl | 13,266 | 18,067 | 31,333 | $0.000 | 14:00 |
| ddalcu/Inkling-2-Mini-MLX-8bit | 15,792 | 17,114 | 32,906 | $0.000 | 4:06 |
| flint | 12,804 | 46,436 | 59,240 | $0.000 | 12:19 |
| qwen3.6-27b-mtp | 13,234 | 20,159 | 33,393 | $0.000 | 15:50 |
| sage-a1.5-35b | 13,457 | 49,470 | 62,927 | $0.000 | 10:21 |
| qwen3.6-35b-a3b-mtp | 13,294 | 18,358 | 31,652 | $0.000 | 3:44 |
| qwen3.6-35b-a3b-splash | 13,457 | 21,243 | 34,700 | $0.000 | 1:20 |
| gemma-4-31b-it-qat | 14,368 | 11,711 | 26,079 | $0.000 | 12:37 |
| gemma-4-26b-a4b-it-qat-nvfp4 | 14,362 | 3,814 | 18,176 | $0.000 | 0:58 |
| gemma-4-12b-it | 14,368 | 9,985 | 24,353 | $0.000 | 5:17 |
| ornith-1.0-35b | 13,234 | 24,295 | 37,529 | $0.000 | 6:27 |
| qwen3.5-9b-mtp | 16,517 | 19,515 | 36,032 | $0.000 | 7:23 |

\* Estimated cost is the dollar figure recorded for each run. A $0.000 entry means no per-token charge was recorded; the hardware and electricity to run the model are not priced. Time is how long the model took to return its analysis (minutes:seconds) on a single run; run times vary with hardware and server load, so treat small differences as noise.

## Correctness: Who Finds the Bugs?

A finding counts as matched when the rule name is correct and the reported line is within four lines of the expected line (differences under five lines are ignored). Recall is matched divided by the 96 expected findings, precision is matched divided by everything the model reported, and F1 combines the two. Models are ranked by F1.

| Model | Matched | Missed | Extra | Recall | Precision | F1 |
|---|---:|---:|---:|---:|---:|---:|
| **kimi-k2.7-code** | 87 | 9 | 0 | 0.906 | 1.000 | **0.951** |
| **kimi-k3** | 83 | 13 | 0 | 0.865 | 1.000 | **0.927** |
| **glm-5.2** | 82 | 14 | 0 | 0.854 | 1.000 | **0.921** |
| **qwen3.8-27b-mlx** | 83 | 13 | 3 | 0.865 | 0.965 | **0.912** |
| **MiniMax M3** | 77 | 19 | 0 | 0.802 | 1.000 | **0.890** |
| **thinkingcap-qwen3.8-27b** | 76 | 20 | 0 | 0.792 | 1.000 | **0.884** |
| muse-glimmer-30b@q4_k_xl | 75 | 21 | 0 | 0.781 | 1.000 | 0.877 |
| ddalcu/Inkling-2-Mini-MLX-8bit | 71 | 25 | 2 | 0.740 | 0.973 | 0.840 |
| flint | 69 | 27 | 2 | 0.719 | 0.972 | 0.826 |
| qwen3.6-27b-mtp | 66 | 30 | 0 | 0.688 | 1.000 | 0.815 |
| sage-a1.5-35b | 65 | 31 | 0 | 0.677 | 1.000 | 0.807 |
| qwen3.6-35b-a3b-mtp | 64 | 32 | 0 | 0.667 | 1.000 | 0.800 |
| qwen3.6-35b-a3b-splash | 60 | 36 | 1 | 0.625 | 0.984 | 0.764 |
| gemma-4-31b-it-qat | 49 | 47 | 23 | 0.510 | 0.681 | 0.583 |
| gemma-4-26b-a4b-it-qat-nvfp4 | 44 | 52 | 18 | 0.458 | 0.710 | 0.557 |
| gemma-4-12b-it | 32 | 64 | 30 | 0.333 | 0.516 | 0.405 |
| ornith-1.0-35b | 4 | 92 | 62 | 0.042 | 0.061 | 0.049 |
| qwen3.5-9b-mtp | 2 | 94 | 62 | 0.021 | 0.031 | 0.025 |

Three tiers emerge:

- **Top tier (F1 0.88 or better):** `kimi-k2.7-code`, `kimi-k3`, `glm-5.2`, `qwen3.8-27b-mlx`, `MiniMax M3`, and `thinkingcap-qwen3.8-27b`. These models reliably identify most rule classes, and all but one report no false findings at all.
- **Middle tier (F1 0.76-0.88):** `muse-glimmer-30b@q4_k_xl`, `ddalcu/Inkling-2-Mini-MLX-8bit`, `flint`, the three Qwen 3.6 variants, and `sage-a1.5-35b`. All but `ddalcu/Inkling-2-Mini-MLX-8bit`, `flint`, and `qwen3.6-35b-a3b-splash` are perfectly precise, and they tend to report each pattern once, so they miss many repeated literals, session-setting changes, and dynamic-SQL companions.
- **Bottom tier (F1 under 0.60):** the Gemma variants, which trade precision for breadth with 18-30 extras each, and `ornith-1.0-35b` and `qwen3.5-9b-mtp`, whose long reports barely line up with the ground truth.

The Qwen 3.8 27B family is worth a closer look. The `thinkingcap` fine-tune lands ten findings ahead of the Qwen 3.6 27B (76 vs. 66), mostly by catching seven of the eight `TopWithoutOrderBy` cases, and it does so with zero false positives. It trails the `mlx` build by seven findings but uses about 15,000 fewer output tokens and reports no extras.

A recent addition, `sage-a1.5-35b`, matched 65 of 96 with zero false positives (F1 0.807), eleventh of eighteen and just behind the Qwen 3.6 27B. It is a clear case of report-once behavior: it found one of nine hard-coded literals and one of eight `TopWithoutOrderBy` cases. It also inverts the usual dynamic-SQL pattern, flagging `SqlInjectionViaDynamicSql` on all three dynamic-SQL blocks but `DynamicSqlConcatenation` on none. It spent 49,470 output tokens to get there, second only to `qwen3.8-27b-mlx`, so its reports are long for a mid-table score.

Another recent addition, `flint`, matched 69 of 96 with two extras (F1 0.826), ninth of eighteen and third in the middle tier behind `muse-glimmer-30b@q4_k_xl` and `ddalcu/Inkling-2-Mini-MLX-8bit`. It covers the whole procedure, including 13 of the 22 issues in its final section, and catches four of eight `TopWithoutOrderBy` cases, but it reported only one of nine hard-coded literals. Its two extras flag date-to-string comparisons as `ImplicitConversion`, a reasonable reading that the answer key covers with its date-literal rules instead. It used 46,436 output tokens.

The newest entry, `ddalcu/Inkling-2-Mini-MLX-8bit`, matched 71 of 96 with two extras (F1 0.840) in 4:06 at $0.00, eighth of eighteen and second in the middle tier behind `muse-glimmer-30b@q4_k_xl`. For a Mini 8-bit model it is a strong showing: it covers 59 of 61 rules, catches 5 of 8 `TopWithoutOrderBy` cases and 3 of 4 leading-wildcard `LIKE` patterns, and uses a compact 17,114 output tokens. It still reports only 1 of 9 hard-coded literals, skips the companion `SessionSettingChanged` findings at lines 13 and 16, and misses the second dynamic-SQL block at line 115. Its two extras are `TopWithoutOrderBy` reports near other expected `TOP` lines. It sits just ahead of `flint` (0.826) and well ahead of several larger 30B+ models, including `sage-a1.5-35b`.

A recent addition, `qwen3.6-35b-a3b-splash`, matched 60 of 96 with one extra (F1 0.764), thirteenth of eighteen and the last model in the middle tier. Its defining trait is speed: it returned its analysis in 1:20, the second-fastest run in the test and nearly three times faster than the `qwen3.6-35b-a3b-mtp` build (3:44). It is also the purest example of report-once behavior: 61 findings spread across 60 rules, reaching all the way to the end of the procedure but flagging only one of nine hard-coded literals, one of eight `TopWithoutOrderBy` cases, and one of four leading-wildcard `LIKE` patterns. Its single extra is a near miss, an `OuterJoinToFilter` reported five lines from the expected line. It used 21,243 output tokens.

## What Kinds of Mistakes Do Models Make?

The missed findings fall into a few predictable categories:

1. **Hard-coded and magic literals.** This is the single biggest source of misses. Even strong models report one `HardCodedLiteral` and then stop; `thinkingcap-qwen3.8-27b`, `sage-a1.5-35b`, `flint`, `ddalcu/Inkling-2-Mini-MLX-8bit`, and `qwen3.6-35b-a3b-splash` each found only 1 of 9. The literals are spread across predicates, UNION branches, temp-table inserts, and update statements, so a model that flags only the first obvious constant under-reports the rest.
2. **Companion findings on the same line.** Many lines carry two expected rules, such as `NoCountDisabled` plus `SessionSettingChanged` at lines 13 and 16, or `DynamicSqlConcatenation` plus `SqlInjectionViaDynamicSql` at line 115. Models usually report one and skip the second. Most of the top tier's remaining misses are of this kind.
3. **Repeated dynamic SQL.** The second and third dynamic-SQL blocks (around lines 115 and 221) are often missed even when the first block at line 111 is detected.
4. **TOP without ORDER BY.** Weaker models catch one `TopWithoutOrderBy` and miss the rest, especially when several occur close together. This is exactly where the stronger Qwen 3.8 builds pull away from Qwen 3.6.
5. **Quiet DML and aggregation issues.** A no-op `UPDATE ... SET Comments = Comments`, an `INSERT` without a column list, an unfiltered `COUNT(*)`, and a correlated scalar subquery are easy to skim past and show up as misses across nearly every model.
6. **Severity disagreements.** Even when a rule is matched, models sometimes call a warning an error or the reverse. `sage-a1.5-35b` disagreed on 15 of its 65 matches and `flint` on 22 of its 69, mostly by raising warnings to errors. These do not affect the score, but they matter if severity drives your build gate.
7. **Extra findings (false positives).** The Gemma variants and the bottom tier produce the most extras, reporting rules on lines that are not in the ground truth. They look plausible but are still wrong, which hurts trust and makes automated remediation harder. Only one top-tier model, `qwen3.8-27b-mlx`, reported any extras (three).

## Run Time

The fastest run in the test was `gemma-4-26b-a4b-it-qat-nvfp4` (0:58), but its short report shows in the score (F1 0.557). The new `qwen3.6-35b-a3b-splash` is next at 1:20, the quickest model outside the bottom tier (F1 0.764). Among the top-tier models, **glm-5.2** is the clear speed leader: an F1 of 0.921 in 2:52, more than a minute ahead of any other top-tier model. `qwen3.6-35b-a3b-mtp` (3:44, F1 0.800), `ddalcu/Inkling-2-Mini-MLX-8bit` (4:06, F1 0.840), and `MiniMax M3` (4:21, F1 0.890) are also quick, and the most accurate model, `kimi-k2.7-code`, finishes in 8:55.

Accuracy can cost time. The Qwen 3.8 27B builds are the slowest runs in the test: `thinkingcap-qwen3.8-27b` took 30:54 and `qwen3.8-27b-mlx` 40:55. Mid-table models are not always quick either: `qwen3.6-27b-mtp` (15:50), `muse-glimmer-30b@q4_k_xl` (14:00), and `flint` (12:19) each took longer than `kimi-k2.7-code`. If SQLAnalyzer runs on every commit, a model that answers in a few minutes keeps feedback fast; for a nightly or pre-release review, the longer runs are easy to schedule.

## Best Model Regardless of Expense

**kimi-k2.7-code** is the strongest overall. It has the highest recall (87 of 96) and the best F1 (0.951), produces zero extra findings, and keeps line-number alignment tight. If maximum correctness is the only goal, this is the model to pick.

## Best Value

**glm-5.2** is the best value. Its F1 of 0.921 is third overall, it has zero extras, and it uses the fewest total tokens of any top-tier model (27,280) at an estimated cost of $0.082, about one-fifth the cost of `kimi-k3` for nearly the same score. It is also the fastest model in the top tier, returning its analysis in 2:52.

If you don't want any per-token charge, **qwen3.8-27b-mlx** gives the highest recall (83 of 96), but it emits 56,176 output tokens and three false positives, and at 40:55 it is the slowest run in the test. **thinkingcap-qwen3.8-27b** is the cleaner alternative: 76 of 96, zero extras, and about 27% fewer output tokens than the `mlx` build, and it finishes about ten minutes sooner. **muse-glimmer-30b@q4_k_xl** is the frugal choice, only one finding behind `thinkingcap` with less than half the output tokens, in less than half the time (14:00).

## Choices You Actually Have to Make

- **Accuracy vs. verbosity.** Output tokens among the top six models range from about 15,000 to 56,000. If you are feeding results into another pipeline or reading them by hand, `glm-5.2` keeps reports short without giving up much accuracy, while `sage-a1.5-35b` shows the opposite: nearly 50,000 output tokens for a mid-table score.
- **Cost sensitivity.** Recorded prices vary widely. `glm-5.2` costs about one-fifth of `kimi-k3` for nearly the same F1, and `MiniMax M3` is cheaper still at 77 of 96.
- **Recall vs. precision.** `qwen3.8-27b-mlx` finds the most issues among the zero-cost runs, while `thinkingcap-qwen3.8-27b` and `muse-glimmer-30b@q4_k_xl` find slightly fewer but never report a false one. For developer tooling, a clean report often beats a few extra hits.
- **Turnaround time.** If reviews run on every commit, `glm-5.2` (2:52) delivers top-tier accuracy fastest. Among the zero-cost runs, `qwen3.6-35b-a3b-splash` returns an F1 of 0.764 in 1:20 and `qwen3.6-35b-a3b-mtp` an F1 of 0.800 in under four minutes, while the more accurate Qwen 3.8 27B builds take half an hour or more.
- **Model size isn't everything.** Several 30B+ models, including the new 35B `sage-a1.5-35b`, score below the 27B Qwen 3.8 builds, and two land at the very bottom. The new Mini 8-bit `ddalcu/Inkling-2-Mini-MLX-8bit` (F1 0.840) also outscores those larger mid-table models. The fine-tune and the version matter more than the parameter count.

## The Bottom Line

For static SQL analysis with SQLAnalyzer, bigger is not automatically better. `kimi-k2.7-code` is the most accurate model tested, and `glm-5.2` delivers nearly the same correctness at a fraction of the token cost and in about a third of the time. Among models with no per-token charge, the Qwen 3.8 27B builds lead, with `thinkingcap-qwen3.8-27b` the precision pick, and `qwen3.6-35b-a3b-splash` is the pick when turnaround matters most. The Gemma, Qwen 3.5, and Ornith variants are not competitive for this task.

The benchmark itself shows why a specialized tool matters. Quant Forge Software SQLAnalyzer supplies the procedure, the rules, and the ground truth, so the comparison measures how well each model performs a well-defined expert task rather than how articulate it is. `usp_TestProcedure.sql` and its 96-finding answer key are available only in SQLAnalyzer, so you can run this same benchmark on any model you are considering before you trust it with your own code.
