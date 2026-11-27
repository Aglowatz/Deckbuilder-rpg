#!/usr/bin/env python3
"""Nov 26 night (Part A2): Octavia's five deck-building puzzles for the Shuffle House's arena quest line.

Rerunnable. Writes:
  - data/arena/deck_puzzles.json      the puzzles' words, order, quest step, reward, Octavia's hint, and the sim decks
  - data/encounters/modifiers.json    each puzzle's house rules under "arena:<id>" (tagged "nov26n": true)
  - data/encounters/encounter_scripts.json  each puzzle's timed moments under the same key
  - docs/dialogue/nov26n_lines.csv    every new line (rule names and texts, beats, hints, quest steps)

Every puzzle opponent plays NO cards: its deck is basic Infrastructure only, so its draws never matter, and everything it does
comes from the rules and timed moments below - the same way, in the same order, every attempt. The player brings their own deck,
gear and items. `tools/deck_puzzle_sim.gd` plays the sim decks listed here against each puzzle.
"""
import csv
import io
import json
import os

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
MODS = os.path.join(ROOT, 'data', 'encounters', 'modifiers.json')
SCRIPTS = os.path.join(ROOT, 'data', 'encounters', 'encounter_scripts.json')
PUZZLES = os.path.join(ROOT, 'data', 'arena', 'deck_puzzles.json')
LINES = os.path.join(ROOT, 'docs', 'dialogue', 'nov26n_lines.csv')

NOTE = lambda who: {"kind": "note", "name": "The House Plays No Cards", "icon": "faithtoken/card-random",
                    "text": "%s's deck is all Infrastructure: no card is ever played from it. Everything that happens is on this list, the same way, in the same order, every time you sit down." % who}

# ---------------------------------------------------------------------------------------------------------------------------
# The five puzzles, easiest first. "rules" go to modifiers.json, "beats" to encounter_scripts.json.
# ---------------------------------------------------------------------------------------------------------------------------
P = []

P.append({
    "id": "deckpuzzle_tea_garden",
    "order": 1,
    "title": "The Tea Garden Grows",
    "enemy_name": "Madame Darjeeling",
    "enemy_hp": 56,
    "basics": "G",
    "ai": "Aggressive",
    "level": 14,
    "quest": "arena_open_table",
    "pitch": "One sprout a turn, and every one of them grows by two. By teatime they are taller than the house.",
    "hint": "Every great oak was a sprout once, darling. The trick is to weed the garden before it learns to bite.",
    "lesson": "You weeded early. A garden that grows every turn is only frightening if you let it get to turn five.",
    "weakness": "the snowball: kill the sprouts while they are small (cheap removal, Toxic blockers, bounce: a token sent back is gone)",
    "reward": {"gold": 150, "xp": 120, "pack": "general_1"},
    "rules": [
        NOTE("Madame Darjeeling"),
        {"kind": "start_of_turn_buff", "atk": 2, "def": 2, "name": "Steeping", "icon": "delapouite/coffee-cup",
         "text": "At the start of each of her turns, every unit she controls gets +2/+2 for good."},
        {"kind": "cannot_block", "name": "Wild Growth", "icon": "delapouite/plant-roots",
         "text": "Her sprouts never block: they only grow, and charge."},
        {"kind": "keyword", "keyword": "bulldoze", "name": "Deep Roots", "icon": "delapouite/tree-roots",
         "text": "Her sprouts have Bulldoze: whatever a blocker can't soak goes through to you."},
        {"kind": "timed_summon", "every": 1, "token": "T-22", "token_name": "Tea Sprout", "token_stats": [1, 1], "token_keywords": [],
         "name": "Tea Time", "icon": "lorc/sprout",
         "text": "Then, each of her turns, a new 1/1 Tea Sprout comes up (it grows from her next turn on)."},
    ],
    "beats": [],
})

P.append({
    "id": "deckpuzzle_velvet_rope",
    "order": 2,
    "title": "Behind the Velvet Rope",
    "enemy_name": "Maurice, Head of Security",
    "enemy_hp": 40,
    "basics": "B",
    "ai": "Aggressive",
    "level": 16,
    "quest": "arena_spin_the_wheel",
    "pitch": "Twenty-four bouncers in six turns, a cover charge every turn, and Maurice drinks for free.",
    "hint": "Twenty-four bouncers and one velvet rope. Nobody gets past them one at a time, darling. All at once, though...",
    "lesson": "Twenty-four bouncers, one sweep. A wall is only a wall until something hits all of it at once.",
    "weakness": "a wall of 1/4 blockers: a board wipe (4 damage to every unit, or destroy them all) clears the lot",
    "reward": {"gold": 200, "xp": 160, "pack": "primary"},
    "rules": [
        NOTE("Maurice"),
        {"kind": "timed_summon", "every": 1, "count": 4, "token": "T-23", "token_name": "Velvet Bouncer", "token_stats": [4, 4],
         "token_keywords": ["wallflower", "swat", "sucker_punch"], "token_art": "res://assets/art/cards/TOK-HOUSESECURITY.webp",
         "name": "Doors Open", "icon": "delapouite/guards",
         "text": "For his first six turns, four 4/4 Velvet Bouncers take their places each turn (Wallflower, Swat and Sucker Punch: they block, flyers too, hit first, and never attack)."},
        {"kind": "always_block", "name": "Nobody Gets Past", "icon": "delapouite/guards",
         "text": "Maurice's bouncers block every attacker they can, every time."},
        {"kind": "start_of_turn_damage", "amount": 2, "name": "Cover Charge", "icon": "delapouite/coins-pile",
         "text": "At the start of each of his turns you pay the cover: you take 2 damage."},
        {"kind": "start_of_turn_heal", "amount": 2, "name": "Comped Drinks", "icon": "lorc/potion-ball",
         "text": "At the start of each of his turns Maurice gains 2 HP."},
    ],
    "beats": [
        {"id": "last_call", "name": "Last Call", "icon": "lorc/padlock", "when": {"type": "turn", "turn": 6}, "open": True,
         "text": "On his turn 6, once that turn's bouncers are in, the doors close: no more Velvet Bouncers arrive after it.",
         "line": "That's capacity. Nobody else comes in. Nobody. Not even the ones already in line.",
         "banner": "Last call: no more Velvet Bouncers.",
         "warn": "Next turn: last call (his last four bouncers come in, then no more).",
         "effects": [{"kind": "remove_rule", "name": "Doors Open"}]},
    ],
})

P.append({
    "id": "deckpuzzle_last_ride",
    "order": 3,
    "title": "The Last Ride",
    "enemy_name": "Dizzy Lizzie, Carousel Queen",
    "enemy_hp": 22,
    "basics": "G",
    "ai": "Aggressive",
    "level": 18,
    "quest": "arena_high_rollers",
    "pitch": "A wall of painted ponies, a pony more every turn, and the ride ends on her seventh turn - whoever is still standing.",
    "hint": "My ponies are lovely, sweetheart, but they never leave the ground. Mind the clock: the music always stops.",
    "lesson": "You went over the ponies (or straight past them) before the music stopped. A wall on the ground is no wall at all from above.",
    "weakness": "a clock and a ground wall: damage that is never blocked (Flying, Elusive, damage straight to her) wins before her turn 7",
    "reward": {"gold": 250, "xp": 200, "pack": "gilded_general"},
    "rules": [
        NOTE("Dizzy Lizzie"),
        {"kind": "starting_tokens", "count": 4, "token": "T-04", "token_name": "Painted Pony", "token_stats": [0, 6], "token_keywords": ["wallflower"],
         "name": "All Aboard", "icon": "delapouite/carnival-mask",
         "text": "She starts with four 0/6 Painted Ponies (Wallflower: they block, they never attack)."},
        {"kind": "timed_summon", "every": 1, "count": 2, "token": "T-04", "token_name": "Painted Pony", "token_stats": [0, 6], "token_keywords": ["wallflower"],
         "name": "Round and Round", "icon": "lorc/flame-spin",
         "text": "Two more 0/6 Painted Ponies join the carousel at the start of each of her turns."},
        {"kind": "always_block", "name": "Hold the Reins", "icon": "lorc/padlock",
         "text": "Her ponies block every attacker they can, every time."},
    ],
    "beats": [
        {"id": "ride_ends", "name": "The Ride Ends", "icon": "delapouite/boombox", "when": {"type": "turn", "turn": 7}, "open": True,
         "text": "At the start of her 7th turn the music stops for good: if Lizzie is still standing, you lose the bout.",
         "line": "And THAT'S the end of the ride! Everybody off! ...Oh dear, you're still on. That's a loss, I'm afraid. House rules.",
         "banner": "The music stops: the ride is over.",
         "warn": "Next turn: the music stops for good. Win this turn or lose the bout.",
         "effects": [{"kind": "defeat_foe"}]},
    ],
})

P.append({
    "id": "deckpuzzle_confetti",
    "order": 4,
    "title": "The Confetti Cannon",
    "enemy_name": "Tilda Tinsel, Confetti Cannoneer",
    "enemy_hp": 38,
    "basics": "R",
    "ai": "Aggressive",
    "level": 20,
    "quest": "arena_two_of_a_kind",
    "pitch": "Two critters a turn, a cannon that pops every unit on the table, and a crowd that cheers every time one of hers falls.",
    "hint": "The crowd adores a tragic exit, darling, and they're not fussy about whose. Count the curtain calls.",
    "lesson": "Her own rule paid you. Every one of YOUR units that fell cost her the cheer she meant for herself.",
    "weakness": "a rule that cuts both ways: the cannon kills your small units too, and every unit of yours that dies costs HER 2 HP",
    "reward": {"gold": 300, "xp": 250, "pack": "gilded_general"},
    "rules": [
        NOTE("Tilda Tinsel"),
        {"kind": "start_of_turn_damage_units", "amount": 1, "whose": "all", "name": "Fire the Cannon!", "icon": "delapouite/party-popper",
         "text": "At the start of each of her turns the cannon goes off: 1 damage to every unit on the table, hers and yours."},
        {"kind": "timed_summon", "every": 1, "count": 2, "token": "T-02", "token_name": "Confetti Critter", "token_stats": [1, 1], "token_keywords": [],
         "token_art": "res://assets/art/cards/TOK-CONFETTI.webp", "name": "Encore!", "icon": "delapouite/sparkles",
         "text": "Then two 1/1 Confetti Critters land on her side, each of her turns."},
        {"kind": "always_block", "name": "Into the Breach", "icon": "delapouite/party-flags",
         "text": "Her critters throw themselves in front of every attacker they can, every time."},
        {"kind": "ally_death_drain", "amount": 2, "name": "Showstopper", "icon": "delapouite/trumpet",
         "text": "Whenever one of HER units dies, you lose 2 HP."},
        {"kind": "ally_death_drain", "amount": 2, "side": "player", "name": "Showstopper (Both Ways)", "icon": "delapouite/trumpet",
         "text": "Whenever one of YOUR units dies, Tilda loses 2 HP. The crowd isn't fussy."},
    ],
    "beats": [],
})

P.append({
    "id": "deckpuzzle_all_in",
    "order": 5,
    "title": "All In",
    "enemy_name": "\"Honest\" Hal Lowball",
    "enemy_hp": 52,
    "basics": "N",
    "ai": "Aggressive",
    "level": 23,
    "quest": "arena_full_house",
    "after_primm": True,
    "pitch": "A pit boss every turn, a sweep of the felt every turn, fifty-two HP - and a dealer who has never once sat at a full table.",
    "hint": "Hal can't abide a crowded table, darling. He's never beaten one. Then again, he's never let one sit down.",
    "lesson": "Seven at the table and Hal folded, fifty-two HP and all. Some fights are won by the count, not the damage.",
    "weakness": "an alternate win: control seven units at once and Hal folds on the spot, however much HP he has left",
    "reward": {"gold": 400, "xp": 300, "pack": "prismatic"},
    "rules": [
        NOTE("Hal"),
        {"kind": "start_of_turn_damage_units", "amount": 2, "whose": "foe", "name": "Sweep the Felt", "icon": "delapouite/trash-can",
         "text": "At the start of each of his turns Hal sweeps the table: 2 damage to each of your units."},
        {"kind": "timed_summon", "every": 1, "token": "T-16", "token_name": "Pit Boss", "token_stats": [3, 4], "token_keywords": ["bulldoze"],
         "token_art": "res://assets/art/cards/TOK-HOUSESECURITY.webp", "name": "The Pit Boss", "icon": "delapouite/strong-man",
         "text": "Then a 3/4 Pit Boss with Bulldoze joins him, each of his turns."},
    ],
    "beats": [
        {"id": "fold", "name": "Hal Folds", "icon": "lorc/poker-hand", "when": {"type": "foe_units_at_least", "count": 7}, "open": True,
         "text": "The moment you control seven or more units at once, Hal folds: you win the bout on the spot, however much HP he has.",
         "line": "Seven? SEVEN? I can't play to a table like that. I fold. I fold! Somebody fetch me a chair. A small one.",
         "banner": "A full table: Hal folds. The pot is yours.",
         "effects": [{"kind": "concede"}]},
    ],
})

# ---------------------------------------------------------------------------------------------------------------------------
# Sim decks: early exploit decks (cards a player can own around the puzzle's level), one late brute-force deck, and the Path
# reference decks (built by the sim from ProgressionModel). Every list is 45+ cards within the copy caps of its level.
# ---------------------------------------------------------------------------------------------------------------------------
# A late player picks gear for the bout (no Crown of Mild Hubris: -10 max HP); the reference decks keep ProgressionModel's own gear.
LATE_KIT = ["saucepan_helmet", "cardboard_cuirass", "glass_jaw_gauntlets", "dog_eared_bookmark", "travelers_boots"]
LATE_BEEF = {"equipment": LATE_KIT, "label": "Late: Beefcake Titans (L25)", "kind": "late", "level": 25, "ai": "Aggressive",
             "cards": {"B-28": 3, "B-13": 3, "B-38": 3, "B-27": 3, "B-29": 3, "B-37": 3, "B-11": 3, "B-26": 3, "B-25": 3, "B-21": 3,
                       "B-32": 2, "B-30": 2, "B-34": 3, "BAS-B": 18}}
LATE_GOUR = {"equipment": LATE_KIT, "label": "Late: Gourmand Golem Kitchen (L25)", "kind": "late", "level": 25, "ai": "Balanced",
             "cards": {"G-33": 2, "G-28": 3, "G-30": 2, "G-32": 1, "G-29": 3, "G-27": 3, "G-12": 3, "G-22": 3, "G-08": 3, "G-25": 3,
                       "G-26": 2, "G-20": 3, "G-05": 3, "BAS-G": 16}}
LATE_REF = {"equipment": LATE_KIT, "label": "Late: Refusemancer Heap (L25)", "kind": "late", "level": 25, "ai": "Balanced",
            "cards": {"R-33": 2, "R-30": 2, "R-29": 2, "R-36": 3, "R-28": 3, "R-27": 2, "R-35": 3, "R-22": 3, "R-25": 3, "R-09": 3,
                      "R-07": 3, "R-05": 3, "BAS-R": 16}}
LATE_NECRO = {"equipment": LATE_KIT, "label": "Late: Necrocrat Board Control (L25)", "kind": "late", "level": 25, "ai": "Balanced",
              "cards": {"N-29": 3, "N-34": 3, "N-15": 3, "N-28": 3, "N-23": 3, "N-03": 3, "N-07": 3, "N-26": 3, "N-06": 3, "N-38": 3,
                        "N-35": 3, "N-27": 2, "N-32": 2, "INF-02": 3, "BAS-N": 15}}

DECKS = {
    "deckpuzzle_tea_garden": [
        {"label": "Exploit: Weed Whacker (Beefcake removal)", "kind": "exploit", "level": 14, "ai": "Balanced",
         "cards": {"B-03": 3, "B-36": 3, "B-15": 3, "B-10": 3, "B-34": 3, "B-24": 3, "B-07": 3, "B-06": 3, "B-12": 3, "B-19": 3, "BAS-B": 16}},
        {"label": "Exploit: Garden Pests (Refusemancer traps)", "kind": "exploit", "level": 14, "ai": "Balanced",
         "cards": {"R-12": 3, "R-14": 3, "R-15": 3, "R-07": 3, "R-09": 3, "R-05": 3, "R-06": 3, "R-21": 3, "R-19": 3, "R-22": 3, "BAS-R": 16}},
        {"label": "Exploit: Kitchen Traps (Gourmand)", "kind": "exploit", "level": 14, "ai": "Balanced",
         "cards": {"G-24": 3, "G-17": 3, "G-16": 3, "G-35": 3, "G-05": 3, "G-04": 3, "G-23": 3, "G-06": 3, "G-07": 3, "G-20": 2, "BAS-G": 17}},
        LATE_BEEF, LATE_NECRO, LATE_GOUR, LATE_REF,
    ],
    "deckpuzzle_velvet_rope": [
        {"label": "Exploit: Bomb Squad (Beefcake)", "kind": "exploit", "level": 16, "ai": "Aggressive",
         "cards": {"B-38": 2, "B-21": 3, "B-34": 3, "B-13": 3, "B-12": 3, "B-11": 3, "B-26": 3, "B-06": 3, "B-07": 3, "B-25": 3, "B-35": 2, "BAS-B": 18}},
        {"label": "Exploit: The Layoff (Necrocrat)", "kind": "exploit", "level": 16, "ai": "Balanced",
         "cards": {"N-29": 2, "N-35": 3, "N-02": 3, "N-06": 3, "N-26": 3, "N-39": 3, "N-23": 2, "N-03": 3, "N-07": 3, "N-15": 3, "N-34": 2, "BAS-N": 18}},
        {"label": "Exploit: Velvet Gloves (Elusive scouts + Beefcake tools)", "kind": "exploit", "level": 16, "ai": "Aggressive",
         "cards": {"C-23": 3, "C-11": 3, "C-26": 3, "B-02": 3, "B-16": 3, "B-18": 3, "B-14": 3, "B-17": 3, "B-21": 3, "B-07": 3, "BAS-B": 18}},
        LATE_BEEF, LATE_NECRO, LATE_GOUR, LATE_REF,
    ],
    "deckpuzzle_last_ride": [
        {"label": "Exploit: Flying Circus (Necrocrat flyers)", "kind": "exploit", "level": 18, "ai": "Aggressive",
         "cards": {"N-06": 3, "N-26": 3, "N-39": 3, "C-04": 3, "N-08": 3, "C-11": 3, "C-13": 3, "N-02": 3, "N-01": 3, "N-37": 3, "BAS-N": 18}},
        {"label": "Exploit: Burn Notice (Beefcake burn to face)", "kind": "exploit", "level": 18, "ai": "Aggressive",
         "cards": {"B-21": 3, "B-34": 3, "B-25": 3, "B-13": 3, "B-12": 3, "B-26": 3, "B-06": 3, "B-10": 3, "B-35": 3, "B-17": 3, "BAS-B": 18}},
        {"label": "Exploit: Ghost Kitchen (Gourmand-Necrocrat flyers)", "kind": "exploit", "level": 18, "ai": "Aggressive",
         "cards": {"GN-07": 2, "GN-04": 3, "GN-12": 2, "G-01": 3, "G-25": 3, "N-06": 3, "N-26": 3, "N-39": 3, "G-34": 3, "GN-01": 3, "BAS-G": 9, "BAS-N": 9}},
        dict(LATE_BEEF, equipment=None), dict(LATE_NECRO, equipment=None), LATE_GOUR, LATE_REF,
    ],
    "deckpuzzle_confetti": [
        {"label": "Exploit: Rat Parade (Refusemancer tokens)", "kind": "exploit", "level": 20, "ai": "Balanced",
         "cards": {"R-35": 3, "R-05": 3, "R-06": 3, "R-23": 3, "R-02": 3, "R-01": 3, "R-37": 3, "R-34": 3, "R-07": 3, "R-09": 3, "BAS-R": 18}},
        {"label": "Exploit: Temp Agency (Necrocrat sacrifice)", "kind": "exploit", "level": 20, "ai": "Balanced",
         "cards": {"N-35": 3, "N-14": 2, "N-20": 3, "N-21": 3, "N-01": 3, "N-02": 3, "N-04": 3, "N-38": 3, "N-23": 3, "N-07": 3, "BAS-N": 18}},
        {"label": "Exploit: Militia Muster (Pathless tokens)", "kind": "exploit", "level": 20, "ai": "Balanced",
         "cards": {"C-22": 3, "C-17": 3, "C-01": 3, "C-04": 3, "C-02": 3, "C-03": 3, "C-05": 3, "C-08": 3, "C-14": 3, "C-13": 3, "BAS-B": 18}},
        LATE_BEEF, LATE_NECRO, LATE_GOUR, LATE_REF,
    ],
    "deckpuzzle_all_in": [
        {"label": "Exploit: Full Table (Refusemancer-Necrocrat swarm)", "kind": "exploit", "level": 23, "equipment": LATE_KIT, "ai": "Balanced",
         "cards": {"R-35": 3, "NR-01": 3, "NR-09": 3, "NR-06": 3, "R-05": 3, "N-35": 3, "R-06": 3, "N-02": 3, "R-23": 3, "N-01": 3, "BAS-R": 9, "BAS-N": 9}},
        {"label": "Exploit: Brick Wall (Gourmand walls)", "kind": "exploit", "level": 23, "equipment": LATE_KIT, "ai": "Balanced",
         "cards": {"G-04": 3, "C-05": 3, "G-23": 3, "G-06": 3, "G-07": 3, "G-03": 3, "G-12": 3, "G-28": 2, "G-25": 3, "R-09": 3, "BAS-G": 15, "BAS-R": 3}},
        {"label": "Exploit: Mercenary Company (Pathless tokens)", "kind": "exploit", "level": 23, "equipment": LATE_KIT, "ai": "Balanced",
         "cards": {"C-22": 3, "C-17": 3, "N-35": 3, "C-05": 3, "C-08": 3, "C-09": 3, "C-03": 3, "N-23": 3, "N-04": 3, "N-07": 3, "BAS-N": 18}},
        LATE_BEEF, LATE_NECRO, LATE_GOUR, LATE_REF,
    ],
}


def load(path):
    return json.load(io.open(path, encoding='utf-8'))


def save(path, data):
    os.makedirs(os.path.dirname(path), exist_ok=True)
    io.open(path, 'w', encoding='utf-8', newline='\n').write(json.dumps(data, indent='\t', ensure_ascii=False) + '\n')


def main():
    mods = load(MODS)
    scripts = load(SCRIPTS)
    rows = []
    puzzles = {}
    for p in P:
        key = "arena:%s" % p["id"]
        rules = []
        for index, rule in enumerate(p["rules"]):
            entry = dict(rule)
            entry["nov26n"] = True
            rules.append(entry)
            rows.append(("data/encounters/modifiers.json::%s/%d/name" % (key, index), p["title"], "(rule badge)", "Before the fight: rule name", entry["name"]))
            rows.append(("data/encounters/modifiers.json::%s/%d/text" % (key, index), p["title"], "(rule badge)", "Before the fight: rule text", entry["text"]))
        mods[key] = rules
        if p["beats"]:
            beats = []
            for beat in p["beats"]:
                entry = dict(beat)
                entry["nov26n"] = True
                beats.append(entry)
                for field in ("name", "text", "line", "banner", "warn"):
                    if field in entry:
                        speaker = p["enemy_name"] if field == "line" else "(scripted beat)"
                        rows.append(("data/encounters/encounter_scripts.json::%s/%s/%s" % (key, entry["id"], field), p["title"], speaker, "In the bout: %s" % field, entry[field]))
            scripts[key] = beats
        elif key in scripts:
            del scripts[key]
        meta = {k: p[k] for k in ("order", "title", "enemy_name", "enemy_hp", "basics", "ai", "level", "quest", "pitch", "hint", "lesson", "weakness", "reward")}
        meta["after_primm"] = bool(p.get("after_primm", False))
        meta["sim_decks"] = [{k: v for k, v in d.items() if v is not None} for d in DECKS[p["id"]]]
        puzzles[p["id"]] = meta
        for field, when in (("title", "Puzzle table name"), ("pitch", "The puzzle's line on the Puzzle Tables board"), ("hint", "Octavia's hint in the Before the fight panel"), ("lesson", "After a win")):
            rows.append(("data/arena/deck_puzzles.json::%s/%s" % (p["id"], field), p["title"], "Octavia Eightfold" if field in ("hint", "pitch", "lesson") else "(title)", when, p[field]))
    for p in P:
        rows.append(("core/draft/draft_arena_quests.gd::%s/puzzle_step" % p["quest"], p["title"], "(quest step)", "The quest log: the level's last step",
                     "Win Octavia's puzzle table \"%s\"" % p["title"]))
        if p["order"] == 1:
            extra = "Octavia also keeps a puzzle table at this level, \"%s\": bring your own deck and find the trick." % p["title"]
        else:
            extra = "Octavia's puzzle table for this level is \"%s\" (it opens once you have won table %d): bring your own deck and find the trick." % (p["title"], p["order"] - 1)
        rows.append(("core/draft/draft_arena_quests.gd::%s/puzzle_summary" % p["quest"], p["title"], "(quest summary)", "The quest log: added to the summary", extra))
    save(MODS, mods)
    save(SCRIPTS, scripts)
    save(PUZZLES, {"_about": "Nov 26 night (Part A2): Octavia's deck-building puzzles (DeckPuzzles). Written by tools/nov26n_deck_puzzles.py; the rules are in data/encounters/modifiers.json and encounter_scripts.json under arena:<id>.", "puzzles": puzzles})
    os.makedirs(os.path.dirname(LINES), exist_ok=True)
    with io.open(LINES, 'w', encoding='utf-8-sig', newline='') as handle:
        writer = csv.writer(handle, quoting=csv.QUOTE_ALL)
        writer.writerow(["ID", "Zone/Area", "Speaker", "When it's heard", "Current line", "New line"])
        for row in rows:
            writer.writerow([row[0], "The Shuffle House, Puzzle Tables: " + row[1], row[2], row[3], "", row[4]])
    print("wrote %d puzzles, %d lines" % (len(P), len(rows)))


if __name__ == '__main__':
    main()
