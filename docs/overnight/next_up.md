# Overnight Oct 19-20 - next up (ranked)

Re-ranked at the end of the overnight run (Tue Oct 20 ~03:45). Done tonight: see `loop_log.md` and `docs/overnight_report.md`.

1. **Import tonight's art** (Playtest readiness / Collection / Visuals): `docs/art/import_oct20.md`, in order; then a short wiring pass so
   the new Gainlands and DUMP-* kit pieces replace their STANDINs (inbox 14).
2. **A listen pass** (Audio, the lowest row at 7.5): the five fixed loops, MUS-TOWN's wrap, MUS-TOWN-FREED's first 40 s, MUS-DECK's step,
   the Old Well's music and hums; then generate the prompts in `docs/audio/music_generation_prompts.md` (Crosspath first) and drop them in
   Approved_Audio (`bash tools/import_audio.sh --dry-run` first).
3. **Your story calls** (Dialogue & story): inbox items 1-5 and 8 (Elowen's name and arc, the lieutenants, species, name clashes, the Old
   Well lore). Then build the canon-not-built beats the bible lists (Isla's homecoming, Plume as a named voice).
4. **The Path choice's 279 words** (Onboarding, Daytime inbox 2): the only long read left in the opening (~80 s).
5. **L5 Necrocrat in the Gainlands** (Balance): the sim's L5 Necrocrat reference deck plays no unit before turn 8 against the roamers
   (cycle 17 replays). Checked: the deck size (46) is as designed; `CUT_ORDER` still names four cards that left the starter on Oct 19
   (N-12, N-14, N-20, N-21 - skipped harmlessly). The slow start is the deck's curve: try a cheaper-unit L5 package (sim only), two seeds x 25.
6. **Showcase citizens' barks after the Capital is freed** and Isla (NPC life): need a freed-bark field in NpcBarks / npcs.json.
7. **Untidy's seed jar** (Clarity): a marker for the seed before the Sick Patch needs a step split (save-compatible QuestMigration).
8. **Stale per-brief smokes**: retire or update `run_final_flow_smoke.sh` and `run_fourth_brief_final_smoke.sh`.
