# Gourmand / Endless Buffet - Music Pass 2 notes (composer fork)

All 13 render and pass build.py audio checks (-20.0 LUFS, true peak <= -3.6 dB, seams within 1.5 dB; score checks ok). Zone theme =
`zones.BUFFET_THEME` (+ `BUFFET_HOOK` in the drops) in every cue; motif bars from the score logs.

| ID | key | BPM/meter | length s | zone theme + motif placements (bars) | LUFS | seam dB (or onset ms) |
|---|---|---|---|---|---|---|
| MUS-GOUR-BATTLE | Bb major | 142, 4/4 | 121.7 | theme A 4-19 (muted tpt/clarinet), B head 22/30 + phrase 24-35 (violins, G minor), hook 36-51 (saw lead), theme tutti 52-67; motif: 1 head, 12 stated, 20/28 stated G minor, 40/48 stated (lead), 60 head augmented, 69 head | -20.0 | -1.07 |
| MUS-GOUR-DUN-EXP | D minor | 112, 4/4 | 137.1 | theme in D minor staccato 8-23 (clarinet), head passed glock/celesta/xylo 26-33, strings unison 36-55; motif: 4 head augmented (bassoon), 24 stated, 30 stated a fifth up (muted tpt), 44 stated low (horns), 60 head | -20.0 | -0.80 |
| MUS-GOUR-DUN-BATTLE | G minor | 140, 4/4 | 123.4 | theme in G minor 4-19 (brass), augmented welcome 24-31 (violins), hook in minor 36-47 + theme head 48 (lead), theme 52-67 (violins); motif: 1 head, 8 stated, 20/28 augmented (horns), 40 stated (lead), 60 stated, 69 head | -20.0 | -0.70 |
| MUS-GOUR-BOSS | F minor | 128, 4/4 | 150.0 | theme F major in canon 4-19 (clarinet + muted tpt, copy a semitone flat from 12), theme F minor 20-25 + 56-61 in canon, MASK (welcome sliding chromatic) 0/16/28-35/64-75, hook minor 52-63; motif: 2 head, 14 stated (F major), 24 stated + 24 inverted MIRROR, 36 inverted augmented, 48 head augmented, 64 stated + 64 inverted, 78 head | -20.0 | -0.08 |
| MUS-GOUR-FREED | F major -> G major -> F | 124, 4/4 | 154.8 | theme on cello 4-19, strings 8va 20-35, hook 36-51, theme tutti in G 56-71; motif: 1 head, RESOLVED 28 (horns), 44 (lead), 64 (horns, G), 72 (cello) | -20.0 | +0.14 |
| MUS-GOUR-RELEASE | F major | 76, 4/4 (one-shot) | 66.3 (+ring = 71.7) | welcome at half speed 4-11 (cello), second phrase 12-15 (violins); motif: 1 head augmented, 16 RESOLVED (horn), 18 resolved tail (cello) onto held F chord | -20.0 | onset 4.7 ms |
| MUS-OMAKASE-EXP | D minor | 84, 4/4 | 137.1 | theme in D minor on koto 8-23, glock 16-23, strings 32-41; motif: 1 head (shakuhachi), 24 stated, 28 stated a fifth down (shakuhachi), 45 head | -20.0 | -0.39 |
| MUS-OMAKASE-BATTLE | D minor | 140, 4/4 | 123.4 | theme 4-19 (brass, clipped), second phrase 36-51 (shakuhachi, half time), theme 52-67 (violins + brass); motif: 1 head, 20/28 stated (shakuhachi), 24 stated (horns), 60 stated, 69 head | -20.0 | +0.09 |
| MUS-OMAKASE-BOSS | G minor | 132, 4/4 | 145.5 | villain ITAMAE theme 1/4-19/48/60-67/72; Buffet theme corrupted in G minor 20-35 (koto + shamisen half a beat behind), 68-71; motif: 24/32 inverted (horns), 36 stated broadened (shakuhachi), 44 head (violins), 52 stated twice (horns vs ITAMAE) | -20.0 | +0.19 |
| MUS-SHOP-MIREPOIX | Bb major | 100, 4/4 | 86.4 | theme on piano 0-15 (formal), second phrase 16-27 (strings, welcoming), close 28-35 (piano); motif: 19 head, 25 head lower (clarinet) | -20.0 | +0.19 |
| MUS-MINIGAME-GOUR | C major | 138, 4/4 | 76.5 | theme on xylophone 4-19, strings + xylo 28-39; motif: 0 head (muted tpt), 20 stated A minor, 24 stated C (clarinet, traded with piano), 40 head | -20.0 | +0.25 |
| MUS-CAP-GOUR-BROKEN | F minor | 96, 4/4 | 120.0 | theme in F minor cut into pieces 8-23 + 36-43 (celesta, clarinet 25 cents flat via detune), one bar of the major welcome on cello 28; motif: 1/32/45 head (flute, unanswered) | -20.0 | -0.09 |
| MUS-CAP-GOUR-RESTORED | F major | 112, 4/4 | 120.0 | theme in tune 4-19 (clarinet + celesta), welcome in D minor 28 (violins), theme 32-47 (strings), 48 (clarinet); motif: 1/53 head (flute), RESOLVED 44 (horns), 48 (cello) | -20.0 | -0.43 |

## Listen for

- **MUS-GOUR-BATTLE**: the "welcome" theme bouncing at battle tempo over tuba and string 8ths; the horns' G-minor motif in B; the saw-lead drop at 0:51; the kick staying under the finale.
- **MUS-GOUR-DUN-EXP**: the machine is on the grid (no humanising); the clarinet's theme should sound correct but lifeless; the head passed station to station in B.
- **MUS-GOUR-DUN-BATTLE**: walking contrabass + claves/woodblock line; B's held tension; whether the minor hook in the machine drop still reads as the Buffet's.
- **MUS-GOUR-BOSS**: the strict canon in A (the copy drifting a semitone flat from bar 12); hero motif vs its mirror at 0:45 and 2:00; the 40-cent-flat celesta in the dark middle.
- **MUS-GOUR-FREED**: the warm cello theme first; the climb on D7 into G major (1:37); resolved motifs throughout; the sparkle loop point.
- **MUS-GOUR-RELEASE**: sincere and slow; the clarinet's little answers; the resolved motif onto a held F chord, room for dialogue.
- **MUS-OMAKASE-EXP**: the space - koto single notes, shakuhachi breaths; GM koto/shakuhachi are thin patches, judge them as colour.
- **MUS-OMAKASE-BATTLE**: the "knife" string stabs in B answering the shakuhachi; taiko on the grid; the half-time C section.
- **MUS-OMAKASE-BOSS**: the ITAMAE theme's blade-like 16th cut; koto and shamisen deliberately half a beat apart; the quiet tea-ceremony middle.
- **MUS-SHOP-MIREPOIX**: crisp formal piano, then strings warm it up; low busyness for browsing.
- **MUS-MINIGAME-GOUR**: TV energy (brass "and now!", timer woodblock, triangle dings); the clarinet/piano trade in B.
- **MUS-CAP-GOUR-BROKEN**: the detuned clarinet behind the celesta (it should sound wrong, not broken audio); phrases cut mid-bar; the one bar of warm cello.
- **MUS-CAP-GOUR-RESTORED**: the same theme, in tune and full; the stiff snare keeping the Capital's tension; the resolved motif at 1:34.
