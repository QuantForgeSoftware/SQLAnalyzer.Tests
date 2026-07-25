import json
from pathlib import Path

output_path = Path('/Users/johnbaima/Code/SQLAnalyzer.Tests/TestDatabases/WideWorldImporters/Results/Output/Cloud/claude-opus-5.json')
expected_path = Path('/Users/johnbaima/Code/SQLAnalyzer.Tests/TestDatabases/WideWorldImporters/Test.ExpectedFindings.json')

output = json.loads(output_path.read_text())
expected = json.loads(expected_path.read_text())

expected_matched = set()
output_matched = set()

for i, e in enumerate(expected):
    for j, o in enumerate(output):
        if o['ruleName'] == e['ruleName'] and abs(o['lineNumber'] - e['lineNumber']) <= 5:
            expected_matched.add(i)
            output_matched.add(j)
            break

missed = [expected[i] for i in range(len(expected)) if i not in expected_matched]
extra = [output[j] for j in range(len(output)) if j not in output_matched]

matched_count = len(expected_matched)
missing_count = len(missed)
extra_count = len(extra)
total_expected = len(expected)

print(f"Total expected: {total_expected}")
print(f"Matched: {matched_count}")
print(f"Missed: {missing_count}")
print(f"Extra: {extra_count}")

# Count missed by rule name
missed_by_rule = {}
for m in missed:
    missed_by_rule[m['ruleName']] = missed_by_rule.get(m['ruleName'], 0) + 1

# Count extra by rule name
extra_by_rule = {}
for e in extra:
    extra_by_rule[e['ruleName']] = extra_by_rule.get(e['ruleName'], 0) + 1

print("\nMissed by rule:")
for rule, count in sorted(missed_by_rule.items(), key=lambda x: -x[1]):
    print(f"  {rule}: {count}")

print("\nExtra by rule:")
for rule, count in sorted(extra_by_rule.items(), key=lambda x: -x[1]):
    print(f"  {rule}: {count}")
