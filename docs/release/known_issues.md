# Known issues - The Wayward Path 1.0 (as of Nov 21 2026)

For the itch.io page or the playtest notes: what is still open after the Nov 21 review, in players' words. Edit freely.
Nothing here stops you from finishing the game. (The developer's list with causes is in `docs/overnight_report.md`, "Fable Nov 21
review", and `docs/release/two_week_plan.md`.)

## Things you may notice

- **Windows warns you before the first start.** "Windows protected your PC" appears because the game is not signed with a paid
  certificate. Click "More info", then "Run anyway".
- **The first start and the first visit to a big place take a while.** The Capital can take 6 to 9 seconds to load on a laptop
  without a graphics card (there is a loading screen). Later visits are quicker.
- **The Arena's first fights are easy, and the last one is hard.** The Arena under the town is being rebalanced; the puzzles are
  finished. It is optional: nothing in the story needs it.
- **Some fights are much harder for one Path than for another.** If a boss walls you, look at the level hint on the dungeon's door,
  buy a few cards of a second Path, and use your items: they are single-use but cheap. There is no difficulty setting.
- **Two people in the Gainlands have not heard the news.** After you free the Gainlands, Gary is still stuck under his barbell and
  the rep-counting host still talks about the regime banning his show.
- **The Endless Buffet's map shows the sushi shop in its old place.** The Raw Deal moved to the east district; its icon on the big
  map (M) is right, the painted shop under the old spot is not. A repainted map is on the way.
- **The D.N.A.'s map looks like a sunny village.** The place itself is a haunted office at dusk. The map is correct, only cheerful.
- **One locked pack in Foil Fenwick's shop looks unwrapped.** The Necrocrat Pack you cannot buy yet is drawn as an open pack with a
  padlock, the other three as sealed parcels. It is locked all the same.
- **With a controller you cannot type in the Deck Station's search box.** Everything else in the Deck Station works with a
  controller; the Path, type, cost and rarity filters do the same job.
- **Rip Tearson does not walk.** He turns to face you where he stands.
- **Pressing Esc during a story scene you have not seen asks before skipping.** A scene you have seen before skips at once.

## If you are loading a save from a test version

- Your cards, gold, level, quests, gear, items, packs and hats carry over.
- You can own three copies of a card now. A fourth copy from an older version turns into essence of its Path (or gold for a
  Pathless card) the first time you load.
- A Path holds at most 18 essence now; anything above that is trimmed.
- Cards of three or four Paths cannot go in a deck until the story's last boss is beaten. Any you own wait in your collection.
- If you saved inside a dungeon, you start that dungeon again from its entrance.

## If something goes wrong

- The game will not start, or it crashes: try "Start (Safe Mode).bat" next to the game, then "Start (Vulkan).bat", then
  "Start (Compatibility).bat".
- It is slow: Settings > Display > Graphics quality > Low-end.
- Text is too small: Settings > Text > Text size (Normal, Large, Larger). Since 1.0 the menus grow too.
- You found a bug: press **F8** in the game, write what happened and press Send. It makes a folder with a screenshot, your save
  and the logs: `%APPDATA%\Deckbuilder-RPG\feedback\`. Zip it and send it to the developer (see the game's page).
