# Ship checklist - free itch.io 1.0 (Nov 9)

Status: **done** (in the game), **done tonight** (added Nov 8-9), **todo** (with effort S < 2 h, M half a day, L a day+), **n/a**.

## Settings

| Item | Status | Where / note |
|---|---|---|
| Master, music, SFX volume | done | Settings > Audio: master, music, effects, interface, ambience, dialogue voices (dB taper) |
| Resolution, fullscreen, VSync | done | Settings > Display: window mode, resolution (windowed), VSync, frame cap |
| Key rebinding | done | Settings > Controls (keys, two slots each; pad buttons) |
| Controller support | done | full pad navigation, prompts follow the device, button-name style option |
| Text speed | done | Settings > Text: dialogue text speed; card/dialogue/tooltip text sizes |
| Camera options | done | Settings > Display: angle (Cinematic / Classic / Overview / Low), zoom, city camera; V cycles |
| Low-end mode | done | the Low-end preset (graphics quality list) + "Start (Compatibility).bat" for the OpenGL renderer; auto on weak PCs |

## Accessibility

| Item | Status | Note |
|---|---|---|
| Readable text size | done | card, dialogue and tooltip text sizes, UI scale slider |
| Colour-blind-safe Path colours | **done (Nov 9)** | Path colours are red / orange / dark green / leaf green (red-orange and the two greens collide for deuteranopia and protanopia), so the "Path symbols" option (Settings > Accessibility) is **on by default** since Nov 9: a symbol on every colour-coded card, list row and Path choice. Necrocrat and Refusemancer card backs, frames and packs are both green (they differ by emblem). |
| Important states not by colour alone | mostly | rule icons carry glyphs and text; quest marks are "!"/"?"; enemy rules have tooltips. The red/green/gold/amber rule-icon tint is explained in the Glossary. |
| Reduce shake / flashing | done | Settings > Accessibility |
| Subtitles / captions | n/a | there is no voiced dialogue: every line is on screen as text (the "dialogue voices" are babble under the text). No audio-only cue carries information that is not also shown (the end-turn and boss warnings are banners). |

## Saves

| Item | Status | Note |
|---|---|---|
| Save slots | done | 3 campaigns, each with manual slots + an autosave; backups of every save |
| Auto-save | done | after battles, zone changes, quests |
| Auto-save indicator | **done (Nov 9)** | a quill in a gold ring with "Saving..." bottom-right on every autosave (`ui/widgets/save_indicator.gd`) |
| Safe quitting | done | Quit Game asks first; the autosave is current; a quit in a dungeon restarts that dungeon from its entrance and, since tonight, reloads **in its zone** (it used to reload in Crosspath) |
| Pause anywhere | done | Escape: world, battles, dungeon maps (not during a scene change) |

## Legal and credits

| Item | Status | Note |
|---|---|---|
| Credits and licences in game | **done tonight** | title menu > Credits (`ui/screens/credits_panel.gd`, text `data/credits/credits.txt`): Godot MIT notice + every third-party engine licence from the engine itself, Cinzel + Alegreya Sans (OFL), FluidR3_GM (MIT), Kenney / KayKit (CC0), Freesound CC0 contributors, game-icons.net (CC BY 3.0, authors named), GUT (MIT; not shipped) |
| Licence files | **fixed tonight** | `assets/fonts/Cinzel/OFL.txt` carried Alegreya Sans' copyright line; now Cinzel's |
| Creator name | **done (Nov 9)** | `data/credits/credits.cfg` `creator="Alex Glowatz"`: "A game by Alex Glowatz" + "Game design, direction and production" on the Credits page, and under the title card in the end credits |
| End credits text | **done tonight** | "PLACEHOLDER CREDITS", "Design and direction: you" and the outdated art/music lines replaced (revertible: `docs/dialogue/text_sweep_nov9.csv`) |
| AI-content disclosure | **done tonight (draft)** | in the Credits page and `docs/release/itch_page/ai_disclosure.md` for the itch page (itch.io also asks it as a tag/field when uploading) |
| CREDITS.md music section | todo (S) | still describes the old LMMS soundtrack; the Credits page is right |

## Release basics

| Item | Status | Note |
|---|---|---|
| Version on the title screen | done | bottom of the menu column, from `project.godot` (`config/version`, now 0.5.4: set 1.0.0 at release) |
| Log file in the user folder | done | `%APPDATA%/Godot/app_userdata/Deckbuilder-RPG/logs/wayward.log` (+4 older runs) |
| "Copy log / open log folder" | **done tonight** | Settings > Accessibility, "Open log folder" and "Copy log" (last 200 KB to the clipboard) |
| Report a Problem | done | pause menu |
| Crash-safe start | done (checked) | missing/damaged settings.cfg -> defaults (first-launch path, Low-end on weak PCs); damaged save -> its backup, else empty; BootGuard offers Safe Mode after a launch that died while starting. Test added: `tests/ui/test_release_basics_nov9.gd` |
| Donation button | **done tonight** | "Support the game" on the title menu, the Credits page and beside Skip in the end credits; opens `support url` from `data/credits/credits.cfg`; **hidden while the url is empty** |

## itch.io page kit (`docs/release/itch_page/`)

| Item | Status |
|---|---|
| Short + long description, features, controls, tags | done tonight (`page.md`) |
| AI disclosure text | done tonight (`ai_disclosure.md`) |
| System requirements (measured) | see `page.md` (measured tonight from the soak and the perf logs) |
| 8-10 screenshots at 1920x1080 | see `screenshots/` (captured tonight) |
| Cover image recommendation | `page.md` (from the existing key art) |

## Bigger missing items (not done tonight)

| Item | Effort |
|---|---|
| Version 1.0.0 + CHANGELOG entry + export | S (owner, release day) |
| itch.io page set-up and upload (butler) | S (owner; steps in `docs/release/itch_upload.md`) |
| A Windows build smoke on a second PC | S (owner) |
