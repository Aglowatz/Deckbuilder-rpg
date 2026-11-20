"""Fable Nov 21: the dialogue lines changed tonight, as one CSV for tools/apply_dialogue_pass.js (ID, Zone/Area, Speaker, When it's heard,
Current line, New line) and the id list for --revert. Current lines are read from the tag pre-fable-nov21, so the script can be re-run
after applying (rows are added part by part through the night).
   python tools/nov21_lines.py
   node tools/apply_dialogue_pass.js --csv=docs/dialogue/nov21_lines.csv --apply
   node tools/apply_dialogue_pass.js --csv=docs/dialogue/nov21_lines.csv --revert=docs/dialogue/nov21_lines_ids.txt"""
import csv, json, os, subprocess

ROOT = os.path.join(os.path.dirname(os.path.abspath(__file__)), '..')
TAG = 'pre-fable-nov21'
CONTENT = 'data/dungeons/dungeon_content.json'
SCENES = 'data/story/story_scenes.json'
ROWS = [
    # Part 1.5: "The Door Under the Well" - the key has a small chest of its own beside the well
    (CONTENT + '::quest.side_s_town.offer::1', 'Crosspath', 'Elder Maren', 'The Door Under the Well: offer',
     "I always thought the key was lost, but it never went far. It's in the little chest beside the well itself, dearie, and I've walked past it for forty years. My knees don't bend that far now. Fetch it and we'll see what that door is for."),
    (CONTENT + '::quest.side_s_town.active::0', 'Crosspath', 'Elder Maren', 'The Door Under the Well: reminder',
     "The key's in the little chest beside the Old Well, dearie, on the other side from the iron hatch. It's marked on your map, so even I could find it."),
]
_cache = {}


def _old(path):
    if path not in _cache:
        text = subprocess.run(['git', 'show', '%s:%s' % (TAG, path)], cwd=ROOT, capture_output=True, check=True).stdout.decode('utf-8')
        _cache[path] = json.loads(text)
    return _cache[path]


def current(line_id):
    path, key, index = line_id.split('::')
    data = _old(path)
    if path == CONTENT:
        return data['text'][key][int(index)]
    node = data
    for part in key.split('/'):
        node = node[int(part)] if isinstance(node, list) else node[part]
    return node[int(index)]


if __name__ == '__main__':
    out = os.path.join(ROOT, 'docs', 'dialogue', 'nov21_lines.csv')
    with open(out, 'w', newline='', encoding='utf-8') as handle:
        writer = csv.writer(handle, quoting=csv.QUOTE_ALL)
        writer.writerow(['ID', 'Zone/Area', 'Speaker', "When it's heard", 'Current line', 'New line'])
        for line_id, area, speaker, when, new in ROWS:
            assert len(new) <= 240, (line_id, len(new))
            writer.writerow([line_id, area, speaker, when, current(line_id), new])
    with open(os.path.join(ROOT, 'docs', 'dialogue', 'nov21_lines_ids.txt'), 'w', newline='\n', encoding='utf-8') as handle:
        handle.write('# Fable Nov 21: lines changed tonight. Revert: node tools/apply_dialogue_pass.js --csv=docs/dialogue/nov21_lines.csv --revert=docs/dialogue/nov21_lines_ids.txt\n')
        for row in ROWS:
            handle.write(row[0] + '\n')
    print('%d rows -> %s' % (len(ROWS), out))
