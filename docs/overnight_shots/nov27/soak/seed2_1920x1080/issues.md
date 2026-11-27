# Soak bot, seed 2, window (1920, 1061), 1500 s, 1725 steps

Segments: { "zone_draft": 1, "fight": 2, "shuffle": 1, "save": 2, "newgame": 1, "town": 2, "dungeon": 1, "zone": 1, "title": 1 }

| # | Kind | Segment | Step | Seen | Problem | Frame |
|---|---|---|---:|---:|---|---|
| 1 | error | fight | 203 | 2 | Lambda capture at index 0 was freed. Passed "null" instead. (gdscript_lambda_callable.cpp:110 in call) | error_01_fight.jpg |
| 2 | offscreen | shuffle | 239 | 1 | Label '@Label@30780' (@Label@30780) runs off the screen ([P: (80.0, 1048.0), S: (290.0, 51.0)]) | offscreen_02_shuffle.jpg |
| 3 | save | save | 558 | 1 | to_dict -> from_dict -> to_dict differs: flags.elowen_seized (new), flags.maren_path_direction (new), flags.own_path_refusemancer (new), flags.rescuer_named (new) | save_03_save.jpg |
| 4 | softlock | fight | 1628 | 15 | the duel ended but the battle screen never finished (mode 0, busy true, banner waiting false) | softlock_04_fight.jpg |
