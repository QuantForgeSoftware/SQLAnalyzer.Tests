import json

expected_path = 'TestDatabases/WideWorldImporters/Test.ExpectedFindings.json'
actual_path   = 'TestDatabases/WideWorldImporters/Results/Output/Local/muse-glimmer-30b@q4_k_xl.json'

with open(expected_path) as f:
    expected = json.load(f)
with open(actual_path) as f:
    actual = json.load(f)

print(f"Expected count: {len(expected)}")
print(f"Actual count:   {len(actual)}")

exp_by_key = {}
for e in expected:
    k = (e['ruleName'], e['lineNumber'], e['severity'])
    exp_by_key.setdefault(k, []).append(e)

line_tol = 5
matched_exp = set()
matched_act = set()
extra = []
missing = []

for ai, a in enumerate(actual):
    key = (a['ruleName'], a['lineNumber'], a['severity'])
    found = False
    if key in exp_by_key:
        for ei, e in enumerate(exp_by_key[key]):
            if (ei, key) not in matched_exp:
                matched_exp.add((ei, key))
                matched_act.add(ai)
                found = True
                break
    if found:
        continue
    for (rn, ln, sev), exps in exp_by_key.items():
        if rn != a['ruleName'] or sev != a['severity']:
            continue
        if abs(ln - a['lineNumber']) <= line_tol:
            for ei, e in enumerate(exps):
                if (ei, (rn, ln, sev)) not in matched_exp:
                    matched_exp.add((ei, (rn, ln, sev)))
                    matched_act.add(ai)
                    found = True
                    break
        if found:
            break
    if not found:
        extra.append(a)

for k, exps in exp_by_key.items():
    for ei, e in enumerate(exps):
        if (ei, k) not in matched_exp:
            missing.append(e)

print(f"\nMatched count:    {len(matched_act)}")
print(f"Extra findings:   {len(extra)}")
print(f"Missing findings: {len(missing)}")

print("\n--- MISSING EXPECTED FINDINGS ---")
for m in sorted(missing, key=lambda x: x['lineNumber']):
    print(f"Line {m['lineNumber']:3d} [{m['severity']:7s}] {m['ruleName']}")

print("\n--- EXTRA FINDINGS ---")
for e in sorted(extra, key=lambda x: x['lineNumber']):
    print(f"Line {e['lineNumber']:3d} [{e['severity']:7s}] {e['ruleName']}")

# Write evaluation file
out_path = 'TestDatabases/WideWorldImporters/Results/Evaluation/Local/muse-glimmer-30b@q4_k_xl.txt'
with open(out_path, 'w') as f:
    f.write(f"Comparison for muse-glimmer-30b@q4_k_xl\n")
    f.write(f"Expected findings: {len(expected)}\n")
    f.write(f"Actual findings:   {len(actual)}\n")
    f.write(f"Matched findings:  {len(matched_act)}\n")
    f.write(f"Missing findings:  {len(missing)}\n")
    f.write(f"Extra findings:    {len(extra)}\n\n")
    f.write("MISSING EXPECTED FINDINGS\n")
    f.write("(line differences within 5 are treated as matches and not listed here)\n\n")
    for m in sorted(missing, key=lambda x: (x['lineNumber'], x['ruleName'])):
        f.write(f"Line {m['lineNumber']:3d} [{m['severity']:7s}] {m['ruleName']}\n")
        f.write(f"    {m['explanation']}\n")
    f.write("\nEXTRA FINDINGS\n\n")
    for e in sorted(extra, key=lambda x: (x['lineNumber'], x['ruleName'])):
        f.write(f"Line {e['lineNumber']:3d} [{e['severity']:7s}] {e['ruleName']}\n")
        f.write(f"    {e['explanation']}\n")

print(f"\nWrote evaluation to {out_path}")
