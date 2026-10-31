"""MUS-CREDITS - Many ways forward (ending credits). One-shot, 126 bars 4/4, 96 BPM at the start (tempo moves per section), D major
overall, ~5:00 with the ring-out.
A suite that develops rather than strings quotations together:
  0-21    the Crosspath theme (horn, then strings with the horn counter), D Dorian, 96
  22-39   the Gainlands march (trumpets + horns, snare), Bb major, 108
  40-53   the D.N.A. waltz (3-beat bars laid across the 4/4 grid), C minor turning to C major - the department healed, 112
  54-71   the Buffet showtune (clarinet, trumpet, glockenspiel, oom-pah), F major, 128
  72-79   the Dump jig (12/8 triplets, solo violin), E Dorian turning to E major, dotted-q 116
  80-97   an adventurous middle: the Crossroads motif developed (fragments, inverted, augmented) over a driving D minor ostinato, 132
  98-107  the whole lullaby (flute and harp, then strings and horn), D, 72
  108-119 the grand finale: the Crossroads motif RESOLVED in D major, tutti and choir, the zone heads woven around it, 88
  120-125 a tender close: the resolved motif once more on the flute, a held D major chord, 66
"""
from lib import Score, p, voice, motif, motif_head, motif_tail, augment, transpose
from lib.zones import DNA_THEME, DNA_PROG, BUFFET_THEME, BUFFET_PROG, BUFFET_CHORDS, DUMP_THEME, DUMP_PROG, DUMP_JIG_HEAD, to_mode
from scores._fork_b import (stack, bed, held, scale, CROSSPATH_A, CROSSPATH_PROG, GAIN_THEME, GAIN_H, LULLABY, lullaby_bed,
                            MAJ_FROM_CMIN, MAJ_FROM_EDOR)


def build():
    s = Score('MUS-CREDITS', bpm=96, bars=126, key='D major', seed=1710, kind='oneshot')
    s.lufs = -20.0
    s.seat('vln', 'pad', 'vc', 'cb', 'harp', 'hn', 'tpt', 'fl', 'cl', 'timp', 'choir', 'glock', 'pizz', 'perc')
    s.channel('fid', 'violin', pan=28, reverb=88, vol=88)
    s.channel('organ', 'organ', pan=58, reverb=105, vol=58)
    for bar, bpm in ((22, 108), (40, 112), (54, 128), (72, 116), (80, 132), (96, 96), (98, 72), (108, 88), (120, 66)):
        s.tempo(bar, bpm)
    for bar, nm in ((0, 'intro'), (4, 'Crosspath'), (22, 'Gainlands'), (40, 'D.N.A.'), (54, 'Buffet'), (72, 'Dump'),
                    (80, 'adventure'), (98, 'lullaby'), (108, 'finale'), (120, 'tender close')):
        s.section(bar, nm)
    s.notes.append('Whole lullaby (after the reveal); Crossroads RESOLVED in the finale; D.N.A. and Dump themes turn to major (healed).')

    # 0-3 intro: starts instantly on harp + strings, the motif's head in the flute
    for t in voice('Dm', 'D3', 4):
        s.note('harp', 0, 4, t, 64, human=False)
    for i, sym in enumerate(['Dm', 'Bb', 'Gm', 'A7sus4']):
        bed(s, i, sym, 54, harp=48 if i else None)
    s.motif('fl', 0, motif_head('D5', 'minor') + [('r', 2)] + motif_tail('D5', 'minor'), 70, form='stated in two halves (flute)')

    # 4-21 Crosspath
    for i in range(16):
        bed(s, 4 + i, CROSSPATH_PROG[i % 8], 56 if i < 8 else 62, bass='whole' if i < 8 else 'half', harp=48)
    s.motif('hn', 4, CROSSPATH_A, 84, form='Crosspath theme (horn), its head is the motif')
    stack(s, [('vln', 12, 0), ('vln', 0, -16)], 12, CROSSPATH_A, 88)
    s.line('hn', 12, [('F4', 4), ('D4', 2), ('B3', 2), ('C4', 2), ('D4', 2), ('E4', 2), ('D4', 2), ('F4', 4), ('F4', 2), ('E4', 2),
                      ('D4', 4), ('C#4', 2), ('E4', 2)], 66)
    bed(s, 20, 'Gm', 60)
    bed(s, 21, 'F7', 62)
    s.timp_roll(21 * 4, 4, 'F2', 30, 90)

    # 22-39 Gainlands (Bb)
    for i in range(16):
        bar = 22 + i
        bed(s, bar, GAIN_H[i], 64, bass='march')
        s.drum(bar, [(0, 'snare', 0), (1, 'snare', -12), (1.5, 'snare', -16), (2, 'snare', -4), (3, 'snare', -12)], 66)
        if i % 4 == 0:
            s.note('timp', bar * 4, .9, p(s.voicing(GAIN_H[i])[0]) + 12, 80)
    stack(s, [('tpt', 0, 0), ('hn', -12, -4)], 22, GAIN_THEME, 90)
    s.line('vln', 30, [('D5', 4), ('C5', 4), ('Bb4', 4), ('A4', 4), ('C5', 4), ('Bb4', 4), ('A4', 4), ('Bb4', 4)], 62)
    bed(s, 38, 'Ab', 60)
    bed(s, 39, 'G7', 62)
    s.motif('hn', 38, motif_head('C4', 'minor', rhythm=(2, 1, 1)) + [('r', 4)], 70, form='head (horn), into the waltz')

    # 40-53 D.N.A. waltz: 16 waltz bars (3 beats) from beat 160 = bars 40-51; then a 2-bar turn
    w0 = 40 * 4
    dna = DNA_THEME[:20] + to_mode(DNA_THEME[20:], MAJ_FROM_CMIN)
    prog = DNA_PROG[:8] + ['F', 'Db', 'C/G', 'G7', 'C', 'Ab', 'G7', 'C']
    for k in range(16):
        b = w0 + 3 * k
        sym = prog[k]
        s.bass_at(b, 1.0, sym, 64)
        for off in (1, 2):
            for t in voice(sym, 'G3', 3):
                s.note('pizz', b + off, .5, t, 50)
        s.pad('organ', 0, sym, 44, beats=3, beat=b, low='G3', n=3)
        s.pad('pad', 0, sym, 46, beats=3, beat=b)
    s.line('cl', 0, transpose(dna[:20], -12), 84, beat=w0, role='mel')
    s.line('vln', 0, dna[20:], 86, beat=w0 + 24, role='mel')
    s.line('vc', 0, [('C4', 6), ('Ab3', 6), ('G3', 6), ('C4', 6)], 52, beat=w0 + 24)
    bed(s, 52, 'Bb', 58)
    bed(s, 53, 'C7', 60)
    s.motif('fl', 52, motif_tail('F5', 'major'), 66, form='tail (flute), into the Buffet', lead=True)

    # 54-71 Buffet (F)
    s.V.update(BUFFET_CHORDS)
    for i in range(16):
        bar = 54 + i
        sym = BUFFET_PROG[i]
        s.pad('pad', bar, sym, 54)
        b = p(s.voicing(sym)[0])
        for k in range(4):
            s.note('cb' if k % 2 == 0 else 'pizz', bar * 4 + k, .5, b if k % 2 == 0 else b + 19, 60)
        s.drum(bar, [(1, 'snare', -26), (3, 'snare', -22)], 64)
    stack(s, [('cl', 0, 0), ('tpt', 0, -12), ('glock', 12, -36)], 54, BUFFET_THEME[:40], 88)
    stack(s, [('vln', 0, 0), ('fl', 12, -16)], 62, BUFFET_THEME[40:], 88)
    s.V.clear()
    bed(s, 70, 'C', 58)
    bed(s, 71, 'B7', 60)
    s.timp_roll(71 * 4 + 2, 2, 'B1', 30, 70)

    # 72-79 Dump jig (12/8 triplets): 16 bars of 6/8 squeezed into 8 bars; the second half in E major
    jig = scale(DUMP_THEME[:48], 2 / 3) + scale(to_mode(DUMP_THEME[48:], MAJ_FROM_EDOR), 2 / 3)
    for i in range(8):
        bar = 72 + i
        sym = DUMP_PROG[2 * i] if i < 4 else {'Em': 'E', 'D': 'D', 'A': 'A', 'G': 'B'}.get(DUMP_PROG[2 * i], 'E')
        s.pad('pad', bar, sym, 62)
        for k in range(4):
            s.note('pizz', bar * 4 + k, .3, p(s.voicing(sym)[0]) + 12, 58)
            s.note('harp', bar * 4 + k + 2 / 3, .5, voice(sym, 'E4', 3)[k % 3], 44)
            s.hit('tamb', bar * 4 + k, 46)
        s.note('cb', bar * 4, 4.02, p(s.voicing(sym)[0]), 54)
    s.line('fid', 72, jig, 92, role='mel')
    s.line('vln', 72, jig, 58, transpose=-12)
    s.line('fl', 76, transpose(jig[48:], 12), 50)

    # 80-97 adventure (D minor): driving ostinato, the motif developed
    AH = ['Dm', 'Bb', 'C', 'A', 'Dm', 'F', 'Gm', 'A'] * 2 + ['Bb', 'A7sus4']
    for i, sym in enumerate(AH):
        bar = 80 + i
        bed(s, bar, sym, 64, bass='pulse')
        tn = voice(sym, 'D4', 3)
        for k in range(8):
            s.note('pizz', bar * 4 + k * .5, .4, [tn[0], tn[2], tn[1], tn[2]][k % 4], 60 + (8 if k % 4 == 0 else 0))
        s.drum(bar, [(0, 'bd', 4), (1, 'snare', -10), (2.5, 'bd', -6), (3, 'snare', -4)], 70)
        if i % 4 == 0:
            s.note('timp', bar * 4, .9, p(s.voicing(sym)[0]) + 12, 84)
    s.motif('hn', 80, motif('D4', 'minor'), 88, form='stated (horns)')
    s.motif('tpt', 82, motif_head('F4', 'major'), 84, form='head (trumpet), answering')
    s.motif('cl', 84, motif('D5', 'minor', inverted=True), 80, form='inverted (clarinet)')
    s.motif('vln', 86, motif_tail('D5', 'minor'), 84, form='tail (strings)')
    stack(s, [('hn', 0, 0), ('vln', 12, -8)], 88, augment(motif('D4', 'minor'), 2), 92, form='augmented (horns + strings)')
    s.line('fid', 90, transpose(DUMP_JIG_HEAD, -2 + 12), 70)
    s.line('tpt', 92, transpose(GAIN_THEME[:9], 4), 74)
    s.timp_roll(97 * 4, 4, 'A2', 40, 96)

    # 98-107 the whole lullaby: flute + harp, then strings + horn
    lullaby_bed(s, 98 * 4, 0, 46, harp=44)
    s.mel('fl', 98, LULLABY, 80, transpose=12)
    lullaby_bed(s, 103 * 4, 0, 56, harp=46)
    stack(s, [('vln', 12, 0), ('hn', 0, -12)], 103, LULLABY, 86)
    s.line('cl', 104, [('F4', 4), ('E4', 4), ('D4', 4), ('C#4', 4)], 52)

    # 108-119 grand finale: the motif RESOLVED in D major, tutti + choir, zone heads around it
    FH = ['D', 'G', 'Bm', 'A', 'G', 'D/F#', 'Em7', 'A', 'D', 'Bm', 'G A', 'D']
    for i, sym in enumerate(FH):
        bar = 108 + i
        bed(s, bar, sym, 70, bass='half', harp=50)
        for off, beats, c in s.parts(sym):
            s.pad('choir', bar, c, 62, beats=beats, beat=off, low='D4')
        if i % 2 == 0:
            s.note('timp', bar * 4, .9, p(s.voicing(sym.split()[0])[0]) + 12, 86)
    stack(s, [('hn', 0, 0), ('vln', 12, -4), ('tpt', 0, -12)], 108, augment(motif('D4', 'major', resolved=True), 2), 98,
          form='RESOLVED, augmented (tutti): the grand finale')
    s.line('cl', 112, transpose(BUFFET_THEME[:11], -3), 64)
    s.line('fid', 113, to_mode(transpose(DUMP_JIG_HEAD, -2 + 12), {5: 1, 0: 1}), 62)
    stack(s, [('vln', 12, 0), ('fl', 12, -8), ('hn', 0, -6)], 116, motif('D4', 'major', resolved=True, rhythm=[1, .5, .5, 1.5, .5, 4]), 100,
          form='RESOLVED (tutti)')
    s.hit('crash', 108 * 4, 70, dur=4)
    s.hit('crash', 118 * 4, 70, dur=4)

    # 120-125 tender close
    for i, sym in enumerate(['G', 'A7sus4', 'D', 'D']):
        s.pad('pad', 120 + i, sym, 46)
        s.harp(120 + i, sym, 42)
        s.note('cb', (120 + i) * 4, 4.02, p(s.voicing(sym)[0]), 44)
    s.motif('fl', 120, motif('D5', 'major', resolved=True, rhythm=[1, .5, .5, 1.5, .5, 4]), 66, form='RESOLVED (flute), tender')
    held(s, 122, 'D', 16, 48, ['pad'], low='D3')
    s.note('cb', 122 * 4, 16, p('D2'), 44)
    s.mel('glock', 123, [('F#6', 2), ('A6', 2), ('D7', 8)], 40)
    return s
