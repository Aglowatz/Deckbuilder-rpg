"""MUS-PRIMM-02 - Reflection (final boss phase 2). Loop, 64 bars 4/4, 136 BPM, F major (moves per zone), quantised, ~113 s.
Borrowed power and imitation: each Path speaks in its own colour and Primm answers with an uncanny copy - his own motif dressed in that
zone's style, doubled by a square-wave synth that exposes the theft, and each copy slightly wrong:
  4-15  D.N.A.: the organ waltz (written as 3-beat bars laid across the 4/4 grid - a hemiola against the barline), the D.N.A. theme in the
        cello, Primm's copy in organ waltz rhythm - in MAJOR over the minor oom-pah (the wrong third).
  16-31 Buffet: the showtune welcome (clarinet + trumpet) and the drop hook; Primm's copy in rigid even quarters where the tune bounces,
        then a machine drop (kick, claps, synth bass, pumped pad).
  32-39 Dump: the jig in the fiddle (12/8 triplets); Primm's copy long-short, but every phrase stops dead on the beat.
  40-55 Gainlands: the march (trumpets + horns, snare); Primm's copy lands on the wrong chord (Gb) and is snapped back to F. The Crossroads
        motif's head in the horn - and Primm copies that too.
  56-59 the four styles stacked and glitching into one unison; 60-63 the intro bed again (loop).
"""
from lib import Score, p, voice, motif, motif_head, PRIMM_HEAD, PRIMM_ANSWER, transpose
from lib.capital import QUANTISED, rudiment
from lib.zones import DNA_THEME, BUFFET_THEME_A, BUFFET_HOOK, DUMP_JIG_1
from scores._fork_b import stack, bed, GAIN_THEME, scale

PRIMM = PRIMM_HEAD + PRIMM_ANSWER


def build():
    s = Score('MUS-PRIMM-02', bpm=136, bars=64, key='F major', seed=1620, human=QUANTISED)
    s.seat('vln', 'pad', 'vc', 'cb', 'cl', 'tpt', 'hn', 'tbn', 'timp', 'pizz', 'xylo', 'perc')
    s.channel('organ', 'organ', pan=58, reverb=105, vol=70)
    s.channel('sq', 'square_lead', pan=80, reverb=70, vol=50)
    s.channel('sbass', 'synth_bass', pan=64, reverb=40, vol=74)
    s.channel('fid', 'violin', pan=30, reverb=85, vol=88)
    for bar, nm in ((0, 'intro mirror'), (4, 'D.N.A. waltz'), (16, 'Buffet showtune'), (24, 'Buffet drop'), (32, 'Dump jig'),
                    (40, 'Gainlands march'), (56, 'glitch stack'), (60, 'outro mirror')):
        s.section(bar, nm)
    s.notes.append('Quantised. Waltz written as 3-beat bars across the 4/4 grid (hemiola); jig as 12/8 triplets. Copies doubled by a square lead.')

    def copy(ch, beat, mel, vel, tr=0):
        """Primm's imitation: the lead plus the square-wave double that exposes it."""
        s.line(ch, 0, mel, vel, transpose=tr, beat=beat, role='mel')
        s.line('sq', 0, mel, vel - 22, transpose=tr + 12, beat=beat)

    def mirror(bar0):
        for i, sym in enumerate(['F', 'F', 'Bb', 'C']):
            bed(s, bar0 + i, sym, 66, bass='pulse')
            s.brass('hn', bar0 + i, sym, 62, low='F3')
            for k in range(4):
                s.note('pizz', (bar0 + i) * 4 + k, .4, voice(sym, 'F3', 3)[k % 3], 58)
            rudiment(s, 'perc', bar0 + i, 'roll' if i == 3 else 'flam', 56)
        s.swell('pad', bar0, 4, 88, 100)
        s.mel('vln', bar0, transpose(PRIMM_HEAD, 5), 84, transpose=12)
        copy('cl', (bar0 + 2) * 4, transpose(PRIMM_HEAD, 5), 80, tr=-12)

    mirror(0)

    # D.N.A. 4-15: 16 waltz bars of 3 beats from beat 16 (F minor)
    w0 = 16
    fm = ['Fm', 'Fm', 'Bbm', 'Bbm', 'C7', 'C7', 'Fm', 'Db'] * 2
    for k in range(16):
        b = w0 + 3 * k
        sym = fm[k]
        root = p(s.voicing(sym)[0])
        s.note('cb', b, 1.0, root, 70)
        s.note('vc', b, 1.0, root + 12, 58) if k >= 4 else None
        for off in (1, 2):
            for t in voice(sym, 'F3', 3):
                s.note('organ', b + off, .8, t, 68)
        s.note('perc', b, .15, 76, 54, human=False)
        s.note('perc', b + 1, .15, 77, 44, human=False)
        s.note('perc', b + 2, .15, 77, 44, human=False)
        s.pad('pad', 0, sym, 62, beats=3, beat=b)
    dna = transpose(DNA_THEME[:10], 5 - 12)                              # first 4 waltz bars, F minor, cello range
    s.line('vc', 0, dna, 84, beat=w0, role='mel')
    waltz = [(p(n) + 5, (2 if i % 2 == 0 else 1)) for i, (n, d) in enumerate(PRIMM)]     # 8 waltz bars (2+1)
    copy('organ', w0 + 12, waltz, 84)
    s.line('vc', 0, transpose(DNA_THEME[10:20], 5 - 12), 80, beat=w0 + 36, role='mel')

    # Buffet 16-31 (F major): welcome call, rigid copy, then the drop
    bh = ['F', 'Dm', 'Gm7', 'C7', 'F', 'Dm', 'Gm7', 'C7']
    for i in range(8):
        bar = 16 + i
        bed(s, bar, bh[i], 60, bass='march')
        for k in range(4):
            s.note('tbn', bar * 4 + k, .4, p(s.voicing(bh[i])[0]) + 12 if k % 2 == 0 else voice(bh[i], 'A3', 1)[0], 62)
        rudiment(s, 'perc', bar, 'march', 52)
    stack(s, [('cl', 0, 0), ('tpt', 0, -10)], 16, BUFFET_THEME_A, 86)
    copy('tpt', 20 * 4, [(p(n) + 5, 1) for n, d in PRIMM], 84)
    s.line('xylo', 20, [(p(n) + 17, 1) for n, d in PRIMM_HEAD], 54)
    dp = ['Dm', 'Bb', 'F', 'C'] * 2
    for i in range(8):
        bar = 24 + i
        sym = dp[i]
        s.pad('pad', bar, sym, 70)
        for k in range(4):
            s.hit('bd', bar * 4 + k, 92)
            s.expr('pad', bar, 40, beat=k)
            s.expr('pad', bar, 100, beat=k + .45)
            s.note('sbass', bar * 4 + k + .5, .4, p(s.voicing(sym)[0]) + 12, 84)
        s.hit('clap', bar * 4 + 1, 70)
        s.hit('clap', bar * 4 + 3, 70)
        s.note('cb', bar * 4, 3.9, p(s.voicing(sym)[0]), 62)
    stack(s, [('tpt', 0, 0), ('sq', 0, -16), ('cl', -12, -10)], 24, BUFFET_HOOK, 88)
    copy('vln', 28 * 4, [(p(n) + 5 + 12, .5) for n, d in PRIMM_HEAD] * 2, 86)

    # Dump 32-39 (F Dorian): jig triplets; the copy is long-short and stops dead
    jig = scale(transpose(DUMP_JIG_1[:24], 1), 2 / 3)          # 2 bars
    jp = ['Fm', 'Eb', 'Fm', 'Bb']
    for i in range(8):
        bar = 32 + i
        sym = jp[i % 4]
        bed(s, bar, sym, 60)
        for k in range(4):
            s.note('pizz', bar * 4 + k, .3, p(s.voicing(sym)[0]) + 12, 64)
            s.note('pizz', bar * 4 + k + 2 / 3, .25, voice(sym, 'C4', 3)[k % 3], 50)
            s.hit('tamb', bar * 4 + k, 50)
    s.line('fid', 32, jig, 88, role='mel')
    jcopy = []
    for n, d in PRIMM:
        jcopy += [(p(n) + 5 + 12, 2 / 3), (p(n) + 5 + 12, 1 / 3)]
    copy('fid', 34 * 4, jcopy, 84)
    s.line('fid', 38, jig, 86, role='mel')

    # Gainlands 40-55 (Bb major): march call, the copy lands wrong; the Crossroads head - copied too
    for i in range(16):
        bar = 40 + i
        sym = ['Bb', 'Bb', 'Cm7', 'F', 'Eb', 'Gm', 'F', 'Bb'][i % 8]
        if i in (7, 15):
            sym = 'Gb'                                           # the copy's wrong landing
        bed(s, bar, sym, 62, bass='march')
        rudiment(s, 'perc', bar, 'march', 64)
        s.brass('tbn', bar, sym, 64, beats=2, low='D3')
        s.brass('tbn', bar, sym, 60, beats=2, beat=2, low='D3')
        if i % 4 == 0:
            s.note('timp', bar * 4, .9, p(s.voicing(sym)[0]) + 12, 84)
    stack(s, [('tpt', 0, 0), ('hn', -12, -6)], 40, GAIN_THEME[:16], 88)
    copy('tpt', 44 * 4, [(p(n) + 10, 1) for n, d in PRIMM], 86, tr=-12)
    s.motif('hn', 48, motif_head('Bb3', 'major'), 84, form='head (horn), then copied')
    copy('vln', 48 * 4 + 2, [(p(n), 1) for n, d in motif_head('Bb4', 'major')] + [('r', 1)], 80)
    stack(s, [('tpt', 0, 0), ('vln', 12, -8), ('hn', -12, -6)], 49, transpose(GAIN_THEME[16:28], 0), 86, beat=2)
    copy('tpt', 52 * 4, [(p(n) + 10, 1) for n, d in PRIMM], 88, tr=-12)

    # 56-59 the styles stacked and glitching into unison
    for i, sym in enumerate(['F', 'Db', 'Gb', 'C7']):
        bed(s, 56 + i, sym, 70, bass='pulse')
        s.pad('organ', 56 + i, sym, 52, low='F3')
        for k in range(8):
            s.note('sq', (56 + i) * 4 + k * .5, .2, voice(sym, 'C5', 3)[k % 3], 58)
        rudiment(s, 'perc', 56 + i, 'roll', 60)
    s.line('fid', 56, jig[:12], 80, role='mel')
    s.line('cl', 57, transpose(BUFFET_THEME_A[:6], 0), 80)
    stack(s, [('vln', 17, 0), ('tpt', 5, -6), ('cl', 5, -8), ('hn', -7, -8)], 58, PRIMM_HEAD, 92)

    mirror(60)
    return s
