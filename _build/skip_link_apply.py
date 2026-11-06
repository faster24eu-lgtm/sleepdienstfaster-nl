#!/usr/bin/env python3
from pathlib import Path
import re

NL = '<a class="skip-link" href="#content">Ga naar inhoud</a>\n'

def fix(t: str) -> str:
    if 'class="skip-link"' not in t:
        m = re.search(r'<body[^>]*>\s*', t, re.I)
        if m:
            t = t[: m.end()] + NL + t[m.end() :]
    if '<main' in t and 'id="content"' not in t:
        t = re.sub(r'<main(?![^>]*\bid=)', '<main id="content"', t, count=1)
    return t

n = 0
for f in Path('.').rglob('*.html'):
    if '.git' in f.parts:
        continue
    t = f.read_text()
    nt = fix(t)
    if nt != t:
        f.write_text(nt)
        n += 1
print('html updated', n)
