import csv
from pathlib import Path

blog = Path('/Users/johnbaima/Code/SQLAnalyzer.Tests/blog_analysis.md').read_text()
csv_path = Path('/Users/johnbaima/Code/SQLAnalyzer.Tests/TestDatabases/WideWorldImporters/Results/comparison_summary.csv')

lines = blog.splitlines()
table = []
seen_heading = False
for line in lines:
    if seen_heading:
        if line.strip() == '':
            continue
        if line.startswith('|') and 'Model' not in line and '---' not in line:
            table.append(line)
        elif not line.startswith('|'):
            break
    if '## The Results at a Glance' in line:
        seen_heading = True

csv_rows = {r['Model']: r for r in csv.DictReader(csv_path.read_text().splitlines())}

print(f"{'Model':30s} {'blog R':>6} {'csv R':>6} {'blog Mat':>8} {'csv Mat':>7} {'blog Sev':>8} {'csv Sev':>7} {'blog $':>7} {'csv $':>7} {'blog T':>7} {'csv T':>7}")
errors = 0
for row in table:
    cols = [c.strip() for c in row.strip('|').split('|')]
    model, recall, matched, missing, extra, sev, cost, time = cols
    recall = recall.replace('**','').replace('%','')
    matched = matched.replace('**','')
    cost = cost.replace('$','').replace('*','')
    time = time.replace('*','')
    r = csv_rows.get(model)
    if r is None:
        print(f"{model:30s} NOT IN CSV")
        errors += 1
        continue
    flags = []
    if float(recall) != float(r['Recall%']): flags.append('RECALL')
    if int(matched) != int(r['Matched']): flags.append('MATCHED')
    if int(sev) != int(r['SeverityMismatchTypes']): flags.append('SEV')
    if float(cost) != float(r['Cost($)']): flags.append('COST')
    if float(time) != float(r['Time(s)']): flags.append('TIME')
    if flags:
        errors += 1
    status = 'OK' if not flags else ','.join(flags)
    print(f"{model:30s} {recall:>6} {r['Recall%']:>6} {matched:>8} {r['Matched']:>7} {sev:>8} {r['SeverityMismatchTypes']:>7} ${cost:>6} ${r['Cost($)']:>6} {time:>7}s {r['Time(s)']:>7}s {status}")

print(f"\nRows checked: {len(table)}; errors: {errors}")
