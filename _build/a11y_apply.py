#!/usr/bin/env python3
from pathlib import Path

def fix(t: str) -> str:
    t = t.replace(' aria-label="Sleepdienst Faster, naar de homepage"', '')
    t = t.replace(
        '<input type="text" name="_honey" class="hp" tabindex="-1" autocomplete="off">',
        '<input type="text" name="_honey" class="hp" tabindex="-1" autocomplete="off" aria-hidden="true">',
    )
    return t

n = 0
for f in Path('.').rglob('*.html'):
    t = f.read_text()
    nt = fix(t)
    if nt != t:
        f.write_text(nt)
        n += 1
print('html updated', n)
