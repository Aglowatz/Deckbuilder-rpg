"""Fable Nov 20: the dialogue lines changed tonight, as one CSV for tools/apply_dialogue_pass.js (ID, Zone/Area, Speaker, When it's heard,
Current line, New line) and the id list for --revert. Current lines are read from the game files (run BEFORE applying).
   python tools/nov20_lines.py
   node tools/apply_dialogue_pass.js --csv=docs/dialogue/nov20_lines.csv --apply
   node tools/apply_dialogue_pass.js --csv=docs/dialogue/nov20_lines.csv --revert=docs/dialogue/nov20_lines_ids.txt"""
import csv, json, os

ROOT = os.path.join(os.path.dirname(os.path.abspath(__file__)), '..')
CONTENT = 'data/dungeons/dungeon_content.json'
SCENES = 'data/story/story_scenes.json'
ROWS = [
    # Part 4.1: "The Door Under the Well" - Maren says where the chest is
    (CONTENT + '::quest.side_s_town.offer::1', 'Crosspath', 'Elder Maren', 'The Door Under the Well: offer',
     "I always thought the key was lost, but it wasn't. Somebody hid it in the big chest out east, dearie, on the little spit of land where the lane past the Rift Express stop meets the water. Fetch it and we'll see what that door is for."),
    (CONTENT + '::quest.side_s_town.active::0', 'Crosspath', 'Elder Maren', 'The Door Under the Well: reminder',
     "The key's in the big chest out east, dearie. Go past the Rift Express stop until the lane meets the water, and it's on the little spit of land there. It's marked on your map, so even I could find it."),
    # Part 6: Elowen at the cave mouth after the third zone - she knows exactly who he is; she sees his memories coming back
    (SCENES + '::scenes/cave_mouth_3/steps/1::1', 'Forest (cave mouth)', 'Elowen', 'After the third zone is freed',
     "Three. And you're looking at these woods as though you've stood in them before. It's coming back, isn't it? A room, a voice, the taste of frosting."),
    (SCENES + '::scenes/cave_mouth_3/steps/1::2', 'Forest (cave mouth)', 'Elowen', 'After the third zone is freed',
     "I've waited ten years to see that look, and I swore I wouldn't hurry it. A past that someone hands you is only one more thing they've told you to be."),
    (SCENES + '::scenes/cave_mouth_3/steps/2::1', 'Forest (cave mouth)', 'The Wanderer', 'After the third zone is freed',
     "Bars, white coats, a courtyard. And Maren keeps starting a story about a boy at court. You've known who I am all along, haven't you?"),
    (SCENES + '::scenes/cave_mouth_3/steps/3::1', 'Forest (cave mouth)', 'Elowen', 'After the third zone is freed',
     "I knew a boy who fell on his behind trying to lift a dumbbell twice his size, and who ate the frosting off every layer of his birthday cake. I knew where they took him, too. I got him out."),
    (SCENES + '::scenes/cave_mouth_3/steps/3::2', 'Forest (cave mouth)', 'Elowen', 'After the third zone is freed',
     "You know who you are. Now go free the last zone {villain} holds, and prove it."),
]


def current(line_id):
    path, key, index = line_id.split('::')
    data = json.load(open(os.path.join(ROOT, path), encoding='utf-8'))
    if path == CONTENT:
        return data['text'][key][int(index)]
    node = data
    for part in key.split('/'):
        node = node[int(part)] if isinstance(node, list) else node[part]
    return node[int(index)]


if __name__ == '__main__':
    out = os.path.join(ROOT, 'docs', 'dialogue', 'nov20_lines.csv')
    with open(out, 'w', newline='', encoding='utf-8') as handle:
        writer = csv.writer(handle, quoting=csv.QUOTE_ALL)
        writer.writerow(['ID', 'Zone/Area', 'Speaker', "When it's heard", 'Current line', 'New line'])
        for line_id, area, speaker, when, new in ROWS:
            assert len(new) <= 240, (line_id, len(new))
            writer.writerow([line_id, area, speaker, when, current(line_id), new])
    with open(os.path.join(ROOT, 'docs', 'dialogue', 'nov20_lines_ids.txt'), 'w', newline='\n', encoding='utf-8') as handle:
        handle.write('# Fable Nov 20: lines changed tonight. Revert: node tools/apply_dialogue_pass.js --csv=docs/dialogue/nov20_lines.csv --revert=docs/dialogue/nov20_lines_ids.txt\n')
        for row in ROWS:
            handle.write(row[0] + '\n')
    print('%d rows -> %s' % (len(ROWS), out))
