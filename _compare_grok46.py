import json
from pathlib import Path
from collections import Counter

base = Path('/Users/johnbaima/Code/SQLAnalyzer.Tests/TestDatabases/WideWorldImporters')
expected_path = base / 'Test.ExpectedFindings.json'
output_path   = base / 'Results/Output/Cloud/grok-4.6.json'
eval_path     = base / 'Results/Evaluation/Cloud/grok-4.6.txt'
stats_path    = base / 'Results/Stats/Cloud/grok-4.6.txt'

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
lines.append('Comparison (line differences < 5 ignored): grok-4.6.json vs Test.ExpectedFindings.json')
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

# Analysis: pattern of missed expected findings
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

analysis = []
analysis.append('')
analysis.append('Notes')
analysis.append('-----')
analysis.append(f"Missing expected findings: {len(missing)}")
analysis.append('')
analysis.append('Misses by rule:')
for rule, count in rule_counter.most_common():
    analysis.append(f'  {rule}: {count}')
analysis.append('')
analysis.append('Misses by severity:')
for sev, count in sev_counter.most_common():
    analysis.append(f'  {sev}: {count}')
analysis.append('')
analysis.append('Misses by line range:')
for rng, count in sorted(line_range_counter.items(), key=lambda x: ['1-99','100-149','150-199','200-249','250+'].index(x[0])):
    analysis.append(f'  {rng}: {count}')
analysis.append('')

patterns = []
for f in missing:
    exp = f['explanation'].lower()
    if 'hard-coded' in exp or 'literal' in exp or 'embedded' in exp:
        patterns.append('hard-coded literals')
    if 'convert' in exp or 'implicit' in exp or 'date' in exp or 'isnull' in exp or 'coalesce' in exp:
        patterns.append('expression/type/conversion issues')
    if 'join' in exp or 'cross' in exp:
        patterns.append('join-related issues')
    if 'transaction' in exp or 'catch' in exp or 'rollback' in exp:
        patterns.append('transaction/error-handling issues')
    if 'dynamic' in exp or 'inject' in exp:
        patterns.append('dynamic SQL issues')

pattern_counter = Counter(patterns)
analysis.append('Common themes among missed findings:')
for theme, count in pattern_counter.most_common():
    analysis.append(f'  {theme}: {count}')
analysis.append('')

if missing:
    analysis.append('Observation:')
    if sev_counter.get('error', 0) > 0:
        analysis.append(f"  {sev_counter['error']} of the missed findings are classified as errors in the expected set, indicating some high-impact issues (e.g., transaction handling, weak delete predicates, SQL injection, NULL equality) were not fully matched.")
    analysis.append('  The missed findings cluster around nuanced rule interpretations: Grok 4.6 sometimes reclassifies severity (e.g., XactAbortDisabled and ExplicitTransactionWithoutTryCatch dropped from error to warning) or reports the same anti-pattern at a slightly different line/under a different rule name, so it misses the exact expected pairing within the 5-line tolerance.')
    analysis.append('  Hard-coded literals, date conversions, and join-related subtleties (COALESCE, outer-join-to-filter) account for a large share of misses, suggesting Grok 4.6 may be consolidating or renaming these findings rather than omitting them entirely.')

stats_path.write_text(stats_path.read_text() + '\n'.join(analysis) + '\n')
print(f'Appended analysis to {stats_path}')
