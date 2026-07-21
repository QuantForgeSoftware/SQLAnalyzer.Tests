# Choosing an LLM for Static SQL Analysis: A Head-to-Head Benchmark with Quant Forge Software SQLAnalyzer

> Evaluating 16 frontier models on a real-world SQL analyzer task: correctness, error patterns, speed, and cost.

Static analysis of SQL is one of the hardest prompt-engineering tasks you can throw at a large language model. The model must read a stored procedure, identify dozens of rule violations, emit the correct rule name, severity, line number, and a concise explanation — and it must do it in a single shot. To make the job even harder, many violations cluster on the same line, and a tolerance of ±5 lines is the only mercy we grant.

This benchmark was run with **Quant Forge Software SQLAnalyzer**. The test case, `usp_TestProcedure.sql`, is part of the SQLAnalyzer test suite and is not publicly available outside the product. SQLAnalyzer generated the JSON reports, the ground-truth expected findings, and the cost/timing telemetry, so the numbers below reflect the actual end-to-end experience of using an LLM-backed SQL analyzer in production.

The ground truth contains **95 expected findings**. Each model produced a JSON report, which we compared to the expected findings using multiset matching within a 5-line window. We then pulled cost and timing data from the per-model Stats files to ask three questions:

1. **Which model is the most accurate, regardless of cost?**
2. **Which model delivers the best value per dollar?**
3. **Did the latest prompt revision help the models that were re-run?**

This post walks through the results, the kinds of mistakes each model makes, and the practical trade-offs a team should consider before picking a model for production SQL analysis.

---

## The Results at a Glance

| Model | Recall | Matched | Missing | Extra | Severity Mismatch Types | Cost (USD) | AI Time (s) |
|---|---:|---:|---:|---:|---:|---:|---:|
| grok-4.5 | **93.7%** | 89 | 6 | 0 | 7 | $0.058 | 381.3 |
| gpt-5.6-sol | **91.6%** | 87 | 8 | 0 | 3 | $0.355 | 153.2 |
| kimi-k2.7-code | **91.6%** | 87 | 8 | 0 | 2 | $0.151 | 535.1 |
| gemini-3.1-pro-preview | 90.5% | 86 | 9 | 1 | 8 | $0.092 | 164.2 |
| kimi-k3 | 87.4% | 83 | 12 | 0 | 4 | $0.449 | 762.3 |
| claude-opus-4-8 | 86.3% | 82 | 13 | 4 | 6 | $0.295 | 68.4 |
| claude-sonnet-5 | 86.3% | 82 | 13 | 1 | 6 | $0.289 | 175.4 |
| claude-fable-5 | 86.3% | 82 | 13 | 0 | 4 | $1.084 | 152.0 |
| glm-5.2 | 86.3% | 82 | 13 | 0 | 4 | $0.082 | 172.4 |
| qwen3.7-max | 85.3% | 81 | 14 | 0 | 3 | $0.183 | 362.9 |
| gpt-5.6-terra | 83.2% | 79 | 16 | 0 | 5 | $0.139 | 56.6 |
| MiniMax M3 | 81.1% | 77 | 18 | 0 | 3 | $0.055 | 260.6 |
| gpt-5.6-luna | 75.8% | 72 | 23 | 0 | 2 | $0.052 | 34.5 |
| qwen3.7-plus | 73.7% | 70 | 25 | 0 | 3 | $0.036 | 346.9 |
| qwen3.6-35b-a3b-ud-mlx | 71.6% | 68 | 27 | 1 | 3 | $0.000* | 307.9 |
| gemini-3.1-flash-lite | 57.9% | 55 | 40 | 5 | 13 | $0.009 | 11.2 |

*The Qwen MLX entry was run locally via MLX, so the listed cost is $0; the real cost is hardware amortization and latency.

---

## Did the New Prompt Help?

We reran **grok-4.5**, **claude-fable-5**, and **claude-opus-4-8** with the latest version of `prompt.md`. The effect on raw recall was positive for all three, with the biggest gain on Grok:

| Model | Run | Matched | Missing | Severity Mismatches | Cost | AI Time (s) |
|---|---|---:|---:|---:|---:|---:|
| grok-4.5 | old prompt | 87 | 8 | 12 | $0.056 | 172.0 |
| grok-4.5 | new prompt | 89 | 6 | 7 | $0.058 | 381.3 |
| claude-fable-5 | old prompt | 81 | 14 | 3 | $1.003 | 138.8 |
| claude-fable-5 | new prompt | 82 | 13 | 4 | $1.084 | 152.0 |
| claude-opus-4-8 | old prompt | 80 | 15 | 5 | $0.321 | 78.6 |
| claude-opus-4-8 | new prompt | 82 | 13 | 6 | $0.295 | 68.4 |

The verdict: **yes, the new prompt helps on the metric that matters most — recall.**

- **Grok 4.5** jumped from 91.6% to **93.7%** recall and cut its severity mismatches from 12 to 7. The trade-off was a longer run time (172 s → 381 s), likely because the revised prompt asks for more thorough line-by-line reasoning.
- **Claude Fable** and **Claude Opus** each picked up two additional matched findings, moving both from the mid-80s to **86.3%** recall. Severity mismatches ticked up slightly for both, but the net result is more correct findings for roughly the same cost.

For a production SQL analyzer, two extra correct findings per procedure is meaningful. For Grok, the improvement was even larger — and it already led the field before the prompt change.

---

## What “Correctness” Means Here

We scored each model on four dimensions:

- **Matched findings** — rule name matches and the reported line is within 5 lines of the expected line.
- **Missing findings** — expected violations the model never reported.
- **Extra findings** — reported violations that do not correspond to any expected finding.
- **Severity mismatch types** — distinct direction-of-error pairs (e.g., model calls an `error` a `warning`).

A model can have high recall but still be noisy. Conversely, a cheap model can look attractive until you notice it hallucinates extra findings or systematically downgrades severities. We weighted all four factors when making recommendations.

---

## The Accuracy Tier

### 🥇 Top tier: grok-4.5, gpt-5.6-sol, kimi-k2.7-code

The top of the leaderboard is now split into two groups:

- **grok-4.5** stands alone at **93.7% recall** (89/95) after the latest prompt revision. It produced **zero extra findings**, cost only **$0.058**, and took 381 seconds. Its six misses are the usual clustered cases: both `SessionSettingChanged` findings (lines 13 and 16), one `SqlInjectionViaDynamicSql` (line 115), `AggregateWithoutFilter` (line 159), `InsertWithoutColumnList` (line 215), and `LeadingWildcardLike` (line 221). At this accuracy level and price, Grok is the most balanced result in the benchmark.

- **gpt-5.6-sol** and **kimi-k2.7-code** tie at **91.6% recall** (87/95). Both produce zero extra findings.
  - **gpt-5.6-sol** costs **$0.355** and finishes in 153 seconds, but it has three severity mismatch types. Unless you need the GPT ecosystem for other reasons, it is hard to justify over Grok.
  - **kimi-k2.7-code** costs **$0.151** but is the slowest accurate model at **535 seconds**. The latency makes it a poor fit for interactive analysis.

### 🥈 Strong tier: gemini-3.1-pro-preview, kimi-k3, claude-sonnet-5, glm-5.2

- **gemini-3.1-pro-preview** scored **90.5%** with one extra finding. At **$0.092** and 164 seconds, it is the closest competitor to Grok in the accuracy-per-dollar race, though it has eight severity mismatch types.
- **kimi-k3** reached **87.4%** recall with zero extras, but at **$0.449** and **762 seconds** it is both expensive and glacial.
- **claude-sonnet-5** and **glm-5.2** both hit **86.3%**. GLM is the cheaper and cleaner of the two ($0.082 vs. $0.289, zero extras vs. one extra). Sonnet’s main advantage is ecosystem familiarity, not raw economics.

### 🥉 Respectable but not leading: claude-fable-5, claude-opus-4-8, qwen3.7-max, gpt-5.6-terra

- **claude-fable-5** improved to **86.3%** recall with the new prompt, but at **$1.084** it is still the most expensive model in the benchmark. The premium is impossible to justify for this task.
- **claude-opus-4-8** also improved to **86.3%** recall and is the fastest Claude model at **68.4 seconds**. Its downside is **4 extra findings**, the most among models above 80% recall.
- **qwen3.7-max** scores **85.3%** at **$0.183**, though its 363-second latency is high.
- **gpt-5.6-terra** is the fastest non-budget model at **56.6 seconds**, but recall drops to **83.2%**.

### ⚠️ Budget tier with caveats: MiniMax M3, gpt-5.6-luna, qwen3.7-plus, qwen3.6-35b-a3b-ud-mlx

- **MiniMax M3** hits **81.1%** for only **$0.055** — almost as cheap as Grok, but 18 misses and a very large 42,754-token output suggest it is verbose and less precise.
- **gpt-5.6-luna** is the fastest non-MLX model at **34.5 seconds** and costs only **$0.052**, but recall falls to **75.8%**. Good for quick triage, not for final review.
- **qwen3.7-plus** is cheap (**$0.036**) but only manages **73.7%** recall. Its Stats notes reveal the core problem: it tends to emit **only one finding per rule/line combination**, so it misses duplicate `TopWithoutOrderBy` and `HardCodedLiteral` violations on the same line. This is a structural pattern failure, not a random miss.
- **qwen3.6-35b-a3b-ud-mlx** (local MLX) reaches **71.6%** at zero API cost, but 307 seconds of local inference is not free when you count hardware and electricity.

### ❌ Not recommended: gemini-3.1-flash-lite

The flash model is the cheapest ($0.009) and fastest (11.2 s), but **57.9% recall**, **5 extra findings**, and **13 severity mismatch types** make it unsuitable for static analysis unless the only goal is a very rough first pass.

---

## The Four Kinds of Errors

Reading across the Stats notes, the models make the same categories of mistakes in different proportions.

### 1. Missing duplicate violations on the same line

The single most important pattern is that **models often report only one finding per line**. The expected set deliberately contains multiple violations on the same line:

- Line 81 has two `HardCodedLiteral` findings.
- Lines 60/63/92/95/98/145/148 have multiple `TopWithoutOrderBy` findings.
- Lines 115/221/222/224 have combinations of dynamic-SQL and wildcard issues.

Models that fail this pattern — especially **qwen3.7-plus**, **qwen3.6-35b-a3b-ud-mlx**, **gemini-3.1-flash-lite**, and **gpt-5.6-luna** — miss a large share of their expected findings simply by not counting the same rule twice. This is a reasoning limitation, not a token-budget limitation.

### 2. Missing clustered violations on lines with multiple rules

Most models miss a disproportionate share of findings on lines that already have multiple expected rules. For example:

- **MiniMax M3**: 83.3% of misses are on multi-rule lines.
- **claude-fable-5**: 85.7%.
- **kimi-k3**: 83.3%.
- **qwen3.7-plus**: 72.0%.

Top-tier models are better here (Grok: 62.5%, kimi-k2.7-code: 62.5%), but every model still struggles. A post-processing step that explicitly asks the model to “look again at lines with multiple findings” would likely lift all scores.

### 3. Severity mismatches

Severity mismatches come in three flavors:

- **Warning → Error**: the model over-reacts (e.g., flags a Cartesian join as an error).
- **Error → Warning**: the model under-reacts (e.g., calls `DeleteWithWeakPredicate` a warning when it should be an error).
- **Warning → Info**: the model downgrades a real issue to informational noise.

The best models keep severity mismatches to a small number of direction pairs. **kimi-k2.7-code** and **gpt-5.6-luna** have only 2; **qwen3.7-max**, **glm-5.2**, **claude-fable-5**, **MiniMax M3**, **qwen3.7-plus**, and **qwen3.6-35b-a3b-ud-mlx** have 3–4. At the high end, **gemini-3.1-flash-lite** has 13 mismatch types despite only 55 matched findings — an extremely high noise-to-signal ratio.

### 4. Extra (hallucinated) findings

Extra findings are rare among top models. The biggest offenders are **claude-opus-4-8** (4 extras), **gemini-3.1-flash-lite** (5 extras), **gemini-3.1-pro-preview** and **claude-sonnet-5** (1 each), and **qwen3.6-35b-a3b-ud-mlx** (1). Extra findings are particularly costly because they require a human to verify that a reported issue is not real.

---

## Best Model, Regardless of Expense

If cost is no object and you want the highest accuracy with the lowest hallucination risk, the answer is now clear:

> **Grok 4.5** is the single most accurate model in the benchmark at **93.7% recall**, and it produces **zero extra findings**.

The next tier — **gpt-5.6-sol** and **kimi-k2.7-code** — ties at **91.6% recall** with zero extras, but Grok outperforms both on accuracy and cost:

- **6× cheaper** than gpt-5.6-sol,
- **4× cheaper** than kimi-k2.7-code,
- and more accurate than either.

Unless your organization has a hard policy against using Grok, there is no accuracy reason to pay the premium for the other two.

---

## Best Value

Value depends on which metric you care about: matched findings per dollar, or acceptable accuracy at the lowest cost.

### If your metric is “matched findings per dollar”

The value leaders are:

1. **gemini-3.1-flash-lite** — ~6,211 matched findings per dollar, but only 55 actual findings.
2. **qwen3.7-plus** — ~1,960 matched/$ at 70 findings.
3. **Grok 4.5** — ~1,538 matched/$ at 89 findings.
4. **MiniMax M3** — ~1,393 matched/$ at 77 findings.
5. **gpt-5.6-luna** — ~1,377 matched/$ at 72 findings.

These numbers are misleading for the flash and qwen models because they mix low cost with low accuracy. A model that misses half the findings is not “good value” just because it is cheap.

### If your metric is “best accuracy at a reasonable price”

> **Grok 4.5 is the best value in the benchmark.**

It delivers the highest accuracy (93.7%) for $0.058 — cheaper than every other top-tier model and only slightly more expensive than the budget models that miss 20–40% of findings.

### If you need an alternative within a specific ecosystem

- **xAI / Grok**: **grok-4.5** is the overall leader.
- **Google ecosystem**: **gemini-3.1-pro-preview** is the clear choice. It is nearly as accurate as Grok (90.5% vs. 93.7%), costs only $0.092, and has 1 extra finding.
- **OpenAI ecosystem**: **gpt-5.6-sol** is the accuracy runner-up at 91.6%, but **gpt-5.6-terra** offers a cheaper, faster option at 83.2% recall.
- **Anthropic ecosystem**: **claude-sonnet-5** (86.3%) is the practical pick over the far more expensive **claude-fable-5** (86.3%) and the extra-prone **claude-opus-4-8** (86.3%).
- **Chinese/open ecosystem**: **glm-5.2** (86.3%, $0.082) is a strong value, and **qwen3.7-max** (85.3%) is reasonable if you accept slower inference.

---

## The Choices You Actually Have to Make

Picking a model is not just a leaderboard exercise. A team needs to decide:

### 1. What tolerance for false negatives?

If you are running static analysis in CI, a model that misses 10–15 findings per procedure will let real issues slip through. In that case, only the top tier (≥91.6% recall) is acceptable, and **Grok 4.5** is the economic choice.

### 2. What tolerance for false positives?

**claude-opus-4-8** and **gemini-3.1-flash-lite** produce extra findings. If your workflow can tolerate a human triage step, that may be fine. If you want fully automated reporting, zero-extra models (Grok, gpt-5.6-sol, kimi-k2.7-code, glm-5.2, kimi-k3) are safer.

### 3. Latency budget

- **Fastest accurate**: **gpt-5.6-sol** at 153 s for 91.6% recall; **Grok 4.5** reaches 93.7% recall but takes 381 s.
- **Fastest acceptable**: **gpt-5.6-terra** at 56.6 s for 83.2% recall.
- **Fastest cheap**: **gpt-5.6-luna** at 34.5 s for 75.8% recall.
- **Slow but good**: **kimi-k3** at 762 s is too slow for interactive use despite strong accuracy.

### 4. Cost budget

- **Under $0.10**: Grok 4.5 ($0.058), MiniMax M3 ($0.055), gpt-5.6-luna ($0.052), gemini-3.1-flash-lite ($0.009), qwen3.7-plus ($0.036).
  - Only Grok 4.5 in this group is top-tier accurate.
- **$0.10–$0.30**: gemini-3.1-pro-preview, glm-5.2, gpt-5.6-terra, qwen3.7-max, claude-opus-4-8.
  - Best here: **gemini-3.1-pro-preview** and **glm-5.2**.
- **Over $0.30**: claude-sonnet-5, gpt-5.6-sol, kimi-k3, claude-fable-5.
  - None justify the premium over Grok for this task, though **gpt-5.6-sol** ties on accuracy at 91.6%.

### 5. Ecosystem and trust

Some teams cannot or will not use certain providers. The good news is that every major ecosystem has at least one viable option:

| Ecosystem | Recommended model | Recall | Cost |
|---|---|---:|---:|
| xAI | grok-4.5 | 93.7% | $0.058 |
| Google | gemini-3.1-pro-preview | 90.5% | $0.092 |
| OpenAI | gpt-5.6-sol | 91.6% | $0.355 |
| Anthropic | claude-sonnet-5 | 86.3% | $0.289 |
| Zhipu | glm-5.2 | 86.3% | $0.082 |
| Alibaba | qwen3.7-max | 85.3% | $0.183 |
| Moonshot / Kimi | kimi-k2.7-code | 91.6% | $0.151 |

---

## Recommendations

### If you want one default recommendation

> **Use Grok 4.5.**
>
> It is the single most accurate model in the benchmark, the cheapest of the top tier, and produces no hallucinated extra findings.

### If you want a safety net with two models

Run **Grok 4.5** as the primary analyzer and **gemini-3.1-pro-preview** as a secondary pass. They miss slightly different subsets of findings; combining them would likely push combined recall above 96% while keeping costs modest.

### If cost is the only thing that matters

**MiniMax M3** or **gpt-5.6-luna** deliver acceptable accuracy (~75–81%) at ~$0.05. Treat their output as a “first-pass” filter, not a final review.

### If latency is the only thing that matters

**gpt-5.6-terra** finishes in under a minute and still captures 83.2% of findings. **gpt-5.6-luna** is even faster at 34.5 s but drops to 75.8% recall.

### If you must stay inside Anthropic

Use **claude-sonnet-5**. Avoid **claude-fable-5** unless someone else is paying the bill: it costs $1.08 for the same recall as Sonnet and produces no advantage for the premium.

---

## Final Thoughts

This benchmark is a single test, but it is a demanding one. The differences between models are not subtle: the best model finds 89 of 95 issues, while the bottom tier finds 55. The cost spread is even wider — over 100× from the cheapest to the most expensive.

The key insight is that **accuracy and price are not tightly coupled**. The best model in the benchmark is also one of the cheapest, and the latest prompt revision widened the gap at the top. That makes the choice relatively simple for most teams:

- **Best overall: grok-4.5**
- **Best alternative by ecosystem: gemini-3.1-pro-preview (Google), gpt-5.6-sol (OpenAI), claude-sonnet-5 (Anthropic), glm-5.2 (Zhipu), kimi-k2.7-code (Moonshot)**
- **Best ultra-budget filter: MiniMax M3 or gpt-5.6-luna**
- **Avoid for this task: gemini-3.1-flash-lite** unless you only need a very rough scan.

Whichever model you pick, the strongest near-term improvement is not switching models — it is adding a second-pass prompt that specifically asks the model to re-examine lines with multiple expected findings. Every model in this benchmark leaves points on the table there.

For teams already using **Quant Forge Software SQLAnalyzer**, the takeaway is even simpler: SQLAnalyzer makes it straightforward to plug in the model of your choice, measure its output against a known ground truth, and iterate on prompts until the accuracy meets your standard. The benchmark you just read was produced inside that same workflow.
