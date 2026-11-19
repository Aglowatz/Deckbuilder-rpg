"""Fable Nov 19 (Parts 3 and 4): adds the Path-colour corrections and the info-screen art to docs/art/batch18_nov18.csv (once; rows
already present by id are replaced). Every description is self-contained and under 600 characters (checked).
   python tools/batch18_nov19_rows.py"""
import csv, os

PATH = os.path.join(os.path.dirname(os.path.abspath(__file__)), '..', 'docs', 'art', 'batch18_nov18.csv')
STATUS = 'To make (Batch 18)'
STYLE = 'Hand-painted storybook fantasy game UI, warm gold filigree on dark walnut, soft painterly shading, same style as the attached panel. No text, no letters.'

ROWS = [
    # ---- Part 3: painted art in the wrong Path colours ---------------------------------------------------------------------------
    ['UI-CARDBACK-N', 'Necrocrat card back, recoloured', '(to make)', '1024x1536 PNG (2:3), same layout as UI-CARDBACK-R', 'The back of Necrocrat cards (collection, packs, Alembic)',
     'UI-CARDBACK-N (its green field reads as the Refusemancer back)', STATUS,
     'A fantasy trading-card back, portrait 2:3, same ornate gold filigree layout as the attached Refusemancer back, but in the Necrocrat colours: the four corner fields in dark SLATE GREY (not green), pale bone-white leaf scrolls, a thin bright ghost-green glow along the gold. In the centre the attached medallion unchanged: a pale skull wrapped in bright green ghost-flame on a dark slate disc in a cracked stone rim. Painted storybook style, no text.',
     'assets/art/ui/UI-CARDBACK-N.webp (layout); UI-CARDBACK-R.webp (the back it must not look like); ICON-ENERGY-N.webp (medallion)'],
    ['UI-PACK-N', 'Necrocrat card pack, recoloured (and its locked version)', '(to make)', '1024x1536 PNG, transparent, same layout as UI-PACK-R; plus UI-PACK-LOCKED-N as the same picture desaturated with a small padlock', 'The Necrocrat Path Pack in the pack shop and the pack opening',
     'UI-PACK-N and UI-PACK-LOCKED-N (the green wrapper reads as the Refusemancer pack)', STATUS,
     'A sealed foil booster pack, portrait, gold crimped top and bottom edges, a cream band down the middle, exactly the layout of the attached pack, but the wrapper in dark SLATE GREY foil (not green) with small pale stamped form-and-seal motifs and a faint bright ghost-green shimmer. In the centre the attached medallion unchanged: a pale skull in bright green ghost-flame on a slate disc. Painted storybook style, transparent background, no text.',
     'assets/art/ui/UI-PACK-N.webp (layout); UI-PACK-R.webp (the pack it must not look like); ICON-ENERGY-N.webp'],
    ['V-ALEMBIC', 'Auntie Alembic portrait, flasks and apron in the four Path colours', '(to make)', 'Same canvas as V-ALEMBIC (portrait, transparent or the same backdrop)', "Auntie Alembic's shop portrait and dialogue portrait",
     'V-ALEMBIC (her flasks and paint splashes are red, yellow, blue and violet: blue and violet are no Path)', STATUS,
     'Repaint of the attached portrait, everything unchanged (the smiling grey-haired alchemist in a green headscarf and a white apron, holding up two round flasks) except the colours of the potions: the flask in her right hand swirls strong RED with gold, the flask in her left hand swirls bright GHOST GREEN on dark slate smoke; the splashes on her apron and the vials on her belt are only these four colours: red, warm cream-copper, deep moss green, bright ghost green. No blue, no violet. No text.',
     'assets/art/portraits/V-ALEMBIC.webp; docs/art/path_colour_swatches.png'],
    ['VS-ALEMBIC', "Auntie Alembic's shop picture, jars in the four Path colours", '(to make)', 'Same canvas as VS-ALEMBIC (16:9)', "The backdrop of Auntie Alembic's shop screen",
     'VS-ALEMBIC (the four jars are blue, red, orange and green; the flame is violet and blue)', STATUS,
     'Repaint of the attached alchemy shop interior, everything unchanged (warm lamplit workshop, a black cauldron on the left, a wooden counter across the front) except: the four glowing jars on the tray stand in this order left to right and in these colours: strong RED, warm CREAM-COPPER, deep MOSS GREEN, bright GHOST GREEN; the flame rising from the cauldron is a braid of the same four colours. No blue or violet glow anywhere. No text.',
     'assets/art/vendors/VS-ALEMBIC.webp; docs/art/path_colour_swatches.png'],
    # ---- Part 4: the info screens (docs/art/ui_style_guide.md) --------------------------------------------------------------------
    ['UI-INFO-PAGE', 'Info screen page: the big parchment board', '(to make)', '1536x1024 PNG, transparent outside; 9-slice margins 128 px (left, top, right, bottom)', 'The background of every info screen: pause menu, settings, quest log, glossary, feats, credits',
     'UI-BG-MENU stretched; plain dark boxes', STATUS,
     'A wide aged-parchment page mounted on a dark walnut board with a slim gold filigree frame: gold corner flourishes with a small diamond, a thin gold inner line, 128 px of frame on every side so the middle can be stretched. The parchment is clean and even in the middle (text will sit on it), slightly darker and worn toward the edges, no stains in the centre. ' + STYLE,
     'assets/art/ui/UI-PANEL-MAIN.webp; UI-BG-MENU.webp'],
    ['UI-INFO-RIBBON', 'Header ribbon', '(to make)', '1024x192 PNG, transparent; 3-slice margins 176 px left and right', 'The title of every info screen and every pop-up',
     'Plain title text on the panel', STATUS,
     'A wide crimson cloth ribbon banner seen from the front, flat and straight in the middle with folded swallow-tail ends curling back on the left and right, thin gold trim along both edges, a small gold diamond stud at each fold. The straight middle part is plain red with soft folds only (a title will be printed on it) and can be stretched. Same red and gold as the ribbon of the attached UI-PANEL-POPUP. ' + STYLE,
     'assets/art/ui/UI-PANEL-POPUP.webp'],
    ['UI-INFO-DIVIDER', 'Section divider', '(to make)', '1024x48 PNG, transparent; 3-slice margins 160 px left and right', 'Between sections of a page (settings groups, quest groups, glossary letters)',
     'A 1 px grey line', STATUS,
     'A thin horizontal gold rule for a storybook page: a fine gold line that thins to a point at both ends, with one small diamond-and-curl flourish in the exact centre and a tiny leaf curl near each end. Delicate, readable on both pale parchment and dark walnut, transparent background. The plain line between the centre flourish and the ends can be stretched. ' + STYLE,
     'assets/art/ui/UI-PANEL-MAIN.webp (the gold of its corners)'],
    ['UI-INFO-ROW', 'List row plate (three states)', '(to make)', '3 pictures of 1024x128 PNG, transparent: normal, hover, selected; 9-slice margins 48 px', 'A row in a list: a quest, a setting, a save slot, a glossary entry',
     'Flat translucent boxes', STATUS,
     'Three versions of one long, low list-row plate for a parchment page. Normal: a slightly darker parchment strip with a hairline sepia border and softly rounded corners. Hover: the same with a warm gold hairline border and a faint glow. Selected: the same with a solid gold border, a small gold diamond at the left end and a soft warm fill. All three exactly the same size and shape, plain in the middle for text. ' + STYLE,
     'assets/art/ui/UI-NAMEPLATE.webp'],
    ['UI-INFO-TAB', 'Page tab (two states)', '(to make)', '2 pictures of 384x128 PNG, transparent: active and inactive; 9-slice margins 56 px', 'The tabs of settings (Display, Text, Audio...) and of the quest log (Main, Side, Done)',
     'Text buttons in a row', STATUS,
     'Two versions of a bookmark-style tab that sticks up from the top edge of a parchment page. Active: pale parchment like the page, gold trimmed rounded top corners, it joins the page with no line at the bottom. Inactive: darker walnut wood with a thin dull-gold trim, sitting a little lower. Both exactly the same outline, plain in the middle for a word. ' + STYLE,
     'assets/art/ui/UI-PANEL-MAIN.webp'],
    ['UI-INFO-BTN-STATES', 'Button states for the gold and the wood button', '(to make)', '6 pictures of 1024x235 PNG, transparent: primary hover, pressed, disabled; secondary hover, pressed, disabled; 9-slice margins 110 px left/right, 60 px top/bottom', 'Every button of the info screens (today one picture is tinted by code for all states)',
     'Code tints of UI-BTN-PRIMARY and UI-BTN-SECONDARY', STATUS,
     'State versions of the two attached buttons, identical shape and size. Gold button: HOVER brighter with a soft warm glow round the rim; PRESSED darker, pushed in, inner shadow at the top; DISABLED dull grey-brown metal, no shine. Wood button: HOVER with a bright gold rim; PRESSED darker wood, pushed in; DISABLED pale and flat, rim dull. The middle of each stays plain (a label is printed on it). ' + STYLE,
     'assets/art/ui/UI-BTN-PRIMARY.webp; UI-BTN-SECONDARY.webp'],
    ['UI-INFO-SCROLLBAR', 'Scroll bar: rail and grip', '(to make)', 'Rail 48x512 PNG (3-slice margins 48 px top and bottom); grip 48x160 PNG (3-slice margins 40 px); transparent', 'Every scrolling list (settings, quest log, glossary, feats, the Deck Station, shops)',
     'The thin grey default scroll bar', STATUS,
     'Two small parts of a storybook scroll bar. The rail: a narrow vertical groove of dark walnut with a hairline gold edge and a tiny gold arrowhead cap at the top and at the bottom. The grip: a short polished gold bar with rounded ends and one small diamond stud in its centre, sized to slide inside the rail. Both can be stretched along their middle. ' + STYLE,
     'assets/art/ui/UI-BTN-PRIMARY.webp (the gold)'],
    ['UI-QUESTBOX', 'Quest box (the tracker, top left)', '(to make)', '768x512 PNG, transparent; 9-slice margins: 96 px left, 88 px top, 64 px right, 64 px bottom', 'The tracked-quest box in the top-left corner of the world view',
     'The dark translucent box with a gold line', STATUS,
     'A small note pinned to the top-left of the screen: a slightly curled sheet of pale parchment with a deckled edge, a narrow dark-walnut strip with gold trim across its top (the header), and a gold pin with a tiny diamond at the top-left corner. Soft drop shadow underneath, as if it floats over a landscape. The parchment is plain and even (dark ink text will sit on it) and can be stretched in the middle. ' + STYLE,
     'assets/art/ui/UI-NAMEPLATE.webp; UI-PANEL-MAIN.webp'],
    ['UI-QUEST-MARKS', 'Quest step marks and tags', '(to make)', '6 pictures of 128x128 PNG, transparent: step open, step done, step next, tag MAIN, tag SIDE, tag NEW (tags are blank shapes 256x96)', 'The bullets and the little tags of quests in the quest box and the quest log',
     'Unicode ticks, arrows and a text label', STATUS,
     'A set of six tiny storybook marks, each centred on its own transparent square. 1: an empty sepia ink ring. 2: the ring filled with a red wax seal stamped with a gold tick. 3: a small gold arrowhead pointing right. 4: a short blank gold ribbon tag with a swallow tail (for MAIN). 5: the same tag in blank dark walnut with gold trim (for SIDE). 6: the same tag in blank crimson (for NEW). Bold shapes that read at 24 px. ' + STYLE,
     'assets/art/ui/UI-PANEL-POPUP.webp (the red and gold)'],
    ['UI-INFO-TOOLTIP', 'Tooltip and small pop-up panel', '(to make)', '640x320 PNG, transparent; 9-slice margins 44 px', 'Hover tooltips (cards, icons, rules) and small notes over any screen',
     'UI-PANEL-TOOLTIP (kept as the fallback)', STATUS,
     'A small dark panel for hover text that must read over any picture: near-black warm walnut with a very faint wood grain, a single hairline gold border with softly rounded corners and one tiny gold diamond at each corner, a soft dark drop shadow all round. Plain and even in the middle (pale text will sit on it); the corners stay crisp when the middle is stretched. ' + STYLE,
     'assets/art/ui/UI-PANEL-TOOLTIP.webp'],
    ['UI-MAP-FRAME', 'Map frame', '(to make)', '2048x1152 PNG, transparent centre; 9-slice margins 176 px', 'The frame round the full map screen (M) and its legend',
     'UI-BG-WORLDMAP used as a background under a square map', STATUS,
     'An empty picture frame for a painted adventure map, landscape: dark walnut with gold filigree corners like the attached panel, a brass compass rose set into the top-left corner, a blue silk bookmark ribbon hanging from the left side, small brass tacks along the inner edge. The whole middle is transparent (the map shows through). 176 px of frame on every side so it can be stretched. ' + STYLE,
     'assets/art/ui/UI-BG-WORLDMAP.webp; UI-PANEL-MAIN.webp'],
]

rows = list(csv.reader(open(PATH, encoding='utf-8', newline='')))
header, body = rows[0], rows[1:]
ids = [r[0] for r in ROWS]
body = [r for r in body if r and r[0] not in ids]
for r in ROWS:
    assert len(r) == len(header), (r[0], len(r), len(header))
    assert len(r[7]) < 600, (r[0], len(r[7]))
    body.append(r)
with open(PATH, 'w', encoding='utf-8', newline='') as f:
    w = csv.writer(f, quoting=csv.QUOTE_MINIMAL)
    w.writerow(header)
    w.writerows(body)
print(len(body), 'rows;', len(ROWS), 'from Fable Nov 19; longest description', max(len(r[7]) for r in ROWS))
