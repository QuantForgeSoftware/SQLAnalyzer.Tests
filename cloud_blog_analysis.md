# Cloud AI Models for T-SQL Static Analysis: A Head-to-Head Comparison

Quant Forge Software SQLAnalyzer was used to analyze a single, deliberately flawed stored procedure—`usp_TestProcedure.sql`—and to ask each model to report code-quality, correctness, and performance issues in a structured JSON format. The procedure is only available as part of SQLAnalyzer and is designed to surface a broad catalog of real-world T-SQL anti-patterns. Every model in this comparison was run under the same prompt, the same source file, and the same expected finding set.

The expected output contains 96 distinct findings. For scoring, a finding is considered matched if the rule name is correct and the reported line number is within 5 lines of the expected line. Speed is not compared because the runs happened on different machines; cost and token usage are.

## The Results at a Glance

| Model | Matched | Missed | Extra | Recall | Precision | F1 | Total Tokens | Est. Cost |
|---|---:|---:|---:|---:|---:|---:|---:|---:|
| qwen3.8-flash | 93 | 3 | 9 | 0.969 | 0.912 | **0.939** | 68,133 | $0.44 |
| grok-4.5 | 92 | 4 | 8 | 0.958 | 0.920 | **0.939** | 18,500 | $0.06 |
| kimi-k2.7-code | 91 | 5 | 7 | 0.948 | 0.929 | 0.938 | 49,953 | $0.15 |
| qwen3.8-max-preview | 92 | 4 | 9 | 0.958 | 0.911 | 0.934 | 0 | $0.00 |
| deepseek-v4-pro | 89 | 7 | 7 | 0.927 | 0.927 | 0.927 | 53,599 | $0.02 |
| glm-5.2 | 87 | 9 | 5 | 0.906 | 0.946 | 0.926 | 27,280 | $0.08 |
| claude-fable-5-1 | 91 | 5 | 10 | 0.948 | 0.901 | 0.924 | 40,303 | $1.02 |
| qwen3.8-max | 90 | 6 | 9 | 0.938 | 0.909 | 0.923 | 56,198 | $0.35 |
| claude-opus-5 | 89 | 7 | 8 | 0.927 | 0.918 | 0.922 | 41,022 | $0.53 |
| deepseek-v4-flash | 90 | 6 | 10 | 0.938 | 0.900 | 0.918 | 55,744 | $0.01 |
| gemini-3.1-pro-preview | 87 | 9 | 8 | 0.906 | 0.916 | 0.911 | 19,572 | $0.10 |
| gpt-5.6-terra | 87 | 9 | 8 | 0.906 | 0.916 | 0.911 | 20,504 | $0.15 |
| glm-5.3 | 85 | 11 | 7 | 0.885 | 0.924 | 0.904 | 51,929 | $0.19 |
| qwen3.7-max | 84 | 12 | 6 | 0.875 | 0.933 | 0.903 | 33,077 | $0.18 |
| gemini-3.6-flash | 83 | 13 | 5 | 0.865 | 0.943 | 0.902 | 19,049 | $0.06 |
| gemini-3.8-flash | 82 | 14 | 4 | 0.854 | 0.953 | 0.901 | 19,299 | $0.03 |
| claude-sonnet-5 | 85 | 11 | 8 | 0.885 | 0.914 | 0.899 | 48,652 | $0.29 |
| gpt-5.6-luna | 85 | 11 | 8 | 0.885 | 0.914 | 0.899 | 20,693 | $0.06 |
| claude-fable-5 | 84 | 12 | 7 | 0.875 | 0.923 | 0.898 | 41,637 | $1.08 |
| glm-5.3-flash | 82 | 14 | 5 | 0.854 | 0.943 | 0.896 | 61,814 | $0.23 |
| kimi-k3 | 84 | 12 | 8 | 0.875 | 0.913 | 0.894 | 42,625 | $0.45 |
| grok-4.6 | 91 | 5 | 17 | 0.948 | 0.843 | 0.892 | 18,951 | $0.06 |
| gpt-5.6-sol | 88 | 8 | 14 | 0.917 | 0.863 | 0.889 | 23,072 | $0.37 |
| gemini-flash-latest | 82 | 14 | 7 | 0.854 | 0.921 | 0.886 | 18,807 | $0.06 |
| MiniMax M3 | 81 | 15 | 6 | 0.844 | 0.931 | 0.885 | 56,044 | $0.06 |
| claude-opus-4-8 | 85 | 11 | 12 | 0.885 | 0.876 | 0.881 | 31,755 | $0.30 |
| qwen3.7-plus | 76 | 20 | 1 | 0.792 | 0.987 | 0.879 | 32,191 | $0.04 |
| gemini-3.7-flash | 74 | 22 | 0 | 0.771 | 1.000 | 0.871 | 18,457 | $0.06 |
| gpt-6-astra | 88 | 8 | 22 | 0.917 | 0.800 | 0.854 | 20,837 | $0.53 |
| gemini-3.1-flash-lite | 28 | 68 | 31 | 0.292 | 0.475 | 0.361 | 17,705 | $0.01 |

## Correctness: What "Wrong" Looks Like

No model achieved a perfect score. The errors fall into two buckets:

- **Missed findings (false negatives):** Rules the model simply did not see. The most common blind spots are `SessionSettingChanged` on `SET NOCOUNT OFF` and `SET XACT_ABORT OFF`—most models report the specific `NoCountDisabled` and `XactAbortDisabled` findings but miss the broader meta-rule that a session setting is changed and never restored. Other frequent misses are contextual hard-coded literals, SQL-injection severity upgrades on dynamic SQL, and repeated anti-patterns that appear twice in close succession (the model flags the first and skips the second).
- **Extra findings (false positives):** Rules reported that were not in the expected set. These are usually duplicates or decompositions of a single statement: a cursor declaration with `SELECT TOP (n)` may generate both a `CursorRowByRow` and a `TopWithoutOrderBy`, or a `LIKE '%...%'` embedded in dynamic SQL may generate both `LeadingWildcardLike` and `SqlInjectionViaDynamicSql`. A few extras are plain line-offset errors, where the model attributes a literal or hint to a nearby declaration line rather than the actual statement line.

The shape of a model's errors says a lot about its behavior:

- **Conservative models** such as `gemini-3.7-flash` (0 extras, 22 missed) and `qwen3.7-plus` (1 extra, 20 missed) err on the side of silence. Their precision is excellent, but they leave a meaningful fraction of issues unreported.
- **Over-eager models** such as `gpt-6-astra` (22 extras, 8 missed) and `grok-4.6` (17 extras, 5 missed) catch most real issues but clutter the report with redundant or fragmented findings that a human reviewer must sort through.
- **Balanced models** such as `qwen3.8-flash`, `grok-4.5`, and `kimi-k2.7-code` keep both error types low, giving them the highest F1 scores.

## Best Regardless of Expense

If cost is no object, **qwen3.8-flash** is the strongest model. It found 93 of 96 expected issues, the highest recall in the entire set, and still maintained strong precision. It is the only model to break above 96% recall while keeping extras in single digits. The closest competitor, `grok-4.5`, matched one fewer finding and used far fewer tokens, so the choice depends on whether absolute recall or efficiency matters more.

`claude-fable-5-1` also deserves mention: it matched 91 findings and its misses were subtle variants of rules it did detect elsewhere. However, it cost over a dollar per run and produced 10 extras, so it is not the outright winner.

## Best Value

Value is a function of correctness divided by cost (and tokens). On that measure, the clear standout is **deepseek-v4-flash**: it found 90 of 96 issues, scored an F1 of 0.918, and cost about **one cent** per run. Its sibling, `deepseek-v4-pro`, is nearly as attractive at roughly two cents for an F1 of 0.927. Either DeepSeek model delivers top-tier accuracy at a fraction of the price of the flagship models.

`grok-4.5` is another value champion: 92 of 96 correct, F1 0.939, for about six cents and only 18,500 tokens. It is the cheapest way to get near-best-in-class recall without the verbosity of larger models.

By contrast, the Anthropic Fable models cost around a dollar per run while scoring below `qwen3.8-flash` and `grok-4.5`. They are accurate, but the price premium is hard to justify on this task.

## Token Usage Matters

Token count is not just a cost proxy; it also reflects how much noise a model produces. The most efficient runs were all under 20,000 total tokens: `grok-4.5` (18,500), `gemini-flash-latest` (18,807), `gemini-3.6-flash` (19,049), `gemini-3.8-flash` (19,299), and `gemini-3.7-flash` (18,457). Several of these also scored well, proving that long outputs do not automatically mean better analysis.

At the other extreme, `qwen3.8-flash` consumed 68,133 tokens—nearly four times what `grok-4.5` used—yet only found one additional correct issue. `glm-5.3-flash` and `MiniMax M3` also burned more than 55,000 tokens without a corresponding accuracy payoff.

## The Choices You Need to Make

1. **Maximum recall or clean reports?** If you want the fewest missed issues, pick `qwen3.8-flash`. If you want the fewest false alarms, pick `gemini-3.7-flash` or `qwen3.7-plus` and accept that some issues will be missed.
2. **Budget or accuracy?** For routine, high-volume scans, `deepseek-v4-flash` or `deepseek-v4-pro` give flagship-grade F1 scores for pennies. For the highest accuracy at a still-modest price, `grok-4.5` is the sweet spot.
3. **Token budget?** If context-window or throughput is a constraint, the Gemini Flash family and Grok-4.5 deliver concise, accurate outputs. Avoid the high-token Qwen and GLM variants unless every missed issue is costly.
4. **What about the bottom tier?** `gemini-3.1-flash-lite` is not usable for this task: it matched only 28 of 96 findings and produced 31 extras. It should not be used for production T-SQL analysis.

## Why This Matters for SQLAnalyzer

The test demonstrates that model choice has a large impact on the quality of SQL code review. Even the best model missed three issues; the worst missed nearly seventy. That variability is exactly why a tool like Quant Forge Software SQLAnalyzer matters: it provides a controlled environment, a curated rule set, and an expected-finding benchmark so teams can choose the model that best fits their accuracy, cost, and token constraints. The procedure used here, `usp_TestProcedure.sql`, is only available as part of SQLAnalyzer, and the benchmark itself is a practical reason to standardize on SQLAnalyzer for consistent, comparable static analysis across models.

## Bottom Line

- **Best regardless of expense:** `qwen3.8-flash` (93/96, F1 0.939).
- **Best value:** `deepseek-v4-flash` (90/96, F1 0.918, ~$0.01) or `grok-4.5` (92/96, F1 0.939, ~$0.06).
- **Most precise conservative choice:** `gemini-3.7-flash` (perfect precision, but 22 misses).
- **Avoid:** `gemini-3.1-flash-lite`.

The right model depends on what you value most—recall, precision, cost, or token efficiency—but the data shows you do not need to spend a dollar per analysis to get excellent T-SQL static analysis.
