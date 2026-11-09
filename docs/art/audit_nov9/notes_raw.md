# Art audit Nov 9 - raw reviewer notes (merged into art_audit_nov9.md / .csv)

Reviewed by the lead (sheets in docs/art/audit_nov9/sheets/, crops in crops/):

## keyart_stills (55) - sheets 01-07
- STORY-PRIMM-P1 / STORY-PRIMM-P2: SCALE - Primm leans over the model as a giant; the hero (small cloaked figure, bottom left) is about a sixth of his arm's length. Glaring (the brief's own example). FIX IN CODE possible: crop/pan to the right 70 % so the tiny hero is out of frame (Primm + model only); or REDO with the hero at true scale.
- STORY-REVEAL-KITCHEN: SCALE - the chef (the Doppelganger reveal) is a giant behind the counter; the hero is a tiny figure at the counter's foot. Noticeable. FIX IN CODE: crop out the left-bottom hero (crop x 0.25-1.0), or REDO.
- TITLE-KEYART-NIGHT: named night but it is a daytime painting (banners added). Minor (only if it is shown at night).
- STORY-EPI-TOGETHER (hands stack, crop epi_together_hands): fingers count right; slightly waxy rendering. KEEP.
- LOAD-GAINLANDS: a brute tossing a flying man (the thrower gag) - reads as intended; KEEP.
- Everything else (loading screens, logos, other stills, zone title banners): KEEP. Text on STORY-EPI-DECREE and STORY-EPI-FILE-COMPLETE is real, legible English.

## boards_maps (44) - sheets 01-05
- All boards and painted maps read as intended; no garbled text (BB-LIEUTENANT-QUOTA's number strip is real digits). KEEP.
- Note: BB-S-GOUR is a sushi counter (Japanese) while the Buffet elsewhere is European banquet; minor style drift, KEEP.

## ui_vendors (75) - sheets 01-07
- UI-CARDBACK-N vs UI-CARDBACK-R, UI-FRAME-N vs UI-FRAME-R, UI-PACK-N vs UI-PACK-R: both Paths are green (Necrocrat dark green + skull, Refusemancer leaf green). Readable by their emblem, but the two are close in colour - the colour-blind check in Part 4 covers it. Minor; KEEP (design, not art).
- Everything else KEEP.

## portraits (129) - sheets 01-11
- GLARING, species flips in expression variants (the dialogue / vendor screen swaps to them mid-conversation):
  - NPC-GATEKEEPER (Brannoch, a bear) -> NPC-GATEKEEPER_HAPPY / _STERN show a bearded HUMAN dwarf.
  - V-SABLE (a fox) -> V-SABLE_PLEASED / _SCHEMING show a HUMAN woman.
  - V-TONIC (a frog) -> V-TONIC_EXCITED / _OOPS show a HUMAN woman.
  - V-FENWICK (a magpie) -> V-FENWICK_EXCITED shows a HUMAN.
  - V-THREADWELL (a mouse) -> V-THREADWELL_DELIGHTED shows a HUMAN.
  FIX IN CODE applied tonight: `Portraits.HELD_EXPRESSIONS` - these variants are never shown (the base portrait stays). REDO the 8 files for Batch 14.
- Consistent and good: every CUT-* entrance cut-out, NPC-ELDER and its two variants, NPC-PLAYER and its two, V-BEETSWORTH / _PROUD, Primm's three phases.
- Everything else KEEP.

## sprites (105 characters, FRONT idle) - sheets 01-06
- Every walk set matches its portrait (species, outfit, colours); Flex and Flex freed are the lion; Dex the ferret. KEEP all.
