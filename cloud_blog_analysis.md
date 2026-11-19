# Cloud AI Models for T-SQL Static Analysis: A Head-to-Head Comparison

Quant Forge Software SQLAnalyzer was used to analyze a single, deliberately flawed stored procedure, `usp_TestProcedure.sql`, and to ask each model to report code-quality, correctness, and performance issues in a structured JSON format. The procedure is only available as part of SQLAnalyzer and is designed to surface a broad catalog of real-world T-SQL anti-patterns. Every model in this comparison was run with the same prompt, the same source file, and the same expected-finding set.

The expected output contains 96 findings across 61 rules. A finding counts as matched when the rule name is correct and the reported line is within four lines of the expected line (differences under five lines are ignored). Cost, token usage, and run time are compared as well. This edition adds `gpt-6.2-astra` and `gpt-6.2-sol` at low, medium, high, xhigh, and max reasoning effort, and `qwen4-max-preview` at low, medium, and xhigh, plus `gemini-4-neon` at low, medium, and high — along with earlier additions of `gemini-4-carbon` and `gemini-4-hydrogen` at several reasoning-effort settings and `gpt-6.1-terra` at both its default and high reasoning effort — bringing the comparison to 42 models and 61 runs; the table also includes a second run of `deepseek-v4.1-flash` (listed as `deepseek-v4.1-flash-1017`). Every run is rescored with the same matching rules.

## The Results at a Glance

| Model | Matched | Missed | Extra | Recall | Precision | F1 | Total Tokens | Est. Cost | Time |
|---|---:|---:|---:|---:|---:|---:|---:|---:|---:|
| qwen3.8-flash | 91 | 5 | 0 | 0.948 | 1.000 | **0.973** | 68,133 | $0.44 | 8:57 |
| deepseek-v4-flash | 90 | 6 | 0 | 0.938 | 1.000 | **0.968** | 55,744 | $0.01 | 4:18 |
| qwen3.8-max-preview | 90 | 6 | 0 | 0.938 | 1.000 | **0.968** | n/a | n/a | n/a |
| claude-fable-5-1 | 90 | 6 | 1 | 0.938 | 0.989 | 0.963 | 40,303 | $1.02 | 2:21 |
| grok-4.5 | 89 | 7 | 0 | 0.927 | 1.000 | 0.962 | 18,500 | $0.06 | 6:21 |
| qwen3.8-max | 89 | 7 | 0 | 0.927 | 1.000 | 0.962 | 56,198 | $0.35 | 13:35 |
| kimi-k2.7-code | 87 | 9 | 0 | 0.906 | 1.000 | 0.951 | 49,953 | $0.15 | 8:55 |
| deepseek-v4-pro | 86 | 10 | 0 | 0.896 | 1.000 | 0.945 | 53,599 | $0.02 | 8:24 |
| claude-opus-5 | 86 | 10 | 1 | 0.896 | 0.989 | 0.940 | 41,022 | $0.53 | 2:25 |
| gemini-3.1-pro-preview | 85 | 11 | 0 | 0.885 | 1.000 | 0.939 | 19,572 | $0.10 | 2:47 |
| gpt-5.6-terra | 85 | 11 | 0 | 0.885 | 1.000 | 0.939 | 20,504 | $0.15 | 1:00 |
| **gemini-4-carbon (none effort)** (new) | 85 | 11 | 0 | 0.885 | 1.000 | 0.939 | 19,253 | $0.08 | 0:53 |
| grok-4.6 | 91 | 5 | 7 | 0.948 | 0.929 | 0.938 | 18,951 | $0.06 | 5:46 |
| minimax-m3.1-flash | 86 | 10 | 2 | 0.896 | 0.977 | 0.935 | 63,794 | $0.03 | 6:24 |
| kimi-k3 | 83 | 13 | 0 | 0.865 | 1.000 | 0.927 | 42,625 | $0.45 | 12:42 |
| glm-5.3 | 83 | 13 | 0 | 0.865 | 1.000 | 0.927 | 51,929 | $0.19 | 6:29 |
| glm-5.2 | 82 | 14 | 0 | 0.854 | 1.000 | 0.921 | 27,280 | $0.08 | 2:52 |
| claude-fable-5 | 82 | 14 | 0 | 0.854 | 1.000 | 0.921 | 41,637 | $1.08 | 2:32 |
| grok-4.7 | 86 | 10 | 5 | 0.896 | 0.945 | 0.920 | 21,214 | $0.16 | 13:23 |
| gpt-5.6-luna | 82 | 14 | 1 | 0.854 | 0.988 | 0.916 | 20,693 | $0.06 | 0:49 |
| claude-sonnet-5 | 82 | 14 | 1 | 0.854 | 0.988 | 0.916 | 48,652 | $0.29 | 2:55 |
| qwen3.7-max | 81 | 15 | 0 | 0.844 | 1.000 | 0.915 | 33,077 | $0.18 | 6:03 |
| gpt-5.6-sol | 86 | 10 | 6 | 0.896 | 0.935 | 0.915 | 23,072 | $0.37 | 2:27 |
| **gpt-6.1-terra (high effort)** (new) | 82 | 14 | 3 | 0.854 | 0.965 | 0.906 | 21,319 | $0.05 | 1:34 |
| gemini-flash-latest | 79 | 17 | 0 | 0.823 | 1.000 | 0.903 | 18,807 | $0.06 | 1:20 |
| gemini-3.6-flash | 79 | 17 | 0 | 0.823 | 1.000 | 0.903 | 19,049 | $0.06 | 1:08 |
| **gemini-4-carbon (medium effort)** (new) | 79 | 17 | 0 | 0.823 | 1.000 | 0.903 | 18,880 | $0.08 | 4:23 |
| claude-opus-4-8 | 82 | 14 | 4 | 0.854 | 0.953 | 0.901 | 31,755 | $0.30 | 1:08 |
| gpt-6-astra | 88 | 8 | 12 | 0.917 | 0.880 | 0.898 | 20,837 | $0.53 | 1:38 |
| glm-5.3-flash | 78 | 18 | 0 | 0.813 | 1.000 | 0.897 | 61,814 | $0.23 | 12:33 |
| deepseek-v4.1-flash | 78 | 18 | 0 | 0.813 | 1.000 | 0.897 | 47,759 | $0.05 | 2:20 |
| **gpt-6.2-astra (low effort)** (new) | 82 | 14 | 6 | 0.854 | 0.932 | 0.891 | 17,215 | $0.31 | 1:14 |
| **gpt-6.2-astra (medium effort)** (new) | 82 | 14 | 6 | 0.854 | 0.932 | 0.891 | 17,392 | $0.32 | 0:57 |
| MiniMax M3 | 77 | 19 | 0 | 0.802 | 1.000 | 0.890 | 56,044 | $0.06 | 4:21 |
| gemini-3.8-flash | 77 | 19 | 0 | 0.802 | 1.000 | 0.890 | 19,299 | $0.03 | 1:04 |
| mercury-3 (see note) | 77 | 19 | 0 | 0.802 | 1.000 | 0.890 | 35,869 | $0.01 | 0:40 |
| **gpt-6.1-terra** (new) | 79 | 17 | 3 | 0.823 | 0.963 | 0.888 | 19,161 | $0.04 | 1:11 |
| **gpt-6.2-astra (high effort)** (new) | 82 | 14 | 7 | 0.854 | 0.921 | 0.886 | 20,085 | $0.46 | 2:02 |
| **gpt-6.2-astra (xhigh effort)** (new) | 82 | 14 | 7 | 0.854 | 0.921 | 0.886 | 25,556 | $0.73 | 4:06 |
| **gemini-4-carbon (low effort)** (new) | 76 | 20 | 0 | 0.792 | 1.000 | 0.884 | 18,619 | $0.08 | 0:54 |
| **gpt-6.2-sol (low effort)** (new) | 80 | 16 | 5 | 0.833 | 0.941 | 0.884 | 17,085 | $0.14 | 0:40 |
| **gpt-6.2-sol (max effort)** (new) | 81 | 15 | 7 | 0.844 | 0.920 | 0.880 | 36,681 | $0.34 | 4:16 |
| **gpt-6.2-sol (medium effort)** (new) | 79 | 17 | 5 | 0.823 | 0.940 | 0.878 | 18,980 | $0.16 | 1:02 |
| **gpt-6.2-sol (xhigh effort)** (new) | 81 | 15 | 8 | 0.844 | 0.910 | 0.876 | 25,841 | $0.23 | 2:18 |
| **gpt-6.2-sol (high effort)** (new) | 80 | 16 | 7 | 0.833 | 0.920 | 0.874 | 21,561 | $0.19 | 1:30 |
| **gpt-6.2-astra (max effort)** (new) | 83 | 13 | 12 | 0.865 | 0.874 | 0.869 | 46,024 | $1.76 | 4:01 |
| **qwen4-max-preview (low effort)** (new) | 73 | 23 | 1 | 0.760 | 0.986 | 0.859 | 23,019 | $0.06 | 2:17 |
| gemini-4-argon | 72 | 24 | 0 | 0.750 | 1.000 | 0.857 | 18,154 | $0.07 | 0:51 |
| **qwen4-max-preview (medium effort)** (new) | 72 | 24 | 1 | 0.750 | 0.986 | 0.852 | 24,038 | $0.06 | 2:44 |
| qwen3.7-plus | 70 | 26 | 0 | 0.729 | 1.000 | 0.843 | 32,191 | $0.04 | 5:47 |
| **gemini-4-neon (medium effort)** (new) | 69 | 27 | 0 | 0.719 | 1.000 | 0.836 | 19,209 | $0.11 | 1:14 |
| **gemini-4-neon (high effort)** (new) | 69 | 27 | 0 | 0.719 | 1.000 | 0.836 | 19,446 | $0.11 | 2:02 |
| **qwen4-max-preview (xhigh effort)** (new) | 68 | 28 | 0 | 0.708 | 1.000 | 0.829 | 42,082 | $0.15 | 7:36 |
| gemini-3.7-flash | 68 | 28 | 0 | 0.708 | 1.000 | 0.829 | 18,457 | $0.06 | 0:25 |
| deepseek-v4.1-flash-1017 | 67 | 29 | 0 | 0.698 | 1.000 | 0.822 | 58,348 | $0.06 | 2:38 |
| **gemini-4-hydrogen (high effort)** (new) | 67 | 29 | 0 | 0.698 | 1.000 | 0.822 | 18,045 | $0.05 | 1:06 |
| **gemini-4-hydrogen (low effort)** (new) | 67 | 29 | 0 | 0.698 | 1.000 | 0.822 | 17,802 | $0.05 | 0:38 |
| muse-wonder-1.0 | 66 | 30 | 0 | 0.688 | 1.000 | 0.815 | 37,086 | $0.53 | 2:01 |
| **gemini-4-neon (low effort)** (new) | 66 | 30 | 0 | 0.688 | 1.000 | 0.815 | 18,888 | $0.11 | 0:59 |
| **gemini-4-hydrogen (none effort)** (new) | 65 | 31 | 0 | 0.677 | 1.000 | 0.807 | 17,585 | $0.05 | 0:35 |
| **gemini-4-hydrogen (medium effort)** (new) | 65 | 31 | 0 | 0.677 | 1.000 | 0.807 | 17,949 | $0.05 | 1:02 |

**Note:** `mercury-3` reported unreliable line numbers that drift progressively earlier through the procedure, so it is scored on the issues it found rather than their locations (same rule, matched one-to-one, line numbers ignored). All other models are scored with the standard four-line tolerance. **Time** is how long the model took to return its analysis (minutes:seconds) on a single run; run times vary with hardware and server load, so treat small differences as noise.

## Correctness: What "Wrong" Looks Like

No model achieved a perfect score. The errors fall into three buckets:

- **Missed findings (false negatives).** This is by far the biggest source of error. The most common blind spot is `SessionSettingChanged` on `SET NOCOUNT OFF` and `SET XACT_ABORT OFF`: nearly every model reports the specific `NoCountDisabled` and `XactAbortDisabled` findings on those lines but skips the broader rule that a session setting is changed and never restored. The same "one finding per line" habit hides `SqlInjectionViaDynamicSql` behind `DynamicSqlConcatenation` at lines 111 and 115; both new runs fell into both traps. Other frequent misses are repeated anti-patterns (hard-coded literals and `TOP` without `ORDER BY` that appear several times), the dynamic `LIKE` at line 221, a no-op `UPDATE`, and an unfiltered `COUNT(*)`.
- **Extra findings (false positives).** Most models report no extras at all. Where extras do appear, they are usually a rule applied more broadly than the answer key: `grok-4.7` flags every `LIKE` pattern and `COALESCE` sentinel as a `HardCodedLiteral`, `minimax-m3.1-flash` and `gpt-6.1-terra` flag the literal initial values of variables, and `gpt-6-astra` and `grok-4.6` decompose single statements into several findings.
- **Severity disagreements.** Even when the rule and line are right, models often promote a warning to an error or the reverse, typically on `AmbiguousDateConversion`, `CatchSwallowsError`, `DeleteWithWeakPredicate`, and `ExplicitTransactionWithoutTryCatch`. `minimax-m3.1-flash` disagreed on ten severities, mostly by raising warnings to errors. These do not affect the score, but they matter if severity drives your build gate.

The shape of a model's errors says a lot about its behavior:

- **Conservative models** such as `gemini-4-neon` at medium and high effort (0 extras, 27 missed), `gemini-4-neon (low effort)` (0 extras, 30 missed), `gemini-4-argon` (0 extras, 24 missed), `qwen3.7-plus` (26 missed), `qwen4-max-preview (xhigh effort)` (0 extras, 28 missed), `gemini-3.7-flash` (28 missed), `deepseek-v4.1-flash-1017` and the better `gemini-4-hydrogen` runs (29 missed), `muse-wonder-1.0` (30 missed), and the none and medium `gemini-4-hydrogen` runs (31 missed) never cry wolf, but they report each pattern once and leave a meaningful fraction of issues unreported. The low and medium `qwen4-max-preview` runs are almost as conservative (one extra, 23–24 missed).
- **Over-eager models** such as `gpt-6-astra` (12 extras), `gpt-6.2-astra (max effort)` (12 extras), `grok-4.6` (7 extras), `gpt-5.6-sol` (6 extras), and `grok-4.7` (5 extras) catch most real issues but add findings a reviewer has to sort through. The lower-effort `gpt-6.2-astra` and `gpt-6.2-sol` runs also add five to eight extras.
- **Balanced models** such as `qwen3.8-flash`, `deepseek-v4-flash`, `qwen3.8-max-preview`, and `grok-4.5` combine 89-91 matches with zero extras, giving them the highest F1 scores. `minimax-m3.1-flash` is close behind: 86 matches with only two extras.

### The newest additions

- **gemini-4-neon (medium effort)** (new) matched 69 of 96 with zero extras for an F1 of 0.836, 51st of 61 runs, tying the high-effort run. Precision is perfect, and it finishes in 1:14 at about $0.11. Like other recent runs, most matches are one line early and still within tolerance. It is the stronger default of the three complete Neon analysis runs.

- **gemini-4-neon (high effort)** (new) also matched 69 of 96 with zero extras for an F1 of 0.836, 52nd of 61 runs, tying medium effort. It takes 2:02 at about $0.11 — a little slower than medium for the same score. Raising effort from medium to high did not help.

- **gemini-4-neon (low effort)** (new) matched 66 of 96 with zero extras for an F1 of 0.815, 59th of 61 runs, tying `muse-wonder-1.0` on F1. It is the fastest and cheapest of the three complete Neon runs (0:59, about $0.11) but misses three more expected findings than medium or high. An xhigh run later completed in a background retry, but official result files were not written, so that effort is omitted here.



- **gpt-6.2-astra (low effort)** (new) matched 82 of 96 with six extras for an F1 of 0.891, 32nd of 61 runs, tying its medium-effort run. It is the strongest of the GPT 6.2 and Qwen4 additions on this test. The six extras keep it just behind `gpt-6-astra` (88 matches, 12 extras, F1 0.898). It finishes in 1:14 at about $0.31, with 17,215 tokens.

- **gpt-6.2-astra (medium effort)** (new) matched 82 of 96 with six extras for an F1 of 0.891, 33rd of 61 runs, tying low effort and finishing a little faster (0:57) at about $0.32. Raising effort from low to medium did not find more of the expected issues.

- **gpt-6.2-astra (high effort)** (new) matched 82 of 96 with seven extras for an F1 of 0.886, 38th of 61 runs, in 2:02 at about $0.46. It does not beat low or medium effort.

- **gpt-6.2-astra (xhigh effort)** (new) matched 82 of 96 with seven extras for an F1 of 0.886, 39th of 61 runs, tying high effort. It takes 4:06 at about $0.73, more than three times the cost of the low-effort run for the same 82 matches.

- **gpt-6.2-astra (max effort)** (new) matched 83 of 96, one more than the other Astra runs, but added 12 extras for an F1 of 0.869, 46th of 61, and cost about $1.76 in 4:01. Max is Astra's weakest and most expensive setting on this test.

- **gpt-6.2-sol (low effort)** (new) matched 80 of 96 with five extras for an F1 of 0.884, 41st of 61 runs, tying `gemini-4-carbon (low effort)` on F1. It is the best Sol run, and at 0:40 and about $0.14 it is one of the quicker mid-table results. It trails its predecessor `gpt-5.6-sol` (86 of 96, six extras, F1 0.915).

- **gpt-6.2-sol (max effort)** (new) matched 81 of 96 with seven extras for an F1 of 0.880, 42nd of 61 runs, in 4:16 at about $0.34. It finds one more expected issue than low effort, at more than twice the cost and time.

- **gpt-6.2-sol (medium effort)** (new) matched 79 of 96 with five extras for an F1 of 0.878, 43rd of 61 runs, in 1:02 at about $0.16, just behind low and max.

- **gpt-6.2-sol (xhigh effort)** (new) matched 81 of 96 with eight extras for an F1 of 0.876, 44th of 61 runs, in 2:18 at about $0.23.

- **gpt-6.2-sol (high effort)** (new) matched 80 of 96 with seven extras for an F1 of 0.874, 45th of 61 runs, in 1:30 at about $0.19. Across five settings, Sol stays in a narrow F1 band (0.874–0.884); more effort does not clearly help.

- **qwen4-max-preview (low effort)** (new) matched 73 of 96 with one extra for an F1 of 0.859, 47th of 61 runs. Precision is essentially perfect, but recall is the limiter: it covers every rule type and still misses repeat instances of the same issue. It is inexpensive — 2:17, about six cents, and 23,019 tokens — and well behind `qwen3.8-flash` (91 of 96, F1 0.973).

- **qwen4-max-preview (medium effort)** (new) matched 72 of 96 with one extra for an F1 of 0.852, 49th of 61 runs, in 2:44 at about six cents. It is slightly behind the low-effort run.

- **qwen4-max-preview (xhigh effort)** (new) matched 68 of 96 with zero extras for an F1 of 0.829, 54th of 61 runs, tying `gemini-3.7-flash`. It thought the longest of the three Qwen4 runs (7:36, 42,082 tokens, about $0.15) and scored the lowest. Only low, medium, and xhigh are valid settings for this model.

- **gemini-4-carbon (none effort)** (new) matched 85 of 96 with zero extras for an F1 of 0.939, 12th of 61 runs, tying `gpt-5.6-terra` and `gemini-3.1-pro-preview` on score. It found all nine hard-coded literals and seven of eight `TOP` without `ORDER BY` cases, and it did not skip the harder single-instance rules that several peers miss. Its 11 misses are the familiar shared-line companions, part of the dynamic `LIKE` block at line 221, and four secondary instances (84, 98, 141, 159, 170). It is also quick and reasonably priced: 0:53, 19,253 tokens, and about eight cents per run, faster and cheaper than `gpt-5.6-terra` (1:00, $0.15) at the same score.

- **gemini-4-carbon (medium effort)** (new) matched 79 of 96 with zero extras for an F1 of 0.903, 27th of 61 runs. It is more thorough than the low-effort run but nine findings behind none, and it is much slower at 4:23.

- **gemini-4-carbon (low effort)** (new) matched 76 of 96 with zero extras for an F1 of 0.884, 40th of 61 runs. It finishes in 0:54 at about eight cents, almost the same cost and time as none, but it misses nine more issues, mostly hard-coded literals it had caught at none effort.

- **gemini-4-hydrogen (high effort)** (new) matched 67 of 96 with zero extras for an F1 of 0.822, 56th of 61 runs, tying the low-effort run and the second `deepseek-v4.1-flash` result. It reports repeated patterns once (one of nine hard-coded literals and one of eight `TOP` without `ORDER BY` cases) but does cover the harder single-instance rules. At 1:06 and about five cents it is cheap, though the low-effort run matches it on score in 0:38.

- **gemini-4-hydrogen (low effort)** (new) matched 67 of 96 with zero extras for an F1 of 0.822, 57th of 61 runs, tying high effort in 0:38 at about five cents. It is the better default for this model: the same score as high, faster than medium or high, and two findings ahead of none.

- **gemini-4-hydrogen (none effort)** (new) matched 65 of 96 with zero extras for an F1 of 0.807, 60th of 61 runs. It is the most compact report in the test (17,585 tokens) and the second-fastest at 0:35, but it finds two fewer issues than low or high.

- **gemini-4-hydrogen (medium effort)** (new) matched 65 of 96 with zero extras for an F1 of 0.807, 61st of 61 runs, tying none and taking 1:02. Raising effort from low to medium did not help.

- **gpt-6.1-terra** (new) matched 79 of 96 with three extras for an F1 of 0.888, 37th of 61 runs and six findings behind its predecessor `gpt-5.6-terra` (85 of 96, F1 0.939). Its strength is repeated patterns: it found eight of nine hard-coded literals and seven of eight `TOP` without `ORDER BY` cases, among the best in the test. Its weakness is coverage: it skipped four rules entirely (`NotInNullableSubquery`, `TableVariableEstimate`, `WhileLoopRowByRow`, and the multi-statement table-valued function), along with the shared-line `SessionSettingChanged` and `SqlInjectionViaDynamicSql` companions and part of the dynamic `LIKE` block at line 221. All three extras are `HardCodedLiteral` findings on constants the answer key does not count. It is quick and lean, though: 1:11, 19,161 tokens, and about four cents per run, under a third of the price of `gpt-5.6-terra`.

- **gpt-6.1-terra (high effort)** (new) is the same model rerun with its reasoning effort raised to high. It matched 82 of 96 with three extras for an F1 of 0.906, 24th of 61 runs and three findings better than the default run. The extra thinking paid off on coverage it had skipped before: it now finds all nine hard-coded literals, the unfiltered `COUNT(*)` at line 159, and the no-op `UPDATE` at line 170. It still skips the same four rules (`NotInNullableSubquery`, `TableVariableEstimate`, `WhileLoopRowByRow`, and the multi-statement table-valued function), and its three extras are the same `HardCodedLiteral` findings. The higher effort is cheap: 1:34 instead of 1:11, 21,319 tokens instead of 19,161, and about five cents instead of four. It still trails `gpt-5.6-terra` (85 of 96, zero extras, F1 0.939) by three findings, at about a third of the price.
- **mercury-3** is the cheapest run in the test (under a cent, 35,869 tokens) and found 77 genuine issues with zero false positives, covering 60 of the 61 rules. Its line numbers, however, were unreliable: they drift steadily earlier as the procedure goes on (the `MERGE` at line 164 is reported at line 122, the index hint at 249 at 197), so it is scored on the issues found rather than their locations. On that basis it matches 77 of 96 for an F1 of 0.890, tied with `MiniMax M3` and `gemini-3.8-flash`. Its misses follow the familiar report-once pattern: five of nine hard-coded literals, the shared-line `SessionSettingChanged` and `SqlInjectionViaDynamicSql` companions, and the multi-statement table-valued function at the end of the procedure. In day-to-day use, a reviewer would have to locate each of its findings by hand.
- **minimax-m3.1-flash** matched 86 of 96 with two extras for an F1 of 0.935, 14th of 61 runs and a big step up from `MiniMax M3` (77 of 96). It is one of the most thorough models on repeated patterns, finding eight of nine hard-coded literals and seven of eight `TOP` without `ORDER BY` cases. Its misses are the shared-line companions above, the dynamic `LIKE` block at line 221, and four single secondary instances. At about three cents per run it is one of the least expensive models in the top half of the table.
- **deepseek-v4.1-flash-1017** is a second run of `deepseek-v4.1-flash` with the same prompt and input. It matched only 67 of 96 (zero extras, F1 0.822), eleven fewer than the first run's 78, while using 22% more tokens (58,348 against 47,759). This time it reported only one of nine hard-coded literals and one of eight `TOP` without `ORDER BY` cases, and it analyzed only the first of three dynamic-SQL blocks in full. Both runs trail their predecessor `deepseek-v4-flash` (90 of 96) by a wide margin.
- **grok-4.7** matched 86 of 96, three fewer than `grok-4.5` and five fewer than `grok-4.6`. It is the most thorough model in the test on hard-coded literals (all nine found) but over-applies that rule, producing all five of its extras. At $0.16 it also costs nearly three times as much as its predecessors.
- **gemini-4-argon** is a compact mid-table report at 18,154 tokens with zero extras, but it matched only 72. The new `gemini-4-hydrogen (none effort)` run is slightly smaller (17,585 tokens) and also has zero extras, but it finds only 65 issues. It reported only one of nine hard-coded literals and two of eight `TOP` without `ORDER BY` cases, so it trails `gemini-3.1-pro-preview` and the better Flash releases.
- **muse-wonder-1.0** matched 66 of 96 with zero extras, but it is the clearest example of report-once behavior in the test: one of nine hard-coded literals, one of eight `TOP` without `ORDER BY` cases, and only the first of three dynamic-SQL blocks analyzed in full. At $0.53 per run it is also one of the most expensive models tested, so it offers poor value on this task.

### The same model can score differently

The two `deepseek-v4.1-flash` runs are one of the most important results in this benchmark. Identical prompt, identical procedure, identical input token count, and yet an 11-finding gap: 78 matches on the first run and 67 on the second. Its F1 fell from 0.897 to 0.822, a bigger drop than the gap between 4th place (0.963) and 28th place (0.901) in the table. A single run is a sample, not a verdict, and any model you rely on should be benchmarked more than once.

## Best Regardless of Expense

If cost is no object, **qwen3.8-flash** is the strongest model. It matched 91 of 96 expected issues with zero extras for the best F1 in the set (0.973). `deepseek-v4-flash` and `qwen3.8-max-preview` are only one finding behind, also with zero extras. `grok-4.6` ties `qwen3.8-flash` on recall but adds seven extras.

`claude-fable-5-1` deserves a mention: 90 matches with a single extra. At over a dollar per run, though, it is not the outright winner.

## Best Value

Value is correctness divided by cost (and tokens). The clear standout is **deepseek-v4-flash**: 90 of 96 issues, F1 0.968, and about **one cent** per run. Its sibling `deepseek-v4-pro` costs about two cents for an F1 of 0.945.

**grok-4.5** is the other value champion: 89 of 96, zero extras, F1 0.962, for about six cents and only 18,500 tokens, a third of what the DeepSeek and Qwen leaders use. It is the cheapest way to get near-best-in-class accuracy in a short report.

The newcomer **minimax-m3.1-flash** joins the value conversation: an F1 of 0.935 for about three cents. Only the two DeepSeek v4 models score higher for less money. The trade-off is volume: at 63,794 tokens it produces one of the longest reports in the test. **gemini-4-carbon (none effort)** is another strong value run: it ties `gpt-5.6-terra` on 85 of 96 with zero extras (F1 0.939) for about eight cents and 0:53.

By contrast, the Fable models cost more than a dollar per run, and `kimi-k3`, `gpt-6-astra`, `claude-opus-5`, and `muse-wonder-1.0` run $0.45-$0.53 without beating models that cost a tenth as much. The newest Grok, `grok-4.7`, also costs more than `grok-4.5` for a lower score, and the second `deepseek-v4.1-flash` run cost about six cents to find 23 fewer issues than the one-cent `deepseek-v4-flash`. Price alone is not value either: `mercury-3` is the cheapest run in the test at under a cent and finds a respectable 77 issues, but because its line numbers cannot be trusted, every finding has to be located by hand.

## Token Usage Matters

Token count is not just a cost proxy; it also reflects how much text a model produces for a reviewer. The most efficient runs stayed under about 21,000 total tokens: `gpt-6.2-sol (low effort)` (17,085), `gpt-6.2-astra (low effort)` (17,215), `gpt-6.2-astra (medium effort)` (17,392), `gemini-4-hydrogen (none effort)` (17,585), `gemini-4-hydrogen (low effort)` (17,802), `gemini-4-hydrogen (medium effort)` (17,949), `gemini-4-hydrogen (high effort)` (18,045), `gemini-4-argon` (18,154), `gemini-3.7-flash` (18,457), `grok-4.5` (18,500), `gemini-4-carbon (low effort)` (18,619), `gemini-flash-latest` (18,807), `gemini-4-carbon (medium effort)` (18,880), `grok-4.6` (18,951), `gemini-3.6-flash` (19,049), `gpt-6.1-terra` (19,161), `gemini-4-carbon (none effort)` (19,253), `gemini-3.8-flash` (19,299), and `gemini-3.1-pro-preview` (19,572). Several of these score very well, showing that long outputs do not automatically mean better analysis.

At the other extreme, `qwen3.8-flash` consumed 68,133 tokens, nearly four times what `grok-4.5` used, to find two more issues. `minimax-m3.1-flash` (63,794, of which 50,098 were output) and `glm-5.3-flash` (61,814) are next. `minimax-m3.1-flash` at least turns those tokens into 86 matches at a low price; `glm-5.3-flash`, `deepseek-v4.1-flash-1017` (58,348), and `MiniMax M3` (56,044) burned similar volumes without a matching accuracy payoff. More tokens did not help `deepseek-v4.1-flash` either: its longer second run found fewer issues.

## Run Time

Speed and accuracy do not always go together. The fastest runs finished in about a minute or less: `gemini-3.7-flash` (0:25), `gemini-4-hydrogen (none effort)` (0:35), `gemini-4-hydrogen (low effort)` (0:38), `mercury-3` (0:40), `gpt-6.2-sol (low effort)` (0:40), `gpt-5.6-luna` (0:49), `gemini-4-argon` (0:51), `gemini-4-carbon (none effort)` (0:53), and `gpt-5.6-terra` (1:00). At the other end, `qwen3.8-max` (13:35), `grok-4.7` (13:23), `kimi-k3` (12:42), and `glm-5.3-flash` (12:33) each took more than twelve minutes.

The standout for turnaround is **gemini-4-carbon (none effort)**: 85 of 96 with zero extras (F1 0.939) in 0:53 at about eight cents, matching `gpt-5.6-terra` (1:00, $0.15) and `gemini-3.1-pro-preview` (2:47) on score. `gpt-5.6-luna` (F1 0.916 in 0:49), `claude-opus-4-8` (F1 0.901 in 1:08), and `gpt-6.1-terra` (F1 0.888 in 1:11, or 0.906 in 1:34 at high effort) are also quick. Among the timed runs with an F1 of 0.962 or better, `claude-fable-5-1` is the fastest at 2:21 but costs about a dollar; the value leader `deepseek-v4-flash` takes 4:18, `grok-4.5` 6:21, and the top-scoring `qwen3.8-flash` 8:57. Newer is not faster either: `grok-4.7` takes more than twice as long as `grok-4.5` for a lower score.

If SQLAnalyzer runs in a pull-request gate or on every commit, a one-minute model keeps feedback fast; for a nightly or pre-release review, the extra minutes of the most accurate models are easy to afford.

## The Choices You Need to Make

1. **Maximum recall or clean reports?** For the fewest missed issues with no noise, pick `qwen3.8-flash`, `deepseek-v4-flash`, or `qwen3.8-max-preview`. If you would rather see a borderline finding than miss one, `grok-4.6` and `gpt-6-astra` lean that way.
2. **Budget or accuracy?** For routine, high-volume scans, `deepseek-v4-flash` and `deepseek-v4-pro` give top-tier F1 scores for pennies, and `minimax-m3.1-flash` is a strong low-cost alternative. For near-top accuracy with a short report, `grok-4.5` is the sweet spot. If turnaround matters most, `gpt-5.6-terra` returns an F1 of 0.939 in about a minute.
3. **Token budget?** If context window or throughput is a constraint, `grok-4.5` and `gemini-3.1-pro-preview` deliver concise, accurate output. Expect long reports from the high-token Qwen, GLM, and MiniMax variants.
4. **Newer is not always better.** `grok-4.7` scores below `grok-4.5` and `grok-4.6`, `gemini-4-argon` scores below several earlier Gemini releases, `muse-wonder-1.0` lands near the bottom of the table, both `deepseek-v4.1-flash` runs score well below `deepseek-v4-flash`, and `gpt-6.1-terra` trails `gpt-5.6-terra` by six findings (three at high effort), though at well under half the price. `gemini-4-carbon` is the other side of that story: at none effort it ties `gpt-5.6-terra` on 85 of 96 with zero extras, at about half the price and in 0:53, but its low- and medium-effort runs score lower, and medium takes 4:23. `minimax-m3.1-flash` shows a new release can also jump ahead, beating `MiniMax M3` by nine findings. `gpt-6.2-sol` trails `gpt-5.6-sol` (F1 0.884 at best versus 0.915), and `gpt-6.2-astra` lands just behind `gpt-6-astra` (0.891 versus 0.898) with fewer extras. Re-test before switching to a new release.
5. **One run or several?** The two `deepseek-v4.1-flash` runs differ by eleven findings. Before standardizing on a model, benchmark it more than once and plan around its weaker run, not its best one. Settings matter too: raising `gpt-6.1-terra` to high reasoning effort added three findings (F1 0.888 to 0.906) for 23 extra seconds and about a cent more per run. Effort cuts both ways: `gemini-4-carbon` scored best at none (F1 0.939) and worse at low (0.884) and medium (0.903), while `gemini-4-hydrogen` tied at low and high (0.822) and scored lower at none and medium (0.807). More effort is not automatically better. The same pattern shows up in this edition: `qwen4-max-preview` scored best at low effort (F1 0.859) and worst at xhigh (0.829), and `gpt-6.2-astra` scored best at low and medium (0.891) and worst at max (0.869), which also cost about $1.76. `gpt-6.2-sol` stayed in a tight 0.874–0.884 band across all five settings.
6. **What about the bottom of the table?** `gemini-4-neon (low effort)` (F1 0.815), `gemini-4-hydrogen` at none and medium effort (F1 0.807), `muse-wonder-1.0`, `qwen4-max-preview (xhigh effort)` (F1 0.829), the second `deepseek-v4.1-flash` run, and `gemini-3.7-flash` sit at the bottom with F1 scores between 0.807 and 0.836: clean reports, but close to a third of the issues go unreported. Line accuracy matters too: `mercury-3` finds issues cheaply but cannot reliably say where they are.

## Why This Matters for SQLAnalyzer

The test shows that model choice has a large impact on the quality of SQL code review. Even the best model missed five issues; the weakest missed 30. Newer releases from the same vendor can be better or worse than their predecessors, and the same model can score very differently from one run to the next. That variability is exactly why a tool like Quant Forge Software SQLAnalyzer matters: it provides a controlled environment, a curated rule set, and an expected-finding benchmark, so teams can choose, and keep re-checking, the model that best fits their accuracy, cost, and token constraints. The procedure used here, `usp_TestProcedure.sql`, is only available as part of SQLAnalyzer, and the benchmark itself is a practical reason to standardize on SQLAnalyzer for consistent, comparable static analysis across models.

## Bottom Line

- **Best regardless of expense:** `qwen3.8-flash` (91/96, 0 extras, F1 0.973).
- **Best value:** `deepseek-v4-flash` (90/96, F1 0.968, ~$0.01) or `grok-4.5` (89/96, F1 0.962, ~$0.06, 18,500 tokens).
- **Best recent addition:** `gpt-6.2-astra (low effort)` and `gpt-6.2-astra (medium effort)` (82/96, 6 extras, F1 0.891, about $0.31–$0.32, 1:14 and 0:57). `gemini-4-carbon (none effort)` remains the stronger earlier addition (85/96, 0 extras, F1 0.939, ~$0.08, 0:53).
- **Fastest strong result:** `gemini-4-carbon (none effort)` (85/96, 0 extras, F1 0.939, 0:53), ahead of `gpt-5.6-terra` (same score in 1:00).
- **Most compact clean report:** `gemini-4-argon` (18,154 tokens, no extras, 72 matches). `gemini-4-hydrogen (none effort)` is slightly smaller (17,585) but finds only 65 issues.
- **Weakest value:** `muse-wonder-1.0` (66/96, F1 0.815, ~$0.53 per run).

The right model depends on what you value most (recall, precision, cost, token efficiency, or speed), but the data shows you do not need to spend a dollar per analysis to get excellent T-SQL static analysis, and that SQLAnalyzer's repeatable benchmark is the way to keep that choice honest.
