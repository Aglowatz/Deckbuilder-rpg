# Fable, Nov 20 day: Batch 18 in the game, the stained-glass info screens, the owner's answers

Repo: C:\Dev\Deckbuilder-rpg (Godot 4.7.2, "The Wayward Path"). The owner approved all 39 pictures of Batch 18 and answered "Fable Nov 21". **The big job is Part 2, the stained-glass info screens**; give it real thought and look at every screen.

Read first:
- the top of docs/overnight_report.md ("Fable Nov 21") and docs/overnight_inbox.md;
- docs/owner_backlog.md;
- docs/art/ui_style_guide.md ("Nov 21", direction B) and the mock-ups `docs/overnight_shots/nov20/ui_mockups_v2/b_*.jpg`;
- docs/art/path_colour_guide.md;
- docs/art/batch18_nov18.csv.

Run `git status`; if anything is uncommitted, run the tests and commit it. Log questions under "Fable Nov 20 day". Tag `pre-fable-nov20-day`. Work in this order; if time runs short, finish the part you're on, skip to Part 6, and list what's left.

## House rules
- STOP_OVERNIGHT check before each part.
- **Memory:** ONE Godot at a time; no sub-agents while Godot runs; `tools/run_tests.sh --min-free=900`. If the guard stops a background run, finish it in the foreground with `--from=N --to=K`. Tests run under the save guard.
- Commit and push after each part. **No export**, no public upload.
- Shots in docs/overnight_shots/nov20b/.
- **Owner constraints:** no difficulty setting; the battle board layout stays; Primm's fight and the castle rooms unchanged; no enemy intent shown; no combat pacing changes; each zone keeps its own colour grade; family friendly; no new painted art (needs become Batch 19 rows in a new `docs/art/batch19.csv`).
- Every rules or quest change gets a test.

## Part 1 — Import Batch 18 (39 pictures)
**Source:** `G:/My Drive/Card Game Art/Pending Review/Batch 18/` (all 39 approved by the owner; the Google Sheet tab "Batch 18 Nov 20" lists them with their sizes and uses).
1. **Copy** each file into its Approved folder on the Drive (the csv's "approved file" column, or the matching `Approved_*` folder for the new UI rows: `Approved_UI`), leaving the Pending Review copies in place. Then import into the game with the usual tools (`import_key_art.sh` and the others), the usual compression, and the ids unchanged.
2. **Wire every picture where its row says**, replacing the stand-in:
   - **Cards:** B-37 Baron Quadzilla and C-36 Announcer Grand Bellows (the card, the Collection Book, the shop, the reward screens).
   - **The Arena:** ARENA-MENU-BG behind the Arena menu (menus on the calm right side); BB-ARENA as the battle board of every Arena battle and puzzle.
   - **The Doppelganger pair:** STORY-REVEAL-KITCHEN (beats 1 to 4) and STORY-DOPPEL (beat 5). Play the cutscene and shoot each beat; make sure the line "I wore her face for so long..." now matches the picture.
   - **The Raw Deal:** BUFF-HERO-RAWDEAL-FRONT as the front of the sushi spot (the freezer door at the left of its base stays the way in; the interaction point lines up with the painted door) and BUFF-SIGN-RAWDEAL as its sign.
   - **ICON-COS-PLAINCLOAK** for the Plain Cloak in the Wardrobe and Pip's shop, tinted by the dye.
   - **Necrocrat violet:** UI-CARDBACK-N, UI-PACK-N, UI-PACK-LOCKED-N everywhere the old green ones showed.
   - **The D.N.A.:** DNA-HERO-CLOCK-TOWER replaces the kit-built tower (keep it visible from the plaza, the right scale against the Hall); DNA-SIGN-HOURGLASS over the Waiting Room's elevator; DNA-PROP-HEAL-COUCH replaces the built couch (the heal and its glow still work).
   - **Rip:** SPR-RIP-FRONTSIDE_IDLE and SPR-RIP-BACKSIDE_IDLE in his facing logic (8 directions using mirrors), so he turns smoothly to face the hero in every zone; make the normal maps the pipeline needs.
   - **TOWN-PROP-CAVE-MOUTH-BRUSH** for the Forgotten Cave's mouth in Crosspath and **CAP-PROP-SERVICE-MANHOLE** for the Old Service Tunnels' way in (the interaction points stay).
   - **The five world maps** (MAP-WORLD-GAIN / BUFF / DUMP / DNA / CAP) on the full map screen (M). **They were painted from plans captured on Nov 17**, so: fit each to the zone's real walk grid (scale, offset, a small warp if needed), check that the hero's marker, quest markers, NPCs and dungeon icons sit on the right painted spots (the Raw Deal moved to the Buffet's east district since then; the D.N.A. has rows of buildings now), and shoot each map with markers on. If a map can't be fitted well, say where it's off and add a redo row to Batch 19 with a fresh top-down plan.
   - **VS-ALEMBIC** behind Auntie Alembic's shop.
   - The 14 UI pieces: Part 2.
3. **Check:** a shot of every picture in place; the walk smokes for every zone touched; the NPC visibility probe; FPS on Medium and Low-end in the D.N.A. and the Buffet before and after; the download size before and after (it should stay near today's 764 MB).

## Part 2 — The stained-glass info screens (the main job)
The owner chose **direction B, "Stained glass"**: a deep night-blue glass page in a leaded gold frame, a strip of coloured Path panes along the top, panes of coloured glass that light up when chosen, pale lettering. Build it with the new pieces: UI-INFO-PAGE, UI-GLASS-STRIP, UI-GLASS-PANE and UI-GLASS-PANE-LIT (neutral grey, tinted in code), UI-ROSE-WINDOW, UI-INFO-DIVIDER, UI-BTN-AMBER, UI-BTN-GLASS (tinted in code), UI-QUESTBOX, UI-INFO-TOOLTIP, UI-MAP-FRAME, UI-QUEST-MARKS (three 128x128 cells), UI-SCROLL-RAIL and UI-SCROLL-GRIP.
1. **One theme, used everywhere:** a shared Godot Theme / style resource (9-slice margins as in the sheet) that every info screen reads, so a later change is one place. Colours from `core/data/path_palette.json`.
2. **The screens:** the pause menu (the rose window on top, Resume as the amber button), the quest box (top left), the quest log, settings (every tab), the glossary, feats, the Collection Book's frame, the map screen's frame, save and load, credits, tooltips and the small pop-ups (the new confirm pop-ups too: the sealed-card pop-up, the too-many-Paths pop-up, the buy-anyway notice, the reward box).
3. **The rules from the style guide:**
   - colour means a Path wherever a Path is meant (a quest wears its zone's colour, a keyword its Path's), always with the Path icon beside it; where a button doesn't stand for a Path, its glass is slate, not a Path colour;
   - one amber button per screen: the action you most likely want;
   - **no pale grey text:** secondary lines are a lighter tint of the page; unknown quest steps italic, not dim;
   - lit glass means chosen or focused (mouse hover and controller focus both);
   - hold back the glow so screens don't shout; long text (quest descriptions, the glossary) must stay comfortable to read: check contrast (at least 4.5:1 for body text) and the Large text setting.
4. **Leave alone:** the battle board and battle HUD, the shops' gold-framed screens, the dialogue box (unless one of them clearly clashes: then ask in the inbox, don't change it).
5. **Check:** before/after shots of every screen at 1920x1080 and at the smallest supported window, mouse and controller; the hover-zoom probe still green; a short UI walk (open every screen from the pause menu, change a setting, track a quest, read the glossary).
6. In `docs/art/batch18_nov18.csv`, mark the 11 old held info-screen rows "superseded by the stained-glass set (Nov 20)".

## Part 3 — The owner's answers to "Fable Nov 21"
1. **The Path-ology Lab's Night Shift Break Room** gets the same rule as the zone dungeons: "heal 5 for a cost" (two options, a cost and a drawback as in the other heal rooms, scaled for a postgame dungeon) or do nothing. Primm's Castle's Resistance Safe Room stays a full heal. Update the choice-node table; tests.
2. **The AI's opening hand:** two Infrastructure, as built. Record it.
3. **The Raw Deal** keeps its name. Record it.
4. **The new heal rooms and drawbacks** stay as they are for now (the owner will playtest). Record it.
5. **The Deck Station search and controllers:** later. Move it to the backlog.
6. **Stained glass** chosen (Part 2).

## Part 4 — Loose ends
1. Every Batch 18 row the game no longer needs a stand-in for: remove the stand-in code and files if nothing else uses them (list what was removed).
2. Update `docs/owner_backlog.md`: take out what's done (Batch 18 art, the Arena art, the Alembic art, the info-screen look, the Path colour pictures), keep what's still open.
3. Anything you find broken on the way that a player would notice: fix it if it's small and safe, otherwise log it in the inbox.

## Part 5 — Check the flow
- Play from a mid-game save: open the Arena (menu, one battle, one puzzle), the Raw Deal's front, the D.N.A. plaza to the clock tower and the couch, Rip in two zones, the map screen in all five zones, Alembic's shop, the Necrocrat pack in the shop and a pack opening, the Doppelganger cutscene.
- Screenshot each.

## Part 6 — Tests and report (no export)
1. All test shards green; the walk smokes (every zone); the NPC visibility probe; the fade probe; the quest hand-in probe; the hover-zoom probe; the puzzle solver tests.
2. **docs/overnight_report.md**, at the top, under "Fable Nov 20 day":
   - each part done or not, with shots;
   - the 39 pictures: where each went, anything that didn't fit and why;
   - the five maps: how each was fitted, and any redo rows;
   - the stained-glass screens: before/after for every screen, the theme file, contrast numbers;
   - the Lab's new heal room;
   - FPS and download size before and after;
   - the owner's decisions needed (at most 6, each with a recommendation).
3. Commit and push. No export, no public upload.
