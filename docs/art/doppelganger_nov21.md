# The Doppelganger's two pictures before the Test Kitchen's last fight (Fable Nov 21)

The cutscene `reveal` plays before the Doppelganger's fight. Beats 1 to 4 sit on one still, beat 5 on another
(`StoryStills.CUTSCENE_BEAT_BACKDROPS["reveal"]`). The two do not look like the same character in the same room.

| | Beats 1 to 4 | Beat 5 |
|---|---|---|
| File in the game | `assets/art/keyart/STORY-REVEAL-KITCHEN.webp` | `assets/art/keyart/STORY-DOPPEL.webp` |
| Source on the Drive | `Approved_KeyArt/STORY-REVEAL-KITCHEN.png` (1659x933) | `Approved_KeyArt/STORY-DOPPEL.png` (1536x864) |
| Batch 18 row | `STORY-REVEAL-KITCHEN` (remake) | `STORY-DOPPEL` (remake) |

## What differs today

| | STORY-REVEAL-KITCHEN | STORY-DOPPEL |
|---|---|---|
| What is under the face | a smooth, blank, white head with no features | a black shadow body with red-black smoke and a clawed black hand |
| How the face comes off | lifted by the jaw like a soft rubber mask | torn away like burning paper |
| The magic's colour | violet sparks | red and black smoke |
| The room | a calm vaulted stone kitchen, hanging copper pans, a steel counter, one copper vat with green fumes | a golden weapons factory: a cake cannon, ovens and machines, orange glow, no counter |
| The hero | in the left foreground, from behind (teal hooded cloak) | not in the picture |
| Her mood | amused, in control | a monster bursting out |

## Which one is right

The first. Her own lines say so: "I wore her face for so long that I forgot my own, and there is nothing in here to taste with"
(`cutscene.reveal.5`), "I have no face of my own and no name" (`cutscene.wonder.2`), and the Grand Chef answers "No face and no
name, and I don't care a crumb about either" (`cutscene.wonder.6`). She has **no face**, not a monster's face; a few scenes later she
is a shy kitchen apprentice, which a clawed smoke creature cannot become. Her other pictures agree with the first still: the portrait,
the entrance cut-out and the Bestiary square (`NPC-DOPPEL`, `CUT-DOPPEL`, `BST-THE-DOPPELGANGER`) all show the Grand Chef's outfit with
a thin **violet** glow at the hair and cuffs, never red or black.

## The description both rows share

**The character.** The Doppelganger wears the Grand Chef's whole outfit: a tall white toque with a gold fleur-de-lis band and a red
bow, silver-grey curls, pearl earrings, a white double-breasted chef's coat with gold filigree, a red neckerchief with a gold
fleur-de-lis pin, red and gold cuffs with white ruffles, a red sash tied in a bow. Under the borrowed face her head is a smooth, blank,
porcelain-white oval with no features at all, and a hair-thin seam of soft violet light runs where the face joined. Eerie and a little
sad, never a monster: no claws, no smoke, no teeth.

**The room.** The Executive Test Kitchen: a warm vaulted stone hall, tall arched windows letting in gold evening light, a hanging ring
of copper pans, a long brushed-steel counter across the front, and one big copper vat on the right breathing green Special Sauce
fumes. The same camera in both pictures.

**The two moments.** `STORY-REVEAL-KITCHEN`: she lifts the face by the jaw and the blank chin shows; the hero stands in the left
foreground with his back to us. `STORY-DOPPEL`: a moment later, the face is off and hangs from one hand like a limp mask; she stands
upright behind the same counter, faceless.

When the pair arrives: import both as usual (`bash tools/import_key_art.sh`); nothing else changes, the ids stay.
