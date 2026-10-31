# Batch 09b - Side areas (Music Pass 3, Part 6) - composer fork C

Core orchestra + each area's own colour and own theme (all original, in `tools/music/scores/_fork_c.py`): VAULT_ROYAL (the vault's quiet
royal phrase, F# minor) and SEALS (the Vault Guardian's idea); GRAVE_HUM (Old Hob's crooked hum, G minor 3/4); ARENA_THEME (Grand Bellows'
fanfare-tune, Eb major). SHIRO's figure, POSE and SLIP live in MUS-SHIRO-BOSS.py. Crossroads motif in every track, never resolved.
MUS-VAULT-BOSS is its own track (was an alias of VAULT-BATTLE); it also plays for the Warden of the Four Seals duel.

| ID | Key | Tempo | Length | Motif / zone theme (bar: form) | Sections (bar: LUFS) | LUFS / TP | Seam / onset | Preview |
|---|---|---|---|---|---|---|---|---|
| MUS-VAULT-EXP | F# minor | 80 BPM 4/4 | 2:12.0 (44 bars) | 1: head (celesta, a clue); 12: stated (cello, under the clarinet); 20: stated (violins, A major - discovery); 34: head (horn, under the phrase); 41: head (celesta, a clue) | 0 clockwork: -25.2; 4 A royal phrase, four colours: -20.1; 20 B discovery: -19.3; 32 C the phrase together: -18.4; 40 clockwork: -26.5 | -20.0 / -6.9 dB | -0.29 dB, no click | `Music Review/Batch 09b/MUS-VAULT-EXP.mp3` |
| MUS-VAULT-BATTLE | B minor | 140 BPM 4/4 | 2:03.4 (72 bars) | 1: head (horns, over the bed); 8: stated (flute, over the horns); 20: stated (trumpets); 28: stated (trumpets); 44: head augmented (horns); 52: augmented (trombones, tension); 69: head (horns, over the bed) | 0 bed: -20.2; 4 A royal phrase (horns): -18.9; 20 B four colours answer: -21.7; 36 C strings drive: -19.4; 52 D tension: -20.6; 68 bed: -19.9 | -20.0 / -6.5 dB | -0.18 dB, no click | `Music Review/Batch 09b/MUS-VAULT-BATTLE.mp3` |
| MUS-VAULT-BOSS | F# minor | 128 BPM 4/4 | 2:07.5 (68 bars) | 1: head (horns, over the seals); 12: stated (trumpet, defying); 20: stated - horn (Beefcake seal); 24: stated - celesta (Necrocrat seal); 28: stated - clarinet (Gourmand seal); 32: stated - flute (Refusemancer seal); 44: head augmented (cello, hush); 50: augmented (horns, climax); 56: stated (violins high, climax); 65: head (horns, over the seals) | 0 seal strokes: -19.4; 4 A the Guardian: -19.4; 20 B four seals: -20.9; 36 C hush: -25.6; 48 climax: -18.2; 64 seal strokes: -19.7 | -20.0 / -4.8 dB | -0.03 dB, no click | `Music Review/Batch 09b/MUS-VAULT-BOSS.mp3` |
| MUS-GRAVE-EXP | G minor | 96 BPM 3/4 | 2:00.0 (64 bars) | 0: head (clarinet, a lantern peeking); 20: stated (clarinet, Bb major, amused); 36: inverted (cello, unease); 60: head (clarinet, a lantern peeking) | 0 lanterns: -22.1; 4 A the hum (bassoon, then Hob): -19.4; 20 B amusing: -19.4; 36 C mist: -23.1; 52 D all hum: -17.8; 60 lanterns: -22.3 | -20.0 / -7.1 dB | -0.19 dB, no click | `Music Review/Batch 09b/MUS-GRAVE-EXP.mp3` |
| MUS-GRAVE-BATTLE | Bb minor | 144 BPM 4/4 | 1:46.7 (64 bars) | 1: head (horns, over the bed); 20: stated (trumpets); 28: stated (trumpets); 44: head augmented (horns, under the hum); 52: inverted (trombones, tension); 61: head (horns, over the bed) | 0 bed: -20.2; 4 A the hum: -18.4; 20 B motif: -21.8; 36 C bones: -19.9; 52 D tension: -21.1; 60 bed: -20.7 | -20.0 / -6.8 dB | +0.99 dB, no click | `Music Review/Batch 09b/MUS-GRAVE-BATTLE.mp3` |
| MUS-ARENA-BATTLE | Eb major | 140 BPM 4/4 | 1:49.7 (64 bars) | 2: head (glockenspiel sparkle); 8: stated (flute, over the trumpets); 20: stated (horn, strategy); 28: stated (clarinet); 38: countermelody (horns, under the violins); 46: head augmented (trombones); 62: head (glockenspiel sparkle) | 0 fanfare: -19.6; 4 A the tune: -20.1; 20 B strategy: -23.4; 36 C the tune, strings: -19.2; 52 D presenting: -18.9; 60 fanfare: -19.3 | -20.0 / -6.3 dB | -0.31 dB, no click | `Music Review/Batch 09b/MUS-ARENA-BATTLE.mp3` |
| MUS-ARENA-ELITE | Ab major | 148 BPM 4/4 | 1:50.3 (68 bars) | 10: stated (flute, above the canon); 24: stated (trombones, E major, in the fugato); 32: stated (trumpets, climax); 36: stated (trumpets, C minor, climax); 40: head augmented (horns); 50: stated (horn, the strategy canon) | 0 fanfare: -19.7; 4 A tune + countersubject + canon: -20.2; 20 B fugato: -20.1; 28 C climax: -18.8; 44 D strategy canon: -23.8; 56 E tutti return: -18.9; 64 fanfare: -19.8 | -20.0 / -6.5 dB | -0.89 dB, no click | `Music Review/Batch 09b/MUS-ARENA-ELITE.mp3` |
| MUS-SHIRO-BOSS | E minor | 152 BPM 4/4 | 1:53.7 (72 bars) | 1: head (horns, behind the curtain); 12: stated (cello, under the trick); 26: stated (clarinet, regaining composure); 36: stated (horns, the sincere side); 52: head augmented (trombones); 66: tail (clarinet, recovering); 69: head (horns, behind the curtain) | 0 clappers: -19.8; 4 A the trick: -22.1; 20 B the pose: -17.6; 28 C chase (sincere): -18.7; 44 D brass trick: -22.6; 60 E the pose again: -19.2; 68 clappers: -19.9 | -20.0 / -3.6 dB | -0.96 dB, no click | `Music Review/Batch 09b/MUS-SHIRO-BOSS.mp3` |

All: true peak -3.6 to -7.1 dBTP, no clicks; score checks (range, low end, melody) ok. Lengths follow the rows (90-150 s) and the bible's
battle rule; GRAVE-EXP is 2:00, VAULT-EXP 2:12.

## Listen for

- MUS-VAULT-EXP: the woodblock/glock clockwork; the royal phrase handed horn -> celesta -> clarinet -> flute (one colour per Path); the middle brightening to A major with the violins' motif and the lullaby's first four notes on the celesta (bar 28, F# C# A G#); the phrase in octaves at the end.
- MUS-VAULT-BATTLE: the 8th string drive and ticking woodblock; the royal phrase in the horns; phrase two's trumpet motif answered by four quick colour calls; the violins taking the phrase up an octave with brass stabs; the darker trombone passage.
- MUS-VAULT-BOSS: the four seal strokes + grinding answer (trombones/tuba over concert bass drum); the royal phrase mirrored in the horns; one seal per Path colour (horn, celesta, clarinet, flute) each with a motif statement; the hush (the phrase as it was, celesta/flute); the climax with the phrase in the strings over the seals.
- MUS-GRAVE-EXP: Old Hob's hum on bassoon, then on the oohs choir (his voice); the late "crooked" pizzicato chords; xylophone bones; the amused Bb-major clarinet section; the misty tremolo with the inverted motif; everybody humming at bar 52. No organ.
- MUS-GRAVE-BATTLE: the chromatic low-string creep; dry stick/click/snare percussion; woodwind echoes a beat behind each phrase end; the hum in bassoon + horns, later in violins with xylophone; trumpets' motif in B.
- MUS-ARENA-BATTLE: the fanfare with snare rolls; the broad tune in trumpet/horns; the quiet strategic B (pizz, clarinet, horn motif); the tune in the violins with the horns' motif as countermelody; the "presenting..." chord ladder over a drumroll.
- MUS-ARENA-ELITE: the violin countersubject and the cellos' canon a bar behind; the fugato through C minor and E major; the climax with the tune augmented in trombones/tuba and the trumpets' motif; the quiet oboe/clarinet/flute canon.
- MUS-SHIRO-BOSS: the accelerating wooden clappers; the sly figure in piccolo + pizzicato with feints; the grand pose climbing to high E and the chromatic slip, the bassoon apologising; the sincere G-major violin melody in the chase with the horns' motif; the second, longer slip.

## Questions

1. **No organ in GRAVE-EXP.** Its row asks for "bassoon/organ colours"; organ is the D.N.A.'s sound and the row also says to stay distinct
   from the Necrocrats, so the hum is bassoon + oohs choir. A quiet reed organ could be added if wanted.
2. **Vault lullaby glimpse.** VAULT-EXP has the lullaby's first four notes once (a "royal clue"); VAULT-BATTLE/BOSS have none. Say if the
   vault should not hint at the lullaby at all.
3. **SHIRO-BOSS peak placement.** The loudest section is the first pose (bar 20), the brass-trick section (bar 44) is lighter by design
   (a feint before the second pose). Easy to lift if the fight needs more drive there.
