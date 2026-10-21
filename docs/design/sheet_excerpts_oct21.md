# Design sheet excerpts (live sheet, fetched Oct 21 2026)

The local CSV snapshots in `data/source/` (Oct 11-13) predate these rows. Copied verbatim from the designer's Google Sheet (Dungeon List,
NPC/Vendor List, Token List) for the story-content brief. The sheet wins over this file if they ever differ.

## Dungeon List

### S-PASTE, The Paste Works (Side Dungeon (lieutenant); Primm's Perfection (the Capital))
- Theme: A grim, spotless factory where vats of grey Perfect Nutrient Paste churn on conveyor belts: steel catwalks, cheerful propaganda
  posters of smiling citizens eating paste, ration dispensers, and a locked pantry of confiscated real food.
- Story: Colonel Cornelius Crumb, who ordered the doppelganger swap and built the Gourmand war machines, fled here when the Endless Buffet
  was freed. He runs the factory that feeds the whole Capital nothing but Primm's paste. Reached through Chef Marlo's quest; free the
  confiscated recipes and shut the vats down.
- Boss: Colonel Cornelius Crumb, Director of Culinary Defense. 3 nodes, 3 battles.
- Nodes: 1. Ration Line - Battle - (18%, 75%) -> 2; 2. The Vat Floor - Battle - (50%, 45%) -> 3; 3. The Colonel's Kitchen - Battle (boss) -
  (82%, 20%).
- Rules: Bland Diet: healing effects do nothing. Real Food: Gourmand cards cost 1 less for the player (the recipes fight back).
- Rewards / hook / map id: blank in the sheet.

### D-HOG (story column, updated)
Vivienne Quota, Minister of Efficiency, designed it all (the wheels, the Iron-less Prison) and steers Chancellor Clench, Flex's former star
pupil, as her figurehead; she 'measures' the Wanderer at the Regime Checkpoint, then flees to the Capital when the zone falls.
Node 6: Regime Checkpoint - Elite - (50%, 72%) -> 7.

### D-TTK (story column, updated)
Colonel Cornelius Crumb, Director of Culinary Defense, ordered the swap ... Crumb inspects the prototypes, then flees to the Capital when
the zone falls. Node 6: Prototype Bay - Elite (unfinished war machine).

### D-ROT (story column, updated)
Hortensia Clipwell, the Royal Groundskeeper, outlawed composting as 'untidy' and brought the grieving Compostella a Path-ologist seed of life
that never dies; Clipwell flees to the Capital when the zone falls.

### D-PC (updated: 10 battles, 12 non-battles)
- Story: The first time the Wanderer enters, Percival Plume has Elowen seized and sent back to the Path-ology Lab; his memo in the Necrocrat
  wing gives it away, right before the player fights him there.
- Node 1: Castle Gate - Start (story: Elowen is seized on Plume's orders).
- Node 8: Archive of Good Intentions - Event (Primm's journals; young Maren's letter).
- Node 14: Necrocrat Wing: Notarized Archives - Elite (Percival Plume; his memo reveals Elowen's capture) - (52%, 32%). (Was a Deck
  Challenge.)
- Node 19: Primm's Private Gallery - Treasure (the painted-over royal portrait).

### D-LAB, The Path-ology Lab (Postgame; 16 nodes, 8 battles, 8 non-battles)
- Theme: sterile white corridors cracked by roots, glass tanks glowing in four colors, draining apparatus, cells, failed hybrid
  experiments, and Path-ologist notes everywhere.
- Story: Where Primm's Path-ologists held Prince Tessar for ten years and drained his power, and where Plume sent Elowen. Her allies have
  been searching; Rip finds the entrance. The lab is full of dual- and tri-Path enemies. In Cell 4, the prince's own cell (ten years of
  tally marks, a child's drawing of four colors), he finds Elowen ('Took you long enough, Tess.'); rescuing her is an optional branch, like
  Flex. In the Mentor's Study, both learn that Chief Path-ologist Ambrose Siphon, Elowen's father and the prince's old Pathguide, opened the
  doors to Primm at the coup. She confronts her father before the boss (or after, if not rescued). Siphon is a four-Path boss: insanely
  powerful and unfair. If Elowen was rescued she fights beside you (token T-24); she doesn't win it for you, she gives you a chance.
- Nodes:
  1. Forest Hatch - Start - (6%, 80%) -> 2, 3
  2. Intake Corridor - Battle (dual-Path) - (18%, 64%) -> 4
  3. Specimen Storage - Battle (dual-Path) - (18%, 90%) -> 5
  4. Observation Deck - Event (notes on 'the Subject') - (30%, 56%) -> 6
  5. Failed Experiments Ward - Elite (tri-Path) - (30%, 84%) -> 6
  6. Decontamination - Deck Challenge - (42%, 70%) -> 7, 8
  7. The Draining Chamber - Event (story: where his power was taken) - (52%, 50%) -> 9
  8. Hall of Hybrids - Battle (tri-Path) - (52%, 88%) -> 9
  9. Night Shift Break Room - Full Heal - (62%, 68%) -> 10, 12 (skipping 10-11 skips the rescue)
  10. Cell Block - Battle (dual-Path) - (60%, 36%) -> 11
  11. Cell 4 - Rescue Event (Elowen joins) - (52%, 16%) -> 12
  12. The Mentor's Study - Event (Siphon's journal: the coup) - (72%, 40%) -> 13, 14
  13. Containment Breach - Elite (tri-Path) - (80%, 62%) -> 15
  14. Prototype Vault - Treasure - (80%, 22%) -> 15
  15. The Antechamber - Battle (tri-Path) - (88%, 44%) -> 16
  16. The Extraction Theater - Boss (Dr. Ambrose Siphon, four-Path) - (94%, 20%)
- Rules: Specimen Conditions: max life -5 for this dungeon; enemy units enter with +1/+1. Boss Protocols (one-sided, Siphon only; Elowen can
  disable one per turn): Augmentation (his units +2/+2); Replication (at the start of his turn, create a Failed Experiment token, T-25);
  Extraction (at the start of his turn, he gains 1 energy of each Path and you lose 1 life); Containment (the first card you play each turn
  costs 2 more).

## Token List

- **T-24 Elowen Vey, Defector** (3/5). Boss-fight ally token (the rescuer); never available to the player normally. Starts on the player's
  field during the Path-ology Lab boss fight if the player rescued her in that dungeon run. Elusive. Unbreakable. Inside Knowledge: At the
  start of your turn, choose one of the Chief Path-ologist's Protocols. It has no effect until your next turn. Sabotage: Failed Experiment
  tokens your opponent creates enter exhausted. Flavor: "I learned everything I know from him. Including how to break it." Art: Needed.
- **T-25 Failed Experiment** (3/3). Unit token (boss-only; created by the Chief Path-ologist's Protocols). Dual- or tri-Path. Has the Paths
  and one keyword of the experiment that created it (random). Flavor: "Specimen 4,117. Discontinued. Still running." Art: Needed.

## NPC/Vendor List (lieutenants, Isla, Hob)

- **NPC-QUOTA** Vivienne Quota, Minister of Efficiency. Beefcake lieutenant (one-off encounter). Gainlands (cameos); Capital, Transit Yards.
  Measures the Wanderer at the Regime Checkpoint and finds him wanting. Flees to the Capital when the Gainlands are freed. Fate: runs the
  Gainlands' new break schedule, and hates it. Function: one-off battle in the Capital's Transit Yards at the end of Rollo Spokes's quest.
- **NPC-CRUMB** Colonel Cornelius Crumb. Gourmand lieutenant (mini-dungeon boss). Inspects the Test Kitchen prototypes; Basil is terrified of
  him. Flees when the Buffet is freed. Fate: learns to actually cook under the Grand Chef. Function: boss of S-PASTE through Chef Marlo's quest.
- **NPC-PLUME** Percival Plume. Necrocrat lieutenant (Castle elite); the NPC everyone loves to hate. Everywhere (loudspeakers); D.N.A.
  (cameos); Primm's Castle. Spins every freed zone, shows up afterward to cut a ribbon and hand the Wanderer a Certificate of Participation.
  Has Elowen taken back to the Lab when the Wanderer enters the Castle (memo: 'Re: the leak in the lab. Handled. Promotion?'). Fate: tries to
  become the prince's spokesman; Agnes denies the form; reassigned as Assistant to the Assistant to the Regional Merchant, under Bertram.
- **NPC-CLIPWELL** Hortensia Clipwell. Refusemancer lieutenant (one-off encounter). Verdant Dump (cameos); Capital, the Showcase Quarter lawn.
  Tense polite standoff with Brother Bramble. Flees when the Dump is freed. Fate: compost duty under Granny Gristle. Function: one-off battle
  on the Showcase Quarter's regulation lawn at the end of Old Fern's quest.
- **NPC-ISLA** Isla Brannoch. Went to the Capital eight years ago and never wrote; stuck on the Showcase Quarter's facade crews, unable to
  leave or send word. When the Capital is freed she walks home through her father's unlocked gate. Tired, warm, a little embarrassed.
- **NPC-HOB** Old Hob (secretly Death). When Primm's paperwork seized the D.N.A., the afterlife's intake froze and Death couldn't collect
  anyone, so he took a job digging graves and waited. Checks his appointment book ('Hm. Not for a good long while.'; Primm: 'Penciled in.';
  Plume: 'Oh, I've got you in pen.'). Turns up digging in impossible places, 'just measuring'. Has been digging the king and queen's graves
  for ten years; at the royal funeral he walks them, and Agnes, home. Function: starts the Graveyard challenge; appears at 0 life instead of
  a plain respawn ('Not on my list. Off you pop.'; lost gold is his handling fee); cameo in every zone; royal funeral.
