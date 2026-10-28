import json
import re
import subprocess
import sys
from pathlib import Path

try:
    import hjson
except ImportError:
    subprocess.check_call([sys.executable, '-m', 'pip', 'install', 'hjson'])
    import hjson

root = Path(r'c:\Users\jhoni\OneDrive\Documents\Auraline-Magna')
color_pattern = re.compile(r'(?i)(?:^|[\s\[{:,])([0-9a-f]{3,8})(?=\s*(?:,|\]|\}|//|$))')


def quote_color_values(text: str) -> str:
    def repl(match):
        val = match.group(1)
        if re.fullmatch(r'[0-9a-fA-F]{3,8}', val) and re.search(r'[a-fA-F]', val):
            return f'"{val}"'
        return val

    for key in [
        'color', 'mapColor', 'lightColor', 'frontColor', 'backColor', 'trailColor',
        'colorFrom', 'colorTo', 'shadowColor', 'colors'
    ]:
        text = re.sub(rf'({key}\s*:\s*)([0-9A-Fa-f]+)(?=\s*(?:,|\]|//|$))',
                      lambda m: f'{m.group(1)}"{m.group(2)}"' if re.fullmatch(r'[0-9A-Fa-f]{3,8}', m.group(2)) and re.search(r'[a-fA-F]', m.group(2)) else m.group(0),
                      text)
        text = re.sub(rf'({key}\s*:\s*\[)([^\]]*)(\])',
                      lambda m: m.group(1) + re.sub(r'([0-9A-Fa-f]{3,8})(?=\s*(?:,|\]))', lambda x: f'"{x.group(1)}"', m.group(2)) + m.group(3),
                      text)
    return text

count = 0
for p in sorted(root.rglob('*.hjson')):
    text = p.read_text(encoding='utf-8')
    fixed = quote_color_values(text)
    data = hjson.loads(fixed)
    out = p.with_suffix('.json')
    out.write_text(json.dumps(data, indent=2, ensure_ascii=False) + '\n', encoding='utf-8')
    p.unlink()
    count += 1

print(f'Converted and deleted {count} HJSON files')
