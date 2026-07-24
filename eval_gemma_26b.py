import json
from pathlib import Path
from collections import Counter

ws = Path('/Users/johnbaima/Code/SQLAnalyzer.Tests')
expected_path = ws / 'TestDatabases/WideWorldImporters/Test.ExpectedFindings.json'
actual_path = ws / 'TestDatabases/WideWorldImporters/Results/Output/Local/gemma-4-26b-a4b-it-qat-nvfp4.json'
report_path = ws / 'TestDatabases/WideWorldImporters/Results/Evaluation/Local/gemma-4-26b-a4b-it-qat-nvfp4.txt'
stats_path = ws / 'TestDatabases/WideWorldImporters/Results/Stats/Local/gemma-4-26b-a4b-it-qat-nvfp4.txt'

def load(path):
    with open(path, 'r', encoding='utf-8') as f:
        return json.load(f)

expected = load(expected_path)
actual = load(actual_path)

def index(items):
    d = {}
    for it in items:
        key = (it['ruleName'], it['lineNumber'])
        d.setdefault(key, []).append(it)
    return d

exp_idx = index(expected)
act_idx = index(actual)
all_keys = sorted(set(exp_idx.keys()) | set(act_idx.keys()), key=lambda k: (k[1], k[0]))

matched = []
missing = []
extra = []
line_shifted = []

for key in all_keys:
    e_items = exp_idx.get(key, [])
    a_items = act_idx.get(key, [])
    rule, line = key
    if e_items and a_items:
        matched.append(key)
    elif e_items and not a_items:
        found_shift = False
        for (arule, aline), ait in act_idx.items():
            if arule == rule and abs(aline - line) < 5:
                line_shifted.append((key, (arule, aline)))
                found_shift = True
                break
        if not found_shift:
            missing.append(key)
    else:
        found_shift = False
        for (erule, eline), eit in exp_idx.items():
            if erule == rule and abs(eline - line) < 5:
                found_shift = True
                break
        if not found_shift:
            extra.append(key)

lines = []
lines.append('Evaluation for gemma-4-26b-a4b-it-qat-nvfp4 (Local)')
lines.append('=' * 60)
lines.append('')
lines.append(f'Total expected findings: {len(expected)}')
lines.append(f'Total actual findings:   {len(actual)}')
lines.append(f'Matched (same rule + line): {len(matched)}')
lines.append(f'Line-shifted matches (<5 lines): {len(line_shifted)}')
lines.append(f'Missing expected findings: {len(missing)}')
lines.append(f'Extra (unmatched) findings: {len(extra)}')
lines.append('')

sev_counter = Counter()
for rule, line in missing:
    for it in exp_idx[(rule, line)]:
        sev_counter[it['severity']] += 1

lines.append('Missing findings by severity:')
for sev, count in sorted(sev_counter.items()):
    lines.append(f'  {sev}: {count}')
lines.append('')

lines.append('Missing expected findings (not matched or line-shifted)')
lines.append('-' * 60)
for rule, line in missing:
    for it in exp_idx[(rule, line)]:
        lines.append(f'{line:4d} [{it["severity"]:7s}] {rule}: {it["explanation"]}')
lines.append('')

lines.append('Extra/unmatched actual findings')
lines.append('-' * 60)
for rule, line in extra:
    for it in act_idx[(rule, line)]:
        lines.append(f'{line:4d} [{it["severity"]:7s}] {rule}: {it["explanation"]}')
lines.append('')

lines.append('Line-shifted matches (within 5 lines, not counted as missing)')
lines.append('-' * 60)
for (erule, eline), (arule, aline) in sorted(line_shifted, key=lambda x: x[0][1]):
    lines.append(f'Expected {eline:4d} {erule} -> Actual {aline:4d}')
lines.append('')

report_path.parent.mkdir(parents=True, exist_ok=True)
report_path.write_text('\n'.join(lines) + '\n', encoding='utf-8')

missing_rules = Counter(rule for rule, _ in missing)
notes_lines = []
notes_lines.append('')
notes_lines.append('Notes')
notes_lines.append('=====')
notes_lines.append(f'This run found {len(matched)} exact matches and {len(line_shifted)} near-matches (line off by <5).')
notes_lines.append(f'{len(missing)} expected findings were missed entirely.')
notes_lines.append('')
notes_lines.append('Pattern of missed findings:')
if sev_counter.get('error', 0) > 0:
    notes_lines.append(f'- {sev_counter["error"]} high-severity errors were missed, including SQL injection, transaction handling, and NULL-comparison bugs.')
if missing_rules.get('TopWithoutOrderBy', 0) >= 3:
    notes_lines.append(f'- Repeated failure to flag SELECT TOP without ORDER BY ({missing_rules["TopWithoutOrderBy"]} instances); the model tends to notice only the first or most prominent TOP clause.')
if missing_rules.get('HardCodedLiteral', 0) >= 3:
    notes_lines.append(f'- HardCodedLiteral detections are inconsistent ({missing_rules["HardCodedLiteral"]} missed); the model flags obvious business identifiers but misses numeric year/order/date literals embedded in predicates.')
if missing_rules.get('SessionSettingChanged', 0) >= 2:
    notes_lines.append(f'- SessionSettingChanged warnings are missed ({missing_rules["SessionSettingChanged"]} instances); SET NOCOUNT/XACT_ABORT state changes at procedure start are not being recognized as unrestored session settings.')
if missing_rules.get('SqlInjectionViaDynamicSql', 0) > 0:
    notes_lines.append(f'- SqlInjectionViaDynamicSql was missed for some concatenation points ({missing_rules["SqlInjectionViaDynamicSql"]} instances), suggesting the model recognizes dynamic SQL but not every user-input concatenation.')
if missing_rules.get('DynamicSqlConcatenation', 0) > 0:
    notes_lines.append(f'- DynamicSqlConcatenation warnings were also missed ({missing_rules["DynamicSqlConcatenation"]} instances); dynamic SQL with variable concatenation is inconsistently detected.')
if missing_rules.get('MultiStatementTvfInsteadOfInline', 0) > 0 or missing_rules.get('SelectStar', 0) > 0:
    notes_lines.append('- Object-specific rule misses (multi-statement TVF, SELECT * from TVF) indicate difficulty with scoped/aliased object references.')
notes_lines.append('- Overall pattern: the model catches broad anti-patterns but misses duplicates, companion rules at the same line, and subtle variants such as session-state changes and hard-coded numeric literals.')

stats_path.parent.mkdir(parents=True, exist_ok=True)
with open(stats_path, 'a', encoding='utf-8') as f:
    f.write('\n'.join(notes_lines) + '\n')

print(f'Wrote evaluation report to {report_path}')
print(f'Appended notes to {stats_path}')
