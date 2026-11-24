"""Fable Nov 24 (Part 4): the Shuffled Halls made static. Every fight room of D-SHUFFLE gets a hand-made encounter like the other
dungeons have: a fixed deck in its own Paths (whatever the player drafted), fixed equipment, its own rules and scripted moments.
Writes, idempotently:
  - data/dungeons/dungeon_content.json     D-SHUFFLE: the ten foes ("cards" = the exact deck, "equipment", "skill", "hp_vs_player"),
                                           the blurbs, and room 18 as an event: the Counting Halls, the optional cash-out
  - data/dungeons/postgame_dungeons.json   room 18 is an event room named "The Counting Halls"; the dungeon's story text
  - data/encounters/modifiers.json         each foe's standing rules
  - data/encounters/encounter_scripts.json each foe's scripted moments
    python tools/nov24_shuffled_halls.py
A foe's HP is the player's base HP plus "hp_vs_player" (a draft is played at the base HP of the player's level, so a fixed number
would be a wall at level 12 and a push-over at level 30); everything else about the encounter is fixed. The numbers were set
with tools/halls_sim.gd (docs/design/sim/nov24/halls_rooms.md)."""
import io
import json
import os

ROOT = os.path.join(os.path.dirname(os.path.abspath(__file__)), '..')
DUNGEON = 'D-SHUFFLE'

MAURICE = 'Maurice, Head of Security'
TILDA = 'Tilda Tinsel, Confetti Cannoneer'
DARJEELING = 'Madame Darjeeling'
HAL = '"Honest" Hal Lowball'
TREY = 'Trey Pickett'
LIZZIE = 'Dizzy Lizzie, Carousel Queen'
FINEPRINT = 'Professor Fineprint'
DEX = 'Dex Shufflewick'
PENNY = 'Penny Sleeves'
OCTAVIA = 'Octavia Eightfold'


def deck(basics, cards):
    made = dict(basics)
    made.update(cards)
    return made


FOES = {
    # ---- column 1: the two gates (the same strength; a single Path each)
    '2': {'name': MAURICE, 'ai': 'Aggressive', 'icon': 'delapouite/guards', 'skill': 'normal', 'hp': 18, 'hp_vs_player': -9,
          'paths': 'Beefcake', 'equipment': ['tinkers_wrench'],
          'cards': deck({'BAS-B': 13}, {'B-01': 2, 'B-05': 2, 'B-07': 2, 'B-08': 2, 'B-09': 1, 'B-10': 2, 'B-11': 2, 'B-12': 1, 'B-03': 2, 'B-14': 1})},
    '3': {'name': TILDA, 'ai': 'Balanced', 'icon': 'delapouite/party-popper', 'skill': 'normal', 'hp': 18, 'hp_vs_player': -9,
          'paths': 'Refusemancer', 'equipment': ['lucky_dice'],
          'cards': deck({'BAS-R': 13}, {'R-06': 2, 'R-02': 2, 'R-05': 2, 'R-35': 2, 'R-04': 1, 'R-07': 2, 'R-08': 2, 'R-14': 1, 'R-19': 1, 'R-21': 1, 'R-37': 1})},
    # ---- column 2
    '5': {'name': DARJEELING, 'ai': 'Defensive', 'icon': 'delapouite/coffee-cup', 'skill': 'normal', 'hp': 19, 'hp_vs_player': -8,
          'paths': 'Gourmand', 'equipment': ['steady_sandals'],
          'cards': deck({'BAS-G': 13}, {'G-01': 2, 'G-06': 2, 'G-04': 2, 'G-07': 2, 'G-08': 1, 'G-12': 1, 'G-13': 1, 'G-15': 1, 'G-05': 2, 'G-17': 1, 'G-25': 1, 'G-21': 1})},
    # ---- column 3
    '7': {'name': HAL, 'ai': 'Defensive', 'icon': 'lorc/poker-hand', 'skill': 'normal', 'hp': 19, 'hp_vs_player': -8,
          'paths': 'Necrocrat', 'equipment': ['rolled_rulebook'],
          'cards': deck({'BAS-N': 13}, {'N-01': 2, 'N-02': 2, 'N-06': 2, 'N-05': 2, 'N-03': 1, 'N-38': 1, 'N-15': 2, 'N-11': 1, 'N-36': 1, 'N-18': 1, 'N-14': 1, 'N-07': 1})},
    '8': {'name': TREY, 'ai': 'Aggressive', 'icon': 'faithtoken/card-pick', 'skill': 'elite', 'hp': 24, 'hp_vs_player': -3,
          'paths': 'Beefcake, Refusemancer and Pathless', 'equipment': ['first_pick_fedora', 'card_sleeve_gauntlets'],
          'cards': deck({'BAS-B': 7, 'BAS-R': 7}, {'C-40': 2, 'C-37': 2, 'C-39': 2, 'R-37': 2, 'B-38': 1, 'BR-02': 2, 'BR-03': 2, 'B-06': 2, 'R-07': 1, 'B-10': 1, 'R-21': 1, 'C-06': 2})},
    '10': {'name': LIZZIE, 'ai': 'Aggressive', 'icon': 'lorc/flame-spin', 'skill': 'normal', 'hp': 19, 'hp_vs_player': -8,
           'paths': 'Gourmand and Beefcake', 'equipment': ['practice_foil'],
           'cards': deck({'BAS-G': 7, 'BAS-B': 7}, {'GB-01': 2, 'GB-02': 2, 'GB-03': 1, 'B-01': 2, 'B-06': 2, 'B-12': 2, 'G-01': 2, 'G-06': 1, 'GB-08': 1, 'B-20': 1})},
    # ---- column 4
    '12': {'name': FINEPRINT, 'ai': 'Defensive', 'icon': 'delapouite/scroll-quill', 'skill': 'normal', 'hp': 19, 'hp_vs_player': -8,
           'paths': 'Necrocrat and Gourmand', 'equipment': ['thinking_cap'],
           'cards': deck({'BAS-N': 7, 'BAS-G': 7}, {'GN-02': 2, 'GN-03': 1, 'N-02': 2, 'N-06': 2, 'G-04': 2, 'G-05': 1, 'GN-09': 1, 'N-12': 1, 'G-17': 1, 'GN-17': 1, 'N-15': 1, 'G-07': 1})},
    '14': {'name': DEX, 'ai': 'Balanced', 'icon': 'delapouite/dice-six-faces-six', 'skill': 'elite', 'hp': 24, 'hp_vs_player': -3,
           'paths': 'Necrocrat, Refusemancer and Pathless', 'equipment': ['cheaters_dice', 'shuffle_slippers'],
           'cards': deck({'BAS-N': 7, 'BAS-R': 7}, {'NR-01': 2, 'NR-03': 2, 'NR-02': 1, 'R-35': 2, 'N-02': 2, 'N-06': 1, 'NR-15': 1, 'NR-10': 1, 'NR-06': 1, 'C-38': 2, 'C-22': 1, 'N-15': 1, 'R-07': 1})},
    # ---- column 5
    '15': {'name': PENNY, 'ai': 'Balanced', 'icon': 'delapouite/shop', 'skill': 'normal', 'hp': 19, 'hp_vs_player': -8,
           'paths': 'Beefcake and Necrocrat', 'equipment': ['fair_play_badge'],
           'cards': deck({'BAS-B': 7, 'BAS-N': 7}, {'NB-02': 2, 'NB-17': 2, 'B-05': 2, 'N-02': 2, 'B-08': 1, 'B-11': 1, 'N-05': 1, 'B-02': 1, 'N-08': 1, 'NB-09': 1, 'B-03': 1, 'N-15': 1})},
    '19': OCTAVIA,
}

BOSS = {
    'name': OCTAVIA, 'deck': 'colorless_regime', 'extra': {}, 'hp': 32, 'hp_vs_player': 4, 'icon': 'delapouite/carnival-mask', 'infra': 16, 'setup_turns': 1,
    'ai': 'Balanced', 'skill': 'boss', 'paths': 'all four Paths', 'equipment': ['dealers_visor', 'pathwork_waistcoat'],
    'cards': deck({'BAS-B': 2, 'BAS-G': 2, 'BAS-N': 2, 'BAS-R': 2, 'INF-05': 1, 'INF-06': 1, 'INF-07': 1, 'INF-08': 1, 'INF-09': 1, 'INF-10': 1, 'INF-11': 2},
                  {'P4-04': 1, 'C-29': 1, 'C-24': 2, 'GB-01': 2, 'GN-02': 2, 'NR-01': 2, 'BR-02': 2, 'GR-03': 1, 'NB-02': 2, 'GN-17': 1, 'GN-09': 1, 'NR-10': 1, 'C-38': 1, 'BR-11': 1}),
}

BLURBS = {
    '2': "The left-hand gate. Maurice, Head of Security, and a velvet rope that is not on the guest list either.",
    '3': "The right-hand gate. Tilda Tinsel is loading the confetti cannon, and she does not ask before she fires.",
    '4': "The Trade Counter: a card of two Paths (or a rare one) for a card of your deck.",
    '5': "Madame Darjeeling is taking tea in the garden. She will pour you a cup. Then she will beat you with the pot.",
    '6': "The house kettle is on. A cup costs a little; the free one costs something else.",
    '7': "A quiet game in the back room. \"Honest\" Hal Lowball deals, and the ante is yours to pay.",
    '8': "A champion's table: Trey Pickett holds the Auction Ring. Going once, going twice... Harder, with a better prize.",
    '9': "A stall of lucky charms. Take one; it lasts the whole run.",
    '10': "The carousel turns. Dizzy Lizzie's riders never stop, until the music does.",
    '11': "A prize in chains. Taking it means carrying its curse to the end.",
    '12': "The house rules, shelved floor to ceiling. Professor Fineprint has read them all, and is about to amend one.",
    '13': "The Prize Tent: another Trade Counter, with a rabbit minding it.",
    '14': "A champion's table: Dex Shufflewick runs the Roulette Pit. The wheel spins on his turns. Harder, with a better prize.",
    '15': "A shop of cards nobody is allowed to buy. Penny Sleeves is behind the till: you break it, you bought it.",
    '16': "Sofas, a candle, and the last cup of tea before the Big Wheel.",
    '17': "Cake, on a cart. A slice before the show lasts the whole run.",
    '18': "The Counting Halls: cash out here and leave with part of the prize. Cashing out ends the run, and it is NOT a win.",
    '19': "Boss: Octavia Eightfold at the Big Wheel. The house always deals.",
}

COUNTING_HALLS = {
    'title': 'The Counting Halls',
    'body': "Three long rooms of abacuses, brass scales and clerks in green eyeshades, all counting the house's takings. A cashier's window stands open. The sign over it: CASH OUT HERE. THE HOUSE THANKS YOU FOR PLAYING. In smaller letters: Cashing out ends your run. You leave with part of the prize, and it does not count as a win. The door to the Big Wheel is the other one.",
    'choices': [
        ["Cash out and leave", "The cashier counts it out twice, stamps your hand, and holds the side door for you. You walk out into Crosspath with your winnings and your dignity. Octavia's laugh follows you down the corridor.", "hint:Ends the run. You keep 120 gold, 80 XP and a General Pack, on top of the gold for the fights you won. Not a win: no clear, no card to keep, no first-clear prize."],
        ["Not yet: on to the Big Wheel", "You leave the cashier's window alone. The clerks do not look up. Somebody, somewhere, starts a drum roll.", "nothing"],
    ],
}


def rule(name, text, icon, kind, **more):
    made = {'name': name, 'text': text, 'icon': icon, 'kind': kind}
    made.update(more)
    return made


def token(name, base, stats, keywords=None):
    return {'token': base, 'token_name': name, 'token_stats': stats, 'token_keywords': keywords or []}


RULES = {
    MAURICE: [
        rule('The Velvet Rope', "Maurice starts with a 0/4 Velvet Rope with Wallflower. Nobody gets past the rope. Well. Not quickly.", 'lorc/manacles', 'starting_tokens', count=1,
             **token('Velvet Rope', 'T-23', [0, 4], ['wallflower'])),
    ],
    TILDA: [
        rule('Confetti Cannon', "Every third turn of hers the cannon goes off, and a 1/1 Confetti Critter lands on her side.", 'delapouite/party-popper', 'timed_summon', every=3,
             **token('Confetti Critter', 'T-02', [1, 1])),
    ],
    DARJEELING: [
        rule('A Proper Cup', "Madame Darjeeling gains 1 HP at the start of each of her turns. One does not rush tea.", 'delapouite/coffee-cup', 'start_of_turn_heal', amount=1),
    ],
    HAL: [
        rule('The Ante', "Hal's table, Hal's ante: the first card you play each turn costs 1 more.", 'delapouite/coins-pile', 'first_card_cost', amount=1, side='player', harmful=True),
    ],
    TREY: [
        rule('Opening Bid', "Trey draws an extra card on his first turn. He always gets the first look at the lot.", 'faithtoken/card-pick', 'first_turn_draw', count=1),
    ],
    LIZZIE: [
        rule('The Ride Never Stops', "Lizzie's units have Hustle: they come off the carousel already running.", 'lorc/flame-spin', 'keyword', keyword='hustle'),
    ],
    FINEPRINT: [
        rule('Rule 1: No Running', "House rule, both sides: units enter exhausted. (His side.)", 'delapouite/book-cover', 'enter_exhausted'),
        rule('Rule 1: No Running', "House rule, both sides: units enter exhausted. (Your side.)", 'delapouite/book-cover', 'enter_exhausted', side='player', harmful=True),
    ],
    DEX: [
        rule('House Edge', "Dex starts the duel with a Garbage and a Red Tape. The house always starts a little ahead.", 'delapouite/dice-six-faces-six', 'starting_resources', resource='garbage', count=1),
        rule('House Edge', "Dex starts the duel with a Garbage and a Red Tape. The house always starts a little ahead.", 'delapouite/dice-six-faces-six', 'starting_resources', resource='red_tape', count=1),
    ],
    PENNY: [
        rule('Mint Condition', "Everything in the shop is sleeved: Penny's units get +0/+1.", 'delapouite/shop', 'stat', atk=0, **{'def': 1}),
    ],
    OCTAVIA: [
        rule('The House Deals', "Octavia Eightfold draws an extra card each turn. The house always deals, darling.", 'lorc/scroll-unfurled', 'extra_draws', count=1),
    ],
}


def trigger(trigger_id, name, icon, when, text, line, banner, effects, warn='', is_open=False):
    made = {'id': trigger_id, 'name': name, 'icon': icon, 'when': when, 'text': text, 'line': line, 'effects': effects, 'banner': banner}
    if warn:
        made['warn'] = warn
    if is_open:
        made['open'] = True
    return made


SCRIPTS = {
    MAURICE: [
        trigger('backup', 'Calling for Backup', 'delapouite/guards', {'type': 'units_died', 'count': 3, 'side': 'own'},
                "When three of his units have died, Maurice whistles: two 2/2 House Security step out from behind the curtain.",
                "Right. That's it. LADS! We have got a situation at the rope.", "Two 2/2 House Security join Maurice.",
                [dict(kind='summon', count=2, **token('House Security', 'T-16', [2, 2]))]),
    ],
    TILDA: [
        trigger('finale', 'The Grand Finale', 'delapouite/party-flags', {'type': 'hp_below', 'pct': 50},
                "At half health Tilda fires everything she has left: her units get +1/+0 for good.",
                "You want a finale? I'll GIVE you a finale! Cover your ears, sweetie!", "Tilda's units get +1/+0.",
                [{'kind': 'buff', 'atk': 1, 'def': 0}]),
    ],
    DARJEELING: [
        trigger('guest', 'A Cup for the Guest', 'delapouite/coffee-cup', {'type': 'turn', 'turn': 4},
                "On her turn 4 she pours you a cup: you gain 3 HP, and she draws a card. Manners cost nothing.",
                "One lump or two, dear? I do so hate to thrash a guest on an empty stomach.", "You gain 3 HP. Madame Darjeeling draws a card.",
                [{'kind': 'foe_heal', 'amount': 3}, {'kind': 'draw', 'count': 1}], "Next turn: Madame Darjeeling pours you a cup (you gain 3 HP).", True),
        trigger('second_pot', 'The Second Pot', 'lorc/cauldron', {'type': 'hp_below', 'pct': 40},
                "At 40% health she rings for the second pot: she gains 4 HP and a 4/4 Cake Golem rolls in on the trolley.",
                "Oh, we are not nearly finished. Albert! The SECOND pot. And the good cake.", "She gains 4 HP. A 4/4 Cake Golem arrives.",
                [{'kind': 'heal', 'amount': 4}, {'kind': 'summon', 'token': 'T-06', 'count': 1}]),
    ],
    HAL: [
        trigger('fold', 'Hal Folds', 'lorc/poker-hand', {'type': 'hp_below', 'pct': 30},
                "At 30% health, if you control three or more units, Hal reads the table and folds: you win the fight on the spot.",
                "I know when I'm beat. I don't know it often, mind. Take the pot, take the pot.", "Hal folds. The pot is yours.",
                [{'kind': 'concede', 'if_foe_units_at_least': 3}], '', True),
        trigger('marked', 'A Marked Deck', 'faithtoken/card-random', {'type': 'turn', 'turn': 5},
                "On his turn 5 Hal deals himself two off the bottom: he draws two cards.",
                "Would you look at that. Two aces. In this light they could be anything, really.", "Hal draws two cards.",
                [{'kind': 'draw', 'count': 2}]),
    ],
    TREY: [
        trigger('once', 'Going Once...', 'delapouite/trumpet', {'type': 'turn', 'turn': 3},
                "On his turn 3: going once. Your strongest ready unit is sold out from under you (it is exhausted).",
                "Going ONCE! (ding!) Do I hear a higher bid? I do not! The big fella sits this one out!", "Your strongest ready unit is exhausted.",
                [{'kind': 'exhaust_foes', 'count': 1}], "Next turn: going once (your strongest ready unit is exhausted).", True),
        trigger('twice', 'Going Twice...', 'delapouite/trumpet', {'type': 'turn', 'turn': 5},
                "On his turn 5: going twice. Your two strongest ready units are exhausted.",
                "Going TWICE! (ding ding!) Two lots, one price, no refunds, pick it, pick it, PICK IT!", "Your two strongest ready units are exhausted.",
                [{'kind': 'exhaust_foes', 'count': 2}], "Next turn: going twice (your two strongest ready units are exhausted).", True),
        trigger('sold', 'SOLD!', 'delapouite/trumpet', {'type': 'turn', 'turn': 7},
                "On his turn 7: SOLD! The gavel comes down, and Trey's units get +2/+0 for good. Beat him before the hammer falls.",
                "SOLD! (DING DING DING!) To the handsome shark in the stripes! That's me! I bought everything!", "Trey's units get +2/+0.",
                [{'kind': 'buff', 'atk': 2, 'def': 0}], "Next turn: SOLD! Trey's units get +2/+0 for good.", True),
    ],
    LIZZIE: [
        trigger('music_stops', 'The Music Stops', 'delapouite/boombox', {'type': 'turn', 'turn': 4},
                "On her turn 4 the music stops and everybody has to get off: her units are exhausted and miss her next turn. That is your opening.",
                "Oh, bother. That's the end of the tune. Everybody OFF! Mind the step! ...Why are you smiling like that?", "The carousel stops: Lizzie's units are exhausted and miss her next turn.",
                [{'kind': 'exhaust_own'}], "Next turn: the music stops (her units stand down for a turn).", True),
        trigger('faster', 'Faster! FASTER!', 'lorc/flame-spin', {'type': 'hp_below', 'pct': 35},
                "At 35% health Lizzie throws the lever all the way over: her units get +1/+0 for good.",
                "FASTER! I said FASTER! Hold on to your hats, your teeth and each other!", "Lizzie's units get +1/+0.",
                [{'kind': 'buff', 'atk': 1, 'def': 0}]),
    ],
    FINEPRINT: [
        trigger('amendment', 'An Amendment', 'delapouite/scroll-quill', {'type': 'turn', 'turn': 4},
                "On his turn 4 he amends the house rules: \"No Running\" is struck out, and Rule 2 comes in for both sides: each player draws an extra card each turn.",
                "Point of order! I move to strike Rule 1 and adopt Rule 2. All in favour? I am. Carried. Do keep up.", "Rule 1 is struck out. Rule 2: each player draws an extra card each turn.",
                [{'kind': 'remove_rule', 'name': 'Rule 1: No Running'}, {'kind': 'remove_rule', 'name': 'Rule 1: No Running', 'side': 'player'},
                 {'kind': 'rule', 'rule': rule('Rule 2: Open Book', "House rule, both sides: draw an extra card each turn. (His side.)", 'delapouite/book-cover', 'extra_draws', count=1)},
                 {'kind': 'rule', 'rule': rule('Rule 2: Open Book', "House rule, both sides: draw an extra card each turn. (Your side.)", 'delapouite/book-cover', 'extra_draws', count=1, side='player')}],
                "Next turn: an amendment (Rule 1 goes; both players draw an extra card each turn).", True),
    ],
    DEX: [
        trigger('red', 'The Wheel: Red', 'delapouite/dice-six-faces-six', {'type': 'turn', 'turn': 3},
                "On his turn 3 the wheel lands on red: both players pay the table. You lose 2 HP, and Dex's units are exhausted for the spin.",
                "Red! Everybody pays the table on red. Yes, me too, I stand very still for it. House rules.", "Red: you lose 2 HP, and Dex's units are exhausted.",
                [{'kind': 'damage', 'amount': 2}, {'kind': 'exhaust_own', 'skip_refresh': False}], "Next turn: the wheel spins (red).", True),
        trigger('black', 'The Wheel: Black', 'delapouite/dice-six-faces-six', {'type': 'turn', 'turn': 5},
                "On his turn 5 the wheel lands on black: Dex's units get +1/+1 for good.",
                "Black! Lovely colour. Slimming. And what do you know, it's the one I had my chips on.", "Black: Dex's units get +1/+1.",
                [{'kind': 'buff', 'atk': 1, 'def': 1}], "Next turn: the wheel spins (black).", True),
        trigger('zero', 'The Wheel: Double Zero', 'delapouite/coins-pile', {'type': 'turn', 'turn': 7},
                "On his turn 7 the wheel lands on the double zero, and the house wins: Dex gains 4 HP and draws two cards.",
                "Double zero. Oh dear. Oh dear, oh dear. That one's just... mine. All of it. Sorry! Not sorry!", "Double zero: Dex gains 4 HP and draws two cards.",
                [{'kind': 'heal', 'amount': 4}, {'kind': 'draw', 'count': 2}], "Next turn: the wheel spins (double zero).", True),
    ],
    PENNY: [
        trigger('bought_it', 'You Break It, You Bought It', 'delapouite/shop', {'type': 'units_died', 'count': 3, 'side': 'own'},
                "When three of her units have died, Penny rings it all up: you lose 3 HP.",
                "That is THREE. Three! Do you know what those were worth sealed? I am ringing it up. All of it.", "Penny rings it up: you lose 3 HP.",
                [{'kind': 'damage', 'amount': 3}]),
        trigger('clearance', 'Clearance Sale', 'delapouite/ticket', {'type': 'hp_below', 'pct': 40},
                "At 40% health everything must go: Penny draws two cards and makes two Iron.",
                "Fine. FINE. Clearance sale! Everything must go! Mostly at you!", "Penny draws two cards and gets two Iron.",
                [{'kind': 'draw', 'count': 2}, {'kind': 'resources', 'resource': 'iron', 'count': 2}]),
    ],
    OCTAVIA: [
        trigger('wheel_iron', 'The Big Wheel: Iron', 'lorc/rainbow-star', {'type': 'hp_below', 'pct': 75},
                "At 75% health the Big Wheel spins and lands on Iron: Octavia's units get +1/+0 for good.",
                "Spin it, darlings! ...IRON! Oh, I do love it when the wheel has opinions. Chins up, my lovelies, and HIT them.", "The wheel lands on Iron: her units get +1/+0.",
                [{'kind': 'buff', 'atk': 1, 'def': 0}]),
        trigger('wheel_kitchen', 'The Big Wheel: The Kitchen', 'lorc/rainbow-star', {'type': 'hp_below', 'pct': 50},
                "At half health the wheel lands on the Kitchen: Octavia gains 5 HP and a 4/4 Cake Golem rolls out from the wings.",
                "And again! ...The KITCHEN! Somebody wheel in the cake. No, the BIG cake. The one with the fists.", "The wheel lands on the Kitchen: she gains 5 HP, and a 4/4 Cake Golem arrives.",
                [{'kind': 'heal', 'amount': 5}, {'kind': 'summon', 'token': 'T-06', 'count': 1}]),
        trigger('wheel_tape', 'The Big Wheel: Red Tape', 'lorc/rainbow-star', {'type': 'hp_below', 'pct': 25},
                "At 25% health the wheel lands on Red Tape: your two strongest ready units are tied up (exhausted), and Octavia draws two cards.",
                "One more spin for the road! ...RED TAPE. Oh, how dreary. For YOU, darling. Do hold still, there are forms.", "The wheel lands on Red Tape: your two strongest ready units are exhausted, and she draws two.",
                [{'kind': 'exhaust_foes', 'count': 2}, {'kind': 'draw', 'count': 2}]),
    ],
}


def load(path):
    text = io.open(path, encoding='utf-8', newline='').read()
    return text, json.loads(text)


def save(path, text, data, indent='\t'):
    newline = '\r\n' if '\r\n' in text else '\n'
    out = json.dumps(data, indent=indent, ensure_ascii=False)
    io.open(path, 'w', encoding='utf-8', newline='').write(out.replace('\n', newline) + (newline if text.endswith('\n') else ''))


def main():
    # -- the dungeon's content
    path = os.path.join(ROOT, 'data', 'dungeons', 'dungeon_content.json')
    text, data = load(path)
    content = data['dungeons'][DUNGEON]
    content['_note'] = ("Fable Nov 24 (Part 4): the Shuffled Halls, played only as a draft, with hand-made STATIC encounters (tools/nov24_shuffled_halls.py). "
        "Every foe has its exact deck (\"cards\"), its fixed equipment, its skill and its rules (data/encounters/modifiers.json, encounter_scripts.json), in its own Paths whatever the player drafted. "
        "\"hp_vs_player\": the foe's HP is the player's base HP plus this (a draft is played at the base HP of the player's level). "
        "Trey Pickett holds the Auction Ring (8), Dex Shufflewick the Roulette Pit (14), Octavia Eightfold the Big Wheel (19). "
        "`draft_rooms`: trade = the Trade Counter, vault = a card of the top two rarities, cashout = the Counting Halls (the optional early exit: part of the prize, not a win).")
    content['defaults'] = {'archetypes': ['colorless_regime'], 'icons': ['delapouite/up-card'], 'ais': ['Balanced'], 'infra': 15}
    content['boss'] = BOSS
    content['foes'] = FOES
    content['draft_rooms'] = {'4': 'trade', '13': 'trade', '11': 'vault', '18': 'cashout'}
    content['blurbs'] = BLURBS
    content['events']['18'] = COUNTING_HALLS
    content.pop('loot', None)
    save(path, text, data)
    # -- the map: room 18 is an event room now
    path = os.path.join(ROOT, 'data', 'dungeons', 'postgame_dungeons.json')
    text, rows = load(path)
    for row in rows:
        if row.get('id') != DUNGEON:
            continue
        row['story'] = ("Octavia Eightfold's own dungeon, played only with a drafted deck. Eighteen rooms in six columns; you walk one room of each. "
            "Every table has its own dealer with their own deck and their own house rule, her nephew Trey Pickett holds the Auction Ring, and Octavia herself waits at the Big Wheel. "
            "The Counting Halls, off the last corridor, let you cash out early with part of the prize.")
        row['buffs'] = 'One HP pool for the whole run. After each fight you win: pick one of three cards (add it, swap it for a card of your deck, or pass). Every dealer has a house rule of their own.'
        for node in row['nodes']:
            if node['n'] == 18:
                node['name'] = 'The Counting Halls'
                node['type'] = 'event'
    save(path, text, rows)
    # -- the standing rules and the scripted moments
    path = os.path.join(ROOT, 'data', 'encounters', 'modifiers.json')
    text, rules = load(path)
    for key, value in RULES.items():
        rules[key] = value
    save(path, text, rules, indent=detect_indent(text))
    path = os.path.join(ROOT, 'data', 'encounters', 'encounter_scripts.json')
    text, scripts = load(path)
    for key, value in SCRIPTS.items():
        scripts[key] = value
    save(path, text, scripts, indent=detect_indent(text))
    print('%s: %d foes, %d rule sets, %d scripts' % (DUNGEON, len(FOES), len(RULES), len(SCRIPTS)))
    for number, foe in sorted(FOES.items(), key=lambda item: int(item[0])):
        made = BOSS if isinstance(foe, str) else foe
        print('  room %2s %-34s %2d cards  %s' % (number, made['name'], sum(made['cards'].values()), made['paths']))


def detect_indent(text):
    for line in text.splitlines()[1:6]:
        stripped = line.lstrip(' \t')
        if stripped and line != stripped:
            lead = line[:len(line) - len(stripped)]
            return '\t' if lead.startswith('\t') else len(lead)
    return '\t'


if __name__ == '__main__':
    main()
