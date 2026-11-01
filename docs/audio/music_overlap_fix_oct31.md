# Music overlap fix (Overnight Oct 31 - Nov 1, Part 2)

**The bug**: a MIDI channel has one voice per pitch. In `tools/music/lib/score.py`, a held note's note-off was written at its own end even when the
same pitch had been struck again on that channel before then, so the re-strike was cut short at the old note's end. Pads, organ and choir
chords that repeat a pitch every bar (and any doubled note) thinned out to short stabs.

**The fix**: `note_spans()` merges each pitch per channel: notes starting together become one (longest, loudest); a re-strike ends the old
note at the re-strike and lasts to the later of the two ends. Unit test: `tools/music/tests/test_note_spans.py` (5/5).

**Re-render**: all 144 scores (123 MUS + 21 STG), `bash tools/music/rerender_all.sh render`. Loudness/seam rules held: every loop -20 LUFS,
every seam <= 1.5 dB after three loops got `Score.soften_tail(0.85)` (MUS-CAP-REF-BROKEN +1.66 -> +0.47, MUS-MINIGAME-NECRO +1.51 -> -0.54,
MUS-TUT-EXP +1.60 -> -0.51 dB: their ends rang on louder than their starts once the held notes stopped being cut), one-shots onset-checked.
Previous renders: `Superseded/Music_v01/<ID>_orch-v1b.ogg|wav` (144 files). New revision in the registry: `orch-v2`.
Previews (10): `Music Review/Overlap fix/` - MUS-FOREST, MUS-TUT-EXP, MUS-GOUR-EXP, MUS-NECRO-EXP, MUS-BEEF-BOSS, MUS-BEEF-FREED,
MUS-CAP-REF-BROKEN, MUS-CAP-RESTORED, MUS-PRIMM-01, MUS-CREDITS.

**Measure**: total sounding note time in the new MIDI vs the old (beats summed over every note), and the parts that gained most.
"Fuller" = held chords now last their written length instead of being chopped at each repeat. The lullaby (MUS-LULLABY) is among them
(its pad +55 beats); it is still waiting for your ears.

## Tracks that changed audibly (>= 5 % more sounding note time)

| Track | Note time | What you will hear |
|---|---|---|
| MUS-CAP-REF-BROKEN | +65.3% (461->763 beats) | Fuller double basses, glass/celesta bed: held chords ring their full length |
| MUS-CAP-NECRO-BROKEN | +39.7% (844->1179 beats) | Fuller glass/celesta bed: held chords ring their full length |
| MUS-MEM-02 | +38.9% (380->528 beats) | Fuller glass/celesta bed, string pad, double basses: held chords ring their full length |
| MUS-REF-DUN-EXP | +35.4% (1781->2412 beats) | Fuller string pad, cellos, double basses: held chords ring their full length |
| MUS-MINIGAME-NECRO | +35.0% (682->922 beats) | Fuller organ, pizzicato: held chords ring their full length |
| MUS-NECRO-DUN-BATTLE | +34.3% (2322->3118 beats) | Fuller tremolo strings, organ, choir: held chords ring their full length |
| MUS-NECRO-DUN-EXP | +34.1% (1255->1682 beats) | Fuller organ, choir, tremolo strings: held chords ring their full length |
| MUS-GALLERY | +32.8% (316->419 beats) | Fuller string pad, piano, double basses: held chords ring their full length |
| MUS-NECRO-EXP | +32.8% (1796->2384 beats) | Fuller organ, tremolo strings, choir: held chords ring their full length |
| MUS-NECRO-BATTLE | +29.9% (2066->2683 beats) | Fuller tremolo strings, choir, organ: held chords ring their full length |
| MUS-TUT-EXP | +29.2% (915->1182 beats) | Fuller string pad, double basses, cellos: held chords ring their full length |
| MUS-NECRO-BOSS | +28.8% (2750->3542 beats) | Fuller tremolo strings, organ, choir: held chords ring their full length |
| MUS-SHOP-LEDGERBONE | +28.4% (576->740 beats) | Fuller organ: held chords ring their full length |
| MUS-CAP-GOUR-RESTORED | +28.3% (1068->1371 beats) | Fuller string pad, glass/celesta bed: held chords ring their full length |
| MUS-PRIMM-BREAK | +28.1% (543->695 beats) | Fuller string pad, double basses: held chords ring their full length |
| MUS-NECRO-FREED | +28.0% (1779->2277 beats) | Fuller organ, string pad, choir: held chords ring their full length |
| MUS-THRONE | +27.0% (714->906 beats) | Fuller string pad, choir, cellos: held chords ring their full length |
| MUS-WAIT-BATTLE | +25.5% (2129->2673 beats) | Fuller tremolo strings, organ, timpani: held chords ring their full length |
| MUS-MEM-04 | +25.5% (458->575 beats) | Fuller string pad, double basses, harp: held chords ring their full length |
| MUS-QUEST-ROLLO | +25.2% (615->770 beats) | Fuller string pad, double basses, harp: held chords ring their full length |
| MUS-LULLABY | +25.1% (262->328 beats) | Fuller string pad, harp, double basses: held chords ring their full length |
| MUS-GOUR-RELEASE | +23.7% (529->655 beats) | Fuller string pad, piano: held chords ring their full length |
| MUS-CAP-GOUR-BROKEN | +22.8% (906->1113 beats) | Fuller glass/celesta bed, string pad: held chords ring their full length |
| MUS-GRAVE-EXP | +22.5% (1111->1362 beats) | Fuller string pad, tremolo strings, harp: held chords ring their full length |
| MUS-BEEF-DUN-EXP | +22.3% (1888->2310 beats) | Fuller string pad, percussion, timpani: held chords ring their full length |
| MUS-BEEF-RELEASE | +22.3% (646->790 beats) | Fuller string pad, double basses, timpani: held chords ring their full length |
| MUS-CAP-FACADE-EXP | +22.2% (1455->1778 beats) | Fuller double basses, glass/celesta bed, pizzicato: held chords ring their full length |
| MUS-CAP-NECRO-RESTORED | +22.1% (1577->1925 beats) | Fuller organ, string pad, choir: held chords ring their full length |
| MUS-TUT-BOSS | +21.4% (2482->3012 beats) | Fuller string pad, horns, choir: held chords ring their full length |
| MUS-REUNION | +21.3% (699->848 beats) | Fuller string pad, double basses, harp: held chords ring their full length |
| MUS-FOREST | +20.9% (1235->1493 beats) | Fuller string pad, double basses, cellos: held chords ring their full length |
| MUS-MEM-03 | +20.9% (782->945 beats) | Fuller string pad, tremolo strings, horns: held chords ring their full length |
| MUS-CAP-BEEF-BROKEN | +20.7% (1158->1397 beats) | Fuller glass/celesta bed, string pad: held chords ring their full length |
| MUS-OMAKASE-BOSS | +20.2% (2074->2493 beats) | Fuller string pad, timpani, double basses: held chords ring their full length |
| MUS-NECRO-RELEASE | +20.2% (731->879 beats) | Fuller organ, string pad, harp: held chords ring their full length |
| MUS-DECK | +20.1% (929->1115 beats) | Fuller string pad: held chords ring their full length |
| MUS-BEEF-FREED | +20.1% (2063->2476 beats) | Fuller string pad, harp, timpani: held chords ring their full length |
| MUS-QUEST-FERN | +19.4% (685->818 beats) | Fuller string pad, double basses, harp: held chords ring their full length |
| MUS-OMAKASE-EXP | +19.4% (1095->1308 beats) | Fuller string pad, harp: held chords ring their full length |
| MUS-SHOP-BENCHLEY | +18.8% (758->901 beats) | Fuller string pad, percussion: held chords ring their full length |
| MUS-VAULT-BATTLE | +18.4% (1975->2339 beats) | Fuller string pad, double basses, cellos: held chords ring their full length |
| MUS-WAIT-EXP | +18.0% (1223->1444 beats) | Fuller string pad, organ: held chords ring their full length |
| MUS-BEEF-BOSS | +18.0% (1935->2283 beats) | Fuller tremolo strings, percussion, horns: held chords ring their full length |
| MUS-CREDITS | +17.6% (3846->4524 beats) | Fuller string pad, organ, choir: held chords ring their full length |
| MUS-GOUR-DUN-EXP | +17.6% (1561->1835 beats) | Fuller string pad, harp, timpani: held chords ring their full length |
| MUS-OMAKASE-BATTLE | +17.5% (1865->2191 beats) | Fuller string pad, timpani, brass: held chords ring their full length |
| STG-PACK-COMMON | +17.5% (10->12 beats) | Fuller harp: held chords ring their full length |
| MUS-WAIT-BOSS | +17.4% (2365->2777 beats) | Fuller tremolo strings, organ, choir: held chords ring their full length |
| MUS-GOUR-BATTLE | +16.8% (1602->1871 beats) | Fuller spad, choir, timpani: held chords ring their full length |
| MUS-CAP-FACADE-BATTLE | +16.6% (2226->2595 beats) | Fuller cellos, glass/celesta bed, timpani: held chords ring their full length |
| MUS-LAB-CELL | +16.3% (462->537 beats) | Fuller string pad, harp, piano: held chords ring their full length |
| MUS-MINIGAME-BEEF | +16.2% (1072->1245 beats) | Fuller string pad, double basses, horns: held chords ring their full length |
| MUS-GOUR-BOSS | +16.0% (1973->2288 beats) | Fuller string pad, tremolo strings, choir: held chords ring their full length |
| MUS-CAP-BEEF-RESTORED | +15.8% (1652->1914 beats) | Fuller string pad, harp, timpani: held chords ring their full length |
| MUS-CAP-RESTORED | +15.8% (2212->2561 beats) | Fuller string pad, choir, harp: held chords ring their full length |
| MUS-PRIMM-DEFEAT | +15.8% (466->540 beats) | Fuller string pad, piano, harp: held chords ring their full length |
| MUS-PRIMM-02 | +15.7% (2064->2388 beats) | Fuller string pad, organ, double basses: held chords ring their full length |
| MUS-LAB-EXP | +15.6% (2650->3064 beats) | Fuller string pad, cellos: held chords ring their full length |
| MUS-VAULT-EXP | +15.5% (1499->1731 beats) | Fuller string pad, harp, cellos: held chords ring their full length |
| MUS-PRIMM-01 | +15.2% (3420->3939 beats) | Fuller string pad, choir, cellos: held chords ring their full length |
| MUS-GOUR-DUN-BATTLE | +15.2% (1992->2294 beats) | Fuller string pad, choir, tremolo strings: held chords ring their full length |
| MUS-MEM-01 | +15.0% (639->735 beats) | Fuller string pad, piano, harp: held chords ring their full length |
| MUS-VAULT-BOSS | +14.7% (2205->2530 beats) | Fuller tremolo strings, string pad, choir: held chords ring their full length |
| MUS-GRAVE-BATTLE | +14.6% (1735->1988 beats) | Fuller tremolo strings, string pad, trombones: held chords ring their full length |
| MUS-PRIMM-03 | +14.4% (2664->3049 beats) | Fuller string pad, choir, horns: held chords ring their full length |
| MUS-CAP-OUT-EXP | +14.4% (1000->1145 beats) | Fuller wind, glass/celesta bed, harp: held chords ring their full length |
| MUS-SWOLY-BATTLE | +14.4% (2397->2743 beats) | Fuller string pad, horns, trombones: held chords ring their full length |
| MUS-SWOLY-BOSS | +14.0% (2108->2402 beats) | Fuller string pad, percussion, timpani: held chords ring their full length |
| MUS-REF-DUN-BATTLE | +14.0% (3161->3603 beats) | Fuller string pad, tremolo strings, double basses: held chords ring their full length |
| MUS-ARENA-ELITE | +14.0% (1656->1887 beats) | Fuller string pad, choir, double basses: held chords ring their full length |
| MUS-GOUR-FREED | +13.4% (1984->2250 beats) | Fuller choir, spad, timpani: held chords ring their full length |
| MUS-SHIRO-BOSS | +12.9% (1434->1619 beats) | Fuller string pad, timpani, double basses: held chords ring their full length |
| MUS-TUT-BATTLE | +12.9% (1843->2080 beats) | Fuller string pad, tremolo strings, percussion: held chords ring their full length |
| MUS-LAB-RESCUE | +12.7% (748->843 beats) | Fuller string pad, tremolo strings, harp: held chords ring their full length |
| MUS-TOWN | +12.6% (1926->2169 beats) | Fuller string pad, choir, harp: held chords ring their full length |
| MUS-BEEF-DUN-BATTLE | +12.6% (2293->2582 beats) | Fuller string pad, tremolo strings, timpani: held chords ring their full length |
| MUS-GOUR-EXP | +12.1% (1362->1526 beats) | Fuller choir, spad, brass: held chords ring their full length |
| MUS-ARENA-BATTLE | +12.0% (1626->1822 beats) | Fuller string pad, cellos, double basses: held chords ring their full length |
| MUS-BEEF-EXP | +11.9% (1491->1669 beats) | Fuller string pad, percussion, horns: held chords ring their full length |
| MUS-SWOLY-EXP | +11.9% (2028->2270 beats) | Fuller string pad, harp, trombones: held chords ring their full length |
| MUS-SIPHON-BOSS | +11.8% (3890->4350 beats) | Fuller string pad, timpani: held chords ring their full length |
| MUS-REF-BOSS | +11.4% (2794->3113 beats) | Fuller string pad, tremolo strings, timpani: held chords ring their full length |
| MUS-MAREN | +11.3% (580->645 beats) | Fuller string pad, bassoon, double basses: held chords ring their full length |
| MUS-ARCHIVE | +11.3% (636->708 beats) | Fuller string pad: held chords ring their full length |
| MUS-TITLE | +11.3% (2153->2396 beats) | Fuller string pad, choir, harp: held chords ring their full length |
| MUS-TOWN-FREED | +11.2% (1990->2214 beats) | Fuller string pad, harp, percussion: held chords ring their full length |
| MUS-PRIMM-MOTIF | +10.3% (481->531 beats) | Fuller string pad: held chords ring their full length |
| MUS-TOWN-BATTLE | +10.3% (2359->2601 beats) | Fuller string pad, double basses, percussion: held chords ring their full length |
| MUS-QUEST-PELL | +10.3% (405->447 beats) | Fuller organ, string pad, double basses: held chords ring their full length |
| MUS-REF-RELEASE | +8.7% (1073->1166 beats) | Fuller string pad, harp, vln: held chords ring their full length |
| MUS-LAB-BATTLE | +8.6% (2929->3181 beats) | Fuller string pad, timpani, stab: held chords ring their full length |
| MUS-BEEF-BATTLE | +8.4% (1962->2128 beats) | Fuller string pad, brass, percussion: held chords ring their full length |
| MUS-REF-BATTLE | +7.6% (2691->2895 beats) | Fuller string pad, tremolo strings, timpani: held chords ring their full length |
| MUS-QUEST-MARLO | +7.5% (513->551 beats) | Fuller string pad, double basses, harp: held chords ring their full length |
| MUS-SHOP-MIREPOIX | +6.5% (675->719 beats) | Fuller string pad: held chords ring their full length |
| MUS-CAP-REF-RESTORED | +6.4% (1760->1873 beats) | Fuller string pad, horns, double basses: held chords ring their full length |
| MUS-SHOP-SABLE | +6.2% (837->889 beats) | Fuller percussion, string pad: held chords ring their full length |
| MUS-PANDA-BATTLE | +6.1% (2572->2730 beats) | Fuller string pad, tremolo strings, horns: held chords ring their full length |
| MUS-SHOP-THREADWELL | +5.7% (949->1003 beats) | Fuller percussion, string pad: held chords ring their full length |
| MUS-PANDA-BOSS | +5.0% (2032->2134 beats) | Fuller string pad, tremolo strings, timpani: held chords ring their full length |

## Slight change (1-5 %): held notes a little longer, hard to hear

STG-ZONE-NECRO (+4.8%), MUS-REF-FREED (+4.0%), MUS-SHOP-ALEMBIC (+3.8%), MUS-SHOP-FENWICK (+3.8%), MUS-PANDA-EXP (+3.7%), MUS-SHOP-ALEMBIC-POST (+3.7%), MUS-REF-EXP (+3.0%), MUS-TUNNEL-EXP (+3.0%), MUS-TUNNEL-BATTLE (+2.8%), MUS-CREASE (+2.7%), STG-ZONE-BEEF (+2.5%), MUS-CAP-OUT-BATTLE (+2.4%), STG-DUNGEON (+2.4%), MUS-SHOP-BELLOWS (+2.0%), MUS-SHOP-FIGSLY (+1.4%), MUS-CAP-CORRECTION (+1.4%), STG-ARENA (+1.4%), STG-VICTORY (+1.3%), STG-PACK-LEGEND (+1.2%)

## No measurable change (< 1 %)

MUS-CASTLE-EXP, STG-ZONE-GOUR, STG-CRAFT, MUS-QUIZ, MUS-MINIGAME-GOUR, MUS-TUNNEL-BOSS, MUS-SHOP-GRISTLE, STG-DEFEAT, STG-CRAFT-POST, STG-RIFT, MUS-MINIGAME-REF, MUS-CAP-ENFORCER, MUS-CASTLE-BATTLE, MUS-CAP-RIFT, MUS-SHOP-BEETSWORTH, MUS-SHOP-TONIC, STG-LEVEL, STG-MINI-FAIL, STG-MINI-SUCCESS, STG-PACK-RARE, STG-PURCHASE, STG-QUEST, STG-SECRET, STG-SHIRO, STG-ZONE-REF
