# Wayfinding critic, run 2 (Nov 11, exported RC4-tree test pack after Parts 2.2 and 3)

(Saved by the main session from the critic's final message: its own write to this file was refused.)

| Zone | Game time | Runs | Reached | Clarity |
|---|---|---|---|---|
| The Verdant Dump (the Rotheart) | 1448 s (24.1 min) | 39 | no | 5/10 |
| The Gainlands (the House of Gains) | 1117 s (18.6 min) | 24 | yes, `wy2_gain24_enter.png` | 6/10 |

Scripts `docs/review/play_scripts/wy_dump_01..39.txt`, `wy_gain_01..24.txt`; shots `_screenshots/exported/wy2_*.png`. Times = the sum of each
run's last play-log timestamp. Most lost time was traversal, not knowing where to go: the scripted player cannot watch the arrow live, so it
caught on props, NPCs, railings and stair edges, and roamers started fights; every resume re-walks from the zone entrance (25-60 s).

## Top three fixes

1. **Clear the blocking spots on the arrow's own routes.** Dump: the hero wedges between the Harvest Meal table/stall and an NPC at
   (39.4, 112.1) (no key moves him; on the town -> bean line); the stair edges north of town at x 75 / 81. Gainlands: the stone bridge at
   (37, 20) only lets you on from about one spot. Move roamers off the single lane to the current goal (the Dump's Mossy Trash Golem at
   (33, 109); the Gainlands road guard ~8 m from the entrance attacks on every arrival).
2. **The world arrow and its floating label follow the "Point me to..." pick** (after picking the scavenger goal the map redrew its route but
   the world label still said "Root Cause: Billie Muckfoot"). The list also reorders and moves between visits; Escape after a pick opened the
   pause menu instead of just closing the map.
3. **The quest log's "Where to go" line true to the world.** Gainlands: "Nothing is locked... the middle road climbs straight to it from the
   bridge" - the middle road stops at the sign boards past Old Man Mountain (z 67.1); the real route goes west and over the stone bridge.
   Dump: the line still listed the bean after it was planted; it does not say which stable lends the barricade mount (one in town, one across
   the stream); the mount is lost on resume.

## The Verdant Dump - not reached, 5/10

Route: runs 1-5 the "Where to go" line named three favour givers; up the entrance bridge to Brother Bramble (`wy2_dump03_w3`), his second
talk gave Who Ate the Compost?. Runs 6-17: two scavengers needed, 9 blue circles on the map; both fights from a Hungry Scarecrow roaming NE of
town (~(71, 110)). Run 18: hand-in finished the favour; the main quest then showed its best line (`wy2_dump19_journal`). Runs 20-32: bean at
(34, 106), planted 8 m west at (25.5, 107), vine bridge grew (13 runs, walking problems only). Runs 34-38: over the vine bridge to the stable at
(30, 86), mounted, rode north and burst a dam at ~(27, 72) (the side quest's barricade, not the main one). Run 39: wedged at (39.4, 112.1) for
18 s (`wy2_dump39_c`), cap hit; the stairs barricade (~(49, 47)) and the root gate (~(51, 14)) never reached.

Confusion: the arrow label did not follow the pick (`wy2_dump07_arrow`, `wy2_dump08_e`, ~50 s); list rows reordered / the panel moved; a
second Escape after a pick opened the pause menu (`wy2_dump02_w3`); the log still said "plant the bean" after it was done
(`wy2_dump33_journal`); the scavenger quest never says what a scavenger looks like; the same arrival hit ("SCREEEE! ... (-2 HP)") on every load
and no healing in the zone; two stables, the town one (36, 128.8) shares its E spot with Billie; the mount gone after a resume.
Blocked spots: the Harvest Meal wedge (`wy2_dump22_b`, `wy2_dump39_c`); stair edges (75.2, 98.8) and (81.6, 93.5) (`wy2_dump14_a`,
`wy2_dump15_c`); the golem fight on the bean path nearly every run; animals and NPCs (animal_2, Wren, Billie) knocking the hero off line.
Markers that lied: the label stayed on Billie; the bean stayed listed as a blocker; the stable goal did not say which stable.
5/10: the text said exactly what bars the Rotheart, but the arrow did not visibly follow the pick and the town is too crowded to walk a line.

## The Gainlands - reached, 6/10

Route: runs 1-6 three favour givers named, the map's default route straight north; a road-guard fight ~8 m in on every run (~10 s each); at
~(55.6, 79) E talked to Old Hob the Gravedigger (mistaken for the target); Old Man Mountain at (56, 69.9), second talk gave Spot Me!. Runs
7-9: "Point me to..." led to Gary at (78.9, 80.5) east of the hot tub; spotting worked (`wy2_gain09_gary2`). Runs 10-11: Mountain would not
take the hand-in; the list showed a Flex Mirror step at (43.9, 83); flexing unlocked it. Run 12: hand-in opened Storm the House of Gains with
the "middle road climbs straight" text (`wy2_gain12_journal`). Runs 13-24: straight north stops at z 67.1 at the sign boards
(`wy2_gain14_b`); the arrow pointed west round a low edge; west to x 43 and north, the road drifts west to the stone bridge at (37, 20); its
west end only lets you on after a tiny W then D (runs 17-21, `wy2_gain17_a`, `wy2_gain20_b`); east over the bridge, north up the plaza, east
5 m to the door: "[E] Enter the House of Gains" and the confirmation dialog (`wy2_gain24_enter`).

Confusion: the "middle road straight" text vs the blocked road (~120 s); Mountain's interact id is "brenda" and Old Hob stands ~9 m before him
on the same road; the Flex Mirror step only in the point-me list, never in the HUD tracker; the sticky bridge entrance; the road pulls west
away from the House at x 56; the door dialog's title is "???".
Markers that lied: the "middle road climbs straight" text; the arrow onto the bridge whose entrance mostly refuses; Mountain with no "not yet"
before the mirror step.
6/10: people named and close, the goal list always had a correct next row, the House visible from the plaza; the one route sentence was
wrong and the bridge cost ~4 runs.

No game file edited; no Godot left running.
