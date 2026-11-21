"""Fable Nov 21 review (Part 4): gathers every player-facing string into one table, and lists what a proof-reader should look at.
   python tools/text_audit_nov21.py [--dialogue=<csv from tools/export_dialogue.js>]
Writes _logs/n21r/text_all.tsv (source <tab> text), _logs/n21r/text_rare_words.txt (words seen once or twice, with one source each),
_logs/n21r/text_mechanical.txt (double spaces, a space before punctuation, doubled words, a lower-case start, a missing full stop on a
card) and _logs/n21r/cards_text_vs_script.tsv (id, name, type line, rules text, script) for the card text check."""
import os, re, sys, json, csv, glob, collections
ROOT = os.path.join(os.path.dirname(os.path.abspath(__file__)), '..')
os.chdir(ROOT)
OUT = '_logs/n21r'
os.makedirs(OUT, exist_ok=True)
rows = []  # (source, text)

def add(source, text):
    if isinstance(text, str):
        text = text.strip()
        if len(text) >= 2 and re.search(r'[A-Za-z]{2}', text):
            rows.append((source, text))

# 1. dialogue export
dialogue = next((a.split('=', 1)[1] for a in sys.argv[1:] if a.startswith('--dialogue=')), '')
if dialogue and os.path.exists(dialogue):
    with open(dialogue, encoding='utf-8-sig', newline='') as f:
        for r in csv.DictReader(f):
            keys = list(r.keys())
            add('dialogue:' + r[keys[0]], r.get('Current line', ''))

# 2. cards and tokens
cards = []
for folder in ['data/cards', 'data/tokens']:
    for path in sorted(glob.glob(folder + '/*.tres')):
        text = open(path, encoding='utf-8').read()
        def field(name, default=''):
            m = re.search(r'^%s = "((?:[^"\\]|\\.)*)"' % name, text, re.M)
            return m.group(1).replace('\\"', '"').replace('\\n', '\n') if m else default
        def raw(name):
            m = re.search(r'^%s = (.*)$' % name, text, re.M)
            return m.group(1) if m else ''
        card = {'id': field('id'), 'name': field('display_name'), 'rules': field('rules_text'), 'flavor': field('flavor_text'), 'script': field('script_text'),
                'attack': raw('attack'), 'defense': raw('defense'), 'cost': raw('cost'), 'pips': raw('colored_pips'), 'keywords': raw('keywords'), 'type': raw('card_type'),
                'subtype': field('subtype'), 'file': path}
        cards.append(card)
        add('card:%s name' % card['id'], card['name'])
        add('card:%s rules' % card['id'], card['rules'])
        add('card:%s flavor' % card['id'], card['flavor'])
with open(OUT + '/cards_text_vs_script.tsv', 'w', encoding='utf-8', newline='\n') as f:
    for c in cards:
        f.write('\t'.join([c['id'], c['name'], 't%s c%s p%s a%s d%s k%s' % (c['type'], c['cost'], c['pips'], c['attack'], c['defense'], c['keywords']), c['rules'].replace('\n', ' / '), c['script'].replace('\n', ' ; ')]) + '\n')

# 3. data json: every string value that reads as prose (has a space) or is a name-like field
NAME_KEYS = {'name', 'title', 'display_name', 'label', 'blurb', 'text', 'line', 'body', 'desc', 'description', 'hint', 'summary', 'banner', 'warn', 'where', 'subtitle', 'tip', 'note'}
SKIP_FILES = ('data/art/', 'data/audio/', 'data/source/', 'data/camera/', 'data/zone_styles/', 'data/maps/', 'data/ai/')
def walk(source, value, key=''):
    if isinstance(value, dict):
        for k, v in value.items():
            walk(source, v, k)
    elif isinstance(value, list):
        for v in value:
            walk(source, v, key)
    elif isinstance(value, str):
        if ' ' in value.strip() or key in NAME_KEYS:
            if not value.startswith('res://') and not re.fullmatch(r'[a-z0-9_/.:-]+', value):
                add('%s [%s]' % (source, key), value)
for path in sorted(glob.glob('data/**/*.json', recursive=True)):
    p = path.replace('\\', '/')
    if p.startswith(SKIP_FILES):
        continue
    try:
        walk(p, json.load(open(path, encoding='utf-8-sig')))
    except Exception as e:
        print('json skipped', p, e)
# story .tres: quoted values
for path in sorted(glob.glob('data/story/*.tres')) + sorted(glob.glob('data/**/*.cfg', recursive=True)):
    p = path.replace('\\', '/')
    for m in re.finditer(r'"((?:[^"\\]|\\.)*)"', open(path, encoding='utf-8').read()):
        s = m.group(1).replace('\\"', '"').replace('\\n', '\n')
        if ' ' in s and not s.startswith('res://'):
            add(p, s)

# 4. code literals: prose-looking strings in the game's scripts (not tools, not tests)
LIT = re.compile(r'"((?:[^"\\\n]|\\.)*)"')
def code_strings(path):
    for n, line in enumerate(open(path, encoding='utf-8').read().split('\n'), 1):
        code = line.split('#', 1)[0] if '"' not in line.split('#', 1)[0] or line.lstrip().startswith('#') else line
        if line.lstrip().startswith('#'):
            continue
        # drop a trailing comment that is outside any string
        out, quoted, i = [], False, 0
        while i < len(line):
            ch = line[i]
            if ch == '\\' and quoted:
                out.append(line[i:i + 2]); i += 2; continue
            if ch == '"':
                quoted = not quoted
            if ch == '#' and not quoted:
                break
            out.append(ch); i += 1
        code = ''.join(out)
        if re.search(r'\b(print|push_warning|push_error|assert|GameLog\.\w+|printerr|_say|_log)\s*\(', code):
            continue
        for m in LIT.finditer(code):
            s = m.group(1).replace('\\"', '"').replace('\\n', '\n').replace('\\t', ' ')
            if ' ' in s.strip() and re.search(r'[A-Za-z]{3}', s) and not s.startswith(('res://', 'user://')) and not re.fullmatch(r'[\w%/.:\- ]*%[sdf][\w%/.:\- ]*', s) and '/' not in s.split(' ')[0]:
                yield n, s
for folder in ['app', 'core', 'ui', 'world', 'scenes']:
    for path in sorted(glob.glob(folder + '/**/*.gd', recursive=True)):
        p = path.replace('\\', '/')
        for n, s in code_strings(path):
            add('%s:%d' % (p, n), s)

with open(OUT + '/text_all.tsv', 'w', encoding='utf-8', newline='\n') as f:
    for source, text in rows:
        f.write(source + '\t' + text.replace('\n', ' / ') + '\n')

# rare words
count = collections.Counter(); where = {}
for source, text in rows:
    plain = re.sub(r'\[[^\]]*\]', ' ', text)  # bbcode
    plain = re.sub(r'\{[^}]*\}|%[-+0-9.]*[sdf]', ' ', plain)
    for w in re.findall(r"[A-Za-z][A-Za-z'’-]*[A-Za-z]|[A-Za-z]", plain):
        k = w.lower().replace('’', "'")
        count[k] += 1
        where.setdefault(k, (source, text))
with open(OUT + '/text_rare_words.txt', 'w', encoding='utf-8', newline='\n') as f:
    for w in sorted(count):
        if count[w] <= 2 and len(w) > 3:
            src, text = where[w]
            i = text.lower().find(w)
            f.write('%s\t%d\t%s\t%s\n' % (w, count[w], src[:60], text[max(0, i - 30):i + len(w) + 30].replace('\n', ' ')))

# mechanical checks
DOUBLED_OK = {'that', 'had', 'very', 'no', 'so', 'yes', 'well', 'ha', 'go', 'bang', 'tick', 'tock', 'clap', 'ding', 'eat', 'work', 'blah', 'la', 'da', 'chef', 'more',
              'never', 'wait', 'nod', 'stamp', 'toro', 'bye', 'now', 'there', 'knock', 'drip', 'tap', 'hush', 'ho', 'hee', 'heh', 'er', 'um', 'oh', 'really', 'far',
              'long', 'one', 'out', 'up', 'down', 'on', 'again', 'run', 'lift', 'rep', 'reps'}
with open(OUT + '/text_mechanical.txt', 'w', encoding='utf-8', newline='\n') as f:
    for source, text in rows:
        probs = []
        if re.search(r'\S  +\S', text):
            probs.append('double space')
        if re.search(r'[A-Za-z] [,;:!?](\s|$)', text) or re.search(r'[A-Za-z] \.(\s|$)', text):
            probs.append('space before punctuation')
        m = re.search(r'\b([A-Za-z]{2,})\s+\1\b', text)
        if m and m.group(1).lower() not in DOUBLED_OK:
            probs.append('doubled word "%s"' % m.group(1))
        if re.search(r',,|\.\.\.\.|;;|!!!!|\?\?\?\?', text):
            probs.append('doubled punctuation')
        if re.search(r"\b(dont|cant|wont|didnt|doesnt|isnt|wasnt|youre|theyre|thats|whats|ive|im)\b", text):
            probs.append('missing apostrophe')
        if re.search(r'\bi\b', text) and 'dialogue' in source:
            probs.append('lower-case i')
        if re.search(r'[.!?] [a-z]', text) and not re.search(r'\.\.\. [a-z]|e\.g\. |i\.e\. |vs\. |etc\. |St\. |Mr\. |Mrs\. |Dr\. |D\.N\.A\. [a-z]', text):
            probs.append('lower-case after a full stop')
        if source.startswith('card:') and source.endswith('rules') and not re.search(r'[.!?")]$', text):
            probs.append('card rules without a final full stop')
        if re.search(r'\bcolor\b|\bcolors\b|\bcolored\b|\barmor\b|\bfavor\b|\bfavorite\b|\bhonor\b|\bneighbor\b|\bcenter\b|\bgray\b', text, re.I) and not source.startswith(('app/', 'core/', 'ui/', 'world/')):
            probs.append('American spelling (the game writes British)')
        if probs:
            f.write('%s\t%s\t%s\n' % (' + '.join(probs), source, text.replace('\n', ' / ')[:300]))
print('%d strings, %d distinct words, %d cards' % (len(rows), len(count), len(cards)))
