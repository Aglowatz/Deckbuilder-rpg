"""MUS-TUT-EXP - Forgotten Cave, old passage. 36 bars 4/4, 66 BPM, E minor (modal: no raised leading tone).
Soft mossy mystery: a low string drone, plucked notes that echo back from the walls, a breathy pan flute trying the Crossroads motif,
water drops in the celesta. The middle turns ancient and royal: a far horn plays the motif slowly over open, old-court harmony and soft
voices. Then the echoes return and the celesta lets slip the lullaby's first three notes before the drone takes over again.
"""
from lib import Score, m, motif, motif_head, motif_tail, augment, p

DRONE = ['Em', 'Em', 'Cmaj7/E', 'Em', 'Em', 'D/E', 'Cmaj7/E', 'Bm/E']
CAVE = ['Em', 'C', 'Am', 'Bm', 'Em', 'C', 'D', 'Bm']
ROYAL = ['Em', 'D', 'C', 'D', 'G', 'D', 'C', 'Bm']


def build():
    s = Score('MUS-TUT-EXP', bpm=66, bars=36, key='E minor', seed=303)
    s.seat('fl', 'harp', 'pizz', 'pad', 'vc', 'cb', 'hn', 'cl', 'cel', 'bsn', 'timp',
           fl=('pan_flute', 52, 100, 84), harp={'rev': 110}, pizz={'rev': 110})
    s.channel('voices', 'oohs', pan=64, reverb=120, vol=62)
    for bar, nm in ((0, 'drone'), (8, 'motif'), (16, 'ancient court'), (24, 'echoes'), (32, 'drone again')):
        s.section(bar, nm)

    def echo(ch, beat, pitch, vel, repeats=3, delay=0.75, decay=0.55, pan_walk=None):
        for k in range(repeats + 1):
            s.note(ch, beat + k * delay, 0.6, p(pitch), vel * (decay ** k))

    def drops(bar, bars, vel):
        for k in range(bars):
            if s.rng.random() < 0.6:
                s.note('cel', (bar + k) * 4 + s.rng.randrange(8) * 0.5, 0.3, s.rng.choice([p(n) for n in ('B5', 'E6', 'F#6', 'G6', 'B6')]), vel)

    def drone(bar, n=8, vel=50):
        for i in range(n):
            spec = DRONE[i % 8]
            s.note('cb', (bar + i) * 4, 4.02, p('E2'), vel - 4)
            s.note('vc', (bar + i) * 4, 4.02, p('B2'), vel - 10)
            s.pad('pad', bar + i, spec, vel - 6, low='G3', n=3)
        s.swell('pad', bar, n, 70, 92, 'arch')
        drops(bar, n, 40)

    def plucks(bar, figs, vel):
        # one plucked note per half bar, echoing back off the walls
        for k, (beat, pitch) in enumerate(figs):
            echo('harp' if k % 2 == 0 else 'pizz', bar * 4 + beat, pitch, vel)

    # DRONE 0-7: low drone, echoing plucks, the pan flute tries the head
    drone(0)
    plucks(0, [(0, 'E4'), (6, 'B4'), (12, 'G4'), (18, 'A4'), (24, 'E4'), (30, 'B4')], 58)
    s.motif('fl', 2, motif_head('E4', rhythm=(1, .5, 2.5)) + m('r:4'), 66, form='head (pan flute), left hanging')
    s.mel('fl', 5, m('G4:1.5 F#4:.5 E4:2 | r:4 | B4:1 A4:.5 G4:.5 F#4:2'), 60)

    # MOTIF 8-15: the pan flute states it whole; plucked answers; clarinet below
    for i, spec in enumerate(CAVE):
        bar = 8 + i
        s.pad('pad', bar, spec, 50, low='G3')
        s.bass_at(bar * 4, 4, spec, 54)
        echo('harp', bar * 4 + 2, s.voicing(spec)[1][-1] + 12, 50, repeats=2)
    s.motif('fl', 8, motif('E4', 'minor') + m('r:1'), 80, form='stated (pan flute)')
    s.mel('fl', 10, m('G4:1 A4:.5 B4:.5 D5:1.5 C5:.5 | B4:3 r:1 | E5:1 D5:.5 C5:.5 B4:1.5 A4:.5 | F#4:4'), 76)
    s.line('cl', 8, m('G3:4 | G3:4 | E3:4 | F#3:4 | G3:4 | E3:4 | F#3:4 | D3:4'), 50, legato=1.0, shape=False)
    s.swell('pad', 8, 8, 76, 100, 'arch')
    drops(8, 8, 36)

    # ANCIENT COURT 16-23: a far horn plays the motif slowly over open old-court harmony; voices; a timpani like a distant door
    for i, spec in enumerate(ROYAL):
        bar = 16 + i
        s.pad('pad', bar, spec, 54, low='E3')
        s.pad('voices', bar, spec, 46, low='G3', n=3)
        s.bass_at(bar * 4, 4, spec, 58)
        s.figure('harp', bar, spec, [(0, 0, 2, 4), (0.25, 1, 2, 0), (0.5, 2, 2, -2), (2, 1, 1.5, -6), (2.5, 2, 1.5, -6)], 48, low='E4')
    s.motif('hn', 16, augment(motif('E4', 'minor'), 2)[:5], 72, form='augmented (far horn, ancient)')
    s.mel('hn', 19, m('r:2 G4:2 | B4:6 A4:2 | G4:4 F#4:4'), 70, beat=2)
    s.line('bsn', 16, m('E3:4 | D3:4 | C3:4 | D3:4 | G3:4 | F#3:4 | E3:4 | D3:4'), 52, legato=1.0, shape=False)
    s.swell('voices', 16, 8, 60, 100, 'arch')
    s.swell('hn', 16, 8, 80, 110, 'arch')
    s.timp_hit(16 * 4, 'E2', 56)
    s.timp_hit(20 * 4, 'G2', 50)
    s.timp_roll(23 * 4, 4, 'B1', 30, 54)

    # ECHOES 24-31: plucks return with the cello singing the tail; the celesta lets slip three notes of the lullaby
    for i, spec in enumerate(CAVE):
        bar = 24 + i
        s.pad('pad', bar, spec, 48, low='G3')
        s.note('cb', bar * 4, 4.02, p(s.voicing(spec)[0]), 52)
    plucks(24, [(0, 'B4'), (6, 'E5'), (12, 'D5'), (18, 'B4'), (24, 'G4'), (30, 'F#4')], 56)
    s.motif('vc', 24, motif_tail('E3', rhythm=(3, 1, 4)) + m('r:4'), 78, form='tail (cello)')
    s.mel('vc', 27, m('A3:2 B3:2 | C4:3 B3:1 | A3:2 G3:2 | F#3:4'), 74)
    s.mel('fl', 30, m('B4:1 A4:.5 G4:.5 F#4:2 | E4:4'), 62)
    s.line('cel', 29, m('E5:1 B5:1 G5:2'), 38)
    s.motifs.append((29, 'lullaby glimmer (E B G, three notes) - story theme', 'cel'))
    drops(24, 8, 34)

    # DRONE AGAIN 32-35: the same drone as bar 0 so the loop lands; the flute's head once more
    drone(32, n=4)
    plucks(32, [(0, 'E4'), (6, 'B4'), (12, 'G4')], 58)
    s.mel('fl', 34, motif_head('E4', rhythm=(1, .5, 2.5)) + m('r:4'), 62)
    return s
