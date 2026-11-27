# Soak bot, seed 1, window (1280, 720), 1500 s, 2181 steps

Segments: { "town": 2, "zone_draft": 2, "fight": 2, "newgame": 1, "shuffle": 1, "zone": 1, "save": 2, "dungeon": 2, "title": 1 }

| # | Kind | Segment | Step | Seen | Problem | Frame |
|---|---|---|---:|---:|---|---|
| 1 | offscreen | fight | 498 | 43 | Label '@Label@15474' (@Label@15474) runs off the screen ([P: (650.5738, 1054.017), S: (84.68, 31.9)]) | offscreen_01_fight.jpg |
| 2 | save | save | 1599 | 1 | to_dict -> from_dict -> to_dict differs: deck (48 -> 47 items), decks (order or values), essence.4 (new), flags.maren_path_direction (new), flags.own_path_necrocrat (new), owned (29 -> 28 items) | save_02_save.jpg |
