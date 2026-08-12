import json
from pathlib import Path
from collections import Counter

base = Path('/Users/johnbaima/Code/SQLAnalyzer.Tests/TestDatabases/WideWorldImporters')
expected_path = base / 'Test.ExpectedFindings.json'
output_path   = base / 'Results/Output/Cloud/deepseek-v4-pro.json'
eval_path     = base / 'Results/Evaluation/Cloud/deepseek-v4-pro.txt'
stats_path    = base / 'Results/Stats/Cloud/deepseek-v4-pro.txt'

expected = json.loads(expected_path.read_text(encoding='utf-8-sig'))
output   = json.loads(output_path.read_text(encoding='utf-8-sig'))

TOL = 4  # ignore line differences < 5 => abs diff <= 4

matched_exp = set()
matched_out = set()
severity_mismatches = []

for i, e in enumerate(expected):
    for j, o in enumerate(output):
        if j in matched_out:
            continue
        if e['ruleName'] != o['ruleName']:
            continue
        if abs(e['lineNumber'] - o['lineNumber']) <= TOL:
            matched_exp.add(i)
            matched_out.add(j)
            if e['severity'] != o['severity']:
                severity_mismatches.append({
                    'expected_line': e['lineNumber'],
                    'output_line': o['lineNumber'],
                    'rule': e['ruleName'],
                    'expected_severity': e['severity'],
                    'output_severity': o['severity']
                })
            break

missing = [expected[i] for i in range(len(expected)) if i not in matched_exp]
extra   = [output[j]   for j in range(len(output))   if j not in matched_out]

lines = []
lines.append('Comparison (line differences < 5 ignored): deepseek-v4-pro.json vs Test.ExpectedFindings.json')
lines.append('')
lines.append(f'Total expected findings: {len(expected)}')
lines.append(f'Total output findings:   {len(output)}')
lines.append(f'Matched within +/-4 lines: {len(matched_exp)}')
lines.append(f'Missing from output:     {len(missing)}')
lines.append(f'Extra in output:         {len(extra)}')
lines.append(f'Severity mismatches:     {len(severity_mismatches)}')
lines.append('')

lines.append('Missing findings (expected but not within line tolerance):')
if missing:
    for f in missing:
        lines.append(f"  line {f['lineNumber']}: {f['ruleName']} - {f['explanation']}")
else:
    lines.append('  (none)')
lines.append('')

lines.append('Extra findings (in output but not within line tolerance):')
if extra:
    for f in extra:
        lines.append(f"  line {f['lineNumber']}: {f['ruleName']} - {f['explanation']}")
else:
    lines.append('  (none)')
lines.append('')

lines.append('Severity mismatches (same rule matched, different severity):')
if severity_mismatches:
    for m in severity_mismatches:
        lines.append(f"  expected line {m['expected_line']} (output line {m['output_line']}): {m['rule']} - expected {m['expected_severity']}, got {m['output_severity']}")
else:
    lines.append('  (none)')

eval_path.write_text('\n'.join(lines) + '\n')
print(f'Wrote comparison to {eval_path}')

# Pattern analysis of misses
rule_counter = Counter(f['ruleName'] for f in missing)
sev_counter  = Counter(f['severity'] for f in missing)
line_range_counter = Counter()
for f in missing:
    ln = f['lineNumber']
    if ln < 100:
        bucket = '1-99'
    elif ln < 150:
        bucket = '100-149'
    elif ln < 200:
        bucket = '150-199'
    elif ln < 250:
        bucket = '200-249'
    else:
        bucket = '250+'
    line_range_counter[bucket] += 1

patterns = []
for f in missing:
    exp = f['explanation'].lower()
    if any(k in exp for k in ['hard-coded', 'literal', 'embedded', 'magic', 'sentinel']):
        patterns.append('hard-coded literals')
    if any(k in exp for k in ['convert', 'implicit', 'date']):
        patterns.append('date/conversion issues')
    if any(k in exp for k in ['dynamic', 'inject']):
        patterns.append('dynamic SQL / injection')
    if any(k in exp for k in ['transaction', 'catch', 'rollback', 'xact']):
        patterns.append('transaction/error-handling')
    if any(k in exp for k in ['session', 'nocount', 'xact_abort', 'rowcount']):
        patterns.append('session settings')
    if any(k in exp for k in ['aggregate', 'sum(', 'count(*)']):
        patterns.append('aggregate issues')

analysis = []
analysis.append('')
analysis.append('Notes')
analysis.append('=====')
analysis.append(f"Total expected findings: {len(expected)} (across 61 rules)")
analysis.append(f"Matched within tolerance: {len(matched_exp)}")
analysis.append(f"Missed expected findings: {len(missing)}")
analysis.append(f"Extra findings in output: {len(extra)}")
analysis.append('')
analysis.append('Missed expected findings by rule:')
for rule, count in rule_counter.most_common():
    total = sum(1 for e in expected if e['ruleName'] == rule)
    matched = sum(1 for i, e in enumerate(expected) if e['ruleName'] == rule and i in matched_exp)
    missed_lines = sorted({f['lineNumber'] for f in missing if f['ruleName'] == rule})
    analysis.append(f"  {rule}: {count} missed out of {total} expected (matched {matched}); expected lines {missed_lines}")
analysis.append('')
analysis.append('Misses by line range:')
for rng, count in sorted(line_range_counter.items(), key=lambda x: ['1-99','100-149','150-199','200-249','250+'].index(x[0])):
    analysis.append(f"  {rng}: {count}")
analysis.append('')
analysis.append('Pattern analysis for missed expected findings:')
analysis.append('  - Rules partially missed (some instances detected, others not):')
for rule, count in rule_counter.most_common():
    total = sum(1 for e in expected if e['ruleName'] == rule)
    if total > count:
        analysis.append(f'      {rule}: {count}/{total} missed')
analysis.append('')
analysis.append('  - Main patterns:')
for theme, count in Counter(patterns).most_common():
    analysis.append(f'      {theme}: {count}')
analysis.append('')

if missing:
    analysis.append('Observation:')
    analysis.append(f'  DeepSeek v4 Pro matched {len(matched_exp)} of {len(expected)} expected findings. Its misses cluster around session-setting restoration (SessionSettingChanged), explicit SQL-injection labeling (SqlInjectionViaDynamicSql), a single hard-coded literal on line 36, and one aggregate-without-filter case. Many of these are sibling labels that the model reports under alternate rule names (e.g., NoCountDisabled/XactAbortDisabled for the session settings), suggesting the issue was noticed but not tagged with the exact expected rule.')

stats_path.write_text(stats_path.read_text() + '\n'.join(analysis) + '\n')
print(f'Appended analysis to {stats_path}')
