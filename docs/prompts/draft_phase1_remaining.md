# Draft Phase 1: what's left (the run was stopped on Nov 23, about 2 PM)

The owner closed the session to playtest. Everything up to commit "Draft phase 1: rivals draft equipment (player 59 % in the sim), draft smoke" (Nov 23, 08:52) is committed and pushed. After that, the gear and item ban sim hung (no output from about 9 AM).

Still to do, in this order:
1. `git status`: check and commit (or discard) anything left after 08:52.
2. **The gear and item ban sims:**
   - in batches of at most 30 variants, each in a fresh process, with a 20-minute limit per batch;
   - log any batch that times out and move on; about an hour in total, then write up what's there;
   - **proposals only, nothing banned.**
3. **The scripted zone draft playthroughs for the D.N.A. and the Dump** (the Gainlands and the Buffet are done), with shots.
4. Full tests in small groups, the walk smokes, the probes, the four story bots one after another, the draft smoke.
5. **Export 1.0.0 with draft mode** for the playtesters: `EXPORT_LOW_MEMORY_OK=1` if needed, then the exported smoke and the three `play_exported.sh` checks. (The zip from Nov 23 at 02:33 has no draft mode.)
6. **The report** at the top of docs/overnight_report.md under "Fable draft phase 1", with the owner's decisions in the inbox. These cover:
   - the host's name: Trey Pickett, plus two alternatives;
   - the new gear and the six new cards;
   - the proposed bans.
7. Then the owner's assistant turns `docs/art/batch20.csv` into a sheet tab for ChatGPT.

Also waiting for the owner: the six decisions in the inbox under "Fable Nov 22 night", including the all-allies castle route (cleared 16 %, where the target was about 35 %).

Fold the owner's draft playtest feedback into the same next run.
