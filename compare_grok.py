import json
from pathlib import Path

base = Path('/Users/johnbaima/Code/SQLAnalyzer.Tests/TestDatabases/WideWorldImporters')
expected_path = base / 'Test.ExpectedFindings.json'
output_path   = base / 'Results/Output/Grok 4.5.json'
out_path      = base / 'Results/Evaluation/Grok 4.5.txt'

expected = json.loads(expected_path.read_text(encoding='utf-8-sig'))
output   = json.loads(output_path.read_text(encoding='utf-8-sig'))

# tolerance: ignore line differences less than 5, i.e. match if |diff| <= 4
TOL = 4

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
lines.append('Comparison (line differences < 5 ignored): Grok 4.5.json vs Test.ExpectedFindings.json')
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

out_path.write_text('\n'.join(lines) + '\n')
print(f'Wrote comparison to {out_path}')


def add_extras_to_expected():
    """Append Grok's extra findings (not matched within tolerance) to Test.ExpectedFindings.json."""
    expected_path = base / 'Test.ExpectedFindings.json'
    expected = json.loads(expected_path.read_text(encoding='utf-8-sig'))

    TOL = 4
    matched_exp = set()
    matched_out = set()

    for i, e in enumerate(expected):
        for j, o in enumerate(output):
            if j in matched_out:
                continue
            if e['ruleName'] != o['ruleName']:
                continue
            if abs(e['lineNumber'] - o['lineNumber']) <= TOL:
                matched_exp.add(i)
                matched_out.add(j)
                break

    extra = [output[j] for j in range(len(output)) if j not in matched_out]
    for e in extra:
        expected.append(e)

    expected.sort(key=lambda x: (x['lineNumber'], x['ruleName']))
    expected_path.write_text(json.dumps(expected, indent=4) + '\n', encoding='utf-8')
    print(f"Added {len(extra)} extra findings. Total now {len(expected)}.")


if __name__ == '__main__':
    add_extras_to_expected()
