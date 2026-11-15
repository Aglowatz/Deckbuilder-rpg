# Fable Nov 15: the owner's four fixes, plus the Batch 16 import when it lands

Repo: C:\Dev\Deckbuilder-rpg (Godot 4.7.2, "The Wayward Path"). Read the top of docs/overnight_report.md (Fable Nov 14) first. Run `git status`; if anything is left uncommitted, run the tests and commit it. Log questions under "Fable Nov 15". Tag `pre-fable-nov15`.

## House rules
Same as docs/prompts/fable_nov14_owner_list.md:
- ONE Godot at a time; no sub-agents while Godot runs.
- `tools/run_tests.sh --min-free=900`.
- Commit and push after each part.
- Before/after shots in docs/overnight_shots/nov15/.
- No difficulty setting, no battle-board layout changes, Primm's fight unchanged, no public upload.

## Part 1 — Outside the D.N.A.: a wasteland like outside the Capital
Last pass's rows of cabinets and crates still don't read as a wasteland. The owner's reference is the Capital's outer wasteland (`docs/overnight_shots/nov15/ref_capital_wasteland.png`; take your own matching shot of the Capital gate approach first):
- cracked grey-brown ground;
- broken low stone walls and rubble piles;
- dead twisted trees and purple crystal clusters;
- dark tufts of dead grass;
- old lamp posts;
- the odd fallen statue;
- soft dusty light.

**Rebuild everything outside the D.N.A.'s playable buildings in that style:**
- **Reuse the Capital's outer ground material and its wasteland kit** (CAP-WALL-RUIN, CAP-SHEET-RUBBLE, CAP-PROP-RUBBLE-ROW, CAP-TREE-DEAD, CAP-PLANT-CRYSTAL, CAP-DEC-ASH, CAPI-PROP-STATUE-FALLEN, lamp posts and the dead grass tufts), tinted toward the D.N.A.'s grey-green.
- A few office touches can stay as debris (a tipped cabinet, a drift of paper) but **the ground and the overall look must match the Capital wasteland.** No flat grey tiles and no neat furniture rows.
- **Keep the floating paper effect** everywhere outside.
- Match the edges and fog to the Capital's, so nothing reads as void.
- Shoot the same cameras before and after. Check FPS on Medium.

## Part 2 — Mortimer Grimsby at the D.N.A.'s Rift Station
After the zone is freed, Mortimer stands on the Rift Station and overlaps it. **Move him to the left side of the entrance room**, in open space where he doesn't overlap any NPC, prop, counter, label or the station. Check his name label, his talk prompt and the NPC visibility probe. Check his position before and after freeing too, if he has two spots.

## Part 3 — 3D NPCs
- Next to Pip Threadwell in Crosspath there's a **blocky 3D character you can't talk to.** Remove it, or replace it with a painted townsfolk sprite (SPR-TOWNSFOLK-A/B/C or SPR-CITIZEN) if the spot needs life.
- **Scan every zone and interior** for any other 3D or placeholder NPC mesh (capsules, blocky low-poly people, untextured figures). Remove or replace each one with a painted sprite. List them in the report.
- Add a test or driver check that fails if a non-sprite humanoid NPC is placed in a zone.

## Part 4 — Every fight shows every rule in effect
In the Capital, the Correction Officer's troops get +1/+1, but the fight doesn't say so anywhere, so players are confused.
1. **Fix this fight:**
   - name the +1/+1 as a rule (e.g. "Regime Drill: their units get +1/+1") on the "Before the fight" panel and in the battle's rule icons, which stay on screen with hover text;
   - units that have the buff show it the usual way (green numbers, and the base value in the tooltip).
2. **Audit every encounter** (roamers, dungeon nodes, bosses, gatekeepers, the Gallery, the Undercroft, the challenges): for each one, compare every modifier actually applied in code (encounter scripts, `modifiers.json`, zone effects, the boss phases, auto-summoned tokens, starting buffs) with the rules shown on the pre-fight panel and during the fight.
   - Anything applied but not shown gets a rule entry with an icon, a name and one line of text.
   - Hidden traits stay "?" by design, but must still be listed as "Hidden trait ?".
3. Add a test that fails when an encounter applies a modifier that has no displayed rule.
4. Report the encounters that were missing rules.

## Part 4b — Shops and pack opening
1. **Scrolling shops need a visible scrollbar.**
   - In Fig's "Gilded Goods" pack shop, only three packs fit and the fourth (Necrocrat) is cut off at the right edge with nothing showing there's more.
   - Add a visible, styled horizontal scrollbar (in the shop's gold theme). Mouse wheel, drag and controller left/right must all scroll it.
   - **Check every shop and list screen** (every vendor tab, the Card Packs page, the Deck Station, the collection, the Wardrobe, the item lists) and add the same scrollbar wherever content can overflow.
   - Test at 1280x720 and 1920x1080, with Large text.
2. **Pack-opening icon clipped:**
   - On the pack-opening screen, the Path icon in the round medallion in the middle of the pack is cut off at the bottom of the circle (seen on the Gilded Necrocrat Pack).
   - Fix the icon's size, position and mask so the whole icon sits centred inside the circle, for every pack type (the four Paths, General, Gilded, Prismatic), both in the shop and on the opening screen.
3. **Path icons on the packs:**
   - The Gilded Necrocrat pack shows a skull with a quill. The style guide says the Necrocrat icon is the skull in green ghost-flame, never a quill.
   - Its wrapper also has a **dumbbell** pattern, which belongs to Beefcake.
   - If the medallion is drawn by code, use the canonical icon.
   - If it's painted into the pack art, overlay the canonical icon in code for now and add a Batch 16 follow-up row (UI-PACK-GILDED and any pack whose wrapper pattern shows another Path's symbol) to docs/art/batch16_nov14.csv. Mention it in the report so the owner can add it to the ChatGPT run.
   - Check every pack's medallion and wrapper pattern against docs/art/path_icon_style_guide.md.

## Part 5 — Import Batch 16 (if it has landed)
The owner is making Batch 16 in ChatGPT from `docs/prompts/chatgpt_batch16.md` (20 items: the Fig Sly fix with exactly two hands, the Path-icon repaints, Sergeant Scuff, the Rescuer's walk, the shore stones, the Crease stalls, and the rest).
- Check for the files at the start of each part: they'll be put in their Approved_* folders on the Drive, named as in docs/art/batch16_nov14.csv. The replaced originals go to `Superseded/Batch 16 replaced/`.
- **When they're there,** import them and wire each one in as its CSV row says:
  - **Fig Sly's new portrait in the shop and in dialogue** (count the hands in the screenshot: two);
  - the Path-icon repaints wherever they're used (story stills, card backs, the feat badge, the plinths, the banners, the logo, the app icon and the wordmark, including the itch page kit and the export icon);
  - Sergeant Scuff as the service-tunnel boss (dialogue portrait, cut-out, bestiary), replacing the Correction Officer stand-in;
  - the Rescuer's walk cycle wherever she moves;
  - the shore stones on Crosspath's lake bank;
  - the Crease stalls and crates;
  - Quadzilla's and Cairn's dialogue portraits;
  - the D.N.A. crates and tipped cabinet (use them in Part 1's debris too).
- Mark the rows "In game" and screenshot each one.
- If the files haven't landed by the end of Part 4, skip this part. It'll run as its own short task later.

## Part 6 — Verify and build
1. Walk-test:
   - outside the D.N.A.;
   - the D.N.A. Rift Station room, freed and not freed;
   - Crosspath around Pip;
   - the Capital Correction Officer fight (rules visible);
   - three other fights with modifiers;
   - any Batch 16 art that was imported.
2. All test shards green.
3. **Export 1.0.0 again:**
   - wait up to 10 minutes for at least 2.2 GB free RAM;
   - in the foreground, run `EXPORT_LOW_MEMORY_OK=1 bash tools/export_windows.sh 1.0.0`;
   - then the exported smoke and the three `play_exported.sh` checks.
   - If there's no memory, put the commands at the top of the report.
4. **docs/overnight_report.md**, with at the top:
   - each part done or not, with before/after shots;
   - the 3D NPCs found;
   - the encounters that were missing rules;
   - the Batch 16 import status;
   - where the zip is.
5. Commit and push. No public upload.
