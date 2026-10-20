# Oct 20 brief: Dev Menu + early-game quest flow (resume file)

All six parts done (commits: P2 f5526ffd, P3 440ee694, P1 6b666baa, P4 fc6b3141, P5 1108c066, P6 = the verify commit).
Summary in docs/progress.md ("Oct 20 (daytime)"); details: docs/dev_menu.md, docs/design/quests.md ("The early-game chain", "Revealed one
at a time"), docs/design/balance_log.md ("the store room ghosts").

Not done / notes:
- No real release export was built: the release gate is covered by GUT (`DevTools.menu_enabled(false)`, `DevMenu.install(.., false)`)
  and `tools/run_release_smoke_exported.sh` checks it when run on a release binary (the stock binary it uses is a debug build).
- `tools/run_onboarding_timing.sh` was not re-run (its arrival check was updated for the new chain).
- `Session.ensure_game` (tests, tools, direct scene launches) sets `early_chain_legacy`: fast-forwarded games skip the chain.
