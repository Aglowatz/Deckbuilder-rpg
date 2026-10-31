"""MUS-PRIMM-DEFEAT - Finally seeing (Primm defeated). One-shot, 21 bars 4/4, 66 BPM (rubato), F major, ~80 s with the ring-out.
Sincerity, accountability and consequence. The civic motif stripped to piano and cello, played human at last - uneven lengths, breathing,
tempo yielding at the phrase ends: the sincere reformer he once was. Then the borrowed Path voices stand apart, each alone in the space he
took them from (horn: Gainlands, clarinet: Buffet, bassoon: D.N.A., violin: Dump), the piano answering softly. The Crossroads motif in the
cello, open. It ends on a quiet, unresolved human cadence (a held Bb major add9 - the IV, not home). No triumph, no ridicule.
"""
from lib import Score, p, voice, motif, PRIMM_HEAD, PRIMM_ANSWER, transpose
from lib.zones import DNA_THEME, BUFFET_THEME_A, DUMP_JIG_HEAD
from scores._fork_b import GAIN_THEME, held, scale

# The Primm motif in F, human: the same pitches, rubato lengths
RUBATO = [1, 1, 1, 1.5, .5, 1, 1, 2, 1, 1, 1, 1.5, .75, .75, 1, 3]
PRIMM_F = [(p(n) + 5, d) for (n, _), d in zip(PRIMM_HEAD + PRIMM_ANSWER, RUBATO)]      # 19.5 beats
H = ['F', 'Am7', 'Bbmaj7', 'C7sus4', 'Dm7', 'Bbmaj7', 'Gm7', 'Csus4']


def build():
    s = Score('MUS-PRIMM-DEFEAT', bpm=66, bars=21, key='F major', seed=1650, kind='oneshot')
    s.lufs = -20.0
    s.seat('piano', 'vc', 'cb', 'pad', 'hn', 'cl', 'bsn', 'harp', piano={'vol': 88}, vc={'vol': 92}, pad={'vol': 70})
    s.channel('vlnsolo', 'violin', pan=34, reverb=95, vol=80)
    s.V.update({'Bbadd9': ('Bb1', ['Bb2', 'F3', 'C4', 'D4'])})
    for bar, nm in ((0, 'piano + cello: the motif human'), (6, 'the Path voices stand apart'), (14, 'crossroads, open'),
                    (18, 'unresolved cadence')):
        s.section(bar, nm)
    s.notes.append('Rubato by tempo changes at phrase ends; Crossroads motif open; ends on IV (Bbadd9), unresolved by design (row).')
    for bar, bpm in ((3, 62), (4, 66), (5, 58), (6, 64), (13, 58), (14, 62), (17, 54), (18, 50)):
        s.tempo(bar, bpm)

    # 0-5: piano alone, then the cello below; starts instantly on an F chord with the first note
    for t in voice('F', 'F3', 3):
        s.note('piano', 0, 2.0, t, 52, human=False)
    s.note('piano', 0, 4.0, p('F2'), 50, human=False)
    s.mel('piano', 0, PRIMM_F, 70, transpose=0)
    for i, sym in enumerate(['F', 'Am7', 'Bbmaj7', 'C7sus4', 'Dm7']):
        if i:
            for k, t in enumerate(voice(sym, 'F3', 3)):
                s.note('piano', i * 4 + k * .5, 3 - k * .5, t, 44)
            s.note('piano', i * 4, 4.0, p(s.voicing(sym)[0]) + 12, 46)
    s.line('vc', 1, [('A3', 2), ('G3', 2), ('F3', 3), ('E3', 1), ('D3', 2), ('E3', 2), ('F3', 4)], 62)

    # 6-13: the borrowed voices stand apart, each alone over a soft string pad; the piano answers with Primm fragments
    for i, sym in enumerate(H):
        s.pad('pad', 6 + i, sym, 40)
        s.note('cb', (6 + i) * 4, 4.02, p(s.voicing(sym)[0]), 40)
    s.mel('hn', 6, transpose(GAIN_THEME[:5], -5), 64)                 # Gainlands head (F)
    s.line('piano', 7, [(p(n) + 5 + 12, 1) for n, _ in PRIMM_HEAD[:4]], 44)
    s.mel('cl', 8, BUFFET_THEME_A[:6], 62)                            # Buffet welcome (F)
    s.line('piano', 9, [(p(n) + 5 + 12, 1) for n, _ in PRIMM_ANSWER[:4]], 42)
    s.mel('bsn', 10, transpose(DNA_THEME[:6], 5 - 12), 62)            # D.N.A. head (F minor) - one bar of minor
    s.mel('vlnsolo', 12, scale(transpose(DUMP_JIG_HEAD, 1), 1.0), 60)  # the jig, slowed to a walk (F Dorian)
    s.harp(13, 'Csus4', 40)

    # 14-17: the Crossroads motif in the cello, open; the piano's last look at the motif, slower
    for i, sym in enumerate(['Dm7', 'Bbmaj7', 'Gm7', 'C7sus4']):
        s.pad('pad', 14 + i, sym, 44)
        s.note('cb', (14 + i) * 4, 4.02, p(s.voicing(sym)[0]), 44)
        for k, t in enumerate(voice(sym, 'F3', 3)):
            s.note('piano', (14 + i) * 4 + k * .5, 3, t, 40)
    s.motif('vc', 14, motif('D3', 'minor', rhythm=[1.5, .75, .75, 2, 1, 4]), 70, form='stated (cello), open')
    s.line('piano', 16, [('F5', 1.5), ('A5', 1.5), ('C6', 1)], 50)

    # 18-20: the unresolved human cadence, held
    held(s, 18, 'Bbadd9', 12, 46, ['pad'], low='Bb2')
    for k, t in enumerate(voice('Bbadd9', 'Bb2', 4)):
        s.note('piano', 18 * 4 + k * .4, 10, t, 50 - k * 2)
    s.note('cb', 72, 12, p('Bb1'), 44)
    s.mel('vc', 18, [('D4', 3), ('C4', 1), ('D4', 8)], 56)
    s.harp(18, 'Bbadd9', 36)
    return s
