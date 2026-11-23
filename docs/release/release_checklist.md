# Release checklist - The Wayward Path 1.0 on itch.io

Written Nov 21 2026 (Fable Nov 21 review, Part 7). Every step from the final build to the page going Public, in order.
**Who:** "Owner" = you, by hand. "Claude" = a Claude Code session can do it if you ask (it never uploads or publishes anything).
Nothing is public until step 30, and that step is yours.

The longer how-tos this list points at: `docs/release/how_to_build.md` (the export), `docs/release/itch_upload.md` (the itch.io forms,
field by field), `docs/release/itch_page.md` (the text to paste), `docs/release/known_issues.md`, `docs/release/player_readme.txt`.

## A. Before the final build (the PC)

| # | Step | Who |
|---|---|---|
| 1 | **The `setx` memory step.** Run the `setx` command you and your assistant agreed on for Claude Code's memory, then open a new terminal so it takes effect. (The exact command is not written down anywhere in the repo; I did not guess it. See the inbox, "Fable Nov 21 review".) | **Owner** |
| 2 | **Remove the old Codex folder:** close the ChatGPT app (it holds a file in it open), then in PowerShell: `Remove-Item -Recurse -Force "C:\Users\asche\Documents\Codex"`. Everything in it is scratch from Nov 15; nothing in the game reads it. | **Owner** |
| 3 | Close what eats memory before a build or a test run: Chrome, the ChatGPT app, the Godot editor. The export wants 2.2 GB of free RAM and 2.5 GB of free disk; the test suite wants 0.9 GB. | Owner |
| 4 | Make sure the last art batch you want in 1.0 is imported and committed (Batch 19: the Buffet map redo, if it is ready; the game works without it). | Owner decides, Claude imports |

## B. Freeze the content

| # | Step | Who |
|---|---|---|
| 5 | Decide the open items in `docs/release/two_week_plan.md` ("Decide" column) and the six decisions at the top of `docs/overnight_report.md`. Anything not decided ships as it is today. | **Owner** |
| 6 | Apply the balance lines you approved in `docs/balance_report_nov21.md` (the Arena table, line by line). | Claude, from your ticks |
| 7 | Last text check: read `docs/release/itch_page.md` and `docs/release/known_issues.md`, edit them in your own words. | **Owner** |
| 8 | Put your donation link in `data/credits/credits.cfg` (`[support] url="..."`), or leave it empty: the "Support the game" buttons stay hidden while it is empty. You only have the link once the itch page exists (step 17), so this can wait until then and be followed by one more build. | **Owner** |
| 9 | Set the version: `project.godot` > `config/version` is already `1.0.0`. Add the release date and a short entry to `CHANGELOG.md`. | Claude |

## C. Test

| # | Step | Who |
|---|---|---|
| 10 | The whole test suite: `bash tools/run_tests.sh --min-free=900` (about 35 minutes). It must end with 0 failing and "Real saves: untouched". | Claude |
| 11 | The walk smokes (seven places), the NPC visibility probe, the fade probe, the quest hand-in probe (commands in `docs/HANDOFF.md`, section 2). | Claude |
| 12 | The four story bots, one per Path, new game to the postgame: `bash tools/run_story_bot_nov21r.sh <beefcake|necrocrat|gourmand|refusemancer>` (8 minutes each; 119 checks each, 0 failed on Nov 21). | Claude |

## D. Build

| # | Step | Who |
|---|---|---|
| 13 | `bash tools/export_windows.sh 1.0.0` in the foreground (about 5 minutes). It ends with `EXPORT OK` and writes `builds/TheWaywardPath-v1.0.0-windows.zip`. "EXPORT STOPPED" means nothing was replaced: free memory and run it again. | Claude |
| 14 | Check the exported game, not the editor: `bash tools/run_release_smoke_exported.sh` (look for `PASSED`), then `bash tools/export_test_pack.sh` and the three `bash tools/play_exported.sh docs/review/play_scripts/exported_rc1_{a,b,c}.txt` runs (0 SCRIPT ERROR each). | Claude |
| 15 | The read-me in the zip: done by the export since Nov 22. `bash tools/export_windows.sh 1.0.0` writes the player read-me (`docs/release/player_readme.txt`) as `README.txt`; a build for playtesters is made with `PLAYTEST_BUILD=1` in front and carries `README_PLAYTEST.txt` instead. Check which one is in the zip before the upload. | Claude (done) |
| 16 | **Play the real `.exe` yourself for 20 minutes** from the unzipped zip, on a fresh folder: a new game, the cave, Crosspath, one shop, one battle, save, quit, start again, Continue. If you can, do the same on a second PC. | **Owner** |

## E. The itch.io page (Draft the whole time)

| # | Step | Who |
|---|---|---|
| 17 | Create the project: Dashboard > Create new project. Title "The Wayward Path", kind "Downloadable", classification "Games". Leave it on **Draft**. (`itch_upload.md`, step 1) | **Owner** |
| 18 | Pricing: "$0 or donate", suggested 3 to 5 USD (or "No payments"). (`itch_upload.md`, step 2) | **Owner** |
| 19 | Paste the short description, the long description, the features, the controls and the system requirements from `docs/release/itch_page.md`. | **Owner** |
| 20 | The AI disclosure: answer **Yes** to "contains AI-generated content" and tick what applies (see `itch_page.md`, "AI disclosure": graphics, sound and music, text, and code). Paste the disclosure paragraph into the page body too. | **Owner** |
| 21 | Genre "Card Game", the ten tags from `itch_page.md`. | **Owner** |
| 22 | Upload the cover (`docs/release/screenshots/cover_630x500.png`) and the eight screenshots in their numbered order (`docs/release/screenshots/`). | **Owner** |
| 23 | Upload `builds/TheWaywardPath-v1.0.0-windows.zip` (about 770 MB: 5 to 15 minutes on a home connection; leave the tab open). Tick **Windows** on the file. | **Owner** |
| 24 | Save. Open "View page" and read it as a stranger would. Download the zip from the page once, unzip it into a new folder and start it: this proves the right file is up. | **Owner** |

## F. Playtesters (Restricted)

| # | Step | Who |
|---|---|---|
| 25 | Visibility > **Restricted**. Send your playtesters the secret link (or download keys from Distribute > Download keys) with `known_issues.md` and how to report (F8 in the game). | **Owner** |
| 26 | Collect their reports for a few days. Give the report folders (`%APPDATA%\Deckbuilder-RPG\feedback\`) to a Claude Code session to triage. | Owner, then Claude |
| 27 | Fix what is a blocker, rebuild (steps 10 to 14), replace the upload (delete the old file from Uploads so players get one file). | Claude builds, **Owner** uploads |

## G. Release day

| # | Step | Who |
|---|---|---|
| 28 | Tag the release commit: `git tag v1.0.0` and `git push origin main --tags`. | Claude, on your word |
| 29 | Last look at the page: the file's size and date, the screenshots' order, the donation setting, the AI disclosure. | **Owner** |
| 30 | **Visibility > Public. Save.** The page is live and reaches itch's "new releases" lists within the hour. | **Owner (only you)** |
| 31 | Optional: a short devlog post ("1.0 is out") from the project dashboard; put the page link in the in-game Support button if you have not (step 8) and ship that as 1.0.1 later. | **Owner** |

## H. After the release

| # | Step | Who |
|---|---|---|
| 32 | Keep `builds/TheWaywardPath-v1.0.0-windows.zip` and the tag; they are the only copy of exactly what players have. | Owner |
| 33 | Bug reports: a player sends the report folder F8 made; give it to a Claude Code session with one of the small prompts in `docs/HANDOFF.md`, section 6. Small fixes go out as 1.0.1 with butler (`itch_upload.md`, step 10), which uploads only what changed. | Owner + Claude |
