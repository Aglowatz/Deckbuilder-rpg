"""MUS-PRIMM-03 - Unraveling (final boss phase 3). Loop, 68 bars 4/4, 146 BPM, D major, ~112 s.
Control fractures; difference returns. It opens on Primm's grid (quantised unison on his motif in D), then the grid cracks: the motif is
displaced off the beat, wrong notes and clusters bite, and the Crossroads motif breaks through in the horn. From bar 16 the HUMAN FEEL
RETURNS (timing and velocity humanised again) and the four zone themes push through one after another over the Crossroads motif in the bass -
Gainlands trumpets, D.N.A. low brass and cello, Buffet clarinet, Dump fiddle (each re-spelled into D major). The climax states the Crossroads
motif broad in horns and strings with all four zone heads woven around it and the choir; a driving battle section trades fragments; the
outro is the grid again so the loop can reassert it. The motif stays open (it loops; it resolves only in the ending cues).
"""
from lib import Score, p, voice, motif, motif_head, motif_tail, augment, PRIMM_HEAD, PRIMM_ANSWER, transpose
from lib.capital import QUANTISED, rudiment
from lib.zones import DNA_THEME, BUFFET_THEME_A, DUMP_JIG_HEAD, to_mode
from scores._fork_b import stack, bed, GAIN_THEME, MAJ_FROM_CMIN

PRIMM_D = transpose(PRIMM_HEAD + PRIMM_ANSWER, 2)
GAIN_D = transpose(GAIN_THEME[:9], 4)                                        # 2 bars
DNA_D = transpose(to_mode(DNA_THEME[:10], MAJ_FROM_CMIN), 2 - 12)           # 12 beats, cello/low brass range
BUF_D = transpose(BUFFET_THEME_A[:11], -3)                                   # 2 bars
DUMP_D = to_mode(transpose(DUMP_JIG_HEAD, -2), {5: 1, 0: 1})                 # 6 beats of reel 8ths
TUTTI = [('vln', 12, 0), ('fl', 12, -10), ('cl', 0, -8), ('tpt', 0, -6), ('hn', -12, -4), ('vla', 0, -10)]
BH = ['D', 'Bm', 'G', 'A', 'D', 'F#m', 'G', 'A', 'Bm', 'G', 'D/F#', 'A', 'G', 'Em', 'A', 'A']


def build():
    s = Score('MUS-PRIMM-03', bpm=146, bars=68, key='D major', seed=1630, human=QUANTISED)
    s.seat('vln', 'vla', 'pad', 'vc', 'cb', 'fl', 'cl', 'tpt', 'hn', 'tbn', 'timp', 'choir', 'perc')
    s.channel('fid', 'violin', pan=30, reverb=85, vol=90)
    for bar, nm in ((0, 'intro grid'), (4, 'A fracture'), (16, 'B voices return'), (32, 'C climax'), (48, 'D drive'),
                    (64, 'outro grid')):
        s.section(bar, nm)
    s.notes.append('Quantised for bars 0-15 and the outro; human feel (jitter .018 / vel 5) from bar 16. Motif open throughout.')

    def ost(bar, sym, vel):
        tn = voice(sym, 'D4', 3)
        cell = [tn[0], tn[2], tn[1], tn[2], tn[0] + 12, tn[2], tn[1], tn[2]]
        for k, n in enumerate(cell):
            s.note('vla', bar * 4 + k * .5, .4, n, vel + (10 if k % 4 == 0 else 0))

    def grid(bar0):
        for i, sym in enumerate(['D', 'D', 'G', 'A']):
            bed(s, bar0 + i, sym, 68, bass='pulse')
            rudiment(s, 'perc', bar0 + i, 'roll' if i == 3 else 'paradiddle', 62)
            s.brass('tbn', bar0 + i, sym, 56, low='D3')
            s.pad('choir', bar0 + i, sym, 48, low='D4')
            s.note('timp', (bar0 + i) * 4, .9, p(s.voicing(sym)[0]) + 12, 82)
        stack(s, TUTTI, bar0, PRIMM_D, 78)

    grid(0)

    # A 4-15: the grid cracks - displaced, wrong notes, clusters; the Crossroads motif breaks through
    for i in range(12):
        bar = 4 + i
        sym = ['D', 'Bb', 'G', 'A', 'D', 'Eb', 'Gm', 'A', 'Bm', 'Bb', 'G', 'A'][i]
        bed(s, bar, sym, 66, bass='pulse')
        ost(bar, sym, 58)
        rudiment(s, 'perc', bar, 'flam' if i % 2 else 'drag', 60)
        if i % 3 == 2:
            for t in (p('D5'), p('Eb5'), p('E5'), p('F5')):       # a cluster stab, off the beat
                s.note('tpt' if t < p('E5') else 'hn', bar * 4 + 3.5, .4, t - 12, 80)
    frac = [(n if i % 4 != 3 else p(n) + 1, d) for i, (n, d) in enumerate(PRIMM_D[:8])]
    stack(s, [('vln', 12, 0), ('cl', 0, -8)], 4, frac, 86, beat=.5)
    s.motif('hn', 6, motif('D4', 'minor'), 90, form='stated (horn) breaking through')
    stack(s, [('vln', 12, 0), ('fl', 12, -10)], 8, [(p(n) - 1, d) for n, d in PRIMM_D[8:]], 84, beat=1.5)
    s.motif('tpt', 10, motif('D4', 'minor'), 90, form='stated (trumpet), louder')
    s.line('vln', 10, motif('D5', 'minor'), 70)
    s.motif('hn', 13, motif_head('D4', 'major'), 92, form='head (horns), the grid gives way')
    s.timp_roll(15 * 4, 4, 'A2', 50, 110)

    # B 16-31: human feel returns; the four zone heads over the Crossroads motif in the bass
    s.jitter, s.vel_spread = 0.018, 5
    for i in range(16):
        bar = 16 + i
        bed(s, bar, BH[i], 66, bass='half')
        ost(bar, BH[i], 60)
        s.drum(bar, [(0, 'bd', 4), (1, 'snare', -10), (2.5, 'bd', -6), (3, 'snare', -4)], 74)
        if i % 4 == 0:
            s.note('timp', bar * 4, .9, p(s.voicing(BH[i])[0]) + 12, 86)
    s.motif('tbn', 16, augment(motif('D3', 'major'), 2), 72, form='augmented (trombones, bass)', lead=False)
    stack(s, [('tpt', 0, 0), ('hn', -12, -8)], 16, GAIN_D, 92)
    stack(s, [('vc', 0, 0), ('tbn', 0, -12)], 20, DNA_D, 90)
    stack(s, [('cl', 0, 0), ('fl', 12, -14)], 24, BUF_D, 90)
    s.motif('hn', 26, motif_tail('D4', 'major'), 72, form='tail (horn) answering', lead=False)
    s.line('fid', 28, DUMP_D + DUMP_D[:4], 92, role='mel')
    s.line('fid', 30, DUMP_D[4:], 88, role='mel', beat=0)

    # C 32-47: the climax - the motif broad in horns + strings, the zone heads woven around it, choir
    CH = ['D', 'G', 'Bm', 'A', 'G', 'D/F#', 'Em', 'A'] * 2
    for i in range(16):
        bar = 32 + i
        bed(s, bar, CH[i], 74, bass='half')
        s.pad('choir', bar, CH[i], 66, low='D4')
        ost(bar, CH[i], 64)
        s.drum(bar, [(0, 'bd', 8), (1, 'snare', -6), (2, 'bd', 0), (3, 'snare', 0)], 78)
        if i % 2 == 0:
            s.note('timp', bar * 4, .9, p(s.voicing(CH[i])[0]) + 12, 90)
    big = augment(motif('D4', 'major'), 2)
    stack(s, [('hn', 0, 0), ('vln', 12, -6), ('tbn', -12, -14)], 32, big, 98, form='augmented, stated (horns + strings): the climax')
    s.line('tpt', 36, GAIN_D, 80)
    s.line('fl', 38, transpose(BUF_D, 12), 70)
    stack(s, [('vln', 12, 0), ('hn', 0, -8), ('tpt', 0, -10)], 40, motif('D4', 'major'), 100, form='stated (tutti)')
    s.line('vc', 40, DNA_D, 78)
    s.line('fid', 42, DUMP_D, 80)
    stack(s, [('vln', 12, 0), ('fl', 12, -8), ('hn', 0, -6)], 44, motif('D4', 'major', rhythm=[1, .5, .5, 1, 1, 4]), 100,
          form='stated, compressed (tutti), open on A')
    s.hit('crash', 32 * 4, 76, dur=4)
    s.hit('crash', 40 * 4, 80, dur=4)

    # D 48-63: drive - fragments traded, heads quick
    DH = ['Bm', 'G', 'D', 'A'] * 4
    for i in range(16):
        bar = 48 + i
        bed(s, bar, DH[i], 76, bass='pulse')
        s.brass('hn', bar, DH[i], 60, low='D3')
        ost(bar, DH[i], 66)
        s.drum(bar, [(0, 'bd', 6), (.5, 'snare2', -20), (1, 'snare', -2), (2, 'bd', 0), (2.5, 'bd', -10), (3, 'snare', 2)], 76)
    for k, (ch, bar) in enumerate((('tpt', 48), ('hn', 50), ('cl', 52), ('fid', 54), ('tpt', 56), ('vln', 58))):
        s.motif(ch, bar, motif_head('B4' if ch in ('cl', 'fid', 'vln', 'tpt') else 'B3', 'minor'), 88,
                form=f'head traded ({ch})', transpose=12 if ch == 'vln' else 0)
    s.line('tpt', 49, transpose(GAIN_D[:5], 0), 80)
    s.line('cl', 53, BUF_D[:6], 78)
    s.line('vc', 57, DNA_D[:5], 76)
    s.line('fid', 60, DUMP_D + DUMP_D[:4], 86, role='mel')
    s.timp_roll(63 * 4, 4, 'A2', 50, 106)

    # outro 64-67: the grid again (loop)
    s.jitter, s.vel_spread = QUANTISED
    grid(64)
    return s
