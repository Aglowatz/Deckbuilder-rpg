"""Fable Nov 21: the dialogue changed tonight.

1. Single lines, as one CSV for tools/apply_dialogue_pass.js (ID, Zone/Area, Speaker, When it's heard, Current line, New line) and the id
   list for --revert. Current lines are read from the tag pre-fable-nov21, so the script can be re-run after applying.
      python tools/nov21_lines.py
      node tools/apply_dialogue_pass.js --csv=docs/dialogue/nov21_lines.csv --apply
      node tools/apply_dialogue_pass.js --csv=docs/dialogue/nov21_lines.csv --revert=docs/dialogue/nov21_lines_ids.txt
2. One scene rewritten whole (the castle gate, `pc_capture`: its steps changed in number, which the line importer cannot express):
      python tools/nov21_lines.py --apply-scenes      (writes the new steps into data/story/story_scenes.json)
      python tools/nov21_lines.py --revert-scenes     (puts the steps of the tag pre-fable-nov21 back)
   Both versions are kept side by side in docs/dialogue/nov21_scene_rewrites.json."""
import csv, json, os, subprocess, sys

ROOT = os.path.join(os.path.dirname(os.path.abspath(__file__)), '..')
TAG = 'pre-fable-nov21'
CONTENT = 'data/dungeons/dungeon_content.json'
SCENES = 'data/story/story_scenes.json'
INTRO = 'data/story/intro_story.tres'
GOURMAND = 'data/story/gourmand_story.tres'
ROWS = [
    # Part 1.5: "The Door Under the Well" - the key has a small chest of its own beside the well
    (CONTENT + '::quest.side_s_town.offer::1', 'Crosspath', 'Elder Maren', 'The Door Under the Well: offer',
     "I always thought the key was lost, but it never went far. It's in the little chest beside the well itself, dearie, and I've walked past it for forty years. My knees don't bend that far now. Fetch it and we'll see what that door is for."),
    (CONTENT + '::quest.side_s_town.active::0', 'Crosspath', 'Elder Maren', 'The Door Under the Well: reminder',
     "The key's in the little chest beside the Old Well, dearie, on the other side from the iron hatch. It's marked on your map, so even I could find it."),
    # Part 8.1: Maren after the fourth zone - her staff: she has leaned on it for as long as she can remember ("never told a soul why" goes)
    (INTRO + '::memory.4.after::3', 'Crosspath', 'Elder Maren', 'After the fourth memory fragment',
     "Four signs in a ring, the same as the ones carved on this staff of mine. I have leaned on it for as long as I can remember, and my fingers have known those four signs longer than my head has."),
    # Part 7.1: the Buffet's sushi side dungeon is "The Raw Deal" (it was Omakase) and stands behind Colonel Casserole's gate
    (CONTENT + '::quest.side_s_gour.done::0', 'The Endless Buffet', 'Basil', 'The Golden Reservation: done',
     "The Raw Deal is open to you now. It's out east, past Colonel Casserole's gate, and you go in through the freezer. You leave your fate to the chef, that's how it works in there. (quietly) Yes, Chef."),
    (GOURMAND + '::sign.mini_dungeon::0', 'The Endless Buffet', 'Sign', 'The board at the sushi spot', "THE RAW DEAL"),
    (GOURMAND + '::sign.mini_dungeon::1', 'The Endless Buffet', 'Sign', 'The board at the sushi spot', "Sushi. Seating: 1. Courses: 3. Enter through the walk-in freezer."),
]

# Part 8.2: Primm's Castle entry. Elowen is being arrested as the Wanderer arrives: he sees her but never reaches her; Plume reads out
# her name and the charges; she shouts to him to stop the Minister and not to follow her; he understands that he must keep out of
# sight and go up, and he listens. (She is rescued in the postgame: scenes/lab_cell4.)
SCENE_REWRITES = {
    'pc_capture': [
        ["", "The castle gate is white and gold and perfectly symmetrical. You are still a street away when guards in polished armour pour out of the gatehouse. They are not coming for you. They already have the hooded woman who pulled you out of the woods."],
        ["NPC-PLUME", "Great news, citizens! The traitor has been located! Please hold your applause until she has been removed."],
        ["NPC-PLUME", "Miss {rescuer_full}! Former junior Path-ologist. The charges: absent without leave, and the removal of one item of laboratory property, which has been walking about ever since."],
        ["@set", "rescuer_named"],
        ["NPC-PLUME", "Now don't fret, Miss Vey. Your father is ever so understanding about these things. Take her home, gentlemen, and do take the long way round."],
        ["", "You start to run. She finds you across the whole width of the square, over the guards' shoulders, and shakes her head once."],
        ["NPC-ELOWEN", "Don't follow me, {wanderer}! Stay out of sight and get to the top of that castle. Stop {villain}! It's the only way any of this ends."],
        ["", "They have her through a side door before you are halfway there, and on this side the door has no handle at all. Nobody at the gate has looked your way yet."],
        ["NPC-PLAYER", "{rescuer}. I had to learn her name from a list of charges. She said not to follow her, and to stop him. So I'll keep out of sight, and I'll go up."],
    ],
}
_cache = {}


def _old_text(path):
    if path not in _cache:
        _cache[path] = subprocess.run(['git', 'show', '%s:%s' % (TAG, path)], cwd=ROOT, capture_output=True, check=True).stdout.decode('utf-8')
    return _cache[path]


def current(line_id):
    path, key, index = line_id.split('::')
    if path.endswith('.tres'):
        for line in _old_text(path).splitlines():
            if line.startswith('"%s": [' % key):
                return json.loads(line[line.index('['):].rstrip().rstrip(','))[int(index)]
        raise KeyError(line_id)
    data = json.loads(_old_text(path))
    if path == CONTENT:
        return data['text'][key][int(index)]
    node = data
    for part in key.split('/'):
        node = node[int(part)] if isinstance(node, list) else node[part]
    return node[int(index)]


def _steps_block(text, scene_id):
    """(start, end) of the JSON array that follows "steps": in the scene `scene_id`."""
    scene = text.index('"%s": {' % scene_id)
    start = text.index('[', text.index('"steps":', scene))
    depth, pos, in_string, escape = 0, start, False, False
    while True:
        ch = text[pos]
        if in_string:
            if escape:
                escape = False
            elif ch == '\\':
                escape = True
            elif ch == '"':
                in_string = False
        elif ch == '"':
            in_string = True
        elif ch == '[':
            depth += 1
        elif ch == ']':
            depth -= 1
            if depth == 0:
                return start, pos + 1
        pos += 1


def write_scenes(use_old):
    path = os.path.join(ROOT, SCENES)
    text = open(path, encoding='utf-8', newline='').read()
    newline = '\r\n' if '\r\n' in text else '\n'
    old = json.loads(_old_text(SCENES))['scenes']
    for scene_id, steps in SCENE_REWRITES.items():
        chosen = old[scene_id]['steps'] if use_old else steps
        for step in chosen:
            for line in step[1:]:
                assert len(line) <= 260, (scene_id, len(line), line[:40])
        start, end = _steps_block(text, scene_id)
        block = json.dumps(chosen, ensure_ascii=False, indent='\t').replace('\n', newline + '\t\t\t')
        text = text[:start] + block + text[end:]
    json.loads(text)
    open(path, 'w', encoding='utf-8', newline='').write(text)
    print('%d scene(s) %s' % (len(SCENE_REWRITES), 'reverted to %s' % TAG if use_old else 'rewritten'))


def write_scene_record():
    old = json.loads(_old_text(SCENES))['scenes']
    record = {scene_id: {'before (tag %s)' % TAG: old[scene_id]['steps'], 'after (Fable Nov 21)': steps} for scene_id, steps in SCENE_REWRITES.items()}
    out = os.path.join(ROOT, 'docs', 'dialogue', 'nov21_scene_rewrites.json')
    with open(out, 'w', encoding='utf-8', newline='\n') as handle:
        json.dump(record, handle, ensure_ascii=False, indent='\t')
        handle.write('\n')


if __name__ == '__main__':
    if '--apply-scenes' in sys.argv:
        write_scenes(False)
        write_scene_record()
        sys.exit(0)
    if '--revert-scenes' in sys.argv:
        write_scenes(True)
        sys.exit(0)
    out = os.path.join(ROOT, 'docs', 'dialogue', 'nov21_lines.csv')
    with open(out, 'w', newline='', encoding='utf-8') as handle:
        writer = csv.writer(handle, quoting=csv.QUOTE_ALL)
        writer.writerow(['ID', 'Zone/Area', 'Speaker', "When it's heard", 'Current line', 'New line'])
        for line_id, area, speaker, when, new in ROWS:
            assert len(new) <= 240, (line_id, len(new))
            writer.writerow([line_id, area, speaker, when, current(line_id), new])
    with open(os.path.join(ROOT, 'docs', 'dialogue', 'nov21_lines_ids.txt'), 'w', newline='\n', encoding='utf-8') as handle:
        handle.write('# Fable Nov 21: lines changed tonight. Revert: node tools/apply_dialogue_pass.js --csv=docs/dialogue/nov21_lines.csv --revert=docs/dialogue/nov21_lines_ids.txt\n')
        handle.write('# The castle gate scene (pc_capture) was rewritten whole: python tools/nov21_lines.py --revert-scenes\n')
        for row in ROWS:
            handle.write(row[0] + '\n')
    write_scene_record()
    print('%d rows -> %s' % (len(ROWS), out))
