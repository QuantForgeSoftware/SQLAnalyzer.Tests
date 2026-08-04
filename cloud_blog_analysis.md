# SQLAnalyzer Model Roundup: Finding the Best AI for T-SQL Code Review

When you hand a complex T-SQL procedure to an AI and ask it to find every anti-pattern, the results vary dramatically. We used **Quant Forge Software SQLAnalyzer** to analyze the same procedure, `usp_TestProcedure.sql`, across a broad set of models. The procedure is packed with deliberate performance, security, and maintainability issues, and it is only available as part of SQLAnalyzer, making this a controlled, reproducible benchmark.

The goal was simple: count how many of the known expected findings each model catches, how many it misses, what extra issues it invents, and how reliably it classifies severity. Because runs happened on different hardware, speed is not compared, but token usage and cost are.

## The Benchmark

The reference set contains **96 expected findings** spanning **61 distinct rules**. These include security risks such as SQL injection through dynamic SQL, performance anti-patterns such as leading wildcards and functions on indexed columns, maintainability issues such as hard-coded literals, and procedural mistakes such as unreset session settings and transactions without proper error handling.

For each model, the raw output was compared to the expected set with a line-number tolerance of +/-4 lines, because models often report an issue one or two lines away from where a human annotator placed it. Matched findings were not listed; only misses, extras, and severity disagreements were tracked.

## Overall Results

| Model | Input Tokens | Output Tokens | Total Tokens | Cost (USD) | Matched | Missed | Extra | Severity Mismatches |
|---|---|---|---|---|---:|---:|---:|---:|
| deepseek-v4-flash | 15,095 | 40,649 | 55,744 | $0.0135 | 90 | 6 | 0 | 3 |
| grok-4.5 | 13,287 | 5,213 | 18,500 | $0.0579 | 89 | 7 | 0 | 7 |
| qwen3.8-max | 13,312 | 42,886 | 56,198 | $0.3549 | 89 | 7 | 0 | 5 |
| qwen3.8-max-preview | — | — | — | — | 90 | 6 | 0 | 3 |
| kimi-k2.7-code | 12,773 | 37,180 | 49,953 | $0.1511 | 87 | 9 | 0 | 4 |
| gpt-5.6-sol | 12,845 | 10,227 | 23,072 | $0.3710 | 86 | 10 | 6 | 4 |
| claude-opus-5 | 24,942 | 16,080 | 41,022 | $0.5267 | 86 | 10 | 1 | 11 |
| gemini-3.1-pro-preview | 14,339 | 5,233 | 19,572 | $0.0986 | 85 | 11 | 0 | 4 |
| gpt-5.6-terra | 12,845 | 7,659 | 20,504 | $0.1470 | 85 | 11 | 0 | 1 |
| kimi-k3 | 12,929 | 29,696 | 42,625 | $0.4493 | 83 | 13 | 0 | 4 |
| claude-sonnet-5 | 24,744 | 23,908 | 48,652 | $0.2886 | 82 | 14 | 1 | 6 |
| claude-opus-4-8 | 24,942 | 6,813 | 31,755 | $0.2950 | 82 | 14 | 4 | 6 |
| claude-fable-5 | 24,942 | 16,695 | 41,637 | $1.0842 | 82 | 14 | 0 | 4 |
| gpt-5.6-luna | 12,845 | 7,848 | 20,693 | $0.0599 | 82 | 14 | 1 | 3 |
| glm-5.2 | 12,540 | 14,740 | 27,280 | $0.0824 | 82 | 14 | 0 | 4 |
| qwen3.7-max | 13,100 | 19,977 | 33,077 | $0.1826 | 81 | 15 | 0 | 3 |
| gemini-3.6-flash | 14,402 | 4,647 | 19,049 | $0.0565 | 79 | 17 | 0 | 3 |
| gemini-flash-latest | 14,339 | 4,468 | 18,807 | $0.0608 | 79 | 17 | 0 | 7 |
| MiniMax M3 | 13,290 | 42,754 | 56,044 | $0.0553 | 77 | 19 | 0 | 3 |
| qwen3.7-plus | 13,155 | 19,036 | 32,191 | $0.0357 | 70 | 26 | 0 | 3 |
| gemini-3.1-flash-lite | 14,339 | 3,366 | 17,705 | $0.0086 | 11 | 85 | 46 | 2 |

A few models sit well ahead of the pack. At the low end, `gemini-3.1-flash-lite` is essentially unusable for this task, matching only 11 of 96 findings while inventing 46 extras.

## Types of Incorrect Answers

### Missed Findings

A missed finding means the model failed to report a known issue within five lines of the expected location. The most common missed rules across models are:

- **`SessionSettingChanged`**: Both `SET NOCOUNT OFF` and `SET XACT_ABORT OFF` at the top of the procedure are frequently missed. Many models report the sibling `NoCountDisabled` or `XactAbortDisabled` rules but overlook that the settings are never restored before the procedure ends.
- **`SqlInjectionViaDynamicSql`**: The procedure contains three separate dynamic-SQL injection risks. Most models catch only one or two, even when they correctly identify related dynamic-SQL concatenation warnings.
- **`HardCodedLiteral` / `MagicDateLiteral`**: Weaker and mid-tier models often miss embedded numeric, date, and sentinel values. This is one of the clearest separators between top-tier and average models.
- **`AggregateWithoutFilter`**, **`InsertWithoutColumnList`**, and correlated subquery rules appear in the miss lists of several otherwise strong models.

### Extra Findings

Extra findings are reports that do not correspond to anything in the expected set. After a small correction to the expected set to include a legitimate hard-coded literal on line 51, only a handful of models still produced extras:

- `gpt-5.6-sol` produced 6 extras, the most of any usable model.
- `claude-opus-4-8` produced 4 extras.
- `gpt-5.6-luna`, `claude-opus-5`, and `claude-sonnet-5` each produced 1 extra.

Most extras fall into two buckets: over-aggressive literal detection and line-number drift that places a legitimate finding outside the tolerance window. `gpt-5.6-sol` stands out for reporting hard-coded literals on line 51 that the expected set does not capture, even after the correction.

### Severity Mismatches

Severity mismatches occur when a model correctly identifies a rule but labels it `warning` instead of `error`, or vice versa. The strongest models still show this weakness:

- `claude-opus-5` has 11 severity mismatches, the most among top models.
- `grok-4.5` has 7, mostly downgrading `error`-level transaction and dynamic-SQL findings to `warning`.
- `qwen3.8-max` has 5, and `deepseek-v4-flash` has only 3.

The pattern is consistent: models tend to be conservative with severity. Several downgrade `DeleteWithWeakPredicate`, `ExplicitTransactionWithoutTryCatch`, and `NotInNullableSubquery` from `error` to `warning`, while occasionally upgrading dynamic-SQL warnings to `error`.

## Token Usage

Total token usage correlates with cost but is not identical to it. The largest outputs came from:

- `qwen3.8-max` (56,198 total tokens)
- `deepseek-v4-flash` (55,744)
- `MiniMax M3` (56,044)

These models all generated lengthy responses, often 40,000+ output tokens. By contrast, `gemini-3.1-flash-lite` used only 17,705 total tokens and `grok-4.5` used only 18,500, yet their quality was radically different. `grok-4.5` produced one of the highest match counts with a modest token footprint, while `gemini-3.1-flash-lite` produced the lowest.

Cost per matched finding tells a clearer story. `deepseek-v4-flash` costs roughly **$0.00015 per matched finding**. `qwen3.8-max` costs **$0.0040 per matched finding**, nearly 27 times more. `claude-fable-5` costs **$0.0132 per matched finding**, the highest among all models. Even `grok-4.5`, at **$0.00065 per matched finding**, is more than four times the cost of `deepseek-v4-flash` for a slightly lower match count.

## Best Model Regardless of Expense

If cost is no object, the best model is **deepseek-v4-flash**. It matched **90 of 96** expected findings, missed only 6, produced zero extras, and had just 3 severity mismatches. The next closest models, `grok-4.5` and `qwen3.8-max`, each matched 89 findings, but both had more severity mismatches. The `qwen3.8-max-preview` run also reached 90 matched findings, but without cost or token data it cannot be ranked for practical use.

DeepSeek’s lead is not marginal. It is the only production-priced model to break the 90-match barrier while also keeping extras and severity mismatches low. Its misses are concentrated in `SessionSettingChanged`, `SqlInjectionViaDynamicSql`, `HardCodedLiteral`, and `AggregateWithoutFilter`, the same categories that trouble every other model.

## Best Value

The best value is also **deepseek-v4-flash**. At **$0.0135** for a 90-match result, it delivers the highest correctness at the lowest cost in the field. The next-best value contender is `grok-4.5`, which costs $0.0579 for 89 matches, roughly four times the price for slightly lower accuracy.

`gemini-3.1-flash-lite` is the cheapest at $0.0086, but it is not a value play because its output is unreliable. Paying less for results you cannot trust is not value. `deepseek-v4-flash` proves that high-quality code review can be inexpensive.

## Choices to Make

Teams choosing an AI for SQL code review face three practical questions:

1. **Do you need the highest possible recall, or is "good enough" acceptable?**
   If you are doing pre-commit or pre-release review and want to catch the maximum number of real issues, `deepseek-v4-flash` is the clear choice. If you only need a lightweight sanity check, cheaper models such as `gemini-3.6-flash` or `grok-4.5` may suffice, but you will miss more.

2. **How much do severity labels matter?**
   If your workflow auto-fails pipelines on `error`-level findings, conservative severity downgrades can hide real problems. `deepseek-v4-flash` and `gpt-5.6-terra` have the fewest severity mismatches, making them safer for automated gating.

3. **Can you tolerate invented findings?**
   Models with many extras create noise that developers learn to ignore. After the expected-set update, most top models have zero extras. Avoid `gpt-5.6-sol` and `claude-opus-4-8` if clean output matters.

4. **Are you watching token budgets?**
   Models such as `qwen3.8-max` and `MiniMax M3` consume 50,000+ tokens per analysis. At scale, that adds up quickly, especially when cheaper alternatives exist.

## Why SQLAnalyzer Matters

This comparison would not be possible without a controlled testbed. `usp_TestProcedure.sql` is designed to exercise dozens of T-SQL anti-patterns in a single script, and the accompanying expected-findings file gives every model the same target. That combination is only available through **Quant Forge Software SQLAnalyzer**.

If you are evaluating AI models for database code review, the first tool you need is a benchmark that separates real signal from marketing noise. SQLAnalyzer provides that benchmark, and the results above show that the right model choice can cut your cost by an order of magnitude while improving accuracy.

## Bottom Line

For T-SQL static analysis, **deepseek-v4-flash** is both the most accurate and the most cost-effective model tested. It is the recommendation for teams who want maximum recall, minimal noise, and a near-zero cost per analysis. If you cannot use that model, `grok-4.5` and `qwen3.8-max` are strong alternatives, but you will pay more and catch slightly less. Avoid the cheapest flash models unless you are willing to manually verify nearly every finding.
