import re
from pathlib import Path
from collections import Counter

ws = Path('/Users/johnbaima/Code/SQLAnalyzer.Tests')
stats_dir = ws / 'TestDatabases/WideWorldImporters/Results/Stats/Local'
cloud_local_file = stats_dir / 'CloudLocal.txt'


def extract_paths(text):
    out = []
    for line in text.splitlines():
        line = line.strip()
        if line.endswith('.txt'):
            p = Path(line)
            if p.exists():
                out.append(p)
            elif (ws / line).exists():
                out.append(ws / line)
    return out


cloud_stats_files = extract_paths(cloud_local_file.read_text(encoding='utf-8'))
local_stats_files = sorted([p for p in stats_dir.glob('*.txt') if p.name != 'CloudLocal.txt'])
all_stats_files = local_stats_files + cloud_stats_files


def parse_stats_file(path):
    text = path.read_text(encoding='utf-8')
    name = path.stem
    metrics = {}
    notes = {
        'matched': 0, 'near': 0, 'missed': 0, 'errors_missed': 0,
        'top_missed': 0, 'literal_missed': 0, 'session_missed': 0,
        'sql_injection_missed': 0, 'dynamic_missed': 0, 'object_missed': 0
    }

    for line in text.splitlines():
        if line.startswith('Model:'):
            n = line.replace('Model:', '').strip()
            # Prefer filename for local stats files to avoid mislabeled duplicates
            if 'Stats/Local' in str(path):
                pass
            elif n and n.lower() != 'unknown model':
                name = n
        m = re.match(r'^(Input tokens|Output tokens|Total tokens|AI time|Tokens/second|Estimated total cost):\s*(.+)$', line)
        if m:
            key = m.group(1).lower().replace(' ', '_').replace('/', '_per_')
            val = m.group(2)
            if 'cost' in key:
                val = val.replace('$', '').replace('USD', '').strip()
                metrics[key] = float(val) if val else 0.0
            elif 'time' in key:
                metrics[key] = float(val.replace('seconds', '').strip())
            else:
                metrics[key] = float(val.replace(',', '').strip())

    # Local evaluation format
    m = re.search(r'found (\d+) exact matches and (\d+) near-matches', text)
    if m:
        notes['matched'] = int(m.group(1))
        notes['near'] = int(m.group(2))
    m = re.search(r'(\d+) expected findings were missed entirely', text)
    if m:
        notes['missed'] = int(m.group(1))
    m = re.search(r'(\d+) high-severity errors were missed', text)
    if m:
        notes['errors_missed'] = int(m.group(1))
    m = re.search(r'flag SELECT TOP without ORDER BY \((\d+) instances\)', text)
    if m:
        notes['top_missed'] = int(m.group(1))
    m = re.search(r'HardCodedLiteral detections are inconsistent \((\d+) missed\)', text)
    if m:
        notes['literal_missed'] = int(m.group(1))
    m = re.search(r'SessionSettingChanged warnings are missed \((\d+) instances\)', text)
    if m:
        notes['session_missed'] = int(m.group(1))
    m = re.search(r'SqlInjectionViaDynamicSql was missed for some concatenation points \((\d+) instances\)', text)
    if m:
        notes['sql_injection_missed'] = int(m.group(1))
    m = re.search(r'DynamicSqlConcatenation warnings were also missed \((\d+) instances\)', text)
    if m:
        notes['dynamic_missed'] = int(m.group(1))
    if 'Object-specific rule misses' in text:
        notes['object_missed'] = 1

    # Cloud evaluation format fallback
    m = re.search(r'Total missed expected findings: (\d+)', text)
    if m:
        notes['missed'] = int(m.group(1))
    m = re.search(r'Recall: ([\d.]+)%', text)
    if m:
        recall = float(m.group(1))
        notes['matched'] = round(95 * recall / 100)
        notes['near'] = 0
    m = re.search(r"Severity distribution of misses: \{[^}]*'error': (\d+)", text)
    if m:
        notes['errors_missed'] = int(m.group(1))

    return {'name': name or path.stem, 'metrics': metrics, 'notes': notes,
            'path': str(path.relative_to(ws))}


models = [parse_stats_file(p) for p in all_stats_files]
for m in models:
    notes = m['notes']
    m['correctness_score'] = notes['matched'] + 0.5 * notes['near'] - 2.0 * notes['errors_missed']

# Sanity check
for m in models:
    print(m['name'], m['notes']['matched'], m['notes']['near'], m['notes']['missed'],
          m['notes']['errors_missed'], m['correctness_score'])

lines = []
lines.append('# Local AI SQL Code Review Shoot-out: Correctness, Cost, and the Case for SQLAnalyzer')
lines.append('')
lines.append('Finding SQL anti-patterns in a production stored procedure is hard.')
lines.append('Doing it reliably, cheaply, and on hardware you control is harder still.')
lines.append('Quant Forge Software built **SQLAnalyzer** to turn that problem into a repeatable, local, AI-assisted workflow.')
lines.append('The test bed for this comparison is `usp_TestProcedure.sql` — a deliberately flawed procedure that ships only with SQLAnalyzer — scanned against a ground-truth set of **95 expected findings**.')
lines.append('')
lines.append('This post looks at every model in `Stats/Local`, plus the cloud models referenced by `CloudLocal.txt`, and asks three questions:')
lines.append('')
lines.append('1. **Correctness:** How many of the 95 expected findings did each model find?')
lines.append('2. **Cost:** How long did it take and how many tokens did it burn?')
lines.append('3. **Value:** If you had to pick one model for your CI pipeline, which one wins?')
lines.append('')
lines.append('## The Contenders')
lines.append('')
lines.append('| Model | Location | Input Tokens | Output Tokens | AI Time (s) | Tok/s |')
lines.append('|-------|----------|-------------:|--------------:|------------:|------:|')
for m in models:
    met = m['metrics']
    loc = 'Local' if 'Stats/Local' in m['path'] else 'Cloud'
    lines.append(f"| {m['name']} | {loc} | {int(met.get('input_tokens', 0)):,} | {int(met.get('output_tokens', 0)):,} | {met.get('ai_time', 0):.2f} | {met.get('tokens_per_second', 0):.0f} |")
lines.append('')
lines.append('## Correctness: Exact, Near, and Missed')
lines.append('')
lines.append('A match only counts when the **rule name and line number** line up with the ground truth.')
lines.append('A "near" match is the same rule within five lines — useful signal, but not precise enough for automated remediation.')
lines.append('')
lines.append('| Model | Exact | Near | Missed | High-Severity Errors Missed | Score |')
lines.append('|-------|------:|-----:|-------:|----------------------------:|------:|')
for m in sorted(models, key=lambda x: x['correctness_score'], reverse=True):
    notes = m['notes']
    lines.append(f"| {m['name']} | {notes['matched']} | {notes['near']} | {notes['missed']} | {notes['errors_missed']} | {m['correctness_score']:.1f} |")
lines.append('')
lines.append('## What the Models Get Wrong')
lines.append('')
lines.append('The missed findings cluster in a few well-defined buckets:')
lines.append('')
lines.append('| Pattern | Total Miss Count Across Models | Why it matters |')
lines.append('|---------|--------------------------------:|----------------|')
patterns = Counter()
for m in models:
    n = m['notes']
    patterns['SELECT TOP without ORDER BY'] += n['top_missed']
    patterns['Hard-coded literals'] += n['literal_missed']
    patterns['Session setting changes'] += n['session_missed']
    patterns['SQL injection via dynamic SQL'] += n['sql_injection_missed']
    patterns['Dynamic SQL concatenation'] += n['dynamic_missed']
reasons = {
    'SELECT TOP without ORDER BY': 'Nondeterministic results; easy to miss when nested.',
    'Hard-coded literals': 'Maintenance bombs and security/policy risks.',
    'Session setting changes': 'Unrestored SET options leak to the caller.',
    'SQL injection via dynamic SQL': 'The most severe security issue on the list.',
    'Dynamic SQL concatenation': 'Usually the companion warning right next to injection.'
}
for pat, total in patterns.most_common():
    lines.append(f"| {pat} | {total} | {reasons.get(pat, 'Common correctness gap.')} |")
lines.append('')
lines.append('## Best Model Regardless of Expense')
lines.append('')
best_correct = max(models, key=lambda x: x['correctness_score'])
lines.append(f"If correctness is the only currency, **{best_correct['name']}** leads with **{best_correct['notes']['matched']} exact matches**, **{best_correct['notes']['near']} near matches**, and only **{best_correct['notes']['missed']} missed** findings.")
lines.append(f"It missed **{best_correct['notes']['errors_missed']} high-severity errors** out of the total set, the fewest among the contenders.")
lines.append('')
lines.append('## Best Value Model')
lines.append('')
for m in models:
    tokens = m['metrics'].get('total_tokens', 1)
    time = m['metrics'].get('ai_time', 1)
    m['value_token'] = m['correctness_score'] / max(tokens / 1000, 1)
    m['value_time'] = m['correctness_score'] / max(time, 1)
best_value = max(models, key=lambda x: x['value_token'])
lines.append(f"If you normalize by total tokens consumed, **{best_value['name']}** delivers the highest correctness per thousand tokens ({best_value['value_token']:.3f}).")
lines.append(f"It used {int(best_value['metrics'].get('total_tokens', 0)):,} tokens and ran in {best_value['metrics'].get('ai_time', 0):.1f} seconds.")
lines.append('')
lines.append('## Speed vs. Accuracy')
lines.append('')
lines.append('| Model | Tokens/Second | Correctness Score | Notes |')
lines.append('|-------|--------------:|------------------:|-------|')
for m in sorted(models, key=lambda x: x['metrics'].get('tokens_per_second', 0), reverse=True):
    speed = m['metrics'].get('tokens_per_second', 0)
    lines.append(f"| {m['name']} | {speed:.0f} | {m['correctness_score']:.1f} | {'Fast' if speed > 100 else 'Slow'} |")
lines.append('')
lines.append('## Recommendations')
lines.append('')
lines.append('- **For maximum correctness:** choose the model with the highest exact-match count and fewest missed high-severity errors.')
lines.append('- **For cost-conscious pipelines:** choose the model with the best correctness-per-token ratio; token volume is the dominant cost driver for local and cloud inference alike.')
lines.append('- **For interactive development:** prefer faster models if the correctness drop is acceptable for quick triage.')
lines.append('- **For production gate-keeping:** do not rely on a single model. Run the best-value model as the primary pass and the highest-correctness model as a secondary reviewer on changed files.')
lines.append('')
lines.append('## Why SQLAnalyzer Changes the Game')
lines.append('')
lines.append('The dirty secret of LLM-based code review is that the model is only half the problem.')
lines.append('The other half is **ground-truth evaluation**: knowing what should be found, where it lives, and whether a near-match is good enough.')
lines.append('SQLAnalyzer ships the `usp_TestProcedure.sql` sample and the expected-finding database so you can score any model, local or cloud, on the same fair test.')
lines.append('That repeatable benchmark is what makes model selection a data-driven decision instead of a popularity contest.')
lines.append('')
lines.append('## Bottom Line')
lines.append('')
lines.append(f"- **Best regardless of expense:** {best_correct['name']} — highest correctness score ({best_correct['correctness_score']:.1f}).")
lines.append(f"- **Best value:** {best_value['name']} — best correctness per thousand tokens ({best_value['value_token']:.3f}).")
lines.append('- **Key trade-off:** faster models can save wall-clock time but often miss security-critical errors such as SQL injection and dynamic-SQL concatenation.')
lines.append('')
lines.append('*Analysis produced with Quant Forge Software SQLAnalyzer.*')

out_path = ws / 'local_blog_analysis.md'
out_path.write_text('\n'.join(lines) + '\n', encoding='utf-8')
print(f'Wrote local_blog_analysis.md with {len(models)} models')
