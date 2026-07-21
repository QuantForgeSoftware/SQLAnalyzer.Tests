# Choosing an LLM for Static SQL Analysis: A Head-to-Head Benchmark with Quant Forge Software SQLAnalyzer

> Evaluating 18 frontier models on a real-world SQL analyzer task: correctness, error patterns, speed, and cost.

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
| qwen3.8-max-preview | **93.7%** | 89 | 6 | 1 | 3 | $0.368 | 725.2 |
| kimi-k2.7-code | **91.6%** | 87 | 8 | 0 | 2 | $0.151 | 535.1 |
| gemini-3.1-pro-preview | 89.5% | 85 | 10 | 0 | 4 | $0.099 | 166.9 |
| gpt-5.6-terra | 89.5% | 85 | 10 | 0 | 1 | $0.147 | 60.1 |
| gpt-5.6-sol | 89.5% | 85 | 10 | 7 | 4 | $0.371 | 147.2 |
| kimi-k3 | 87.4% | 83 | 12 | 0 | 4 | $0.449 | 762.3 |
| gpt-5.6-luna | 86.3% | 82 | 13 | 1 | 3 | $0.060 | 48.5 |
| glm-5.2 | 86.3% | 82 | 13 | 0 | 4 | $0.082 | 172.4 |
| claude-sonnet-5 | 86.3% | 82 | 13 | 1 | 5 | $0.289 | 175.4 |
| claude-opus-4-8 | 86.3% | 82 | 13 | 4 | 6 | $0.295 | 68.4 |
| claude-fable-5 | 86.3% | 82 | 13 | 0 | 4 | $1.084 | 152.0 |
| qwen3.7-max | 85.3% | 81 | 14 | 0 | 3 | $0.183 | 362.9 |
| gemini-flash-latest | 83.2% | 79 | 16 | 0 | 7 | $0.061 | 79.6 |
| MiniMax M3 | 81.1% | 77 | 18 | 0 | 3 | $0.055 | 260.6 |
| qwen3.7-plus | 73.7% | 70 | 25 | 0 | 3 | $0.036 | 346.9 |
| qwen3.6-35b-a3b-ud-mlx | 71.6% | 68 | 27 | 1 | 3 | $0.000* | 307.9 |
| gemini-3.1-flash-lite | 11.6% | 11 | 84 | 46 | 2 | $0.009 | 10.2 |

*The Qwen MLX entry was run locally via MLX, so the listed cost is $0; the real cost is hardware amortization and latency.

---

## Did the New Prompt Help?

We reran **grok-4.5**, **claude-fable-5**, **claude-opus-4-8**, **gpt-5.6-sol**, **gpt-5.6-terra**, **gpt-5.6-luna**, **gemini-3.1-pro-preview**, **glm-5.2**, and **gemini-flash-latest** with the latest version of `prompt.md`. The effect on raw recall was positive for most, with the biggest gains on the GPT-5.6 trio and on Grok:

| Model | Run | Matched | Missing | Severity Mismatches | Cost | AI Time (s) |
|---|---|---:|---:|---:|---:|---:|
| grok-4.5 | old prompt | 87 | 8 | 12 | $0.056 | 172.0 |
| grok-4.5 | new prompt | 89 | 6 | 7 | $0.058 | 381.3 |
| claude-fable-5 | old prompt | 81 | 14 | 3 | $1.003 | 138.8 |
| claude-fable-5 | new prompt | 82 | 13 | 4 | $1.084 | 152.0 |
| claude-opus-4-8 | old prompt | 80 | 15 | 5 | $0.321 | 78.6 |
| claude-opus-4-8 | new prompt | 82 | 13 | 6 | $0.295 | 68.4 |
| gpt-5.6-sol | old prompt | 87 | 8 | 2 | $0.355 | 153.2 |
| gpt-5.6-sol | new prompt | 85 | 10 | 4 | $0.371 | 147.2 |
| gpt-5.6-terra | old prompt | 79 | 16 | 2 | $0.139 | 56.6 |
| gpt-5.6-terra | new prompt | 85 | 10 | 1 | $0.147 | 60.1 |
| gpt-5.6-luna | old prompt | 72 | 23 | 2 | $0.052 | 34.5 |
| gpt-5.6-luna | new prompt | 82 | 13 | 3 | $0.060 | 48.5 |
| gemini-3.1-pro-preview | old prompt | 86 | 9 | 8 | $0.092 | 164.2 |
| gemini-3.1-pro-preview | new prompt | 85 | 10 | 4 | $0.099 | 166.9 |
| glm-5.2 | old prompt | 82 | 13 | 2 | $0.082 | 172.4 |
| glm-5.2 | new prompt | 82 | 13 | 4 | $0.082 | 172.4 |
| gemini-flash-latest | old prompt | — | — | — | — | — |
| gemini-flash-latest | new prompt | 79 | 16 | 7 | $0.061 | 79.6 |

The verdict: **the new prompt helps some models more than others, and it hurt one.**

- **Grok 4.5** jumped from 91.6% to **93.7%** recall and cut its severity mismatches from 12 to 7. The trade-off was a longer run time (172 s → 381 s), likely because the revised prompt asks for more thorough line-by-line reasoning.
- **Claude Fable** improved from 85.3% to **86.3%** recall; **Claude Opus 4.8** improved from 84.2% to **86.3%** recall. Both picked up two matched findings. Severity mismatches ticked up slightly for each, but the net result is more correct findings for roughly the same cost.
- **gpt-5.6-terra** was the biggest mover: it jumped from **83.2%** to **89.5%** recall, gained six matched findings, and dropped from 2 severity mismatch types to 1 at almost the same price. The new prompt clearly suits the mid-size GPT model.
- **gpt-5.6-luna** climbed from **75.8%** to **86.3%** recall — a 10.5-point gain for only an extra $0.008 and 14 seconds. It is now competitive with the strong tier.
- **gpt-5.6-sol** moved backward on raw recall (87 → 85 matched) and produced **7 extra findings** and **4 severity mismatches** under the new prompt, suggesting the revised instructions made it more verbose and over-sensitive. It is still accurate, but it dropped from the top tier to the strong tier and is no longer the cleanest GPT option.
- **gemini-3.1-pro-preview** slipped from 90.5% to **89.5%** recall (86 → 85 matched) but cut severity mismatches from 8 to 4 and produced zero extra findings, so its signal quality improved.
- **glm-5.2** was unchanged at **86.3%** recall. It is already a strong value, and the new prompt did not materially change its output.
- **gemini-flash-latest** was evaluated for the first time with the new prompt: **83.2%** recall, zero extras, **7 severity mismatches**, and only **$0.061** in **79.6 s**. It has no old-prompt baseline.
- **qwen3.8-max-preview** was also evaluated only with the new prompt, where it tied Grok at **93.7%** recall.

For a production SQL analyzer, two extra correct findings per procedure is meaningful. For **gpt-5.6-terra** and **gpt-5.6-luna**, the gains were large enough to change their recommendation category.

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

### 🥇 Top tier: grok-4.5, qwen3.8-max-preview, kimi-k2.7-code

The top of the leaderboard requires at least **91.6%** recall.

- **grok-4.5** and **qwen3.8-max-preview** tie at **93.7% recall** (89/95).
  - **Grok** produced **zero extra findings** for **$0.058** and **381 seconds**.
  - **qwen3.8-max-preview** costs **$0.368**, took **725 seconds**, and produced **1 extra finding** with only **3 severity mismatch types**. It is the best option inside the Alibaba/Qwen ecosystem, but it is expensive and slow.
- **kimi-k2.7-code** reaches **91.6% recall** (87/95), with **zero extra findings** and only **2 severity mismatch types**. At **$0.151** and **535 seconds** it is precise but the slowest accurate model.

Grok is the clear overall leader: it ties the highest recall, has the lowest cost of the top tier, and emits no hallucinated findings.

### 🥈 Strong tier: gemini-3.1-pro-preview, gpt-5.6-terra, gpt-5.6-sol, kimi-k3, gpt-5.6-luna, glm-5.2, claude-sonnet-5, claude-opus-4-8, claude-fable-5

Models in this band score **86.3%–89.5%** recall. They are good enough for many production workflows, but they trade off cost, speed, or noise.

- **gemini-3.1-pro-preview** scored **89.5%** with zero extra findings. At **$0.099** and **167 seconds**, it is the closest competitor to Grok in the accuracy-per-dollar race.
- **gpt-5.6-terra** improved to **89.5%** recall, zero extra findings, and only **1 severity mismatch type**. At **$0.147** and **60 seconds**, it is now the fastest model in the strong tier.
- **gpt-5.6-sol** is also at **89.5%** recall, but the new prompt made it noisier: **7 extra findings** and **4 severity mismatch types**. It is the most expensive OpenAI option in this group ($0.371). Choose it only if latency matters more than zero-exactness.
- **kimi-k3** reached **87.4%** recall with zero extras, but at **$0.449** and **762 seconds** it is both expensive and glacial.
- **gpt-5.6-luna** improved to **86.3%** recall with **1 extra finding**. It is the cheapest ($0.060) and fastest (**48.5 s**) model in this tier.
- **glm-5.2** hits **86.3%** with zero extras for **$0.082**. It is the strongest value in this tier.
- **claude-sonnet-5** reaches **86.3%** with **1 extra finding** for **$0.289**. It is the practical Anthropic choice over the premium models.
- **claude-opus-4-8** also reaches **86.3%** and is the fastest Claude model at **68.4 seconds**, but it produces **4 extra findings**, the most among models above 80% recall.
- **claude-fable-5** improved to **86.3%** recall with the new prompt, but at **$1.084** it is still the most expensive model in the benchmark. The premium is impossible to justify for this task.

### 🥉 Respectable but not leading: qwen3.7-max, gemini-flash-latest, MiniMax M3

- **qwen3.7-max** scores **85.3%** at **$0.183**, though its **363-second** latency is high.
- **gemini-flash-latest** scores **83.2%** recall with zero extra findings and costs only **$0.061**. It is faster than Gemini 3.1 Pro (79.6 s) and nearly as cheap as the budget tier, but it misses 16 findings and has 7 severity mismatch types.
- **MiniMax M3** hits **81.1%** for only **$0.055** — almost as cheap as Grok, but 18 misses and a very large 42,754-token output suggest it is verbose and less precise.

### ⚠️ Budget tier with caveats: qwen3.7-plus, qwen3.6-35b-a3b-ud-mlx

- **qwen3.7-plus** is cheap (**$0.036**) but only manages **73.7%** recall. Its Stats notes reveal the core problem: it tends to emit **only one finding per rule/line combination**, so it misses duplicate `TopWithoutOrderBy` and `HardCodedLiteral` violations on the same line. This is a structural pattern failure, not a random miss.
- **qwen3.6-35b-a3b-ud-mlx** (local MLX) reaches **71.6%** at zero API cost, but 307 seconds of local inference is not free when you count hardware and electricity.

### ❌ Not recommended: gemini-3.1-flash-lite

The flash model is the cheapest ($0.009) and fastest (10.2 s), but **11.6% recall**, **46 extra findings**, and **2 severity mismatch types** make it unsuitable for static analysis unless the only goal is a deliberately wrong first pass. With the new prompt, its output collapsed: it reports only 57 findings, most of them line-shifted duplicates, and misses 84 of the 95 expected issues.

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

The best models keep severity mismatches to a small number of direction pairs. **kimi-k2.7-code** has only 2; **qwen3.8-max-preview**, **gpt-5.6-terra**, **qwen3.7-max**, **glm-5.2**, **claude-fable-5**, **MiniMax M3**, **qwen3.7-plus**, and **qwen3.6-35b-a3b-ud-mlx** have 3–4. At the high end, **gemini-flash-latest** has 7 mismatch types, while **gemini-3.1-flash-lite** has only 2 mismatch types but sits on top of 46 extra findings and just 11 matched findings — an extremely high noise-to-signal ratio.

### 4. Extra (hallucinated) findings

Extra findings are rare among top models. The biggest offenders are **gemini-3.1-flash-lite** (46 extras), **gpt-5.6-sol** (7 extras), **claude-opus-4-8** (4 extras), **qwen3.8-max-preview** and **gpt-5.6-luna** (1 each), and **qwen3.6-35b-a3b-ud-mlx** (1). Extra findings are particularly costly because they require a human to verify that a reported issue is not real.

---

## Best Model, Regardless of Expense

If cost is no object and you want the highest accuracy with the lowest hallucination risk, the answer is now clear:

> **Grok 4.5** is the single most accurate model in the benchmark at **93.7% recall**, and it produces **zero extra findings**.

The only other model that reaches **93.7%** recall is **qwen3.8-max-preview**, but it costs **$0.368**, took **725 seconds**, and emitted **one extra finding**. **kimi-k2.7-code** reaches **91.6%** recall for **$0.151** but is slow (**535 s**).

Compared with those alternatives, Grok is:

- **1.5× cheaper** than kimi-k2.7-code,
- **6× cheaper** than qwen3.8-max-preview,
- and the only top-tier model with zero extra findings.

Unless your organization has a hard policy against using Grok, there is no accuracy reason to pay the premium for the other top models.

---

## Best Value

Value depends on which metric you care about: matched findings per dollar, or acceptable accuracy at the lowest cost.

### If your metric is “matched findings per dollar”

The raw value leaders are:

1. **qwen3.7-plus** — ~1,944 matched findings per dollar at 70 findings.
2. **MiniMax M3** — ~1,400 matched/$ at 77 findings.
3. **gpt-5.6-luna** — ~1,367 matched/$ at 82 findings.
4. **gemini-flash-latest** — ~1,295 matched/$ at 79 findings.
5. **Grok 4.5** — ~1,534 matched/$ at 89 findings.
6. **gemini-3.1-flash-lite** — ~1,222 matched/$ at 11 findings.

These numbers are misleading for the cheap, low-accuracy models. **qwen3.7-plus** and **gemini-3.1-flash-lite** both miss a large share of the 95 expected issues, so a high matched/$ ratio is not the same as good value.

### If your metric is “best accuracy at a reasonable price”

> **Grok 4.5 is the best value in the benchmark.**

It delivers the highest accuracy (93.7%) for $0.058 — cheaper than every other top-tier model and only slightly more expensive than the budget models that miss 20–40% of findings.

### If you need an alternative within a specific ecosystem

| Ecosystem | Recommended model | Recall | Cost | Notes |
|---|---|---:|---:|---|
| xAI | grok-4.5 | 93.7% | $0.058 | Overall leader; zero extras. |
| Alibaba / Qwen | qwen3.8-max-preview | 93.7% | $0.368 | Ties Grok on recall; expensive and slow. |
| Moonshot / Kimi | kimi-k2.7-code | 91.6% | $0.151 | Precise but slow (535 s). |
| Google | gemini-3.1-pro-preview | 89.5% | $0.099 | Best balance in the Google ecosystem. |
| OpenAI | gpt-5.6-terra | 89.5% | $0.147 | Faster and cleaner than gpt-5.6-sol. |
| Anthropic | claude-sonnet-5 | 86.3% | $0.289 | Practical pick over the costlier / noisier Anthropic options. |
| Zhipu | glm-5.2 | 86.3% | $0.082 | Strong open-ecosystem value. |
| MiniMax | MiniMax M3 | 81.1% | $0.055 | Cheap but misses 18 findings. |

---

## The Choices You Actually Have to Make

Picking a model is not just a leaderboard exercise. A team needs to decide:

### 1. What tolerance for false negatives?

If you are running static analysis in CI, a model that misses 10–15 findings per procedure will let real issues slip through. In that case, only the top tier (≥91.6% recall) is acceptable, and **Grok 4.5** is the economic choice.

### 2. What tolerance for false positives?

**claude-opus-4-8**, **gpt-5.6-sol**, **gpt-5.6-luna**, **qwen3.8-max-preview**, and **gemini-3.1-flash-lite** produce extra findings. If your workflow can tolerate a human triage step, that may be fine. If you want fully automated reporting, zero-extra models (Grok, kimi-k2.7-code, glm-5.2, gemini-3.1-pro-preview, gpt-5.6-terra, kimi-k3, claude-fable-5) are safer.

### 3. Latency budget

- **Fastest top-tier**: **Grok 4.5** at 381 s for 93.7% recall.
- **Fastest strong-tier**: **gpt-5.6-terra** at 60.1 s for 89.5% recall.
- **Fastest cheap accurate**: **gpt-5.6-luna** at 48.5 s for 86.3% recall.
- **Fastest budget**: **gemini-3.1-flash-lite** at 10.2 s, but only 11.6% recall.
- **Slow but good**: **kimi-k3** at 762 s is too slow for interactive use despite strong accuracy.

### 4. Cost budget

- **Under $0.10**: Grok 4.5 ($0.058), MiniMax M3 ($0.055), gpt-5.6-luna ($0.060), gemini-flash-latest ($0.061), gemini-3.1-flash-lite ($0.009), qwen3.7-plus ($0.036), qwen3.6-35b-a3b-ud-mlx ($0.000 local).
  - Only **Grok 4.5** is top-tier accurate. **gemini-flash-latest** is the best sub-$0.10 option if you can accept 83.2% recall.
- **$0.10–$0.30**: gemini-3.1-pro-preview ($0.099), glm-5.2 ($0.082), gpt-5.6-terra ($0.147), qwen3.7-max ($0.183), claude-sonnet-5 ($0.289), claude-opus-4-8 ($0.295).
  - Best here: **gemini-3.1-pro-preview** and **glm-5.2**.
- **Over $0.30**: qwen3.8-max-preview ($0.368), gpt-5.6-sol ($0.371), kimi-k3 ($0.449), claude-fable-5 ($1.084).
  - None justify the premium over Grok for this task, though **qwen3.8-max-preview** at least ties Grok on recall.

### 5. Ecosystem and trust

Some teams cannot or will not use certain providers. The good news is that every major ecosystem has at least one viable option:

| Ecosystem | Recommended model | Recall | Cost | Notes |
|---|---|---:|---:|---|
| xAI | grok-4.5 | 93.7% | $0.058 | Overall leader; zero extras. |
| Alibaba / Qwen | qwen3.8-max-preview | 93.7% | $0.368 | Ties Grok on recall; expensive and slow. |
| Moonshot / Kimi | kimi-k2.7-code | 91.6% | $0.151 | Precise but slow (535 s). |
| Google | gemini-3.1-pro-preview | 89.5% | $0.099 | Best balance in the Google ecosystem. |
| OpenAI | gpt-5.6-terra | 89.5% | $0.147 | Faster and cleaner than gpt-5.6-sol. |
| Anthropic | claude-sonnet-5 | 86.3% | $0.289 | Practical pick over the costlier / noisier Anthropic options. |
| Zhipu | glm-5.2 | 86.3% | $0.082 | Strong open-ecosystem value. |
| MiniMax | MiniMax M3 | 81.1% | $0.055 | Cheap but misses 18 findings. |

---

## Recommendations

### If you want one default recommendation

> **Use Grok 4.5.**
>
> It is the single most accurate model in the benchmark, the cheapest of the top tier, and produces no hallucinated extra findings.

### If you want a safety net with two models

Run **Grok 4.5** as the primary analyzer and **gemini-3.1-pro-preview** as a secondary pass. They miss slightly different subsets of findings; combining them would likely push combined recall above 96% while keeping costs modest.

### If cost is the only thing that matters

**MiniMax M3** or **gpt-5.6-luna** deliver acceptable accuracy (~81–86%) at ~$0.05. Treat their output as a “first-pass” filter, not a final review.

### If latency is the only thing that matters

**gpt-5.6-terra** finishes in 60 seconds and captures 89.5% of findings. **gpt-5.6-luna** is even faster at 48.5 s and still reaches 86.3% recall.

### If you must stay inside Anthropic

Use **claude-sonnet-5**. Avoid **claude-fable-5** unless someone else is paying the bill: it costs $1.08 for the same recall as Sonnet and produces no advantage for the premium.

---

## Final Thoughts

This benchmark is a single test, but it is a demanding one. The differences between models are not subtle: the best models find 89 of 95 issues, while the bottom tier finds only 11. The cost spread is even wider — over 100× from the cheapest to the most expensive.

The key insight is that **accuracy and price are not tightly coupled**. The best model in the benchmark is also one of the cheapest, and the latest prompt revision widened the gap at the top for the GPT-5.6 family while collapsing gemini-3.1-flash-lite. That makes the choice relatively simple for most teams:

- **Best overall: grok-4.5**
- **Best alternative by ecosystem: qwen3.8-max-preview (Alibaba), gemini-3.1-pro-preview (Google), gpt-5.6-terra (OpenAI), claude-sonnet-5 (Anthropic), glm-5.2 (Zhipu), kimi-k2.7-code (Moonshot)**
- **Best ultra-budget filter: MiniMax M3, gpt-5.6-luna, or gemini-flash-latest**
- **Avoid for this task: gemini-3.1-flash-lite** unless you only need a deliberately wrong first pass.

Whichever model you pick, the strongest near-term improvement is not switching models — it is adding a second-pass prompt that specifically asks the model to re-examine lines with multiple expected findings. Every model in this benchmark leaves points on the table there.

For teams already using **Quant Forge Software SQLAnalyzer**, the takeaway is even simpler: SQLAnalyzer makes it straightforward to plug in the model of your choice, measure its output against a known ground truth, and iterate on prompts until the accuracy meets your standard. The benchmark you just read was produced inside that same workflow.
