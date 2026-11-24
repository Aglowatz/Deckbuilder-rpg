"""Fable big pass Nov 23 (Part 4): the room content of the Shuffled Halls (D-SHUFFLE) in data/dungeons/dungeon_content.json: who
stands in the fight rooms before the run's rival drafters are dealt in (`Session.prepare_draft_dungeon` names each room after
its rival), the two Trade Counters, the two Kettles, the two buff rooms, the Chained Vault and the Counting Room. Idempotent.
    python tools/nov23_shuffled_halls_content.py"""
import io
import json
import os

ROOT = os.path.join(os.path.dirname(os.path.abspath(__file__)), '..')
PATH = os.path.join(ROOT, 'data', 'dungeons', 'dungeon_content.json')
DRAFTER = 'A House Drafter'

CONTENT = {
    "_note": "Fable big pass Nov 23 (docs/design/draft_dungeon_plan.md): the Shuffled Halls, played only as a draft. The fight rooms are held by rival drafters dealt in when the run starts (DraftRivals.build_halls; the names below are stand-ins for the map's data), Trey Pickett holds the Auction Ring (8), Dex Shufflewick the Roulette Pit (14) and Octavia Eightfold the Big Wheel (19). `draft_rooms`: the first choice of these rooms puts a draft offer on the table (trade = the Trade Counter: a multi-Path card for a card of the deck; vault = a card of the top two rarities).",
    "defaults": {"archetypes": ["colorless_regime"], "icons": ["delapouite/up-card"], "ais": ["Balanced"], "infra": 15},
    "boss": {"deck": "colorless_regime", "extra": {}, "hp": 32, "icon": "delapouite/up-card", "infra": 15, "setup_turns": 0},
    "foes": {
        "2": DRAFTER, "3": DRAFTER, "5": DRAFTER, "7": DRAFTER, "10": DRAFTER, "12": DRAFTER, "15": DRAFTER,
        "8": {"name": "Trey Pickett", "deck": "colorless_regime", "size": 30, "hp": 24, "infra": 15, "ai": "Aggressive", "icon": "delapouite/up-card"},
        "14": {"name": "Dex Shufflewick", "deck": "colorless_regime", "size": 30, "hp": 24, "infra": 15, "ai": "Balanced", "icon": "delapouite/up-card"},
        "19": "Octavia Eightfold",
    },
    "draft_rooms": {"4": "trade", "13": "trade", "11": "vault"},
    "blurbs": {
        "2": "The left-hand gate. A drafter is waiting at the first table.",
        "3": "The right-hand gate. A drafter is waiting at the first table.",
        "4": "The Trade Counter: a card of two Paths (or a rare one) for a card of your deck.",
        "5": "Somebody is taking tea in the garden, with a deck beside the pot.",
        "6": "The house kettle is on. A cup costs a little; the free one costs something else.",
        "7": "A quiet game in the back room. It will not stay quiet.",
        "8": "A champion's table: Trey Pickett holds the Auction Ring. Harder, with a better prize.",
        "9": "A stall of lucky charms. Take one; it lasts the whole run.",
        "10": "The carousel turns, and somebody is dealing from one of the horses.",
        "11": "A prize in chains. Taking it means carrying its curse to the end.",
        "12": "The house rules, shelved floor to ceiling, and a drafter who has read them all.",
        "13": "The Prize Tent: another Trade Counter, with a rabbit minding it.",
        "14": "A champion's table: Dex Shufflewick runs the Roulette Pit. Harder, with a better prize.",
        "15": "A shop of cards nobody is allowed to buy, and a drafter behind the till.",
        "16": "Sofas, a candle, and the last cup of tea before the Big Wheel.",
        "17": "Cake, on a cart. A slice before the show lasts the whole run.",
        "18": "The house's takings, and a side door to the Big Wheel.",
        "19": "Boss: Octavia Eightfold. The house always deals.",
    },
    "events": {
        "4": {
            "title": "The Trade Counter",
            "body": "A counter draped in velvet, three cards under glass, and a small brass sign: ONE OF OURS FOR ONE OF YOURS. Nobody is minding it. The glass lifts easily.",
            "choices": [
                ["Look at the three cards", "The glass lifts. Three cards, and each one wants a card of yours in its place.", "hint:Trade a card of your deck for one of three"],
                ["Walk on", "You leave the glass down. The cards watch you go, as cards do.", "nothing"],
            ],
        },
        "13": {
            "title": "The Prize Tent",
            "body": "A striped tent stacked with prizes, and a large toy rabbit sitting behind a table with three cards on it. A sign round its neck reads: SWAPS ONLY. NO REFUNDS. THE RABBIT'S DECISION IS FINAL.",
            "choices": [
                ["Look at the three cards", "The rabbit says nothing, which you take as a yes.", "hint:Trade a card of your deck for one of three"],
                ["Walk on", "The rabbit watches you leave. You are fairly sure it did not blink.", "nothing"],
            ],
        },
        "6": {
            "title": "The House Kettle",
            "body": "A copper kettle the size of a barrel sings over a little stove. A card on the table says HOUSE BLEND 60 GOLD, and under it, in smaller writing: YESTERDAY'S POT, FREE.",
            "choices": [
                ["Buy a cup of the house blend", "Sixty coins in the dish. It tastes of cinnamon and winning.", "heal:6", "pay:60"],
                ["Drink yesterday's pot", "It is free, it is warm, and it sits in your stomach like a bad hand: in the next fight you skip your first card draw.", "heal:6", "curse:Yesterday's Pot|first_draw=-1,next=1"],
                ["Leave the kettle singing", "You are not thirsty. The kettle sings on without you.", "nothing"],
            ],
        },
        "16": {
            "title": "The Quiet Lounge",
            "body": "Two velvet sofas, one candle and a tea tray. It is the only quiet room in the Shuffle House, and the last one before the Big Wheel. A little card on the tray: A PROPER SIT-DOWN, 80 GOLD. A QUICK PERCH, ON THE HOUSE.",
            "choices": [
                ["Pay for a proper sit-down", "Eighty coins, a whole pot of tea and ten minutes of nobody dealing you anything.", "heal:8", "pay:80"],
                ["Take a quick perch", "You sit on the arm of the sofa and it is nearly restful. You get up stiff: in the next fight the first card you play each turn costs 1 more.", "heal:5", "curse:Pins and Needles|first_cost=1,next=1"],
                ["Stay on your feet", "You walk through without sitting. The sofas look disappointed.", "nothing"],
            ],
        },
        "9": {
            "title": "The Lucky Stall",
            "body": "A stall hung with charms: a rabbit's foot (the rabbit is fine, it says so on the tag), a horseshoe and a four-leaf clover pressed in a pack wrapper. A sign: ONE PER CUSTOMER. THEY ALL WORK. MOSTLY. LUCK IS NOT FREE.",
            "choices": [
                ["Take the horseshoe", "It is heavier than it looks, and it drops on your foot at once (lose 3 HP). Your units hit a little harder for the rest of the run.", "boon:Lucky Horseshoe|atk=1", "damage:3"],
                ["Buy the clover", "Forty coins for a leaf. You tuck it into your sleeve: your opening hand has one more card for the rest of the run.", "boon:Four-Leaf Clover|draw=1", "pay:40"],
                ["Take the rabbit's foot", "It is warm, which is a little worrying, and it kicks: in the next fight you skip your first card draw. You have 4 more max HP for the rest of the run.", "boon:Rabbit's Foot|max_hp=4", "curse:A Kick for Luck|first_draw=-1,next=1"],
                ["Leave the charms alone", "You make your own luck. The stallholder, who is not there, does not mind.", "nothing"],
            ],
        },
        "17": {
            "title": "The Dessert Cart",
            "body": "A cart of cakes parked in the corridor, with one slice of everything already cut. A card in icing: FOR THE PERFORMERS. YOU ARE ABOUT TO BE ONE.",
            "choices": [
                ["Buy the sponge", "Thirty coins in the tin. Light as a first pick: your units get +0/+1 for the rest of the run.", "boon:A Slice of Sponge|def=1", "pay:30"],
                ["Buy the fudge cake", "Fifty coins in the tin. Dense as a rulebook: you have 5 more max HP for the rest of the run.", "boon:A Slice of Fudge Cake|max_hp=5", "pay:50"],
                ["Take the espresso tart", "It is free, and you find out why: your hands will not stop shuffling. You take the first turn in every fight for the rest of the run, and in the next fight the first card you play each turn costs 1 more.", "boon:Espresso Tart|first=1", "curse:The Jitters|first_cost=1,next=1"],
                ["No cake before a show", "You walk past the cart. It takes a great deal of character.", "nothing"],
            ],
        },
        "11": {
            "title": "The Chained Vault",
            "body": "A cabinet wound in purple chain, and behind the glass three cards far too good to be left lying about. The padlock is open. A note hangs from it in Octavia's hand: TAKE ONE, DARLING. THE HOUSE TAKES A LITTLE BACK.",
            "choices": [
                ["Take a card, and the house's share", "The chain slides off like a ribbon. You choose a card, and feel the house lean on you: for the rest of the run enemy units get +1 attack.", "curse:The House's Share|foe_atk=1", "hint:A card of the top two rarities; enemy units get +1 attack for the rest of the run"],
                ["Leave the chains alone", "You walk past. The padlock clicks shut behind you, a little sulkily.", "nothing"],
            ],
        },
    },
    "loot": {"18": {"gold": 120}},
}


def main():
    text = io.open(PATH, encoding='utf-8', newline='').read()
    newline = '\r\n' if '\r\n' in text else '\n'
    data = json.loads(text)
    data['dungeons']['D-SHUFFLE'] = CONTENT
    out = json.dumps(data, indent='\t', ensure_ascii=False)
    io.open(PATH, 'w', encoding='utf-8', newline='').write(out.replace('\n', newline) + (newline if text.endswith('\n') else ''))
    print('D-SHUFFLE content: %d events, %d fight rooms' % (len(CONTENT['events']), len(CONTENT['foes'])))


if __name__ == '__main__':
    main()
