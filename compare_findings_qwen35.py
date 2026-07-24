import json
import os
from collections import Counter, defaultdict

base = "/Users/johnbaima/Code/SQLAnalyzer.Tests"
expected_path = os.path.join(base, "TestDatabases/WideWorldImporters/Test.ExpectedFindings.json")
actual_path = os.path.join(base, "TestDatabases/WideWorldImporters/Results/Output/Local/qwen3.5-9b-mtp.json")
stats_path = os.path.join(base, "TestDatabases/WideWorldImporters/Results/Stats/Local/qwen3.5-9b-mtp.txt")

with open(expected_path) as f:
    expected = json.load(f)
with open(actual_path) as f:
    actual = json.load(f)

actual_used = [False] * len(actual)
matched = []
missed = []

for e in expected:
    best_idx = -1
    best_diff = None
    for i, a in enumerate(actual):
        if actual_used[i]:
            continue
        if a.get("ruleName") != e.get("ruleName"):
            continue
        diff = abs(a.get("lineNumber", 0) - e.get("lineNumber", 0))
        if diff < 5:
            if best_idx == -1 or diff < best_diff:
                best_idx = i
                best_diff = diff
    if best_idx != -1:
        actual_used[best_idx] = True
        matched.append((e, actual[best_idx]))
    else:
        missed.append(e)

extras = [a for i, a in enumerate(actual) if not actual_used[i]]

expected_by_rule = Counter(f["ruleName"] for f in expected)
matched_by_rule = Counter(f["ruleName"] for f, _ in matched)
missed_by_rule = Counter(f["ruleName"] for f in missed)
extra_by_rule = Counter(f["ruleName"] for f in extras)

lines = []
lines.append("")
lines.append("Notes")
lines.append("=====")
lines.append("Comparison performed: 2026-07-24")
lines.append(f"Total expected findings: {len(expected)} (across {len(expected_by_rule)} rules)")
lines.append(f"Matched within tolerance: {len(matched)}")
lines.append(f"Missed expected findings: {len(missed)}")
lines.append(f"Extra findings in actual output: {len(extras)}")
lines.append("")
if missed:
    lines.append("Missed expected findings by rule:")
    for rule, cnt in sorted(missed_by_rule.items(), key=lambda x: (-x[1], x[0])):
        total = expected_by_rule[rule]
        hit = matched_by_rule.get(rule, 0)
        missed_lines = sorted(set(f["lineNumber"] for f in missed if f["ruleName"] == rule))
        lines.append(f"  {rule}: {cnt} missed out of {total} expected (matched {hit}); expected lines {missed_lines}")
    lines.append("")
    lines.append("Pattern analysis for missed expected findings:")
    completely_missed = [rule for rule in expected_by_rule if missed_by_rule.get(rule, 0) == expected_by_rule[rule]]
    if completely_missed:
        lines.append(f"  - Rules completely missed (no instance detected): {sorted(completely_missed)}")
    partial = [(rule, missed_by_rule[rule], expected_by_rule[rule]) for rule in expected_by_rule if 0 < missed_by_rule.get(rule, 0) < expected_by_rule[rule]]
    if partial:
        lines.append("  - Rules partially missed (some instances detected, others not):")
        for rule, m, t in sorted(partial, key=lambda x: -x[1]):
            lines.append(f"      {rule}: {m}/{t} missed")
    cat_counts = defaultdict(int)
    for f in missed:
        rn = f["ruleName"]
        if "DynamicSql" in rn or "SqlInjection" in rn:
            cat_counts["Dynamic SQL / injection"] += 1
        elif "Join" in rn or "Subquery" in rn or "Exists" in rn or "Correlation" in rn or "Scalar" in rn:
            cat_counts["Joins, subqueries, and correlated lookups"] += 1
        elif "OrderBy" in rn or "Sort" in rn or "Top" in rn or "Pagination" in rn or "Distinct" in rn:
            cat_counts["Ordering, paging, and aggregation semantics"] += 1
        elif "Literal" in rn or "Date" in rn:
            cat_counts["Hard-coded / magic literals"] += 1
        elif "Temp" in rn or "TableVariable" in rn or "Cursor" in rn or "While" in rn or "InsertWithoutColumn" in rn or "UpdateWithoutWhere" in rn or "Merge" in rn:
            cat_counts["Procedural / DML constructs"] += 1
        elif "Transaction" in rn or "Catch" in rn or "RaiseError" in rn or "Print" in rn or "Nocount" in rn or "Xact" in rn or "SessionSetting" in rn or "Identity" in rn:
            cat_counts["Error handling and session settings"] += 1
        else:
            cat_counts["Other predicate / schema issues"] += 1
    lines.append("  - Missed findings by broad category:")
    for cat, cnt in sorted(cat_counts.items(), key=lambda x: -x[1]):
        lines.append(f"      {cat}: {cnt}")
else:
    lines.append("No missed expected findings.")

if extras:
    lines.append("")
    lines.append("Extra findings in actual output by rule:")
    for rule, cnt in sorted(extra_by_rule.items(), key=lambda x: (-x[1], x[0])):
        extra_lines = sorted(set(f["lineNumber"] for f in extras if f["ruleName"] == rule))
        lines.append(f"  {rule}: {cnt} at lines {extra_lines}")

notes = "\n".join(lines)

with open(stats_path, "a") as f:
    f.write(notes)

print(f"Total expected: {len(expected)}")
print(f"Matched: {len(matched)}")
print(f"Missed: {len(missed)}")
print(f"Extra: {len(extras)}")
print("\nAppended notes:\n" + notes)
