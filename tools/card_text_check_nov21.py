"""Fable Nov 21 review (Part 4.2): card text against card script, mechanically.
   python tools/card_text_check_nov21.py      (after tools/text_audit_nov21.py, which writes _logs/n21r/cards_text_vs_script.tsv)
For every card: the keywords named in the rules text against the script's `kw` list, and the numbers in the text against the numbers in
the script. Prints the cards where they differ, for a reader to judge (most differences are wording, e.g. "a" for 1)."""
import re, sys, os
ROOT = os.path.join(os.path.dirname(os.path.abspath(__file__)), '..')
os.chdir(ROOT)
KEYWORDS = ['flying', 'swat', 'hustle', 'wallflower', 'bulldoze', 'sucker punch', 'one-two punch', 'toxic', 'nourish', 'overtime', 'elusive', 'untouchable', 'unbreakable']
WORDS = {'a': 1, 'an': 1, 'one': 1, 'two': 2, 'three': 3, 'four': 4, 'five': 5, 'six': 6, 'seven': 7, 'eight': 8, 'ten': 10, 'twice': 2}
flagged = 0
for line in open('_logs/n21r/cards_text_vs_script.tsv', encoding='utf-8'):
    cid, name, stats, rules, script = (line.rstrip('\n').split('\t') + ['', '', '', '', ''])[:5]
    if not script and not rules:
        continue
    notes = []
    low = rules.lower()
    # keywords the card HAS (a sentence that is only keyword names), against the script's own kw list
    own_text = set()
    for sentence in re.split(r'/|\n', rules):
        parts = [p.strip().lower() for p in sentence.strip().rstrip('.').split('.') if p.strip()]
        if parts and all(p in KEYWORDS for p in parts):
            own_text.update(parts)
    own_script = set()
    for m in re.finditer(r'(?:^|; )\s*kw ([a-z_,-]+)', script):
        own_script.update(k.replace('_', ' ').replace('one two punch', 'one-two punch') for k in m.group(1).split(','))
    if own_text != own_script:
        notes.append('keywords: text %s, script %s' % (sorted(own_text), sorted(own_script)))
    # numbers
    text_numbers = sorted(int(n) for n in re.findall(r'(?<![A-Za-z(/+-])(\d+)(?![/\d])', re.sub(r'\d+/\d+', ' ', rules)))
    stat_pairs = sorted(re.findall(r'([+-]?\d+)/([+-]?\d+)', rules))
    script_numbers = sorted(int(n) for n in re.findall(r'(?<![A-Za-z-])(\d+)', re.sub(r'T-\d+', ' ', script)))
    for n in text_numbers:
        if n not in script_numbers and script:
            notes.append('the text says %d, the script has no %d' % (n, n))
    for a, d in stat_pairs:
        a_, d_ = int(a), int(d)
        if a.startswith(('+', '-')) and script:
            if not re.search(r'[(,]%d,%d[,)]' % (a_, d_), script):
                notes.append('the text says %s/%s, no (%d,%d) in the script' % (a, d, a_, d_))
    if notes:
        flagged += 1
        print('%s %s\n   text:   %s\n   script: %s\n   -> %s' % (cid, name, rules, script, '; '.join(notes)))
print('%d cards flagged' % flagged)
