"""Batch 07 - all 21 stingers (Music Pass 2, Oct 31). One builder per STG- ID; each tools/music/scores/STG-*.py imports its builder.

One-shots: -17 LUFS, ring out (no fold), first sound at beat 0 (a plucked, struck or tongued attack on the downbeat so the cue starts
instantly; the renderer also trims any synth lead-in and reports onset_ms). Short and dry where they are heard constantly (VICTORY,
PURCHASE, MINI-*), broader where they are rare (DUNGEON, PACK-LEGEND, ZONE-*).

STG-VICTORY is the most-heard cue in the game: ~4 s, brass + strings over a short timpani roll, a cymbal and a held Bb major chord; its
tune is the Crossroads motif's RESOLVED tail (D C Bb in Bb major) - the one exception outside freed tracks: the battle lands home.
The STG-ZONE-* liberation stings are each zone's freeing moment, so they also carry the resolved tail, inside their zone's theme and
palette. Everything else ends open or on a plain cadence (no resolved motif).
"""
from lib import Score, Song, m, motif, motif_head, motif_tail, voice, p, Scale
from lib.zones import DNA_THEME, BUFFET_THEME, DUMP_JIG_HEAD

TRIANGLE = 81      # orchestra kit: open triangle
HUMAN = (0.006, 4)


def sting(id, bpm, bars, key, seed, meter=(4, 4), cap=None):
    s = Score(id, bpm=bpm, bars=bars, meter=meter, key=key, seed=seed, kind='oneshot', human=HUMAN)
    s.max_seconds = cap
    return s


def chord(s, ch, beat, beats, notes, vel):
    for n in notes:
        s.note(ch, beat, beats, p(n), vel, human=False)


# ---------------------------------------------------------------- STG-VICTORY
def victory():
    """4 s. Beat 0: timpani roll + a rising string run (the lift); beat 1: brass and strings sing D5 C5 over Bb - F7 (the resolved tail,
    dotted rhythm of the motif); beat 2.5: Bb4 lands with the cymbal on a held, warm Bb major chord that is cut cleanly (no long tail)."""
    s = sting('STG-VICTORY', 120, 2, 'Bb major', 701, cap=4.0)
    s.seat('tpt', 'hn', 'tbn', 'tuba', 'vln', 'pad', 'vc', 'cb', 'timp', 'perc', 'harp')
    s.section(0, 'lift')
    s.section(1, 'cadence')
    # lift: a short timpani roll on F and a 16th-note string run Bb3 -> F5 into the downbeat
    s.timp_roll(0.0, 1.0, 'F2', 70, 104)
    s.run('vln', 0, 'Bb3', 'Eb5', Scale('Bb3', 'major'), 70, step=1 / 11, crescendo=24)
    s.note('harp', 0.0, 1.0, p('Bb2'), 84, human=False)
    s.note('harp', 0.0, 1.0, p('F3'), 70, human=False)
    chord(s, 'hn', 0.0, 0.9, ['F3', 'Bb3', 'D4'], 66)
    # cadence: the resolved tail D C | Bb (q. e | held), harmonised Bb  F7 | Bb
    tail = motif_tail('Bb4', 'major', rhythm=(1.5, .5, 2.5), resolved=True)      # D5 C5 Bb4
    s.motif('tpt', 0, tail, 98, form='RESOLVED tail (trumpets): the battle lands home', beat=1.0, legato=0.92)
    s.line('vln', 0, tail, 96, transpose=12, beat=1.0, legato=0.98)
    s.line('hn', 0, tail, 90, transpose=-12, beat=1.0, legato=0.95)
    chord(s, 'tbn', 1.0, 1.4, ['F3', 'Bb3', 'D4'], 82)
    chord(s, 'tbn', 2.5, 0.48, ['F3', 'A3', 'Eb4'], 82)
    chord(s, 'pad', 1.0, 1.5, ['D4', 'F4', 'Bb4'], 74)
    chord(s, 'pad', 2.5, 0.5, ['C4', 'Eb4', 'A4'], 74)
    s.note('tuba', 1.0, 1.4, p('Bb1'), 92, human=False)
    s.note('tuba', 2.5, 0.48, p('F2'), 88, human=False)
    s.note('cb', 1.0, 1.5, p('Bb1'), 84, human=False)
    s.note('cb', 2.5, 0.5, p('F2'), 80, human=False)
    s.note('vc', 1.0, 1.5, p('D3'), 80, human=False)
    s.note('vc', 2.5, 0.5, p('C3'), 78, human=False)
    s.timp_hit(1.0, 'Bb2', 96)
    # landing: Bb major, held 2.5 beats (brass cut a little before the strings), cymbal + timpani
    land = 3.0
    chord(s, 'tbn', land, 2.0, ['F3', 'Bb3', 'D4'], 88)
    chord(s, 'hn', land, 2.2, ['Bb3', 'D4', 'F4'], 84)
    chord(s, 'pad', land, 2.6, ['F3', 'Bb3', 'D4', 'F4', 'Bb4'], 82)
    s.note('vln', land, 2.6, p('D6'), 90, human=False)
    s.note('tpt', land, 2.0, p('F5'), 84, human=False)
    s.note('tuba', land, 2.2, p('Bb1'), 96, human=False)
    s.note('cb', land, 2.6, p('Bb1'), 88, human=False)
    s.note('vc', land, 2.6, p('Bb2'), 86, human=False)
    s.timp_hit(land, 'Bb2', 108)
    s.hit('crash', land, 92, dur=2)
    s.harp(0, 'Bb', 72, beats=1.0, beat=land, octave=1)
    for ch in ('tpt', 'hn', 'tbn', 'pad', 'vln'):
        s.expr(ch, 0, 112)
    s.notes.append('Resolved Crossroads tail D C Bb (the one exception outside freed tracks). ~4 s with the ring; no fanfare repeat.')
    return s


# ---------------------------------------------------------------- STG-DEFEAT
def defeat():
    """A descending oboe/cello phrase (A G F E) over D minor that turns to Bb and settles on a soft F major chord: a setback, hope left."""
    s = sting('STG-DEFEAT', 72, 1, 'D minor -> F major', 702, cap=5.0)
    s.seat('ob', 'vc', 'cb', 'pad', 'harp', 'cl')
    s.note('harp', 0.0, 2.0, p('D3'), 70, human=False)
    s.note('harp', 0.0, 2.0, p('A3'), 60, human=False)
    s.mel('ob', 0, m('A4:.5 G4:.5 F4:.5 E4:1 D4:1.5'), 80, legato=0.98)
    s.line('vc', 0, m('D3:1.5 Bb2:1 A2:1 r:.5'), 70, legato=1.0)
    s.motif('cl', 0, motif_head('D4', 'minor', rhythm=(.75, .5, 1.25)), 54, form='head (clarinet, a quiet question under the fall)',
            lead=False, beat=1.5)
    chord(s, 'pad', 0.0, 1.5, ['D4', 'F4', 'A4'], 50)
    chord(s, 'pad', 1.5, 1.0, ['D4', 'F4', 'Bb4'], 48)
    chord(s, 'pad', 2.5, 2.5, ['C4', 'F4', 'A4'], 46)
    s.note('cb', 0.0, 1.5, p('D2'), 60, human=False)
    s.note('cb', 1.5, 1.0, p('Bb1'), 56, human=False)
    s.note('cb', 2.5, 2.5, p('F2'), 54, human=False)
    s.note('ob', 3.5, 1.5, p('A4'), 58, human=False)
    s.harp(0, 'F', 50, beats=1.5, beat=3.0)
    return s


# ---------------------------------------------------------------- STG-LEVEL
def level():
    """A rising harp/pizzicato figure (G B D G B D) answered by a warm Gadd9 chord (horn + strings) and a triangle."""
    s = sting('STG-LEVEL', 132, 1, 'G major', 703, cap=3.8)
    s.seat('harp', 'pizz', 'hn', 'pad', 'vc', 'fl', 'perc')
    rise = ['G3', 'B3', 'D4', 'G4', 'B4', 'D5']
    for i, n in enumerate(rise):
        s.note('harp', i * 0.25, 1.2, p(n), 78 + i * 3, human=False)
        s.note('pizz', i * 0.25, 0.3, p(n), 70 + i * 3, human=False)
    land = 1.5
    chord(s, 'pad', land, 2.6, ['G3', 'D4', 'A4', 'B4'], 70)
    chord(s, 'hn', land, 2.4, ['B3', 'D4', 'G4'], 72)
    s.note('vc', land, 2.6, p('G2'), 70, human=False)
    s.note('fl', land, 2.2, p('G5'), 64, human=False)
    s.note('harp', land, 2.0, p('G5'), 70, human=False)
    s.hit(TRIANGLE, land, 66, dur=2)
    s.swell('pad', 0, 1, 96, 80)
    return s


# ---------------------------------------------------------------- STG-QUEST
def quest():
    """A compact clarinet/piano cadence (C A Bb G | F) over IV - V7 - I in F major; the strings answer with a warm F chord."""
    s = sting('STG-QUEST', 104, 1, 'F major', 704, cap=3.8)
    s.seat('piano', 'cl', 'pad', 'vc', 'cb')
    s.mel('cl', 0, m('C5:.5 A4:.5 Bb4:.5 G4:.5 F4:2'), 82, legato=0.95)
    s.line('piano', 0, m('C6:.5 A5:.5 Bb5:.5 G5:.5 F5:1'), 70)
    chord(s, 'piano', 0.0, 1.0, ['Bb3', 'D4', 'F4'], 66)
    chord(s, 'piano', 1.0, 1.0, ['Bb3', 'C4', 'E4', 'G4'], 64)
    chord(s, 'piano', 2.0, 1.5, ['A3', 'C4', 'F4'], 66)
    s.note('cb', 0.0, 1.0, p('Bb1'), 60, human=False)
    s.note('cb', 1.0, 1.0, p('C2'), 60, human=False)
    s.note('cb', 2.0, 2.5, p('F1'), 64, human=False)
    chord(s, 'pad', 2.0, 2.6, ['C4', 'F4', 'A4', 'C5'], 68)
    s.note('vc', 2.0, 2.6, p('F2'), 66, human=False)
    s.swell('pad', 0, 1, 70, 100, 'arch')
    return s


# ---------------------------------------------------------------- STG-DUNGEON
def dungeon():
    """The victory cadence broadened (96 BPM): a timpani roll, horns and strings climb Eb - F - Bb, the melody lands on the third (D),
    not the motif, and the chord is held a little longer than VICTORY's before exploration resumes."""
    s = sting('STG-DUNGEON', 96, 2, 'Bb major', 705, cap=6.0)
    s.seat('hn', 'tbn', 'tuba', 'vln', 'pad', 'vc', 'cb', 'timp', 'perc', 'harp', 'tpt')
    s.timp_roll(0.0, 1.0, 'F2', 64, 100)
    s.note('harp', 0.0, 1.0, p('Eb3'), 82, human=False)
    chord(s, 'hn', 0.0, 1.0, ['G3', 'Bb3', 'Eb4'], 74)
    s.mel('vln', 0, m('Bb4:1 Eb5:1 F5:.75 G5:.25 F5:1 D5:3'), 92, transpose=0, legato=0.98)
    s.line('hn', 0, m('Bb3:1 Eb4:1 F4:.75 G4:.25 F4:1 D4:3'), 86)
    s.line('tpt', 1, m('F4:1 Bb4:3'), 82, beat=0.0)
    for beat, sym, bass in ((0, ['G3', 'Bb3', 'Eb4'], 'Eb2'), (2, ['A3', 'C4', 'F4'], 'F2'), (3, ['Bb3', 'D4', 'F4'], 'Bb1')):
        dur = 3.2 if beat == 3 else (2.0 if beat == 0 else 1.0)
        chord(s, 'pad', beat, dur, sym, 76)
        chord(s, 'tbn', beat, dur * 0.85, sym, 76)
        s.note('cb', beat, dur, p(bass), 82, human=False)
        s.note('vc', beat, dur, p(bass) + 12, 76, human=False)
        s.note('tuba', beat, dur * 0.85, p(bass), 84, human=False)
    s.timp_hit(4.0, 'Bb2', 104)
    s.hit('crash', 4.0, 84, dur=2)
    s.harp(1, 'Bb', 70, beats=1.5, beat=0.0, octave=1)
    s.swell('pad', 0, 2, 90, 110, 'arch')
    return s


# ---------------------------------------------------------------- STG-ZONE-NECRO
def zone_necro():
    """The D.N.A. theme's last phrase on bassoon + clarinet over a soft organ and pizzicato, the clock ticking; the cadence it always
    postponed (D F B ... C) finally arrives - on C MAJOR, a softened organ chord, the clock stops. A horn carries the resolved tail."""
    s = Song('STG-ZONE-NECRO', bpm=116, bars=4, meter=(3, 4), key='C minor -> C major', seed=706, kind='oneshot', jitter=0.006)
    s.add('organ', 0, 19, pan=64, rev=105, vol=84)
    s.add('bsn', 1, 70, pan=70, rev=85, vol=88)
    s.add('cl', 2, 71, pan=60, rev=85, vol=80)
    s.add('pizz', 3, 45, pan=74, rev=80, vol=84)
    s.add('cb', 4, 43, pan=92, rev=90, vol=90)
    s.add('hn', 5, 60, pan=78, rev=95, vol=88)
    s.add('choir', 6, 52, pan=64, rev=110, vol=66)
    s.add('celesta', 7, 8, pan=44, rev=100, vol=66)
    s.add('kit', 9, 48, pan=64, rev=85, vol=80)
    phrase = DNA_THEME[30:]            # C5 Eb5 G5 Ab5 Eb5 | D5 F5 B4 | C5 (the theme's final, delayed cadence)
    s.mel('bsn', 0, phrase, 86, transpose=-12)
    s.line('cl', 0, phrase, 70)
    for bar, ch in enumerate([['C3', 'G3', 'C4', 'Eb4'], ['C3', 'F3', 'Ab3', 'C4'], ['D3', 'F3', 'G3', 'B3']]):
        s.chord('organ', s.B(bar), 3.0, ch, 52)
        s.chord('pizz', s.B(bar), 0.4, [ch[0]], 74)
        s.chord('pizz', s.B(bar, 1), 0.4, ch[1:3], 60)
        s.chord('pizz', s.B(bar, 2), 0.4, ch[1:3], 56)
        s.note('cb', s.B(bar), 2.8, p(ch[0]) - 12, 70)
        for k in range(3):
            s.note('kit', s.B(bar, k), 0.2, 76 if k == 0 else 77, 46 if k == 0 else 36, human=False)
    land = s.B(3)
    s.chord('organ', land, 4.5, ['C3', 'G3', 'C4', 'E4', 'G4'], 58)
    s.note('organ', land, 4.5, p('C2'), 54)
    s.chord('choir', land, 4.2, ['E4', 'G4', 'C5'], 56)
    s.note('cb', land, 4.0, p('C2'), 70)
    s.chord('pizz', land, 0.5, ['C3', 'G3', 'E4'], 70)
    s.note('celesta', land, 3.0, p('E6'), 54)
    s.note('celesta', land + 1, 3.0, p('G6'), 48)
    s.motif('hn', 3, motif_tail('C4', 'major', rhythm=(1.5, .5, 3), resolved=True), 70, form='RESOLVED tail (horn, C major): approved')
    s.ramp('organ', 3, 1.5, 96, 70)
    s.max_seconds = 8.0
    return s


# ---------------------------------------------------------------- STG-ZONE-GOUR
def zone_gour():
    """The Buffet theme's first two bars, full showtune band (brass, strings, oom-pah, glock), a snare build, then the BUTTON: the
    resolved tail A G | F as a brass stab with a kick, a clap and a crash. Original - quotes no song."""
    s = Song('STG-ZONE-GOUR', bpm=132, bars=3, meter=(4, 4), key='F major', seed=707, kind='oneshot', jitter=0.006)
    s.add('vln', 0, 48, pan=36, rev=95, vol=92)
    s.add('brass', 1, 61, pan=70, rev=90, vol=92)
    s.add('tuba', 2, 58, pan=88, rev=85, vol=88)
    s.add('pizz', 3, 45, pan=74, rev=75, vol=84)
    s.add('glock', 4, 9, pan=44, rev=95, vol=70)
    s.add('mtpt', 5, 59, pan=56, rev=85, vol=84)
    s.add('choir', 6, 52, pan=64, rev=105, vol=66)
    s.add('timp', 7, 47, pan=64, rev=80, vol=90)
    s.add('sbass', 8, 38, pan=64, rev=30, vol=90)
    s.add('kit', 9, 0, pan=64, rev=60, vol=96)
    head = BUFFET_THEME[:11]           # C A C F E F | D C A F A  (bars 1-2)
    s.mel('brass', 0, head, 96)
    s.line('vln', 0, head, 92, transpose=12)
    s.line('glock', 0, head, 60, transpose=12)
    for bar, (root, ch) in enumerate([('F2', ['A3', 'C4', 'F4']), ('D2', ['A3', 'D4', 'F4'])]):
        s.note('tuba', s.B(bar, 0), 0.8, p(root), 88)
        s.note('tuba', s.B(bar, 2), 0.8, p(root) + 7, 80)
        for beat in (1, 3):
            s.chord('pizz', s.B(bar, beat), 0.4, ch, 72)
        s.note('kit', s.B(bar, 0), 0.25, 36, 84 if bar == 0 else 74, human=False)
        s.note('kit', s.B(bar, 2), 0.25, 36, 70, human=False)
    s.note('kit', 0.0, 1.0, 49, 84, human=False)
    for i in range(8):
        s.note('kit', s.B(1, 2) + i * 0.25, 0.2, 38, 50 + i * 7, human=False)
    # the button: resolved tail A G | F (stab) - C7 then F, kick + clap + crash on the stab
    tail = [('A5', 1), ('G5', 1), ('F5', 1.5)]
    s.motif('brass', 2, tail, 104, form='RESOLVED tail (brass): the button')
    s.line('vln', 2, tail, 98)
    s.line('mtpt', 2, tail, 84, transpose=-12)
    s.chord('choir', s.B(2), 2.0, ['Bb3', 'E4', 'G4'], 60)
    s.note('tuba', s.B(2), 1.8, p('C2'), 90)
    stab = s.B(2, 2)
    s.chord('brass', stab, 0.9, ['F3', 'A3', 'C4', 'F4', 'A4'], 108)
    s.chord('vln', stab, 0.9, ['A4', 'C5', 'F5'], 100)
    s.chord('choir', stab, 1.2, ['A3', 'C4', 'F4'], 66)
    s.note('tuba', stab, 0.9, p('F1'), 100)
    s.note('sbass', stab, 0.6, p('F1'), 104, human=False)
    s.note('timp', stab, 1.0, p('F2'), 104, human=False)
    s.note('kit', stab, 0.3, 36, 118, human=False)
    s.note('kit', stab, 0.3, 39, 100, human=False)
    s.note('kit', stab, 2.0, 49, 104, human=False)
    s.max_seconds = 7.0
    return s


# ---------------------------------------------------------------- STG-ZONE-REF
def zone_ref():
    """The fiddle's jig head (two bars of 6/8) over strummed guitar and tambourine; then the crowded harmony lets go: a clear flute
    sings the resolved tail in E major (G# F# E) over harp and a gently decaying E major chord, chimes ringing."""
    s = Song('STG-ZONE-REF', bpm=174, bars=5, meter=(6, 8), key='E Dorian -> E major', seed=708, kind='oneshot', jitter=0.006)
    s.add('fid', 0, 40, pan=40, rev=85, vol=96)
    s.add('fl', 1, 73, pan=52, rev=90, vol=84)
    s.add('gtr', 2, 24, pan=70, rev=70, vol=84)
    s.add('harp', 3, 46, pan=46, rev=95, vol=80)
    s.add('bells', 4, 14, pan=60, rev=110, vol=62)
    s.add('vln', 5, 48, pan=36, rev=100, vol=84)
    s.add('cb', 6, 43, pan=92, rev=90, vol=88)
    s.add('celesta', 7, 8, pan=44, rev=105, vol=68)
    s.add('kit', 9, 48, pan=64, rev=80, vol=84)
    s.mel('fid', 0, DUMP_JIG_HEAD, 96, legato=0.88)
    for bar, ch in enumerate([['E3', 'B3', 'E4', 'G4'], ['D3', 'A3', 'D4', 'F#4']]):
        for e, acc in ((0, 1.0), (2, 0.6), (3, 0.85), (5, 0.6)):
            s.chord('gtr', s.B(bar, e * .5), 0.45, ch, 74 * acc, spread=0.02)
        s.note('cb', s.B(bar), 1.4, p(ch[0]) - 12, 72)
        for e in range(6):
            s.note('kit', s.B(bar, e * .5), 0.2, 54, 50 + (12 if e in (0, 3) else -6), human=False)
    # release: B7 -> E major, flute resolved tail, chimes, harp, warm strings decaying
    s.chord('gtr', s.B(2), 0.6, ['B2', 'F#3', 'A3', 'D#4'], 70, spread=0.03)
    s.note('cb', s.B(2), 2.8, p('B1'), 70)
    s.chord('vln', s.B(2), 3.0, ['A3', 'D#4', 'F#4'], 56)
    s.motif('fl', 2, motif_tail('E5', 'major', rhythm=(1.5, 1.5, 6), resolved=True), 84, form='RESOLVED tail (flute, E major)')
    s.chord('vln', s.B(3), 6.0, ['E3', 'B3', 'E4', 'G#4'], 62)
    s.chord('gtr', s.B(3), 3.0, ['E2', 'B2', 'E3', 'G#3', 'B3', 'E4'], 66, spread=0.05)
    s.note('cb', s.B(3), 5.0, p('E1') + 12, 66)
    for i, n in enumerate(['E4', 'G#4', 'B4', 'E5', 'G#5', 'B5']):
        s.note('harp', s.B(3) + i * 0.375, 3.0, p(n), 64)
        s.note('celesta', s.B(3) + i * 0.375, 2.0, p(n) + 12, 50)
    s.note('bells', s.B(3), 5.0, p('E5'), 66)
    s.note('bells', s.B(3, 1.5), 5.0, p('B4'), 56)
    s.note('kit', s.B(3), 2.0, TRIANGLE, 54, human=False)
    s.ramp('vln', 3, 2, 100, 60)
    s.max_seconds = 8.0
    return s


# ---------------------------------------------------------------- STG-ZONE-BEEF
def zone_beef():
    """The Gainlands theme's opening (the Crossroads motif as its fanfare) on trumpets over a march; this time the motif RESOLVES - warm
    horns sing Bb F Eb D C Bb, the bass walks freely, and a healthy snare/timpani flourish leads to a held Bb major chord."""
    s = sting('STG-ZONE-BEEF', 126, 4, 'Bb major', 709, cap=8.0)
    s.seat('tpt', 'hn', 'tbn', 'tuba', 'vln', 'pad', 'cb', 'timp', 'perc', 'xylo')
    s.mel('tpt', 0, m('Bb4:1 F5:.5 Eb5:.5 D5:1.5 C5:.5 | F5:2 D5:1 Bb4:1'), 94)
    s.line('vln', 0, m('Bb4:1 F5:.5 Eb5:.5 D5:1.5 C5:.5 | F5:2 D5:1 Bb4:1'), 82, transpose=12)
    s.drum(0, [(0, 'snare', 10), (1, 'snare', -6), (1.5, 'snare', -12), (2, 'snare', 4), (3, 'snare', -6), (3.5, 'snare', -10)], 70, bars=2)
    for bar, (sym, bass) in enumerate([(['D4', 'F4', 'Bb4'], 'Bb1'), (['F4', 'A4', 'C5'], 'F2')]):
        for k in range(4):
            s.note('tuba', bar * 4 + k, 0.7, p(bass) + (7 if k % 2 else 0), 84 + (6 if k == 0 else 0), human=False)
            if k % 2:
                chord(s, 'hn', bar * 4 + k, 0.5, sym, 66)
    s.timp_hit(0.0, 'Bb2', 96)
    s.hit('crash', 0.0, 80, dur=2)
    # the motif resolves in warm horns, the bass walks up, the strings pad
    res = motif('Bb4', 'major', rhythm=(1, .5, .5, 1.5, .5, 2), resolved=True)
    s.motif('hn', 2, res, 96, form='RESOLVED, stated (warm horns)', transpose=-12)
    s.line('tpt', 2, res, 80)
    s.line('cb', 2, m('Bb1:1 D2:1 Eb2:1 E2:1 | F2:1 A1:1 Bb1:2'), 82)
    s.line('tuba', 2, m('Bb1:1 D2:1 Eb2:1 E2:1 | F2:1 A1:1 Bb1:2'), 80)
    for beat, sym in ((8, ['D4', 'F4', 'Bb4']), (10, ['Eb4', 'G4', 'Bb4']), (12, ['C4', 'Eb4', 'A4'])):
        chord(s, 'pad', beat, 2.0, sym, 70)
        chord(s, 'tbn', beat, 1.8, [p(n) - 12 for n in sym], 70)
    s.snare_roll(13.0, 1.0, 50, 100)
    s.timp_roll(13.0, 1.0, 'F2', 60, 104)
    land = 14.0
    chord(s, 'hn', land, 2.6, ['Bb3', 'D4', 'F4'], 92)
    chord(s, 'tbn', land, 2.4, ['F3', 'Bb3', 'D4'], 88)
    chord(s, 'pad', land, 3.0, ['F3', 'Bb3', 'D4', 'F4', 'Bb4'], 84)
    s.note('tpt', land, 2.4, p('D5'), 90, human=False)
    s.note('vln', land, 3.0, p('F6'), 86, human=False)
    s.note('tuba', land, 2.6, p('Bb1'), 96, human=False)
    s.note('cb', land, 3.0, p('Bb1'), 90, human=False)
    s.timp_hit(land, 'Bb2', 110)
    s.hit('crash', land, 96, dur=2)
    s.hit('bd', land, 96)
    s.note('xylo', land, 1.0, p('Bb5'), 70, human=False)
    return s


# ---------------------------------------------------------------- pack reveals (grandeur rises common -> rare -> legend)
def pack_common():
    """1.3 s: a small celesta/harp sparkle (E G C) and a clean C major chord."""
    s = sting('STG-PACK-COMMON', 140, 1, 'C major', 710, meter=(2, 4), cap=1.9)
    s.seat('cel', 'harp', 'pizz')
    for i, n in enumerate(['E5', 'G5', 'C6']):
        s.note('cel', i * 0.25, 1.4, p(n), 76, human=False)
        s.note('harp', i * 0.25, 1.4, p(n) - 12, 72, human=False)
    chord(s, 'harp', 0.75, 1.5, ['C4', 'E4', 'G4', 'C5'], 64)
    s.note('pizz', 0.0, 0.4, p('C3'), 70, human=False)
    return s


def pack_rare():
    """2.8 s: a richer rising harp figure (D to D two octaves up), strings Dsus4 -> D, a crystal-synth shimmer on top."""
    s = sting('STG-PACK-RARE', 120, 1, 'D major', 711, cap=3.6)
    s.seat('harp', 'pad', 'vc', 'fl', 'cel')
    s.channel('shim', 'crystal', pan=64, reverb=110, vol=54)
    for i, n in enumerate(['D3', 'A3', 'D4', 'E4', 'F#4', 'A4', 'D5', 'E5', 'F#5', 'A5']):
        s.note('harp', i * 0.15, 1.6, p(n), 70 + i * 2, human=False)
    chord(s, 'pad', 0.0, 1.5, ['D4', 'G4', 'A4'], 62)
    chord(s, 'pad', 1.5, 2.5, ['D4', 'F#4', 'A4', 'D5'], 70)
    s.note('vc', 0.0, 4.0, p('D3'), 66, human=False)
    s.line('fl', 0, m('G5:1.5 F#5:2.5'), 70, beat=0.0)
    s.note('cel', 1.5, 2.0, p('A6'), 56, human=False)
    s.note('shim', 1.5, 2.5, p('D6'), 64, human=False)
    s.note('shim', 1.5, 2.5, p('A6'), 56, human=False)
    s.swell('pad', 0, 1, 70, 104)
    return s


def pack_legend():
    """5 s: a distinctive rising figure in the horns (Bb Eb F Bb, then up to G) over a soft timpani roll opens into spacious strings and
    woodwinds on Eb add9, flutes shimmering, a tasteful synth glint and a cymbal."""
    s = sting('STG-PACK-LEGEND', 96, 2, 'Eb major', 712, cap=6.0)
    s.seat('hn', 'tpt', 'vln', 'pad', 'vc', 'cb', 'fl', 'ob', 'cl', 'harp', 'timp', 'perc', 'choir')
    s.channel('glint', 'star_theme', pan=64, reverb=110, vol=50)
    s.note('harp', 0.0, 2.0, p('Eb2'), 86, human=False)
    s.timp_roll(0.0, 2.0, 'Bb1', 50, 96)
    s.mel('hn', 0, m('Bb3:.5 Eb4:.5 F4:.5 Bb4:1.5 G4:1'), 96, legato=0.97)
    s.line('tpt', 0, m('r:2 Bb4:1 G5:5'), 84)
    s.line('vln', 0, m('Bb3:.5 Eb4:.5 F4:.5 Bb4:1.5 G5:5'), 84)
    chord(s, 'pad', 0.0, 2.0, ['Eb3', 'Bb3', 'Eb4'], 60)
    s.note('cb', 0.0, 8.0, p('Eb2'), 76, human=False)
    s.note('vc', 0.0, 8.0, p('Bb2'), 70, human=False)
    land = 3.0
    chord(s, 'pad', land, 5.0, ['Eb3', 'Bb3', 'F4', 'G4', 'Bb4', 'Eb5'], 82)
    chord(s, 'choir', land, 4.6, ['G4', 'Bb4', 'Eb5'], 66)
    chord(s, 'hn', land, 4.0, ['G3', 'Bb3', 'Eb4'], 82)
    for i in range(12):
        s.note('fl', land + i * 0.25, 0.25, p('Bb5') if i % 2 == 0 else p('C6'), 58, human=False)
    s.line('ob', 1, m('Eb5:1 F5:1 G5:2'), 70, beat=0.0)
    s.line('cl', 1, m('Bb4:4'), 62, beat=0.0)
    s.harp(1, 'Ebadd9', 72, beats=2.0, beat=0.0, octave=1)
    s.note('glint', land, 3.0, p('Eb6'), 62, human=False)
    s.note('glint', land + 0.5, 3.0, p('Bb6'), 54, human=False)
    s.timp_hit(land, 'Eb2', 100)
    s.hit('crash', land, 80, dur=3)
    s.swell('pad', 0, 2, 76, 112, 'arch')
    return s


# ---------------------------------------------------------------- crafting
def craft():
    """Two gestures - a low pizzicato figure (G B D) and a high flute answer (D G B) - then both join on a warm G major chord."""
    s = sting('STG-CRAFT', 120, 1, 'G major', 713, cap=3.8)
    s.seat('pizz', 'fl', 'pad', 'harp', 'vc')
    for i, n in enumerate(['G2', 'B2', 'D3', 'G3']):
        s.note('pizz', i * 0.25, 0.4, p(n), 80, human=False)
    s.mel('fl', 0, m('r:1 D5:.25 G5:.25 B5:.5'), 80)
    land = 2.0
    chord(s, 'pad', land, 2.2, ['G3', 'D4', 'G4', 'B4'], 70)
    chord(s, 'pizz', land, 0.5, ['G2', 'D3', 'B3'], 78)
    s.note('fl', land, 2.0, p('D6'), 70, human=False)
    s.note('vc', land, 2.2, p('G2'), 68, human=False)
    s.harp(0, 'G', 64, beats=1.0, beat=land)
    return s


def craft_post():
    """Three complementary phrases - pizzicato, flute, horn - enter one after another and resolve together on A major (with the harp)."""
    s = sting('STG-CRAFT-POST', 120, 2, 'A major', 714, cap=4.8)
    s.seat('pizz', 'fl', 'hn', 'pad', 'harp', 'vc')
    for i, n in enumerate(['A2', 'C#3', 'E3', 'A3']):
        s.note('pizz', i * 0.25, 0.4, p(n), 80, human=False)
    s.mel('fl', 0, m('r:.75 E5:.25 A5:.25 C#6:.75'), 80)
    s.line('hn', 0, m('r:1.5 E4:.5 F#4:.5 G#4:.5'), 78)
    land = 3.0
    chord(s, 'pad', land, 2.4, ['A3', 'E4', 'A4', 'C#5'], 72)
    chord(s, 'hn', land, 2.0, ['C#4', 'E4', 'A4'], 76)
    chord(s, 'pizz', land, 0.5, ['A2', 'E3', 'C#4'], 80)
    s.note('fl', land, 2.0, p('E6'), 72, human=False)
    s.note('vc', land, 2.4, p('A2'), 70, human=False)
    s.harp(0, 'A', 66, beats=1.0, beat=land)
    return s


# ---------------------------------------------------------------- small cues
def secret():
    """An upward clarinet/flute question (a Lydian lift: C D E F#) answered by a soft celesta/harp sparkle on D major."""
    s = sting('STG-SECRET', 112, 1, 'C Lydian -> D major', 715, cap=3.0)
    s.seat('cl', 'fl', 'cel', 'harp', 'pad')
    s.note('harp', 0.0, 1.0, p('C3'), 74, human=False)
    s.mel('cl', 0, m('C4:.25 D4:.25 E4:.25 F#4:.25 A4:1'), 82)
    s.line('fl', 0, m('r:1 F#5:.5 A5:.5'), 70)
    chord(s, 'pad', 0.0, 2.0, ['C4', 'E4', 'G4'], 50)
    land = 2.0
    for i, n in enumerate(['D5', 'F#5', 'A5', 'D6']):
        s.note('cel', land + i * 0.12, 1.5, p(n), 66, human=False)
        s.note('harp', land + i * 0.12, 1.5, p(n) - 12, 62, human=False)
    chord(s, 'pad', land, 1.8, ['D4', 'F#4', 'A4'], 54)
    return s


def purchase():
    """0.8 s: a tiny plucked two-note resolution (G4 -> C5, harp and pizzicato), soft enough to hear a hundred times."""
    s = sting('STG-PURCHASE', 150, 1, 'C major', 716, meter=(2, 4), cap=1.0)
    s.seat('harp', 'pizz')
    s.note('harp', 0.0, 0.6, p('G4'), 74, human=False)
    s.note('pizz', 0.0, 0.3, p('G4'), 64, human=False)
    s.note('harp', 0.5, 1.0, p('C5'), 78, human=False)
    s.note('harp', 0.5, 1.0, p('E4'), 56, human=False)
    s.note('pizz', 0.5, 0.3, p('C5'), 66, human=False)
    return s


def arena():
    """Grand Bellows presents: an over-the-top horn-and-trumpet flourish in D (triplet pickups, a leap to the octave) over a snare roll
    and timpani, landing on a D major chord with a cymbal - leading into the arena loop."""
    s = sting('STG-ARENA', 126, 2, 'D major', 717, cap=5.0)
    s.seat('hn', 'tpt', 'tbn', 'tuba', 'pad', 'cb', 'timp', 'perc')
    s.hit('bd', 0.0, 100)
    s.timp_hit(0.0, 'D2', 104)
    s.mel('tpt', 0, [('A4', 1 / 3), ('A4', 1 / 3), ('A4', 1 / 3), ('D5', 1), ('F#5', .5), ('A5', .5),
                     ('D5', 1 / 3), ('F#5', 1 / 3), ('A5', 1 / 3), ('D6', 1.5)], 100, legato=0.85)
    s.line('hn', 0, [('A3', 1 / 3), ('A3', 1 / 3), ('A3', 1 / 3), ('D4', 1), ('F#4', .5), ('A4', .5),
                     ('D4', 1 / 3), ('F#4', 1 / 3), ('A4', 1 / 3), ('D5', 1.5)], 92, legato=0.85)
    chord(s, 'tbn', 0.0, 1.0, ['D3', 'A3', 'D4'], 80)
    s.note('tuba', 0.0, 1.0, p('D2'), 88, human=False)
    s.snare_roll(1.0, 2.0, 50, 104)
    s.timp_roll(2.0, 1.0, 'A1', 70, 108)
    land = 4.0
    chord(s, 'tpt', land, 1.6, ['F#4', 'A4', 'D5'], 100)
    chord(s, 'hn', land, 2.0, ['D4', 'F#4', 'A4'], 94)
    chord(s, 'tbn', land, 2.0, ['D3', 'A3', 'D4'], 90)
    chord(s, 'pad', land, 2.4, ['D4', 'F#4', 'A4', 'D5'], 80)
    s.note('tuba', land, 2.0, p('D2'), 100, human=False)
    s.note('cb', land, 2.4, p('D2'), 92, human=False)
    s.timp_hit(land, 'D2', 112)
    s.hit('crash', land, 104, dur=2)
    s.hit('bd', land, 104)
    return s


def shiro():
    """Smoke bomb! A smug rising pizzicato flourish in C (C D E G A C) steps abruptly sideways a semitone into a cheeky clarinet/bassoon
    staccato cadence in Db, one woodblock pop."""
    s = sting('STG-SHIRO', 132, 1, 'C major -> Db major', 718, cap=3.5)
    s.seat('pizz', 'cl', 'bsn', 'perc', 'fl')
    for i, n in enumerate(['C4', 'D4', 'E4', 'G4', 'A4', 'C5']):
        s.note('pizz', i * 0.25, 0.3, p(n), 76 + i * 3, human=False)
    s.hit('rim', 1.5, 80)
    s.mel('cl', 0, m('r:1.75 Ab4:.25 F4:.25 Db5:.25 C5:.25 Ab4:.25 Db5:.5'), 86, legato=0.5)
    s.line('bsn', 0, m('r:1.75 Db3:.25 r:.25 Ab2:.25 r:.25 Eb3:.25 Db3:.5'), 82, legato=0.5)
    s.line('fl', 0, m('r:3.5 Db6:.5'), 70, legato=0.4)
    return s


def mini_success():
    """1.2 s: two light notes resolving upward (G4 -> C5) on piano and harp, nothing bigger."""
    s = sting('STG-MINI-SUCCESS', 132, 1, 'C major', 719, meter=(2, 4), cap=1.8)
    s.seat('piano', 'harp')
    s.note('piano', 0.0, 0.5, p('G4'), 74, human=False)
    s.note('harp', 0.0, 0.5, p('G4'), 66, human=False)
    s.note('piano', 0.5, 1.5, p('C5'), 80, human=False)
    s.note('piano', 0.5, 1.5, p('E4'), 58, human=False)
    s.note('harp', 0.5, 1.5, p('C5'), 70, human=False)
    return s


def mini_fail():
    """1.5 s: a small descending clarinet phrase (E D B), soft harp under it, ending on the fifth - a kind question, try again."""
    s = sting('STG-MINI-FAIL', 112, 1, 'E minor', 720, meter=(2, 4), cap=1.9)
    s.seat('cl', 'harp')
    s.note('harp', 0.0, 1.5, p('E3'), 64, human=False)
    s.mel('cl', 0, m('E5:.5 D5:.5 B4:1.5'), 76, legato=0.95)
    s.note('harp', 1.0, 1.5, p('G3'), 54, human=False)
    s.note('harp', 1.0, 1.5, p('B3'), 52, human=False)
    return s


def rift():
    """The seam closes: a glass-synth cluster wobbling out of tune (pitch bends) settles into a warm D major string/piano chord."""
    s = sting('STG-RIFT', 90, 1, 'D major', 721, cap=5.0)
    s.seat('pad', 'piano', 'vc', 'cb', 'harp')
    s.channel('glass', 'bowed_glass', pan=64, reverb=110, vol=70)
    s.channel('glass2', 'crystal', pan=50, reverb=110, vol=56)
    s.note('glass2', 0.0, 2.0, p('E5'), 80, human=False)
    chord(s, 'glass', 0.0, 4.0, ['D4', 'E4', 'G#4', 'A4'], 74)
    for k, c in enumerate([-35, 30, -24, 18, -10, 5, 0]):
        s.detune('glass', c, 0, beat=k * 0.5)
        s.detune('glass2', -c, 0, beat=k * 0.5 + 0.25)
    s.note('piano', 0.0, 0.6, p('G#5'), 60, human=False)
    land = 3.0
    chord(s, 'pad', land, 3.5, ['D3', 'A3', 'D4', 'F#4', 'A4'], 72)
    chord(s, 'piano', land, 3.0, ['D3', 'A3', 'D4', 'F#4'], 70)
    s.note('cb', land, 3.5, p('D2'), 70, human=False)
    s.note('vc', land, 3.5, p('A2'), 66, human=False)
    s.harp(0, 'D', 60, beats=1.5, beat=land)
    s.expr('glass', 0, 110)
    s.swell('glass', 0, 1.25, 110, 20)
    return s


BUILDERS = {
    'STG-VICTORY': victory, 'STG-DEFEAT': defeat, 'STG-LEVEL': level, 'STG-QUEST': quest, 'STG-DUNGEON': dungeon,
    'STG-ZONE-NECRO': zone_necro, 'STG-ZONE-GOUR': zone_gour, 'STG-ZONE-REF': zone_ref, 'STG-ZONE-BEEF': zone_beef,
    'STG-PACK-COMMON': pack_common, 'STG-PACK-RARE': pack_rare, 'STG-PACK-LEGEND': pack_legend,
    'STG-CRAFT': craft, 'STG-CRAFT-POST': craft_post, 'STG-SECRET': secret, 'STG-PURCHASE': purchase, 'STG-ARENA': arena,
    'STG-SHIRO': shiro, 'STG-MINI-SUCCESS': mini_success, 'STG-MINI-FAIL': mini_fail, 'STG-RIFT': rift,
}
