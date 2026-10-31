"""MUS-SHIRO-BOSS - The oldest trick in the book (Shiro Swindle, secret ninja boss). Loop, 72 bars 4/4, 152 BPM, E minor.
A theatrical trickster. Shiro's own idea (SHIRO: a sly, quick figure that darts up to G and back, then sinks) is passed between
pizzicato and piccolo with feints - runs that stop dead and dart the other way - and wooden clappers that accelerate like a stage cue.
The overconfident pose: a grand tutti gesture climbing to a high E... that slips chromatically down, with a sheepish bassoon after it.
The chase section reveals the sincere side: a warm G-major string melody, the Crossroads motif in the horns beside it - he only wants a
worthy rival. Then the figure in the brass with woodwind flourishes, the pose again (bigger, slipping further), and the clapper intro
at the loop point.
"""
from lib import Score, motif, motif_head, motif_tail, augment, m, p, transpose, voice, Scale

SHIRO = m('E5:.5 B4:.25 E5:.25 F#5:.5 G5:1 F#5:.25 E5:.25 D#5:.5 E5:.5 | B4:.5 r:.5 C5:.5 B4:.5 A4:.25 G4:.25 F#4:.5 B3:1')
POSE = m('E5:.5 G5:.5 B5:1 E6:2')
SLIP = m('D#6:.5 D6:.5 C#6:.5 C6:.5 B5:2')
PROG = ['Em', 'B7', 'Em', 'C B7', 'Am', 'Em', 'C', 'B7']
SC = Scale('E4', 'harmonic')


def build():
    s = Score('MUS-SHIRO-BOSS', bpm=152, bars=72, key='E minor', seed=968)
    s.seat('vln', 'spic', 'pad', 'perc', 'vc', 'cb', 'pizz', 'picc', 'fl', 'cl', 'bsn', 'hn', 'tpt', 'tbn', 'timp')
    s.channel('ki', 'woodblock', pan=50, reverb=70, vol=72)
    for bar, nm in ((0, 'clappers'), (4, 'A the trick'), (20, 'B the pose'), (28, 'C chase (sincere)'), (44, 'D brass trick'),
                    (60, 'E the pose again'), (68, 'clappers')):
        s.section(bar, nm)
    s.notes.append('Own idea SHIRO (sly figure) + the POSE/SLIP gesture; the sincere G-major melody in the chase.')

    def ki(bar, vel=70):
        """Kabuki-style clappers accelerating across a bar."""
        t = 0.0
        gap = 1.0
        while t < 4 - 1e-6:
            s.note('ki', bar * 4 + t, .1, p('A5'), vel + int(t * 4), human=False)
            t += gap
            gap = max(.125, gap * .62)

    def drive(bar, sym, vel):
        tn = voice(sym.split()[0], 'E3', 3)
        cell = [tn[0], tn[2], tn[1], tn[2]]
        for k in range(8):
            s.note('spic', bar * 4 + k * .5, .35, cell[k % 4] + (12 if k == 4 else 0), vel + (10 if k % 4 == 0 else -2))

    def ground(bar, spec, vel, pattern='half'):
        syms = spec.split()
        if len(syms) == 1:
            s.bass(bar, syms[0], vel, pattern, chs=('cb', None))
        else:
            for k, sym in enumerate(syms):
                s.bass_at(bar * 4 + k * 2, 2, sym, vel, chs=('cb', None))

    def feint(bar, beat, up=True, vel=72):
        """A pizzicato run that stops dead and darts the other way."""
        start = SC.deg(0 if up else 7)
        t = bar * 4 + beat
        for k in range(5):
            s.note('pizz', t + k * .25, .2, SC.deg((k if up else 7 - k)), vel + k * 2)
        s.note('pizz', t + 1.5, .2, SC.deg(-3 if up else 9), vel + 10)

    def bed(bar):
        for i, sym in enumerate(['Em', 'C', 'Am', 'B7']):
            s.pad('pad', bar + i, sym, 62, low='E3')
            s.brass('tbn', bar + i, sym, 58, low='E3')
            ground(bar + i, sym, 66)
            ki(bar + i, 62 + i * 3)
        s.motif('hn', bar + 1, motif_head('E4', 'minor', rhythm=(1, .5, 2.5)), 82, form='head (horns, behind the curtain)')
        s.mel('picc', bar + 2, m('B5:.25 C6:.25 D#6:.25 E6:.25 r:1 B5:.25 r:1.75 | F#6:.5 E6:.5 D#6:.5 B5:.5 r:2'), 72)
        s.timp_roll((bar + 3) * 4 + 2, 2, 'B2', 46, 80)

    bed(0)

    # A 4-19: Shiro's figure in pizzicato + piccolo, feints, clappers on the phrase ends
    for i in range(16):
        bar, spec = 4 + i, PROG[i % 8]
        drive(bar, spec, 64)
        ground(bar, spec, 70)
        s.drum(bar, [(0, 'bd', 4), (1.5, 'snare2', -12), (2, 'bd', 0), (3, 'snare', -8)], 62)
    for k in (4, 8, 12, 16):
        s.mel('picc', k, SHIRO, 84)
        s.line('pizz', k, SHIRO, 78, transpose=-12)
        feint(k + 2, 0, up=k % 8 == 4)
        s.mel('cl', k + 2, m('r:2 E5:.25 F#5:.25 G5:.25 A5:.25 B5:1 | G5:.5 E5:.5 r:3'), 76)
        s.note('ki', (k + 3) * 4 + 3, .1, p('A5'), 84, human=False)
        s.note('ki', (k + 3) * 4 + 3.5, .1, p('A5'), 90, human=False)
    s.motif('vc', 12, motif('E3', 'minor') + [('r', 1)], 74, form='stated (cello, under the trick)', lead=False)
    for b in range(4, 20, 4):
        s.timp_hit(b * 4, 'E3', 80)

    # B 20-27: the pose and the slip (twice), the bassoon apologising, then the motif in the clarinet
    for i, sym in enumerate(['Em', 'Em', 'C', 'B7', 'Am', 'Em', 'F', 'B7']):
        bar = 20 + i
        s.pad('pad', bar, sym, 56, low='E3')
        ground(bar, sym, 66, 'whole')
    for k in (20, 24):
        s.mel('vln', k, POSE + SLIP, 98)
        s.line('tpt', k, POSE, 86, transpose=-12)
        s.brass('tbn', k, 'Em', 84, beats=4, low='E3')
        s.brass('tbn', k + 1, 'C', 66, beats=2, low='E3')
        s.timp_roll(k * 4 + 2, 2, 'B2', 60, 96)
        s.mel('bsn', k + 2, m('B3:1 A#3:1 A3:1 G#3:1 | A3:.5 r:3.5'), 78)
    s.motif('cl', 26, motif('E4', 'minor') + [('r', 1)], 82, form='stated (clarinet, regaining composure)')

    # C 28-43: the chase - fast strings, and the sincere G-major melody (he wants a worthy rival), the motif in the horns
    cprog = ['G', 'D/F#', 'Em', 'C', 'G', 'Bm', 'C', 'D', 'Em', 'C', 'G/B', 'Am', 'C', 'D', 'B7', 'B7']
    for i, sym in enumerate(cprog):
        bar = 28 + i
        drive(bar, sym, 70)
        ground(bar, sym, 72, 'march')
        s.pad('pad', bar, sym, 52, low='G3')
        s.drum(bar, [(0, 'bd', 4), (2, 'bd', 0), (3, 'snare', -4)], 64)
    s.mel('vln', 28, m('B4:2 D5:1 G5:1 | F#5:3 E5:1 | E5:1.5 D5:.5 B4:2 | C5:4 | B4:1 D5:1 G5:1 B5:1 | A5:3 F#5:1 | '
                       'G5:1.5 E5:.5 C5:2 | D5:4'), 96)
    s.motif('hn', 36, motif('E4', 'minor') + [('r', 1)], 88, form='stated (horns, the sincere side)')
    s.mel('vln', 38, m('E5:1 G5:1 B5:2 | A5:1.5 G5:.5 E5:2 | E5:2 F#5:2 | D#5:4 | E5:1 F#5:1 G5:1 A5:1 | F#5:4'), 98)
    s.line('fl', 38, m('B5:4 | C6:4 | A5:4 | B5:4 | E6:4 | D#6:4'), 62)
    s.timp_roll(43 * 4, 4, 'B2', 50, 90)

    # D 44-59: Shiro's figure in the brass, woodwind flourishes, feints in the strings
    for i in range(16):
        bar, spec = 44 + i, PROG[i % 8]
        drive(bar, spec, 74)
        ground(bar, spec, 76, 'march' if ' ' not in spec else 'half')
        if i % 4 == 0:
            s.timp_hit(bar * 4, 'E3', 88)
    for k in (44, 48, 52, 56):
        s.mel('tpt', k, SHIRO, 94)
        s.line('hn', k, SHIRO, 76, transpose=-12)
        s.run('fl', k + 2, 'E5', 'E6', SC, 70, step=.125, beat=2, crescendo=14)
        s.run('cl', k + 3, 'B5', 'B4', SC, 66, step=.125, beat=0)
        feint(k + 3, 2, up=k % 8 == 4, vel=76)
        ki(k + 3, 60)
    s.motif('tbn', 52, augment(motif_head('E3', 'minor'), 2) + [('r', 4)], 84, form='head augmented (trombones)', lead=False)

    # E 60-67: the pose again, bigger - and the slip goes further
    for i, sym in enumerate(['Em', 'C', 'Am', 'B7', 'Em', 'C', 'F', 'B7']):
        bar = 60 + i
        s.pad('pad', bar, sym, 60, low='E3')
        ground(bar, sym, 72, 'whole')
        drive(bar, sym, 66)
    s.mel('vln', 60, POSE + SLIP + m('A#5:.5 A5:.5 G#5:.5 G5:.5 F#5:2 | E5:4'), 100)
    s.line('tpt', 60, POSE + transpose(SLIP, -12), 88, transpose=-12)
    s.line('picc', 62, m('E6:.25 D#6:.25 D6:.25 C#6:.25 r:3'), 70)
    s.mel('bsn', 64, m('E3:1 D#3:1 D3:1 C#3:1 | C3:2 B2:2'), 80)
    s.motif('cl', 66, motif_tail('E4', 'minor', rhythm=(1, 1, 2)) + [('r', 4)], 80, form='tail (clarinet, recovering)')
    s.timp_roll(67 * 4, 4, 'B2', 46, 76)

    bed(68)
    return s
