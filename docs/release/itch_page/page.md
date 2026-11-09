# itch.io page kit - The Wayward Path (final check Nov 9, against 1.0.0-rc1)

Paste-ready text for the itch.io project page. Pricing: **free, donations welcome** (itch's "$0 or donate" with a suggested 3-5 USD; or
"No payments" and the in-game Support button only - see `../itch_upload.md`). Kind of project: Downloadable. Classification: Game.
Genre: Card Game (secondary: Role Playing). Checked Nov 9 against the 1.0.0-rc1 build: descriptions, features, controls (`app/keybinds.gd`
defaults), requirements (the exported build's own log on the 7.4 GB iGPU laptop), tags, the AI disclosure.

## Short description (the one-line tagline, max ~120 characters)

A cozy deckbuilding RPG: wake with no name, walk four strange lands, and win back a kingdom one card duel at a time.

## Long description

**You wake in a forest with no memory, a deck of cards, and soldiers looking for you.**

The kingdom of Patchwork once ran on four Paths that argued constantly and needed each other anyway: the Beefcakes kept the lights on with
giant hamster wheels, the Gourmands fed everyone, the Necrocrats kept the records of the dead, and the Refusemancers turned rubbish into
harvests. Then Primm, the Royal Minister of Improvements, took the throne and "perfected" them all - and each land became its own flaw turned
into law.

Walk the Gainlands, the D.N.A. (the Department of Necrotic Affairs), the Endless Buffet and the Verdant Dump. Out-muscle, out-file, out-cook
and out-compost their corrupted leaders in tactical card duels, build your deck from a few hundred cards, free the four Paths, and find out who
you were before the forest.

The Wayward Path is a single-player story game of about 12-20 hours, with a postgame. It is **free; donations are welcome** but never needed.

## Features

- **Card duels with a real board:** units, spells, traps, tools and wonders; five Path resources (Iron, Red Tape, Ingredients, Garbage,
  Contracts); bosses with scripted events that are announced, never hidden.
- **Four zones and a capital to walk,** each with its own people, music, minigames (a classroom quiz, a gym rep counter, Dex's card-matching
  tables), side quests and dungeons - and a postgame with three more dungeons.
- **Deckbuilding that follows the story:** start with one Path and unlock more as you free the zones; craft, trade, open packs and keep
  several decks in the Deck Station's slots (four to start, more as you level).
- **A full quest log:** main story, a Path line per zone, side quests, a hidden secret line or two, and a postgame with three extra dungeons.
- **Hand-painted look:** painted cards, characters, story pictures and battleboards (see "About the art" below).
- **An original orchestral score** with a theme for every place.
- **Comfort options:** controller support, rebindable keys, text sizes, colour-blind Path symbols (on by default), Reduce motion / shake /
  flashing, autosaves with a visible indicator, a Low-end preset that older PCs pick by themselves, level hints at every dungeon door.

## Controls

| Action | Keyboard / mouse | Controller |
|---|---|---|
| Move | WASD or arrow keys (Shift: sprint) | left stick (click: sprint) |
| Tracked quest: previous / next | [ ] or , . | LB / RB |
| Talk / interact / enter | E or Space | A |
| Map | M | View/Back |
| Character / Deck / Packs / Wardrobe / Quests | C / B / P / T / J | Y / X / D-pad |
| Camera angle / zoom / turn | V / F / hold Z or X | right stick click / - / triggers |
| Battle: next phase, end turn | Space | X |
| Battle: play a card | drag it to the board, or click it then a target; right-click inspects | select and A; Y inspects |
| Dungeon rules | R | Y |
| Pause / settings | Escape | Start |

Every key can be changed in Settings > Controls.

## System requirements

Measured Nov 8-9 on the development PC (Windows 11, AMD Ryzen 5 4500U with its integrated Radeon GPU, 7.4 GB RAM): 60 fps at the
Medium preset in the zones, the town and battles; the game process uses about 350-800 MB of RAM (engine-static memory 450-510 MB, flat over a
9-minute soak through four zones and three fights) plus 300-1,100 MB of video memory (the exported 1.0.0-rc1 build reported 278-370 MB in the
opening forest). On that PC the exported build picks the Low-end preset by itself on its first start (30 fps cap); Medium is a menu click.

- **OS:** Windows 10 or 11, 64-bit.
- **Minimum:** integrated graphics with DirectX 12 or Vulkan (Intel UHD 620 class), **4 GB RAM** (the Low-end preset is picked by itself on
  weak PCs); a 2015-or-later dual-core CPU. Very old GPUs: "Start (Compatibility).bat" (OpenGL).
- **Recommended:** **8 GB RAM**, any dedicated GPU from the last eight years (an estimate - only the iGPU PC was measured).
- **Disk:** about 950 MB unpacked; the download is about 740 MB zipped.

## Screenshots

Upload in this order (captured in game at 1920x1080, `screenshots/`): see `screenshots/README.md` for the list and what each shows.

## Cover image

Recommendation: **TITLE-KEYART** (`assets/art/keyart/TITLE-KEYART.webp`, the hero on the road above the four lands with the castle behind)
cropped to itch.io's 630x500 cover: keep the hero on the left third and the castle and the green D.N.A. tower in frame; put
**LOGO-WORDMARK** over the sky. The source is 1672x941, so crop a 1176x941 window from x = 120 and scale down. Banner (960x? header): the
same key art, full width, with the wordmark. Do not use STORY-* stills as the cover (spoilers).

## Tags (itch.io allows up to 10)

card-game, deckbuilding, rpg, fantasy, story-rich, singleplayer, cozy, turn-based, adventure, funny

## AI disclosure

itch.io asks creators to disclose AI-generated content (the "AI generated" tag and the upload form's disclosure). Use the text in
`ai_disclosure.md` in the page body as well.
