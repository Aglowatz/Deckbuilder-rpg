"""Fable Nov 21 castle: the dialogue and story text written or changed in this pass, as one sheet, and its revert.

   python tools/nov21c_lines.py            -> docs/dialogue/nov21c_lines.csv (ID, Zone/Area, Speaker, When it's heard, Current line,
                                              New line; "Current line" is the text at the tag pre-fable-nov21-castle, empty for a new
                                              line) and docs/dialogue/nov21c_lines_ids.txt
   python tools/nov21c_lines.py --revert   -> puts every listed line back to its text at the tag (a line that is new is removed):
                                              the eight ally scenes, Gary's and Chet Thunderabs's freed lines, Primm's three phase
                                              lines, the two loading tips and the level-30 headline. Give --only=<id prefix> for a part.
   The choice rooms' texts in data/dungeons/dungeon_content.json (D-PC) are listed for reading but belong to the new map: reverting
   them means reverting the map (git revert of the Parts 2 to 4 commit), not this tool.
   What is compared: data/story/story_scenes.json (scene -> steps), the "key": [lines] entries of data/story/gainlands_story.tres and
   capital_story.tres, data/loading/loading_tips.txt, the D-PC block and data/progression/level_track.json's headlines."""
import csv, io, json, os, re, subprocess, sys

ROOT = os.path.join(os.path.dirname(os.path.abspath(__file__)), '..')
TAG = 'pre-fable-nov21-castle'
SCENES = 'data/story/story_scenes.json'
TRES = ['data/story/gainlands_story.tres', 'data/story/capital_story.tres']
TIPS = 'data/loading/loading_tips.txt'
CONTENT = 'data/dungeons/dungeon_content.json'
TRACK = 'data/progression/level_track.json'
SPEAKERS = {'NPC-FLEX': 'Grandmaster Flex', 'NPC-ESCOFFINA': 'The Grand Chef', 'NPC-AGNES': 'Agnes Overdue', 'NPC-COMPOSTELLA': 'Archdruid Compostella',
            'NPC-PLAYER': 'The Wanderer', '': '(narration)'}
ZONES = {'beefcake': 'Beefcake wing', 'gourmand': 'Gilded Pantry', 'necrocrat': 'Necrocrat wing', 'refusemancer': 'Refusemancer wing'}


def now(path):
    return io.open(os.path.join(ROOT, path), encoding='utf-8', newline='').read()


def old(path):
    return subprocess.run(['git', 'show', '%s:%s' % (TAG, path)], cwd=ROOT, capture_output=True, check=True).stdout.decode('utf-8')


def tres_entries(text):
    """key -> (start, end, [lines]) for every "key": [ ... ] entry of a story .tres."""
    found = {}
    decoder = json.JSONDecoder()
    for match in re.finditer(r'^"([^"\n]+)": (?=\[)', text, re.M):
        try:
            value, length = decoder.raw_decode(text[match.end():])
        except ValueError:
            continue
        if isinstance(value, list) and all(isinstance(item, str) for item in value):
            found[match.group(1)] = (match.start(), match.end() + length, value)
    return found


def rows():
    out = []
    # the ally scenes (and any other scene changed)
    new_scenes = json.loads(now(SCENES))['scenes']
    old_scenes = json.loads(old(SCENES))['scenes']
    for key, scene in new_scenes.items():
        before = old_scenes.get(key, {}).get('steps', [])
        if scene.get('steps') == before:
            continue
        zone = next((ZONES[z] for z in ZONES if z in key), '')
        when = "Primm's Castle, %s: %s the fight (only when that zone is freed)" % (zone, 'before' if key.endswith('before') else 'after')
        for step_index, step in enumerate(scene['steps']):
            for line_index, line in enumerate(step[1:]):
                was = before[step_index][1 + line_index] if step_index < len(before) and 1 + line_index < len(before[step_index]) else ''
                if was != line:
                    out.append(['%s::scenes/%s/steps/%d::%d' % (SCENES, key, step_index, line_index), "Primm's Castle", SPEAKERS.get(step[0], step[0]), when, was, line])
    # the story files
    for path in TRES:
        new_entries = tres_entries(now(path))
        old_entries = tres_entries(old(path))
        area = 'The Gainlands (freed)' if 'gainlands' in path else "Primm's Castle"
        for key, (_s, _e, lines) in new_entries.items():
            before = old_entries.get(key, (0, 0, []))[2]
            if lines == before:
                continue
            speaker = 'Gary' if 'gary' in key else ('Chet Thunderabs' if 'minigame' in key else ('Rules text' if key.startswith('boss.phase') else ''))
            for index, line in enumerate(lines):
                was = before[index] if index < len(before) else ''
                if was != line:
                    out.append(['%s::%s::%d' % (path, key, index), area, speaker, key, was, line])
    # the loading tips
    old_tips = old(TIPS).replace('\r\n', '\n').split('\n')
    for index, line in enumerate(now(TIPS).replace('\r\n', '\n').split('\n')):
        if index < len(old_tips) and old_tips[index] != line and not line.startswith('#'):
            out.append(['%s::line::%d' % (TIPS, index + 1), 'Loading screens', '(tip)', 'A loading tip', old_tips[index], line])
    # the level track's headline
    for index, (was, line) in enumerate(zip(re.findall(r'"headline": "([^"]*)"', old(TRACK)), re.findall(r'"headline": "([^"]*)"', now(TRACK)))):
        if was != line:
            out.append(['%s::headline::%d' % (TRACK, index), 'Level-up screen', '(headline)', 'Level reward headline', was, line])
    # the castle's choice rooms (for reading; they belong to the new map)
    block = json.loads(now(CONTENT))['dungeons']['D-PC']
    before_block = json.loads(old(CONTENT))['dungeons']['D-PC']
    old_texts = set()
    for event in before_block.get('events', {}).values():
        old_texts.add(event.get('body', ''))
        for choice in event.get('choices', []):
            old_texts.update(choice[:2])
    for number, event in sorted(block.get('events', {}).items(), key=lambda pair: int(pair[0])):
        if 'ref' in event:
            continue
        if event['body'] not in old_texts:
            out.append(['%s::D-PC/events/%s/body' % (CONTENT, number), "Primm's Castle", '(narration)', 'Choice room: %s' % event['title'], '', event['body']])
        for choice_index, choice in enumerate(event['choices']):
            for part, name in ((0, 'choice'), (1, 'result')):
                if choice[part] not in old_texts:
                    out.append(['%s::D-PC/events/%s/%s/%d' % (CONTENT, number, name, choice_index), "Primm's Castle", '(narration)', 'Choice room: %s' % event['title'], '', choice[part]])
    for number, blurb in sorted(block.get('blurbs', {}).items(), key=lambda pair: int(pair[0])):
        out.append(['%s::D-PC/blurbs/%s' % (CONTENT, number), "Primm's Castle", '(map)', 'The room\'s line on the castle map', '', blurb])
    return out


def write():
    table = rows()
    folder = os.path.join(ROOT, 'docs', 'dialogue')
    with io.open(os.path.join(folder, 'nov21c_lines.csv'), 'w', encoding='utf-8', newline='') as handle:
        writer = csv.writer(handle, quoting=csv.QUOTE_ALL, lineterminator='\n')
        writer.writerow(['ID', 'Zone/Area', 'Speaker', "When it's heard", 'Current line', 'New line'])
        writer.writerows(table)
    with io.open(os.path.join(folder, 'nov21c_lines_ids.txt'), 'w', encoding='utf-8', newline='\n') as handle:
        handle.write('# Fable Nov 21 castle: the lines written or changed. Revert: python tools/nov21c_lines.py --revert [--only=<id prefix>]\n')
        handle.write('# (the D-PC choice-room ids are listed for reading; they belong to the new castle map and are not reverted by the tool)\n')
        for row in table:
            handle.write(row[0] + '\n')
    print('%d lines -> docs/dialogue/nov21c_lines.csv' % len(table))


def revert(only):
    done = 0
    # scenes
    text = now(SCENES)
    data = json.loads(text)
    old_scenes = json.loads(old(SCENES))['scenes']
    for key in list(data['scenes'].keys()):
        if only and not ('%s::scenes/%s' % (SCENES, key)).startswith(only):
            continue
        if key not in old_scenes:
            del data['scenes'][key]
            done += 1
        elif data['scenes'][key] != old_scenes[key]:
            data['scenes'][key] = old_scenes[key]
            done += 1
    io.open(os.path.join(ROOT, SCENES), 'w', encoding='utf-8', newline='\n').write(json.dumps(data, ensure_ascii=False, indent='\t') + '\n')
    # the story files, from the last entry backwards so the offsets stay true
    for path in TRES:
        text = now(path)
        old_entries = tres_entries(old(path))
        for key, (start, end, lines) in sorted(tres_entries(text).items(), key=lambda pair: -pair[1][0]):
            if only and not ('%s::%s' % (path, key)).startswith(only):
                continue
            if key not in old_entries:
                line_end = text.index('\n', end) + 1 if '\n' in text[end:] else len(text)
                text = text[:start] + text[line_end:]
                done += 1
            elif old_entries[key][2] != lines:
                text = text[:start] + '"%s": [%s]' % (key, ', '.join(json.dumps(item, ensure_ascii=False) for item in old_entries[key][2])) + text[end:]
                done += 1
        io.open(os.path.join(ROOT, path), 'w', encoding='utf-8', newline='').write(text)
    for path in (TIPS, TRACK):
        if not only or path.startswith(only) or only.startswith(path):
            if now(path) != old(path):
                io.open(os.path.join(ROOT, path), 'w', encoding='utf-8', newline='').write(old(path))
                done += 1
    print('%d entries put back to %s' % (done, TAG))


if __name__ == '__main__':
    if '--revert' in sys.argv:
        revert(next((arg.split('=', 1)[1] for arg in sys.argv if arg.startswith('--only=')), ''))
    else:
        write()
