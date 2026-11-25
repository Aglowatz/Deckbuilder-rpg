"""Fable Nov 21 castle (Parts 2 to 4): writes the new layered map of Primm's Castle into the game's data.
   python tools/castle_nov21.py            -> the dungeon list's D-PC cell (data/source/dungeon_list.csv), data/dungeons/map_layout.json,
                                              the D-PC block of data/dungeons/dungeon_content.json, the castle's encounter rules and
                                              scripts, the four ally scenes and the Pantry Mimic's bestiary entry.
   Then: bash tools/import_dungeons.sh     -> data/dungeons/dungeons.json from the CSV.
   The layout itself (rows, links, room kinds) is the table ROOMS below; tools/castle_plan_nov21.py draws the plan from the same table."""
import csv, io, json, os, sys

ROOT = os.path.join(os.path.dirname(os.path.abspath(__file__)), '..')

# number, name, CSV type, note, row, (x, y) on the painted map (0..1), exits
# Nov 25 (Batch 21, the portrait MAP-PC): the spots are the painted landings as tools/map_curves.py --fit found them, except
# the Castle Gate, which stands in its gateway (its landing is at the picture's bottom edge, where the room's disc and name
# would be cut off). Do not run --fit on D-PC again without putting the gate back.
ROOMS = [
    (1, "Castle Gate", "Start", "story: Elowen is seized on Plume's orders", 0, (0.500, 0.948), [2, 3]),
    (2, "Gilded Pantry", "Elite", "the Pantry Mimic; the Grand Chef's recipe", 1, (0.243, 0.882), [4, 5]),
    (3, "Courtyard of Perfect Hedges", "Battle", "", 1, (0.762, 0.874), [5, 6, 7]),
    (4, "Gourmand Wing: the Doppelganger's Lab Notes", "Event", "", 2, (0.136, 0.779), [8, 9]),
    (5, "Portrait Gallery", "Battle", "", 2, (0.347, 0.775), [8, 9]),
    (6, "Grand Foyer", "Event", "", 2, (0.632, 0.767), [9, 10]),
    (7, "Garden of Uniform Flowers", "Full Heal", "heal for a cost", 2, (0.872, 0.754), [9, 10]),
    (8, "Beefcake Wing: Coup Orders Barracks", "Battle", "ally room: Grandmaster Flex", 3, (0.173, 0.640), [11, 12]),
    (9, "Hall of Mirrors", "Elite", "", 3, (0.501, 0.635), [11, 12, 13]),
    (10, "Correction Ward Cells", "Event", "free prisoners for a boon", 3, (0.844, 0.641), [12, 13]),
    (11, "Necrocrat Wing: Notarized Archives", "Elite", "ally room: Agnes; Percival Plume, his memo reveals Elowen's capture", 4, (0.179, 0.520), [14, 15]),
    (12, "Ministry of Correction", "Battle", "", 4, (0.498, 0.512), [14, 15, 16]),
    (13, "Mirror Maze", "Deck Challenge", "", 4, (0.819, 0.513), [16, 17]),
    (14, "Refusemancer Wing: the Corrupted Seed Vault", "Battle", "ally room: Archdruid Compostella", 5, (0.137, 0.375), [18, 19]),
    (15, "Archive of Good Intentions", "Event", "Primm's journals; young Maren's letter", 5, (0.380, 0.373), [19, 20]),
    (16, "Resistance Safe Room", "Full Heal", "", 5, (0.631, 0.369), [19, 20]),
    (17, "Royal Kitchens", "Treasure", "", 5, (0.869, 0.373), [20, 21]),
    (18, "Primm's Private Gallery", "Treasure", "the painted-over royal portrait", 6, (0.130, 0.216), [22]),
    (19, "Royal Stair", "Elite", "", 6, (0.379, 0.221), [22]),
    (20, "Clocktower Balcony", "Elite", "", 6, (0.634, 0.219), [22]),
    (21, "Royal Vault", "Treasure", "", 6, (0.875, 0.217), [22]),
    (22, "The Model Room", "Boss", "", 7, (0.500, 0.105), []),
]

# Batch 19 (Fable Nov 22 night): the repainted MAP-PC has a landing spot for every room (the coordinates above are their centres) and a
# painted walkway for 30 of the 41 links. These eleven have none, so the game still draws a line for them (map_layout.json,
# "drawn_links"); docs/art/batch20.csv asks for them.
DRAWN_LINKS = [(2, 5), (3, 7), (4, 9), (5, 8), (6, 9), (7, 9), (9, 11), (10, 12), (12, 14), (16, 19), (17, 20)]

BUFFS = ("The Capital's broken-services debuffs (one per faction whose zone isn't freed yet). Perfect Order: each player may play only one "
         "card of each type per turn (one unit, one spell, one trap, one wonder, one tool). Mirrors (the Gilded Pantry and the Hall of "
         "Mirrors only): the first card each player plays each game is copied for the opponent; the copy can be paid with energy of any Path.")


def layout_cell():
    lines = []
    for number, name, kind, note, _row, (x, y), exits in ROOMS:
        label = kind if not note else "%s (%s)" % (kind, note)
        line = "%d. %s - %s - (%d%%, %d%%)" % (number, name, label, round(x * 100), round(y * 100))
        if exits:
            line += " -> " + ", ".join(str(e) for e in exits)
        lines.append(line)
    return "\n".join(lines)


def write_csv():
    path = os.path.join(ROOT, 'data', 'source', 'dungeon_list.csv')
    raw = io.open(path, encoding='utf-8', newline='').read()
    crlf = '\r\n' in raw
    rows = list(csv.reader(io.StringIO(raw)))
    done = False
    for row in rows:
        if row and row[0] == 'D-PC':
            row[10] = layout_cell()
            row[11] = BUFFS
            done = True
    assert done, 'no D-PC row'
    out = io.StringIO()
    csv.writer(out, lineterminator='\r\n' if crlf else '\n').writerows(rows)
    io.open(path, 'w', encoding='utf-8', newline='').write(out.getvalue())


def write_layout():
    """Nov 25: the file is kept compact by tools/map_curves.py, so the rooms are written through the same writer (the text
    surgery of Nov 21 no longer found its anchors). The castle's `drawn_links` stay as the file has them."""
    sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
    import map_curves
    path = os.path.join(ROOT, 'data', 'dungeons', 'map_layout.json')
    text = io.open(path, encoding='utf-8', newline='').read()
    newline = chr(13) + chr(10) if chr(13) in text else chr(10)
    layout = json.loads(text)
    layout['D-PC'] = {str(number): [round(x, 3), round(y, 3)] for number, _n, _k, _note, _row, (x, y), _e in ROOMS}
    out = map_curves.compact(json.dumps(layout, indent=chr(9), ensure_ascii=False))
    io.open(path, 'w', encoding='utf-8', newline='').write(out.replace(chr(10), newline) + (newline if text.endswith(chr(10)) else ''))


REGIME = ["necrocrat", "gourmand"]

CONTENT = {
    "defaults": {
        "archetypes": ["colorless_regime"],
        "icons": ["delapouite/guards", "delapouite/portrait", "delapouite/shinto-shrine-mirror", "delapouite/stamper", "cathelineau/nun-face", "delapouite/book-cover"],
        "ais": ["Balanced", "Defensive", "Aggressive"],
        "infra": 14,
    },
    "boss": {"deck": "colorless_regime", "extra": {}, "hp": 28, "icon": "cathelineau/old-king"},
    "foes": {
        "2": {"name": "The Pantry Mimic", "deck": "gourmand_control", "size": 33, "hp": 36, "icon": "delapouite/chef-toque", "ai": "Balanced"},
        "3": {"name": "Hedge Trimmer Guard", "deck": "colorless_regime", "size": 32, "hp": 24, "mixed": REGIME},
        "5": {"name": "Gallery Curator", "deck": "colorless_regime", "size": 32, "hp": 25, "mixed": REGIME},
        "8": {"name": "Coup Barracks Sergeant", "deck": "necrocrat_beefcake", "size": 32, "hp": 24, "ai": "Aggressive"},
        "9": {"name": "Mirror Knight", "deck": "necrocrat_beefcake", "size": 33, "hp": 23, "icon": "delapouite/shinto-shrine-mirror"},
        "11": {"name": "Percival Plume, Deputy Minister of Good News", "deck": "necrocrat_beefcake", "size": 33, "hp": 24, "icon": "delapouite/trumpet", "ai": "Aggressive"},
        "12": {"name": "Ministry Clerk", "deck": "gourmand_necrocrat", "size": 32, "hp": 25, "icon": "delapouite/stamper"},
        "14": {"name": "Seed Vault Gardener", "deck": "necrocrat_refusemancer", "size": 32, "hp": 24},
        "19": {"name": "Royal Staircase Guard", "deck": "colorless_regime", "size": 35, "hp": 32, "mixed": REGIME, "infra": 11, "extra": {"C-30": 1, "C-32": 1}},
        "20": {"name": "Clocktower Sentinel", "deck": "colorless_regime", "size": 35, "hp": 32, "mixed": REGIME, "infra": 11, "extra": {"C-30": 1, "C-32": 1}},
        "22": "PRIMM_BOSS",
    },
    "events": {
        "4": {
            "title": "The Doppelganger's Lab Notes",
            "body": "A lab table of food notes: a shapeshifter's recipe for becoming a Grand Chef, with an entire page on how to smile like her. The margins are full of practice smiles.",
            "choices": [
                ["Read the notes", "It explains everything, including why the sauce tastes of nothing. There is no Grand Chef in here, only a very good understudy. You read every page, and you walk on knowing a little too well how the next one will move. A jar on the table bites you on the way out.",
                 "boon:Read Ahead|draw=1,next=1", "damage:3"],
                ["Take the samples", "Somebody downstairs will pay for them and nobody upstairs will miss them, which is as much of a plan as you need. One of the jars bites.",
                 "gold:80", "damage:3"],
                ["Practise the smile in the mirror", "The smile comes out perfect, which is horrifying, and your face stays like that for a while. The next guard waves you through to go first, and whoever you send out first is too busy smiling to hit properly.",
                 "boon:Perfect Smile|first=1,next=1", "curse:Stuck Smile|first_unit_atk=-2,next=1"],
            ],
        },
        "6": {
            "title": "Grand Foyer",
            "body": "A portrait of a smiling ruler fills the wall. The floor is so polished you can see yourself, and he is standing behind you in every reflection.",
            "choices": [
                ["Study the portrait", "The smile never changes, and neither, you realise, does anything else in this place. It is strangely restful, and that frightens you more than the guards do. You leave rested, and you keep checking over your shoulder.",
                 "heal:6", "curse:His Eyes Follow|max_hp=-6"],
                ["Pocket a gilded candlestick", "It is heavier than it looks and worth more than it should be, and now it is covered in your fingerprints, in a building that remembers fingerprints.",
                 "gold:80", "curse:Fingerprints Everywhere|max_hp=-7"],
                ["Count the reflections", "There is always one more reflection than there should be. You wave, he waves a moment too late, and you know where to look for him next time. Then the extra one steps out of the floor and goes to tell someone.",
                 "boon:Seen Him First|draw=1,next=1", "curse:One Reflection Too Many|foe_unit=16,next=1"],
            ],
        },
        "7": {
            "title": "Garden of Uniform Flowers",
            "body": "A thousand identical flowers stand in identical rows, and one of them is, very slightly, a different shade of yellow. A gardener's lunch sits on the bench beside it, untouched, with a price pencilled on the paper.",
            "choices": [
                ["Leave the coins and eat the lunch", "Sixty coins go under the stone, where the gardener will find them. It is bread, cheese and an apple, and nobody has improved any of it.",
                 "heal:6", "pay:60"],
                ["Pick the odd one out and eat it", "It tastes of dandelion, bitter and ordinary, and it feels like the first honest thing you have found in the castle. Somebody was watching that flower.",
                 "heal:6", "curse:The Gardeners Noticed|foe_atk=1,next=1"],
                ["Leave the garden as it is", "You count the rows once more and walk on. The odd flower is still there when you look back.",
                 "nothing"],
            ],
        },
        "10": {"ref": "pc_corrected_citizens"},
        "15": {"ref": "pc_early_journals"},
    },
    "challenges": {"13": {"ref": "pc_mirror_test"}},
    "loot": {
        "17": {"gold": 90, "xp": 40, "item": "energy_draught"},
        "18": {"gold": 130, "xp": 60, "item": "vitality_charm"},
        "21": {"gold": 170, "xp": 60, "card": "C-30"},
    },
    "blurbs": {
        "2": "Optional and hard: the Pantry Mimic copies what you play. Beat it for a Gilded Pack and one strong boon for the last fight.",
        "3": "A fight: the Hedge Trimmer Guard keeps the courtyard square.",
        "4": "A choice: the shapeshifter's notes. Something for the next fight, at a price.",
        "5": "A fight: the Gallery Curator and a thousand portraits of one man.",
        "6": "A choice: every reflection in this floor has him in it.",
        "7": "A place to rest: heal 6 HP, for gold or for a drawback.",
        "8": "A fight to hold a line: the Sergeant and his coup orders.",
        "9": "A tougher fight: the Mirror Knight, under the Mirrors rule.",
        "10": "A choice: the Corrected. Sit with them, and they stay with you to the end.",
        "11": "A tougher fight against the clock: Percival Plume and his red tape. Afterwards, the archivists' kettle: heal 6 for a cost.",
        "12": "A fight: the Ministry Clerk has a form for you.",
        "13": "Your deck is put to the test by a mirror that hesitates.",
        "14": "A fight: the Gardener and three spotless statues.",
        "15": "A choice: his early journals. What you read here stays with you to the end.",
        "16": "The resistance keeps a quiet room here: a full heal.",
        "17": "Treasure: the royal kitchens' strongbox.",
        "18": "Treasure: his private gallery, and a painting someone has painted over.",
        "19": "A tougher fight: the Royal Staircase Guard holds the stair.",
        "20": "A tougher fight: the Clocktower Sentinel. Its prize is worth the climb.",
        "21": "Treasure: the Royal Vault.",
    },
    "story_keys": {"1": "pc_gate", "10": "pc_ward", "15": "pc_archive_gate", "18": "pc_gallery", "22": "pc_boss"},
    "sections": {"4": "the Gourmand Wing", "8": "the Beefcake Wing", "11": "the Necrocrat Wing", "14": "the Refusemancer Wing", "20": "the Clocktower"},
    "scenes": {"22": {"before": "primm_intro", "after": "primm_end"}},
    "talks": {"1": {"before": "pc_capture"}, "11": {"before": "pc_plume_memo", "after": "pc_plume_memo_after"}},
}

TRAINEE_ART = "res://assets/art/cards/T-PC-TRAINEE.webp"
STATUE_ART = "res://assets/art/cards/T-PC-STATUE.webp"

RULES = {
    "The Pantry Mimic": [
        {"name": "Mimicry", "text": "The first unit you play each turn is copied for the Mimic.", "icon": "delapouite/chef-toque", "side": "player", "harmful": True, "kind": "mirror_first_unit"},
        {"name": "Well Fed", "text": "The Mimic's units get +1/+1. It has eaten the cookbook.", "icon": "delapouite/chef-toque", "kind": "stat", "atk": 1, "def": 1},
    ],
    "Coup Barracks Sergeant": [
        {"name": "Captured Trainees", "text": "Two Captured Trainees (0/3) stand on your side from the start. Keep one alive until the Sergeant's 6th turn begins and the barracks gives up.",
         "icon": "lorc/muscle-up", "side": "player", "kind": "starting_tokens", "token": "T-16", "count": 2, "token_id": "PC-TRAINEE", "token_name": "Captured Trainee",
         "token_stats": [0, 3], "token_keywords": [], "token_text": "One of Flex's trainees, who would not sign. Keep one alive.", "token_art": TRAINEE_ART},
        {"name": "Coup Orders", "text": "The Sergeant's units get +2/+0. They were told to go through the line.", "icon": "lorc/crossed-swords", "kind": "stat", "atk": 2, "def": 0},
    ],
    "Percival Plume, Deputy Minister of Good News": [
        {"name": "Great News!", "text": "Plume draws an extra card each turn. There is always another announcement.", "icon": "delapouite/trumpet", "kind": "extra_draws", "count": 1},
        {"name": "Positive Spin", "text": "Plume's units get +1/+1. Everything hits harder in a press release.", "icon": "delapouite/scroll-quill", "kind": "stat", "atk": 1, "def": 1},
    ],
    "Seed Vault Gardener": [
        {"name": "Spotless", "text": "Three Spotless Statues (0/4) stand on the Gardener's side from the start. Destroy all three and the vault is yours.",
         "icon": "delapouite/plant-seed", "kind": "starting_tokens", "token": "T-16", "count": 3, "token_id": "PC-STATUE", "token_name": "Spotless Statue",
         "token_stats": [0, 4], "token_keywords": [], "token_text": "Polished every morning. It keeps the damp out.", "token_art": STATUE_ART},
        {"name": "Waxed and Polished", "text": "The Gardener's own units get +1/+1 (the statues do not).", "icon": "lorc/crossed-swords", "kind": "stat", "atk": 1, "def": 1, "non_tokens": True},
    ],
}

SCRIPTS = {
    "Coup Barracks Sergeant": [
        {"id": "hold", "open": True, "name": "Hold the Line", "icon": "lorc/muscle-up", "when": {"type": "turn", "turn": 6, "if_foe_controls": "PC-TRAINEE"},
         "text": "When the Sergeant's 6th turn begins, if a Captured Trainee is still alive, the barracks gives up and you win.",
         "line": "They're still standing? Nobody told me they would still be standing.",
         "effects": [{"kind": "concede", "if_foe_controls": "PC-TRAINEE"}],
         "warn": "Next turn: if a Captured Trainee still stands, the barracks gives up.",
         "banner": "The line held. The barracks gives up."},
    ],
    "Percival Plume, Deputy Minister of Good News": [
        {"id": "spin", "name": "Positive Spin", "icon": "delapouite/trumpet", "when": {"type": "hp_below", "pct": 50},
         "text": "At half health Plume announces that he is fine: he heals 2.",
         "line": "Great news, citizens! I have been approved to feel fine!",
         "effects": [{"kind": "heal", "amount": 2}], "banner": "Plume heals 2."},
        {"id": "deadline", "open": True, "name": "Filing Deadline", "icon": "delapouite/alarm-clock", "when": {"type": "turn", "turn": 12},
         "text": "When Plume's 12th turn begins the office closes and you lose the duel. Win before then.",
         "line": "And that is the end of the filing day! Do come back tomorrow. There is always a tomorrow, we have a great many in stock.",
         "effects": [{"kind": "defeat_foe"}],
         "warn": "Next turn: the filing deadline. Win now, or the office closes and the duel is lost.",
         "banner": "The filing day is over. The office is closed."},
    ],
    "Seed Vault Gardener": [
        {"id": "polish", "open": True, "name": "Clean Out the Polish", "icon": "delapouite/plant-seed", "when": {"type": "units_died", "count": 3, "card": "PC-STATUE"},
         "text": "When all three Spotless Statues are destroyed, the Gardener has nothing left to guard: you win.",
         "line": "You've let the damp in. Do you know how long it takes to wax a seed?",
         "effects": [{"kind": "concede"}],
         "banner": "The last statue falls. The vault is yours."},
    ],
}

SCENES = {
    "pc_ally_beefcake_before": [
        ["", "The Beefcake wing is a barracks with the coup orders still pinned to the door, signed and countersigned. Behind the bars at the far end, a dozen young lifters sit in rows with their hands on their knees, as they have been told to."],
        ["NPC-FLEX", "There you are, son. Those are my trainees in there, the ones who would not sign. The Sergeant means to march them out in front of his line when the bell rings, so that anyone who comes for him has to go through them.",
         "I got two of them out before he noticed me. I'm an old man who walked here from the Gainlands, and that was as much as I had in me today."],
        ["NPC-FLEX", "Stand with those two until his sixth turn begins, and the rest of that barracks will see that a line can hold. They've only ever been shown the other thing."],
        ["NPC-PLAYER", "And if it doesn't hold?"],
        ["NPC-FLEX", "Then we shall have learned how much we can carry, my boy, and that is worth knowing too. Breathe in. Hold."],
    ],
    "pc_ally_beefcake_after": [
        ["", "The Sergeant's men put their shields down one at a time, the way people put down something heavy they were never sure they wanted. The cell doors open. Nobody cheers. A dozen young lifters stand up and stretch."],
        ["NPC-FLEX", "Well held, son. You kept your feet under you and you kept those two behind you, and that is the whole of the lesson. Most people take years over the second half.",
         "I told myself I had come only for the children. Then I watched you stand there, and I find I have one more lift in me after all."],
        ["NPC-FLEX", "When you face him in the Model Room, give me a moment to get up the stairs. My knees spent ten years in a cell. I'll be beside you by your second turn, and I won't be leaving before you do."],
    ],
    "pc_ally_gourmand_before": [
        ["", "The Gilded Pantry is gold from floor to ceiling, and every jar on every shelf is labelled in the same neat hand: PERFECTED. A woman in a flour-dusted apron stands in the doorway with a ladle, glaring at a cupboard."],
        ["NPC-ESCOFFINA", "Don't touch anything. Have you eaten? No, of course you haven't, and you won't in here, because nothing in this room is food.",
         "My recipe book is in that cupboard. Forty years of dinners in my own hand, gravy stains and all. They took it when they took my kitchen, and they fed it to that thing so it could learn to cook like me."],
        ["", "The cupboard opens one door, like an eye. Something inside it wears your face for a moment, and then hers."],
        ["NPC-ESCOFFINA", "It copies whatever is put in front of it. It has never once made anything up. Go on, show it something it hasn't seen before, and fetch my book out while it's still chewing."],
    ],
    "pc_ally_gourmand_after": [
        ["", "The Mimic folds up like a napkin and is only a cupboard again. On its bottom shelf lies a fat book held shut with butcher's string, a little chewed at one corner."],
        ["NPC-ESCOFFINA", "There you are, you silly old thing. Look at that, it's had the corner off the soup chapter. I never did like that chapter.",
         "That creature could copy every dish I ever made and it still couldn't cook, because it never had anybody to cook for. You do. So you may have a page."],
        ["NPC-ESCOFFINA", "I'll be at your elbow in the Model Room, passing you the next thing before you know you want it. One more card in your hand every turn, and it will be hot."],
    ],
    "pc_ally_necrocrat_before": [
        ["", "A ghost in a cardigan is standing at the archive's front counter with a form in each hand and a third held in her teeth. She takes it out to speak."],
        ["NPC-AGNES", "Oh, it's you, dear. Good. I have an appeal here against the whole of the last ten years: every correction, every transfer, every signature he made in the kingdom's name. It runs to forty thousand pages and I have checked the staples.",
         "It only counts if it is stamped in this room before the filing day closes, and the Deputy Minister has the stamp. He also has the desk, the clock, and a great deal of red tape that he keeps putting in front of people."],
        ["NPC-PLAYER", "What do you need from me?"],
        ["NPC-AGNES", "Get me to that desk before his twelfth turn, dear. After that the office is closed and they tell you to come back tomorrow. I have been told to come back tomorrow for forty years."],
    ],
    "pc_ally_necrocrat_after": [
        ["", "Agnes floats through the wreck of the Deputy Minister's desk, picks the stamp out of the inkwell, breathes on it and brings it down once. The sound is small. Every drawer in the archive slides open an inch."],
        ["NPC-AGNES", "Filed. Received. Accepted. I have never seen all three words on one page before. I think I shall have to sit down, and I haven't needed to sit down since I died.",
         "It doesn't undo what he did, dear. Paper never does. But from this minute nothing he signed is valid, and valid was the only thing he ever had."],
        ["NPC-AGNES", "I have found you a technicality for the Model Room as well. Anything of yours that isn't a unit is now filed as pre-approved, so it costs you one less. Don't thank me, dear. Sign here."],
    ],
    "pc_ally_refusemancer_before": [
        ["", "The seed vault is the cleanest room you have ever seen. Every seed of the old kingdom lies in a glass drawer, polished, numbered and dead. An old woman with bark at her wrists is kneeling by a drain with her sleeves rolled up."],
        ["NPC-COMPOSTELLA", "Mind the floor, child, it's been waxed. Everything in here has been waxed. They polish the seeds every morning so that nothing can get in, and then nothing can get out either, and that is the end of a seed.",
         "There are three of his statues in there holding the polish in. Tip them over and the damp comes back, and the damp is all a seed is ever waiting for."],
        ["NPC-COMPOSTELLA", "I would do it myself, but the last time I couldn't let a thing go, half the Dump went with me. Knock down all three and the Gardener will have nothing left to guard. I'll be right here, making a mess."],
    ],
    "pc_ally_refusemancer_after": [
        ["", "The Gardener's wall is down, and what is left of the statues lies about the floor like broken plates. For a moment nothing happens. Then a drawer near the floor clicks, and a thread of green as thin as a hair comes out of it and has a look round."],
        ["NPC-COMPOSTELLA", "There. Did you hear that? No, you wouldn't, you're young. That was ten years of holding its breath.",
         "He thought clean meant safe. I thought keeping meant loving, so I have no business scolding him. But nothing grows in a room where nothing is allowed to rot."],
        ["NPC-COMPOSTELLA", "I've put a pinch of this floor in your pocket, the good dirty part. Whatever you set down in front of him will stand a little taller for it, one more in the arm and one more in the roots. Even him, child. Especially him."],
    ],
}

BESTIARY = {"name": "The Pantry Mimic", "kind": "elite", "where": "Primm's Castle", "icon": "delapouite/chef-toque",
            "blurb": "A cupboard that learned to cook by eating the cookbook. It copies whatever is put in front of it and has never once made anything up."}


def tabs(obj):
    return json.dumps(obj, ensure_ascii=False, indent='\t')


def write_json(path, mutate):
    full = os.path.join(ROOT, path)
    data = json.load(io.open(full, encoding='utf-8'))
    mutate(data)
    io.open(full, 'w', encoding='utf-8', newline='\n').write(tabs(data) + '\n')


def main():
    write_csv()
    write_layout()
    if '--layout' in sys.argv:  # Batch 19: only the room coordinates and the drawn links (then: bash tools/import_dungeons.sh)
        print('castle layout written; now run: bash tools/import_dungeons.sh')
        return

    def content(data):
        data['dungeons']['D-PC'] = CONTENT
    write_json('data/dungeons/dungeon_content.json', content)

    def rules(data):
        for key, value in RULES.items():
            data[key] = value
    write_json('data/encounters/modifiers.json', rules)

    def scripts(data):
        for key, value in SCRIPTS.items():
            data[key] = value
    write_json('data/encounters/encounter_scripts.json', scripts)

    def scenes(data):
        for key, steps in SCENES.items():
            data['scenes'][key] = {"steps": steps}
    write_json('data/story/story_scenes.json', scenes)

    # the bestiary keeps one entry a line: insert the Mimic's line before the Mirror Knight's
    path = os.path.join(ROOT, 'data', 'bestiary', 'bestiary.json')
    text = io.open(path, encoding='utf-8').read()
    if '"The Pantry Mimic"' not in text:
        at = text.index('{"name": "Mirror Knight"')
        line_start = text.rindex(chr(10), 0, at) + 1
        indent = text[line_start:at]
        text = text[:line_start] + indent + json.dumps(BESTIARY, ensure_ascii=False) + ',' + chr(10) + text[line_start:]
        io.open(path, 'w', encoding='utf-8', newline=chr(10)).write(text)
    print('castle data written; now run: bash tools/import_dungeons.sh')


if __name__ == '__main__':
    main()
