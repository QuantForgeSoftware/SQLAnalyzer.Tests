# SQLAnalyzer Model Roundup: Finding the Best AI for T-SQL Code Review

When you hand a complex T-SQL procedure to an AI and ask it to find every anti-pattern, the results vary dramatically. We used **Quant Forge Software SQLAnalyzer** to analyze the same procedure, `usp_TestProcedure.sql`, across a broad set of models. The procedure is packed with deliberate performance, security, and maintainability issues, and it is only available as part of SQLAnalyzer, making this a controlled, reproducible benchmark.

The goal was simple: count how many of the known expected findings each model catches, how many it misses, what extra issues it invents, and how reliably it classifies severity. Because runs happened on different hardware, speed is not compared, but token usage and cost are.

## The Benchmark

The reference set contains **96 expected findings** spanning **61 distinct rules**. These include security risks such as SQL injection through dynamic SQL, performance anti-patterns such as leading wildcards and functions on indexed columns, maintainability issues such as hard-coded literals, and procedural mistakes such as unreset session settings and transactions without proper error handling.

For each model, the raw output was compared to the expected set with a line-number tolerance of +/-4 lines, because models often report an issue one or two lines away from where a human annotator placed it. Matched findings were not listed; only misses, extras, and severity disagreements were tracked.

## Overall Results

| Model | Input Tokens | Output Tokens | Total Tokens | Cost (USD) | Matched | Missed | Extra | Severity Mismatches |
|---|---|---|---|---|---:|---:|---:|---:|
| grok-4.6 | 13,287 | 5,664 | 18,951 | $0.0606 | 91 | 0* | 7 | 6 |
| deepseek-v4-flash | 15,095 | 40,649 | 55,744 | $0.0135 | 90 | 6 | 0 | 3 |
| qwen3.8-max-preview | — | — | — | — | 90 | 6 | 0 | 3 |
| grok-4.5 | 13,287 | 5,213 | 18,500 | $0.0579 | 89 | 7 | 0 | 7 |
| qwen3.8-max | 13,312 | 42,886 | 56,198 | $0.3549 | 89 | 7 | 0 | 5 |
| deepseek-v4-pro | 15,095 | 38,504 | 53,599 | $0.0205 | 86 | 10 | 0 | 3 |
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

A few models sit well ahead of the pack. `grok-4.6` tops the raw match count at 91, though its score needs a closer look: the five entries in the "missed" column are rule-name mismatches rather than true omissions. It detected every one of those anti-patterns, but labeled `NoCountDisabled` instead of `SessionSettingChanged`, `XactAbortDisabled` instead of `SessionSettingChanged`, `MagicDateLiteral` instead of `HardCodedLiteral`, and `DynamicSqlConcatenation` instead of `SqlInjectionViaDynamicSql`. The trade-off is that it introduced 7 extra findings, mostly additional date-conversion and hard-coded-literal reports at the same locations.

`deepseek-v4-pro` is a notable addition. It costs slightly more than `deepseek-v4-flash` ($0.0205 vs. $0.0135) and matched fewer findings (86 vs. 90). It shares the same zero-extras, low-severity-mismatch profile as its cheaper sibling, but it missed more hard-coded literals, the second dynamic-SQL injection cluster, and a few later-procedure rules such as `UpdateWithoutMeaningfulChange` and `InsertWithoutColumnList`. The “pro” variant is not a clear upgrade for this task.

## Types of Incorrect Answers

### Missed Findings

A missed finding means the model failed to report a known issue within five lines of the expected location. The most common missed rules across models are:

- **`SessionSettingChanged`**: Both `SET NOCOUNT OFF` and `SET XACT_ABORT OFF` at the top of the procedure are frequently missed. Many models report the sibling `NoCountDisabled` or `XactAbortDisabled` rules but overlook that the settings are never restored before the procedure ends. `grok-4.6` is an exception here: it reported both anti-patterns, just under the sibling rule names.
- **`SqlInjectionViaDynamicSql`**: The procedure contains three separate dynamic-SQL injection risks. Most models catch only one or two, even when they correctly identify related dynamic-SQL concatenation warnings. `grok-4.6` again reports the underlying concatenations but does not label the injection risk explicitly for the first two cases.
- **`HardCodedLiteral` / `MagicDateLiteral`**: Weaker and mid-tier models often miss embedded numeric, date, and sentinel values. This is one of the clearest separators between top-tier and average models. `grok-4.6` finds the 2016 literal but calls it `MagicDateLiteral`, which our benchmark counts as a miss for `HardCodedLiteral` even though the issue was identified.
- **`AggregateWithoutFilter`**, **`InsertWithoutColumnList`**, and correlated subquery rules appear in the miss lists of several otherwise strong models.

### Extra Findings

Extra findings are reports that do not correspond to anything in the expected set. `grok-4.6` produced 7 extras, the most of any top-tier model, split between additional hard-coded-literal labels (`'urgent'`, `Quantity > 1`, `'%A%'`) and additional date-conversion labels at lines 138 and 229. These are defensible interpretations, but they create noise that simpler models avoided.

After a small correction to the expected set to include a legitimate hard-coded literal on line 51, only a handful of other models still produced extras:

- `gpt-5.6-sol` produced 6 extras.
- `claude-opus-4-8` produced 4 extras.
- `gpt-5.6-luna`, `claude-opus-5`, and `claude-sonnet-5` each produced 1 extra.

Most extras fall into two buckets: over-aggressive literal/conversion detection and line-number drift that places a legitimate finding outside the tolerance window. `grok-4.6` and `gpt-5.6-sol` both show that a model can catch more issues while also producing more reports that do not match the benchmark.

### Severity Mismatches

Severity mismatches occur when a model correctly identifies a rule but labels it `warning` instead of `error`, or vice versa. The strongest models still show this weakness:

- `claude-opus-5` has 11 severity mismatches, the most among top models.
- `grok-4.5` has 7, mostly downgrading `error`-level transaction and dynamic-SQL findings to `warning`.
- `grok-4.6` has 6, an improvement over `grok-4.5`, but it still upgrades `XactAbortDisabled`, two `CatchSwallowsError` instances, `AmbiguousDateConversion`, and `OuterJoinToFilter` to `error` while downgrading `ExplicitTransactionWithoutTryCatch` to `warning`.
- `qwen3.8-max` has 5, and `deepseek-v4-flash` has only 3.

The pattern is consistent: models tend to be conservative with severity. Several downgrade `DeleteWithWeakPredicate`, `ExplicitTransactionWithoutTryCatch`, and `NotInNullableSubquery` from `error` to `warning`, while occasionally upgrading dynamic-SQL warnings to `error`.

## Token Usage

`grok-4.6` is notably efficient. It produced the highest match count using only 18,951 total tokens and 5,664 output tokens, a fraction of what most top-tier models consumed. That frugal output makes it one of the cheapest high-accuracy models to use at scale despite a higher per-token price.

Total token usage correlates with cost but is not identical to it. The largest outputs came from:

- `qwen3.8-max` (56,198 total tokens)
- `deepseek-v4-flash` (55,744)
- `MiniMax M3` (56,044)

These models all generated lengthy responses, often 40,000+ output tokens. By contrast, `gemini-3.1-flash-lite` used only 17,705 total tokens and `grok-4.5` used only 18,500, yet their quality was radically different. `grok-4.6` and `grok-4.5` both produced some of the highest match counts with a modest token footprint, while `gemini-3.1-flash-lite` produced the lowest.

Cost per matched finding tells a clearer story. `deepseek-v4-flash` costs roughly **$0.00015 per matched finding**. `deepseek-v4-pro` costs about **$0.00024 per matched finding** — still cheap, but more expensive and less accurate than the flash variant. `grok-4.6` costs **$0.00067 per matched finding**, roughly four times DeepSeek’s price but for the highest match count. `qwen3.8-max` costs **$0.0040 per matched finding**, nearly 27 times more than `deepseek-v4-flash`. `claude-fable-5` costs **$0.0132 per matched finding**, the highest among all models.

## Best Model Regardless of Expense

If correctness is the only criterion, **grok-4.6** is the most accurate model tested. It matched **91 of 96** expected findings and, on closer inspection, had **zero true misses** — every expected anti-pattern was reported, but five were labeled under sibling rule names (`NoCountDisabled` instead of `SessionSettingChanged`, `MagicDateLiteral` instead of `HardCodedLiteral`, and `DynamicSqlConcatenation` instead of `SqlInjectionViaDynamicSql`). It also kept severity mismatches to 6, one fewer than `grok-4.5`, and it produced only 7 extras, all defensible interpretations.

`deepseek-v4-flash` and `qwen3.8-max-preview` are the next closest, each matching 90 findings. `deepseek-v4-flash` is the strongest *clean* performer: 90 matches, only 6 real misses, zero extras, and just 3 severity mismatches. `qwen3.8-max-preview` has the same 90/6/0/3 profile but lacks cost or token data, so it cannot be ranked for practical use.

The rest of the field sits at 89 or below. `grok-4.5` and `qwen3.8-max` reached 89 matches. `kimi-k2.7-code` and several GPT and Claude variants clustered in the mid-80s. Every one of these models missed more genuine issues than `grok-4.6`.

For a benchmark that rewards pure recall, `grok-4.6` is the leader. For a benchmark that rewards precision plus recall, `deepseek-v4-flash` is the safer fallback because it avoids the extra noise and rule-name ambiguity that `grok-4.6` introduces.

## Best Value

Value depends on whether you define it as lowest cost per matched finding or lowest cost per *clean* matched finding.

`deepseek-v4-flash` is the lowest-cost clean option: **$0.0135** for 90 matches, zero extras, and minimal severity mismatches. It is the choice if you want the cheapest report you can trust without manual review.

`grok-4.6` is the value choice if you want the highest raw recall. At **$0.0606** it is not the cheapest per match, but it is far less expensive than `qwen3.8-max`, `claude-opus-5`, or `claude-fable-5`, and it catches more than any of them. Its tiny token footprint (18,951 total tokens) also keeps serving costs low. The 7 extras add some triage overhead, but the underlying issues were all detected.

`grok-4.5` is a close sibling: slightly cheaper at $0.0579 for 89 matches and zero extras. If you do not need the extra match, it is a marginally more economical pick from the same family.

`deepseek-v4-pro` is also worth mentioning. Despite the “pro” label and a slightly higher price than `deepseek-v4-flash`, it matched fewer findings and is not an upgrade for this task. It does, however, keep the same clean profile: zero extras and only 3 severity mismatches.

`gemini-3.1-flash-lite` is the cheapest at $0.0086, but it is not a value play because its output is unreliable. Paying less for results you cannot trust is not value.

## Choices to Make

Teams choosing an AI for SQL code review face three practical questions:

1. **Do you need the highest possible recall, or is "good enough" acceptable?**
   If you are doing pre-commit or pre-release review and want to catch the maximum number of real issues, **grok-4.6** is the clear choice: it found more issues than any other model, with zero true misses after review. If you want a quieter report and can accept slightly lower recall, `deepseek-v4-flash` is the better fit. If you only need a lightweight sanity check, cheaper models such as `gemini-3.6-flash` or `grok-4.5` may suffice, but you will miss more.

2. **How much do severity labels matter?**
   If your workflow auto-fails pipelines on `error`-level findings, conservative severity downgrades can hide real problems. `deepseek-v4-flash` and `gpt-5.6-terra` have the fewest severity mismatches, making them safer for automated gating.

3. **Can you tolerate invented findings?**
   Models with many extras create noise that developers learn to ignore. After the expected-set update, most top models have zero extras, but `grok-4.6` produced 7 extras and `gpt-5.6-sol` produced 6. In `grok-4.6`’s case the extras are mostly sibling labels for real issues, so they are more tolerable than outright inventions. Avoid `gpt-5.6-sol` and `claude-opus-4-8` if clean output matters most.

4. **Are you watching token budgets?**
   Models such as `qwen3.8-max` and `MiniMax M3` consume 50,000+ tokens per analysis. At scale, that adds up quickly, especially when cheaper alternatives exist. `grok-4.6` and `grok-4.5` show that high accuracy does not require a huge token footprint.

## Why SQLAnalyzer Matters

This comparison would not be possible without a controlled testbed. `usp_TestProcedure.sql` is designed to exercise dozens of T-SQL anti-patterns in a single script, and the accompanying expected-findings file gives every model the same target. That combination is only available through **Quant Forge Software SQLAnalyzer**.

If you are evaluating AI models for database code review, the first tool you need is a benchmark that separates real signal from marketing noise. SQLAnalyzer provides that benchmark, and the results above show that the right model choice can cut your cost by an order of magnitude while improving accuracy.

## Bottom Line

For T-SQL static analysis, **grok-4.6** is the most accurate model tested, matching 91 of 96 expected findings with zero true misses after review. It delivers that accuracy with a small token footprint and at a moderate cost, making it the recommendation for teams who want maximum recall. The trade-off is 7 extra findings and 5 rule-name mismatches, so teams that prioritize clean, directly comparable output should consider **deepseek-v4-flash** instead — it matched 90 findings with zero extras and only 3 severity mismatches, and it is by far the lowest-cost option. `grok-4.5` and `qwen3.8-max` are solid alternatives but trail `grok-4.6` and `deepseek-v4-flash` on both accuracy and cost. Avoid the cheapest flash models unless you are willing to manually verify nearly every finding.
