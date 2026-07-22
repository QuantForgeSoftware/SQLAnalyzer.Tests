from pathlib import Path

p = Path('/Users/johnbaima/Code/SQLAnalyzer.Tests/TestDatabases/WideWorldImporters/Results/Output/gemini-3.6-flash.json')
text = p.read_text(encoding='utf-8-sig')

start = text.find('[\n  {\n    "rule')
if start == -1:
    print('No JSON array found')
else:
    p.write_text(text[start:], encoding='utf-8-sig')
    print(f'Stripped {start} prefix characters')
