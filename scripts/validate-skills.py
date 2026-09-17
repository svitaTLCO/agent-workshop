#!/usr/bin/env python3
"""Validate Agent Skills spec compliance for skills/*/SKILL.md."""
import re, sys
from pathlib import Path
ROOT = Path(__file__).resolve().parents[1]
name_re = re.compile(r'^[a-z0-9]+(-[a-z0-9]+)*$')
errors = []
skills = sorted((ROOT / 'skills').glob('*/SKILL.md'))
if not skills:
    print('no skills found'); sys.exit(1)
for f in skills:
    name = f.parent.name
    text = f.read_text(encoding='utf-8')
    if not text.startswith('---'):
        errors.append(f'{name}: missing frontmatter'); continue
    fm = text.split('---', 2)[1]
    m_name = re.search(r'^name:\s*(.+)$', fm, re.M)
    m_desc = re.search(r'^description:\s*(.+)$', fm, re.M | re.S)
    if not m_name or m_name.group(1).strip() != name:
        errors.append(f'{name}: name must equal dirname')
    elif not name_re.match(name) or not (1 <= len(name) <= 64):
        errors.append(f'{name}: bad name format/length')
    if not m_desc or not (1 <= len(m_desc.group(1).strip()) <= 1024):
        errors.append(f'{name}: description must be 1-1024 chars')
    body = text.split('---', 2)[2]
    if len(body.strip().splitlines()) > 500:
        errors.append(f'{name}: body > 500 lines')
    if 'Token budget' not in body:
        errors.append(f'{name}: missing "Token budget" statement')
    if 'Quality gate' not in body:
        errors.append(f'{name}: missing "Quality gate" statement')
for s in skills:
    print(f'ok {s.parent.name}')
if errors:
    print('\nERRORS:'); [print(' -', e) for e in errors]; sys.exit(1)
print(f'\n{len(skills)} skills valid')
