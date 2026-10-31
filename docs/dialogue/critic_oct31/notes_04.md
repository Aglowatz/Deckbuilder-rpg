# Critic notes, chunk 04: the D.N.A. (Oct 31 2026)

Rows read: 541 (master rows 1578-2118). Suggestions: 16 (`suggestions_04.csv`, all pass `dialogue_critic_check.js --check`).

## Critique

### D.N.A. / gatekeeper (Prudence Pallor, rows 1578-1607)
- The strongest gatekeeper set I would expect to see. Corrupted Prudence has a clean monotone ("Your number is zero. It is always zero.
  Now serving: nobody.", 1585), the defeat line is a real joke ("reapply in ten to twelve centuries. This is our express service.", 1596),
  and the freed lines show the change without speeches ("I have a new stamp. It says HELPED. I have used it nine times. I am counting.",
  1579). The mid-fight wrong-stamp event (1591) is character comedy and foreshadowing in one. No suggestions.
- "Old habits die hard. Unlike me." (1593) works because it comes after the sincere "I can hear my own thoughts again".
- Quest Log "Take a Number" is clear and names every place ("Out-file Prudence Pallor" is a good verb).

### D.N.A. (zone, rows 1608-1881)
- Works: the deadpan register is consistent and the signs/memos are dense with good office jokes (Rule 40,002 "All rules include this
  rule", "This is not oppression. This is policy.", the 1873 complaint filed under C, F and P, "Please stop billing it as 'ergonomic
  seating'"). The authorization sign (1835-1836) tells the zone's whole plot as a notice, which is exactly right.
- Agnes's intro (1673-1675) is the best exposition in the zone: "Valid things just sit there and smile at you." Her funeral-form beat
  (1679-1680) is played straight and lands.
- Gerald, Ledgerbone and Kyle each have a distinct rhythm; cover the plate and you still know who is talking. Ledgerbone's "Oh. Oh, that's
  lovely." and "my legs are on loan to Accounts" are his best tics; Kyle's lowercase works.
- Flat or weak: Agnes's return lines lean on generic workplace filler ("Loyalty is rewarded here... With more work", 1676; "It builds
  character", 1677) while the zone's biggest fact - nobody can pass on since the transfer, Death is stuck in the lobby - is only said by
  Old Hob. Gerald's "I don't have email. I hope the phrase conveys..." (1672) explains its own joke. Kyle's second bark (1866) is muddled.
  Ectomund's mid scores (1765, 1766) are slightly off-key ("My interest remains non-refundable"; "Half-credit is the highest honor").
- Missed: the Beefcake rivalry is present in the debuff text (1852) and the elevator blurb (1983) but nowhere a Necrocrat complains about
  Beefcakes in their own voice. One memo now does (suggestion on 1662).
- Repetition: the 13-B/13-A loop appears in a memo, a sign, Agnes, Ledgerbone, a node blurb and an event chain. It is the zone's running
  gag and it holds, but it is near the ceiling; no new uses suggested.

### The Waiting Room of Eternity (Gerald's side quest and Betty Bones, rows 1873-1896)
- Gerald's quest chain is warm and clear ("The queue will not move itself. I've given it a very fair chance.", 1879). The payoff (1895-1896,
  the ghost with a crumpled ticket cheering quietly) is lovely and should stay exactly as it is.
- Betty is thin: "Forms A through F. Then we'll talk. We won't, but still." is used twice (1883 and 1888) and her intro line borrows
  Mortimer's "irrelevant". The lunch-break event is the best Betty moment. One Low suggestion to separate her voice from Mortimer's.

### The Hall of Final Approvals (rows 1897-2060)
- Works: the queue thread (4,000,213 on the ticket, Agnes saving your place, "Nobody noticed. Nobody ever does."), Vellum's "Noted"
  escalating to a question (1973-1974), Mortimer's FILED ON A TUESDAY reveal, and the vacancy cutscene, which is sincere and well paced.
  The heir clause (1943-1945) is quiet and right; "Irregular" lands because Agnes "looks at it for a long time".
- Event screens are funny and clear: "You feel seen, and slightly worse" (1916), "THINGS INCLUDE YOU" (1976), "slightly nonexistent" (1980),
  the clerk who winks (1963).
- Flat: the Notary's Counter blurb (1934) is a definition. It is the best spot in the Hall for a quiet clue to Plume, who notarized the
  transfer and is otherwise unseen until the ribbon scene (suggestion: blue-green feathers).
- Small contradiction: Agnes says "I stopped counting the appeals" (1903) while her bark and the met variant count "forty thousand and one".
- Mortimer's before-node narration says "His face is as smooth as a blank form" for a skeleton; it reads fine as an image but the designer
  may want "His skull is as smooth as a blank form" (not suggested; judgement call).

### After freeing (rows 2061-2118)
- Works: Gerald's "CALLED" line and "Agnes switched the queue machines off and called every number herself... She never sat down." (2088-
  2089) are the emotional peak of the zone. Mortimer's freed set (2114-2117) is precise and earns "whether that was ever the right
  question". Ledgerbone practising being unbusy is a perfect small arc. The freed signs undo each corrupted sign cleanly (40,000 to 39,000).
- Fix: Kyle's freed line says his number is still "four hundred years" away (2061), which contradicts Gerald's account of every number
  being called that night and the NOW SERVING: EVERYONE sign.
- Flat: Ectomund's freed line (2063) states the change instead of paying off his own "ethics questions... not in the building" setup.
  Agnes's freed intro (2083) ends on a ghost line that does not follow from what she said.

## Scores (current lines)

| Area | Writing | Humour | Worldbuilding | Reason |
|---|---|---|---|---|
| D.N.A. / gatekeeper | 9 | 8 | 8 | Clean corrupted/freed contrast, every line has a job; the transfer is explained in one sentence. |
| D.N.A. (zone) | 8 | 8 | 7 | Dense, consistent deadpan; Agnes's return lines are generic and "Death froze" lives only with Hob. |
| The Waiting Room of Eternity | 7 | 6 | 6 | Gerald's chain and payoff are strong; Betty repeats one line and borrows Mortimer's vocabulary. |
| The Hall of Final Approvals | 9 | 8 | 8 | Queue thread, Vellum, Tuesday and the vacancy all land; a few blurbs are plain definitions. |
| After freeing | 8 | 7 | 8 | Gerald and Mortimer are the zone's best writing; Kyle contradicts the canon of the night, Ectomund is flat. |

## Best 5

1. `npc.dolores.return::0` - before: "Back again? Loyalty is rewarded here. Not with money. With more work." / after: "Back again, dear? Nobody
   else leaves. Since the transfer, not one soul has passed on. Not even me."
2. `scenes/hob_necrocrat/steps/0::2` - before: "I took a number. Heh. It's a big one." / after: "I took a number. Heh. Makes a change. Usually
   I'm the one calling them."
3. `dungeon.ha_notary.blurb::0` - before: "Every important document in the Hall passes through here. It must be stamped, signed and witnessed
   by a notary." / after: "Every important document in the Hall is stamped, signed and witnessed here. The transfer of authority was,
   too. The notary is still finding blue-green feathers."
4. `npc.matching.return.freed::0` - before: "the queue moved. like, actually moved. my number's coming up in only four hundred years. new
   personal best." / after: "the queue moved. like, actually moved. agnes called my number at 3am. i was afk. she called it again.
   nobody's ever called me twice."
5. `memo.parking::1` - before: "Parking Lot D has been renamed Parking Lot Dead. Please stop asking why." / after: "Beefcake couriers: throwing
   a parcel through the window is not 'delivery'. Neither is throwing the courier."

## Flavour inventions

- The transfer of authority was notarized at the Hall's Notary's Counter, and Plume left blue-green (peacock) feathers there. Consistent
  with story bible section 6 (Plume drafted, notarized and filed it); if Plume notarized it with his own seal elsewhere, drop the middle
  sentence and keep only the feathers.
- Beefcake couriers deliver to the D.N.A. and sometimes throw parcels (and couriers) through windows. Fits the Beefcake "throwing people"
  transport service.
- Agnes called Kyle's number at 3am and called it twice because he was away. Fits Gerald's "called every number herself... all night".
- The ethics questions have been returned to the building but not yet to Ectomund's exam.

## Design notes

- The chunk's lines are already strong (several prior passes show); I suggested on about 3 percent of rows rather than forcing the
  10-25 percent target. Most remaining rows are UI, rule text, names and signs that work.
- "Death froze" is the zone's most important background fact and is carried only by Old Hob's scene. With the Agnes return suggestion it
  gets one more voice; consider also letting one clerk or the HUD hint at it if playtesters miss it.
- Betty Bones repeats "Forms A through F. Then we'll talk. We won't, but still." in the node narration and the mid-fight event. Consider
  giving the event a second line (the bible sample "Fine. Approved. Don't make it a thing." is already used in the after-node).
- The freed Prudence rows are labelled "After freeing: Prudence Pallor (corrupted) talks" in the chunk; the label looks wrong (she is
  freed). Tooling only.
- Question: Gerald's number is approved in the Waiting Room of Eternity side dungeon (1895) and again "CALLED" in the freed zone (2088).
  If a player does the side dungeon first, does Gerald acknowledge being approved before the vacancy? Worth a check that the two beats do
  not double up.
- Question: Mortimer is "a skeleton" per the cast table, but the before-node narration describes his face. Confirm the art, then decide
  between "face" and "skull".

## Counts

- Rows read: 541.
- Suggestions: 16.
- By priority: High 1, Medium 8, Low 7.
- By category: Humor 5, Worldbuilding 3, Fix 2, Voice 2, Natural 2, Story 1, Clarity 1.
