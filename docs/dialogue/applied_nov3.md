# Dialogue applied - Nov 3 (overnight Nov 2-3, Part 1)

The dialogue freeze ends here. Every critic suggestion of docs/dialogue/critic_suggestions_oct31.csv was accepted (the 12 designer-line typo
fixes included), plus docs/dialogue/typo_fixes_nov1.csv and the Primm phase-1 rule wording from docs/dialogue/new_lines_proposed_oct31.csv; the
rows of docs/dialogue/new_rows_nov1.csv are in the game exactly as written (13/13 checked).

Built by `node tools/dialogue_build_nov3.js` from a fresh export of the game (docs/dialogue/applied_nov3/export_before.csv) into
docs/dialogue/applied_nov3/edit_apply.csv, then `node tools/apply_dialogue_pass.js --csv=... ` (dry run, then --apply).

## Counts

- **Applied: 217 lines** (dry run and apply: 217 would apply / applied, 0 conflicts, 0 failed validation, 0 held, 0 locked).
  - critic suggestions: 215 (4 of them designer-line fixes, 3 applied over the Nov 1 typo fixes the designer had already typed - the suggestion carries those fixes)
  - typo fixes (Nov 1) not already in the game: 1 (the other four were fixed in the game already, or by a suggestion)
  - proposed lines: 1 (Primm's phase-1 rule: "starts as a 3/3; buffs and debuffs still change it")
  - by category: Fix 20, Clarity 13, Worldbuilding 25, Humor 58, Voice 38, Natural 32, Story 29
- **No-ops: 2** - the suggestion equals the current line (the designer had already typed it): prologue.rescuer.1::0, cave_mouth.maren::0.
- **Held: 1, fixed: 1** - capital_story.tres sign.out_rift::1 lost the tested beat "failing" (test_finale_v2); kept the critic's line and
  reworded around the beat ("His hold is failing; it first slipped the night someone escaped the Ministry.") - docs/dialogue/applied_nov3/held_fixed.md.
- Story / prologue / quest / dialogue GUT groups (104 files, 925 tests): 924/925 before the fix, the held beat re-run green.

## Re-export

docs/dialogue/edit_nov3.csv (+ edit_nov3/export_snapshot.json): the same columns as edit_oct27.csv (ID, Zone/Area, Speaker, When it's heard,
Current line = the game text now, New line empty), the critic columns dropped, 4216 rows in story order (the Nov 1 new rows are in it, in
story order rather than appended at the end).

## 15 highlights (before -> after)

- **The Rescuer** (Prologue (Opening Forest), Clarity): Earlier review (critic #11): arriving in town gave no goal; naming the elder points the player at her (the cave exit lands beside Maren).
  - before: Behind me is the Forgotten Cave. Follow it all the way through to {town}. Someone there will be waiting for you.
  - after: Behind me is the Forgotten Cave. Follow it all the way through to {town}. Elder Maren will be waiting for you. Find her first.
- **The Wanderer** (Prologue (Opening Forest), Clarity): Folds in the earlier note: names the landmark the player can actually see.
  - before: No point getting lost twice in one day. Back to the cave.
  - after: No point getting lost twice in one day. Back up the path to the glowing arch.
- **Elder Maren** (Crosspath (first visit), Worldbuilding): A list becomes a Maren line with a sting, and seeds 'they argued and needed each other anyway'.
  - before: Ten years ago {kingdom} was whole. Beefcakes made the energy, Gourmands fed us, Necrocrats minded the dead, Refusemancers hauled the waste and grew the crops.
  - after: Ten years ago {kingdom} was whole. Beefcakes made the energy, Gourmands fed us, Necrocrats minded the dead, Refusemancers hauled the waste and grew the crops. Everyone complained. Everything worked.
- **Sable** (Crosspath (first visit), Voice): The tutorial line could be anyone's; 'darling' and a three-beat pitch make it Sable's.
  - before: You start with plain neutral cards. The Paths are where the power is. Browse, buy, then put it all to work at the Deck Station.
  - after: You start with plain neutral cards, darling: honest, dependable, dull. The Paths are where the power is. Buy some, then put them to work at the Deck Station.
- **Crosspath townsfolk** (Crosspath (first visit), Worldbuilding): Swaps a generic 'lovely day for a quest' for Primm's real reform and the watched town in one bark.
  - before: Lovely day for a quest, isn't it? Shh. Not too lovely. Somebody's listening.
  - after: Say what you like about His Perfection, the wells are clean. Shh. Don't, actually.
- **Old Man Mountain** (Gainlands, Voice): Same Path facts in his voice instead of a brochure sentence; punchline last.
  - before: Shh. Welcome to the Gainlands. The regime has ears. Big ones. I'm Old Man Mountain. We Beefcakes power the kingdom on mills and hamster wheels, and move folks by throw and by portal.
  - after: Shh. Welcome to the Gainlands. The regime has ears. Big ones. Old Man Mountain. We Beefcakes keep the kingdom's lights on and its folks moving. Wheels, mills... and if you're in a hurry, we throw you.
- **Professor Pump** (Gainlands, Worldbuilding): Says what the regime burned and why it matters: the festival and the old king, which Mountain then fills in.
  - before: Fifteen concern biceps; the regime burned the other two, so I rewrote them from memory. You cannot confiscate a well-trained brain-cep.
  - after: Fifteen concern biceps. The other two were a history of the Lifting Festival; the regime burned those, so I rewrote them from memory. You cannot confiscate a well-trained brain-cep.
- **Grandmaster Flex, the Unbroken** (Gainlands / after freeing, Story): Shows Clench's first step back instead of only stating it, and pays off Gary.
  - before: Clench is learning to lift from zero. The strongest take the longest. The gym is open to everyone now. Come whenever you like.
  - after: Clench is learning to lift from zero. The strongest take the longest. Yesterday he spotted Gary without being asked. The gym is open to everyone now; come whenever you like.
- **Basil** (Endless Buffet, Story): Swaps two poster slogans for a nervous hint of the war programme; Basil's voice, same fact.
  - before: Psst. Hello. I'm Basil, line cook. Ladle in one hand, nerves in the other. We Gourmands feed the kingdom and protect it. Every plate is a promise. Every golem is a guard.
  - after: Psst. Basil, line cook. Ladle in one hand, nerves in the other. We Gourmands feed the kingdom and protect it: chefs cook, golems guard. Lately the golems have been... practising.
- **Sous-Chef Tarragon** (Endless Buffet, Humor): Basil already does 'hears everything, never tastes'; this gives Tarragon his own fear and pays off the taste-tester signs.
  - before: Don't tell the Grand Chef I said anything. She hears everything. She just never tastes anything.
  - after: Don't tell the Grand Chef I said anything. Last cook who complained got promoted to taste tester. We haven't seen him since.
- **Agnes Overdue** (D.N.A., Worldbuilding): Generic workplace gag swapped for the zone's key fact (Death froze) in Agnes's own want.
  - before: Back again? Loyalty is rewarded here. Not with money. With more work.
  - after: Back again, dear? Nobody else leaves. Since the transfer, not one soul has passed on. Not even me.
- **Brother Bramble** (Verdant Dump, Worldbuilding): Same facts, shorter, plus the rivalry and why the Paths need each other, punchline last.
  - before: We are the Refusemancers: druids of waste removal and agriculture. Our animals eat the kingdom's garbage and turn it into fertilizer, and our magic helps the crops grow.
  - after: We are the Refusemancers: druids of waste removal and agriculture. Our animals turn the kingdom's garbage into fertilizer for its crops. The Buffet calls us garbage eaters. They eat our carrots.
- **Compostella, the Rotheart, and Archdruid Compostella** (Verdant Dump / after freeing, Humor): Lands her canon barn gag (she forgets, it remembers); her bark already offers to mend it.
  - before: Archdruid Compostella. I am told what happened to the barn. I cannot remember doing it. I will help put it right.
  - after: Archdruid Compostella. I am told what happened to the barn. I cannot remember doing it. The barn, I gather, remembers me. I will help put it right.
- **Elder Maren** (Crosspath (between zones), Voice): Restores Maren's own turn into the confession; the current line says she is hiding things instead of showing it.
  - before: You have earned the truth. I have been keeping more from you than I should.
  - after: You have earned the truth, so here is the first piece of it: I am not only a tortoise who bakes.
- **Wren** (The Capital, Worldbuilding): The archivist is the natural voice for Primm's sincere early reforms; one concrete good deed makes him tragic before the castle.
  - before: The records say he began as a good man. Keep that in mind. It does not excuse what he has done.
  - after: The records say he began well. His first decree put a hot lunch in front of every schoolchild. Remember that. It excuses nothing.
