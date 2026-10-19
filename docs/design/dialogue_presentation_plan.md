# Dialogue presentation plan (Overnight Oct 18, Part 5 - plan only)

Planning document: nothing here is implemented tonight, and no art was generated. The image list is `docs/art/portrait_expression_requests.md`
(+ `.csv`); the speaker audit is `node tools/dialogue_audit.js`; the request list is regenerated with `node tools/portrait_expression_requests.js`.

## Where the game is today

The dialogue box (`ui/town/dialogue_box.gd`) already has more of this than the brief assumed:

| Feature | Today | Gap |
|---|---|---|
| Name plate | A plate with the speaker's name over the box's top edge (`_build_plate`, `_plate_text`), shown for every speaker. | Plain style; no colour per speaker or Path, no title line ("Elder of Crosspath"). |
| Portrait | `PortraitView` stands the NPC's portrait behind the box (left or right), fades in/out, slides, has a `set_talking` flag (currently only stored). | No talking motion; no swap animation between expressions. |
| Expressions | A line may start with `[happy] ...`; `Portraits.texture_for(id, "happy")` loads `<ID>_HAPPY.webp` and falls back to the base portrait. 13 expression images exist (Elder happy/worried, Gatekeeper happy/stern, Wanderer confused/determined, Bertram proud, Fenwick excited, Sable pleased/scheming, Threadwell delighted, Tonic excited/oops). | Almost no lines are tagged (4 `[revealed]` tags in all the story files); no defaults, no families (a `[happy]` tag on Sable does not find SABLE_PLEASED). |
| Typewriter text | `visible_ratio` tween at `Settings.dialogue_chars_per_second()` (Settings: text speed); the first advance finishes the line, the next one moves on. | Even speed: no pause on punctuation, no per-character speed, no emphasis. |
| Voice blips | none | Everything. |

Other places that put words on screen: story stills (`ui/screens/story_still_screen.gd`, narration over a painting), the dungeon map and
rewards screens (they open a DialogueBox), vendor speech bubbles (`_say` in the vendor screens), world barks (floating bubbles over NPCs,
`npc_truth_input.json` lines), the rift trip and the giant-chest event. Bosses speak only through the dungeon map's box before and after
their fight.

## 1. Portrait expressions

**Standard set**: NEUTRAL (the base portrait), HAPPY, SAD, ANGRY, SURPRISED, THINKING. Plus character-specific extras where the story needs a
look the set lacks (Primm BROKEN, Flex FRAIL / REVEAL, Hob OMINOUS, the corrupted NPCs FREED, Elowen SOFT, the lieutenants DEFEATED...).

**Families**: every specific expression belongs to one standard slot, so a tag always finds the closest image a character has:

| Slot | Family (examples) |
|---|---|
| HAPPY | happy, pleased, delighted, warm, proud, excited, cheering, grinning, approving, impressed, hopeful, relieved, gracious, freed |
| SAD | sad, worried, tearful, exhausted, disappointed, frail, doubtful, soft, nostalgic, defeated, broken |
| ANGRY | angry, stern, furious, enraged, outraged, indignant, disapproving, unimpressed, exasperated, fierce, defiant, shouting |
| SURPRISED | surprised, oops, shocked, horrified, overwhelmed, panicked, sweating, nervous, awakened, revealed |
| THINKING | thinking, confused, suspicious, scheming, conspiratorial, calculating, mysterious, sly, smug, fascinated, denying, ominous |

Lookup for `[tag]` on character C: (1) `C_TAG` if it exists; (2) the first image of C in TAG's family (a `[happy]` on Sable shows
SABLE_PLEASED; a `[worried]` on Gatekeeper with no WORRIED shows... nothing in SAD yet, so (3)); (3) the base portrait. Families live in one
data file (`data/npcs/expression_families.json`) so the writer can move a word between slots.

**Swap**: when the expression changes between lines, a 0.12 s cross-fade plus a 2-3 px "pop" (scale 1.0 -> 1.02 -> 1.0); no slide.
**Talking**: while the typewriter runs the portrait gets a subtle 1.5 % vertical "breathing" bob at ~3 Hz (no mouth flaps: the art has none).

## 2. How a line gets its expression

Format (unchanged, already parsed by `DialogueBox._split_expression`): `[expr] Text`. Additions:

- `[expr]` may appear mid-line once (`"Fine. [angry] Fine!"`): the box swaps when the typewriter reaches it.
- `[=]` keeps the previous line's expression; a line without a tag uses the **default**.
- **Defaults**, in order: the line's key context (`*.victory*` / `*.freed*` -> HAPPY, `*.defeat*` / `*.loss*` -> SAD or ANGRY for bosses,
  `*.intro*` of a boss -> the boss's signature look), then the character's `default_expression` in `npcs.json` (Primm GRACIOUS, Sable
  SCHEMING, the citizens SMILING), then NEUTRAL.
- **Heuristics** (a tool, not runtime): `tools/tag_expressions.js` proposes tags for untagged lines - "!" + "?" -> SURPRISED, "!" alone
  with words like no/never/how dare -> ANGRY, "..." openings and sorry/miss/lost -> SAD, ha/wonderful/thank -> HAPPY, hmm/perhaps/I
  wonder -> THINKING - writes them as a review CSV (key, line, proposed tag, reason), and only the lines the writer accepts are written
  back into the story files. Runtime never guesses, so a line reads the same every time.

## 3. Typewriter text

- Keep the current speed setting (Slow / Normal / Fast / Instant) and click-to-finish.
- Pauses: +0.18 s after `. ! ?`, +0.08 s after `, ; :` and before `-`, +0.3 s at `...` (scaled by the speed setting; none at Instant).
- Inline markup for the writer: `{slow}...{/slow}` (half speed), `{p}` (0.4 s beat), `*word*` emphasis (bold + 1-frame shake). The
  `visible_ratio` tween becomes a per-character timer that reads these.
- Accessibility: Instant always available; a "Dialogue auto-advance" setting (off by default) moves on 1.2 s + 0.03 s per character
  after a line completes.

## 4. Voice blips

- One short blip per 2-3 revealed letters (skipping spaces and punctuation), each a tiny sample pitched per character, like Animal
  Crossing / Undertale. No voice acting.
- **Voice profile** per speaker in `npcs.json`: `voice: {bank, pitch, variance, rate}`; banks are 4-6 short CC0 blips (soft, chirpy,
  gruff, hollow (undead), squeaky (small animals), regal), made with the existing `tools/build_sfx` pipeline from approved sources or
  synthesized (MusicSynth already synthesizes). Defaults by species and role (bears gruff, Necrocrat dead hollow, royals regal) so every
  NPC has a voice on day one.
- Mixed on the SFX bus at -18 dB, ducking nothing; a "Voice blips" volume slider (0 = off) in Settings > Audio.
- Expression nudges the voice: ANGRY +rate -pitch, SAD -rate -pitch, SURPRISED +pitch, HAPPY +variance.

## 5. Name plates

- The plate keeps its place and shows **name + a small title line** (from `npcs.json` role, short form: "Elder of Crosspath",
  "Arena master"), the plate edge tinted by the speaker's Path (neutral gold for townsfolk), a tiny Path glyph for Path leaders.
- The Wanderer's own lines use an italic "inner voice" style with no portrait when they are thoughts (`(thought)` key or `[think]` tag).
- Unknown speakers show "???" until introduced (a `known_<npc>` flag), which the story already implies for Old Hob and the Rescuer.

## Screens and systems that change

| Piece | Change | Effort |
|---|---|---|
| `ui/town/dialogue_box.gd` | per-character typewriter with pauses/markup, mid-line tags, expression swap, blip calls, plate title + tint | 1 day |
| `ui/*/portrait_view.gd` | cross-fade swap, talking bob | 0.25 day |
| `core/data/portraits.gd` | family lookup (`texture_for(id, tag)` -> exact, family, base) + `expression_families.json` | 0.25 day |
| `app/` (new `VoiceBlips` autoload or part of `UiSounds`) | banks, per-speaker profile, rate limiting, settings slider | 0.5 day |
| `data/npcs/npcs.json` + `tools/npc_truth.js` | `default_expression`, `voice`, short `title` per NPC | 0.25 day (+ writer time) |
| `tools/tag_expressions.js` | heuristic tag proposals as a review CSV, then write-back | 0.5 day |
| Story files (`data/story/*.tres`), `npc_truth_input.json` barks | tags on the important lines (story beats first) | 1-2 days of writing review |
| Story stills, vendor bubbles, world barks | stills: same typewriter + blips (narrator voice); vendor bubbles: blips only; barks: unchanged (silent) | 0.5 day |
| Settings screen | text speed (exists), auto-advance, voice blip volume | 0.25 day |
| Tests | family lookup, tag parsing (mid-line, `[=]`, defaults), pause timing, blip cadence | 0.5 day |

Total: about **4-5 days of code** plus the tagging review and the art (204 images, below).

## Speaking characters (audit)

Approximate line counts from `tools/dialogue_audit.js` (story-file keys that name the character + barks; zone quest givers whose lines sit
under quest keys are undercounted). Top speakers: Elder Maren 84, Primm 82, the Capital's "Perfectly Happy Citizens" 81, the Wanderer 66,
Grand Bellows 56, Gatekeeper Brannoch 40, Wren 32, Big Hurl 29, Pip Threadwell 26, Rip Tearson 25, Bertram 24, Flex 24, Fenwick 23,
Old Hob 20, Captain Spotless 16, the Rescuer (Elowen) 15. 71 NPCs are in `npcs.json`; 60 have a base portrait; 11 have none yet (King,
Queen, Elowen, Dr. Siphon, the four lieutenants, Isla, the baker, the Vault's Warden). The black market (Fig Sly, the Secret Dealer) is
left out of the requests on purpose.

**Requested images: 204** (High 72, Medium 87, Low 45; 29 wait for a base portrait that does not exist yet) in 11 batches of 20:

- **High** (story leads and the most frequent speakers: the Wanderer, Elowen, Maren, Primm, Wren, Brannoch, Bellows, Flex, Hob, Spotless,
  Escoffina, Compostella, Agnes, Kestrel): the full standard set plus their story extras.
- **Medium** (vendors, quest givers, hosts, the Capital citizen): HAPPY, ANGRY, SURPRISED plus their own extras.
- **Low** (bosses with a line or two, traversal NPCs, corrupted NPCs): their own extras only (DEFEATED, FREED, WINDING UP...).

## Rollout order

1. Family lookup + defaults + `[=]` (works with the 13 images we have; no art needed).
2. Typewriter pauses and markup; name-plate titles.
3. Voice blips with species defaults.
4. Tagging pass on the main story beats (forest, Maren, each zone's freeing, Primm), then the zones.
5. Art in priority order; every new file is picked up by "import portraits" with no code change.

## Open questions for you

1. **Blips or silence?** Blips suit the tone, but some players find them grating; default volume 50 % or off?
2. **Talking bob**: is a subtle bob enough, or do you want mouth-open frames (doubles the High tier's art)?
3. **Who gets the full set?** The High list above is my guess from line counts and story weight; move anyone up or down.
4. **The Wanderer's thoughts**: italic and portrait-less, or always with the portrait?
5. **"???" before introductions** for Hob and the Rescuer: wanted, or always show names?
6. **Auto-advance** for the story stills (cinematic) - on by default there, off in conversations?
7. **Black market NPCs**: left out on purpose (they are off limits); should they ever get expressions?
