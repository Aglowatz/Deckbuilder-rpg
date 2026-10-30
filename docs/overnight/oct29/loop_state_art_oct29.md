# Art import Oct 29 (Opus) - loop state (resume from here)

Start: Thu Oct 29 ~14:50 MDT 2026. Tag `pre-art-import-oct29`. Last run's state: `docs/overnight/oct28/loop_state_oct28.md`.
Brief: "IMPORT ART BATCHES 5-9 + v0.4.7 CANDIDATE" (Parts 0-6 + report). Questions: `docs/overnight_inbox.md`, section "Art import Oct 29".
Import log: `docs/art/import_oct29.md`; status `docs/art/art_status_oct29.csv`.

Rules: one Godot at a time, foreground, closed between runs; max 12 screenshots per part; GUT in groups (`bash tools/gut_group.sh
root|core|ui|world`); per part GUT + walkability + that area's walk smoke + `bash tools/perf_budget.sh` + commit + push; revert what can't
pass; old saves load; no enemy intent; NO image generation; never read Pending Review / Superseded / Replaced Artwork; Drive copy-only;
black market vendors untouched. **DIALOGUE FREEZE**: no existing line/key changed, added, removed or reordered; new text only in new keys.
Part 6: bump 0.4.7, guarded export, release smoke exported (Medium + Low), zip `builds/TheWaywardPath-v0.4.7-windows.zip` (flag >850 MB,
never overwrite a good zip), notes `docs/release/v0.4.7_notes.md`, tag; do NOT share.

## Progress

| Part | State | Commit | Notes |
|---|---|---|---|
| 0 Inventory | done | 8ead7f6c | 86/86 sound; assets/art 447 MB before |
| 1 Story stills | done | 8ead7f6c | StillBackdrop behind cutscene/ending/scene/memory narration; scenes/dev/still_gallery.tscn; GUT root 281 ui 242 |
| 2 Cards/icons/hat/NPC sprites | done | 5ba61b8d | cards 356/356, relic+feat icons, Leaf Crown hand fit, DUMPWORKER/PRIMM sets; GUT all groups OK, Dump walk OK, structure OK |
| 3 Zone pieces | done | 2cfa186f, bedd13ff | all zones; walk smokes OK, memory flat, budgets: capital_out Medium p99 pre-existing (A/B) |
| 4 Old Hob | done | (this commit) | Hob 1.4 m north (was 0.4 m from the D.N.A. road line); hub walk smoke OK |
| 5 Verify | done | (this commit) | tour 281/0, story 90/90, smokes OK, budgets: averages OK, p99 noise + capital_out pre-existing; status 78 In Game / 12 Skipped / 0 redo |
| 6 v0.4.7 | done | d90e6c20 + tag v0.4.7 | zip 762 MB, pck 852 MB (over 800 budget), exported smoke D3D12 Medium+Low PASSED |
| Report | done | final | docs/overnight_report.md |
