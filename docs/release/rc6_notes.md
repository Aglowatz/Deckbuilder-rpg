# The Wayward Path 1.0.0-rc6 (2026-11-12) - release candidate 6 for playtesters

Windows build: `builds/TheWaywardPath-v1.0.0-rc6-windows.zip`. **Not built yet on Nov 12** (too little free memory; the commands are in
`docs/overnight_report.md`, Part E). Unzip the whole folder somewhere you can write to (Desktop or Documents, not Program Files) and run
`TheWaywardPath.exe`. If Windows says "Windows protected your PC", click "More info", then "Run anyway". `README_PLAYTEST.txt` in the
folder explains the start files. **Saves carry over** from RC5 and every earlier build.

RC6 is the owner's fix list, a new look for the dungeon pop-ups, and the Crease rebuilt as a cavern. The battle board and the other menus
are where they were.

## What changed since RC5

**The Forgotten Cave**
- **The Hollow Well is an offer now, not a test:** "Sacrifice a random card from your deck for the rest of this dungeon: heal 4 HP."
  The well shows the card it took, and the card is back in your deck when you leave the cave (win, lose or walk out). You can leave
  the offer. At full HP it is closed, and it can be taken once per run.
- **The Hollow Warden says his last words with his picture**, in the dialogue box, like everyone else. The four gatekeepers' lines after
  their fights show their pictures too.
- **Out of the cave you stand just left of Elder Maren, facing the square**, and her house no longer fades away around you.

**Dungeon pop-ups**
- **Every room that is not a fight has a new card:** the shrine, the well, events, rescues, treasure and deck challenges. A picture of
  that corner of the dungeon across the top with the room's icon glowing in it, the name on a title plate, what the room does as icons
  and plain words, your HP before and after ("HP 9 → 15") with the heal drawn on the bar, the cost as a small chip, and two clear
  buttons. Esc (or B on a controller) is "Leave it" wherever leaving is allowed. **The shrine can be left** now too.
- **"Before the fight" is the same card:** the foe's picture, then every rule as its own row with an icon, a name and one line. A
  hidden trait is a "?" row.

**The Capital**
- **The floating grey rectangles on the hills are gone.** They were dead trees and rubble that lost their paint after the first visit.
  The ridges outside the wall now carry ruined houses, stretches of ash wall, toppled statues, rubble and crystals.
- **Walls no longer vanish.** A wall section could stay invisible after you had walked along its inside, and the east wall faded away
  whenever you walked beside it.
- **The Crease is a cavern:** rock on every side and overhead, stalactites that drip, puddles, lanterns and glowing crystals, a market of
  stalls and crates round Fig Sly. No sky and no castle over it. The six black doorways are iron hatches in the floor (the same six
  service shafts); the ladder and the tunnel are still there, against the rock.
- **A new quest, "Under the Capital", starts the first time you reach the Capital** and leads to the Crease and Fig Sly's Black Market,
  with a map pin and directions for each step.
- **One "Services restored" bar** in the corner, not two.
- **The fountains hold moving water.**

**Primm**
- **Lose to Primm and you choose:** "Fight Primm again" (from the start of Phase 1, with full HP and the freed leaders' boons; the
  castle's rooms are not replayed) or "Leave the castle". His fight is unchanged.
- **The castle's map shows room types one step further ahead**, so a route can be planned.
- **Every castle fight offers at least one Uncommon or better** among its three reward cards.

**Cards**
- **The coloured dots under a two-Path card's name are gone**, everywhere. The Path icons in the cost stay.
- **Chef Fennel Gravois's Snack is a 1/1**, as its text says (it entered as a 0/1 when his zone was reached early).
- **Deck copies:** the texts say what the rule is - up to 3 copies of any one card, depending on your level.

**The world**
- People and creatures have darker, clearer shadows at their feet, and props have a soft shade at their base.
- Quest markers shrink when the camera is close, so they no longer fill the screen at the Low camera.

## Known issues
- Fig Sly's portrait still has the extra arm: the replacement picture had not arrived when this build was made.
- The pale "ghost" building at the top left of the Transit Yards view is still there.
- The far north-east corner of the Capital (behind the houses) crowds the camera against the wall.
- See `docs/release/post_1_0_backlog.md` for the rest.

## Reporting a problem
Pause menu > **Report a Problem** (F8) writes a report file with a screenshot; or Settings > Accessibility > **Copy log**.
