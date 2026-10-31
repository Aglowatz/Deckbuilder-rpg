"""MUS-GOUR-BATTLE - The Endless Buffet, combat. 72 bars 4/4, 142 BPM, Bb major.
The Buffet showtune at battle tempo: the zone theme (zones.BUFFET_THEME) up a fourth in muted trumpet and clarinet over a driving tuba
oom-pah and string 8ths, a tense B section on the relative minor where the brass state the Crossroads motif against the theme's
"welcome" head in stabs, then an EDM DROP (four-on-the-floor, claps, synth bass, pumped pad, the saw lead on the drop hook and the motif),
and a tutti finale with the kick still under the orchestra. The intro/outro is a brass-and-pad bed over the drive, so the loop never
falls into an ostinato-only hole.
"""
from lib import Song, motif, motif_head, augment, transpose, p
from lib.zones import BUFFET_THEME, BUFFET_THEME_A, BUFFET_THEME_8, BUFFET_HOOK, BUFFET_PROG, BUFFET_DROP_PROG, BUFFET_CHORDS

SEMIS = 5          # F -> Bb


def cmap(semis):
    out = {}
    for k, (b, v) in BUFFET_CHORDS.items():
        bb = p(b) + semis
        while bb > 42:
            bb -= 12
        while bb < 30:
            bb += 12
        vv = [p(n) + semis for n in v]
        while max(vv) > 69:
            vv = [x - 12 for x in vv]
        while min(vv) < 52:
            vv = [x + 12 for x in vv]
        out[k] = (bb, vv)
    return out


def build():
    s = Song('MUS-GOUR-BATTLE', bpm=142, bars=72, key='Bb major', seed=401, jitter=0.012)
    s.V = cmap(SEMIS)
    s.channel('vln', 'strings', 36, 95, 96)
    s.channel('spic', 'strings', 30, 85, 78)
    s.channel('pizz', 'pizz', 74, 75, 80)
    s.channel('cl', 'clarinet', 60, 80, 96)
    s.channel('mtpt', 'muted_tpt', 56, 85, 96)
    s.channel('brass', 'brass', 70, 90, 88)
    s.channel('hn', 'horn', 78, 95, 92)
    s.channel('tuba', 'tuba', 88, 85, 86)
    s.channel('glock', 'glock', 44, 95, 64)
    s.channel('timp', 'timpani', 64, 80, 92)
    s.channel('sbass', 38, 64, 30, 92)
    s.channel('lead', 81, 60, 70, 84)
    s.channel('spad', 'warm_pad', 64, 90, 74)
    s.channel('choir', 'choir', 64, 105, 66)
    s.channel('kit', 'standard_kit', 64, 60, 94)
    for bar, nm in ((0, 'intro bed'), (4, 'A showtune'), (20, 'B minor turn'), (36, 'drop'), (52, 'finale'), (68, 'outro bed')):
        s.section(bar, nm)
    s.notes.append('Approved Buffet direction (showtune + EDM drop) supersedes the old "chamber dance" row wording.')

    def kick(bar, vel, clap=False, hats=False, snare=True):
        for b in range(4):
            t = bar * 4 + b
            s.note('kit', t, .25, 36, vel, human=False)
            if clap and b in (1, 3):
                s.note('kit', t, .25, 39, vel - 14, human=False)
            elif snare and b in (1, 3):
                s.note('kit', t, .25, 38, vel - 26, human=False)
            if hats:
                s.note('kit', t + .5, .2, 46, vel - 34, human=False)
                s.note('kit', t, .1, 42, vel - 44, human=False)

    def oompah(bar, sym, vel):
        b = p(s.V[sym][0])
        s.note('tuba', bar * 4, .7, b, vel)
        s.note('tuba', bar * 4 + 2, .7, b + 7 if sym not in ('C7', 'D7') else b, vel - 8)
        for beat in (1, 3):
            s.chord('pizz', bar * 4 + beat, .35, s.V[sym][1], vel - 16)

    def drive(bar, sym, vel):
        tn = sorted(s.V[sym][1])
        cell = [tn[0], tn[0], tn[2], tn[0], tn[1], tn[0], tn[2], tn[0] + 12]
        for k, n in enumerate(cell):
            s.note('spic', bar * 4 + k * .5, .3, n - 12, vel + (10 if k % 4 == 0 else -4))

    def bed(bar, sym, vel):
        s.chord('brass', bar * 4, 3.9, s.V[sym][1], vel)
        s.chord('choir', bar * 4, 4.05, s.V[sym][1], vel - 14)

    def intro(bar):
        for i, sym in enumerate(['F', 'Dm', 'Gm7', 'C7']):
            oompah(bar + i, sym, 82)
            drive(bar + i, sym, 72)
            bed(bar + i, sym, 72)
            kick(bar + i, 74)
            s.line('glock', bar + i, [(p(x) + SEMIS, .5) for x in ('F5', 'A5', 'C6', 'F6', 'C6', 'A5', 'F5', 'C5')], 50, arc=False)
        s.timp_hit(bar * 4, s.V['F'][0] + 12, 80)
        s.timp_roll(bar * 4 + 14, 2, s.V['C7'][0] + 12, 50, 88)
        s.motif('hn', bar + 1, motif_head('Bb3', 'major', rhythm=(1, .5, 2.5)), 82, form='head (horns, over the bed)')
        s.swell('brass', bar + 3, 1, 70, 96)

    intro(0)

    # A 4-19: the Buffet theme at battle tempo - muted trumpet + clarinet, oom-pah, string drive, snare on 2 and 4
    for i in range(16):
        sym = BUFFET_PROG[i]
        oompah(4 + i, sym, 82)
        drive(4 + i, sym, 62)
        kick(4 + i, 58)
        if i % 4 == 0:
            s.timp_hit((4 + i) * 4, s.V[sym][0] + 12, 82)
    s.mel('mtpt', 4, BUFFET_THEME, 92, tr=SEMIS - 12)
    s.line('cl', 4, BUFFET_THEME, 74, tr=SEMIS)
    s.motif('hn', 12, motif('Bb3', 'major') + [('r', 1)], 72, form='stated (horns, under the theme)', lead=False)
    s.line('brass', 19, [(p(n) + SEMIS - 12, .5) for n in ['C5', 'D5', 'E5', 'F5', 'G5', 'A5', 'Bb5', 'B5']], 84, arc=False)

    # B 20-35: the minor turn - the hero's motif stated in the brass, the theme's welcome head snapped back in stabs
    bprog = ['Dm', 'Bb', 'Gm', 'C7'] * 4
    for i, sym in enumerate(bprog):
        bar = 20 + i
        drive(bar, sym, 72)
        s.note('tuba', bar * 4, 1.8, p(s.V[sym][0]), 78)
        s.note('tuba', bar * 4 + 2, 1.8, p(s.V[sym][0]), 70)
        s.chord('spad', bar * 4, 4.05, s.V[sym][1], 44)
        kick(bar, 62, snare=True)
        s.chord('brass', bar * 4 + 1.5, .35, s.V[sym][1], 70)
        s.chord('brass', bar * 4 + 3.5, .35, s.V[sym][1], 66)
    for k in (20, 28):
        s.motif('hn', k, motif('G4', 'minor') + [('r', 1)], 96, form='stated (horns, G minor)')
        s.line('mtpt', k + 2, transpose(BUFFET_THEME_A[:6], SEMIS - 12 - 3), 70)
    s.mel('vln', 24, transpose(BUFFET_THEME_8[21:40], SEMIS - 3) + [('r', 1)], 88, legato=.9)
    s.mel('vln', 32, augment(transpose(BUFFET_THEME_A[:6], SEMIS - 3), 2) + [('r', 2)], 92)
    for k in range(16):
        s.note('kit', 35 * 4 + 2 + k * .125, .1, 38, 40 + k * 4, human=False)

    # DROP 36-51: four-on-the-floor, synth bass, pumped pad, saw lead on the hook and the motif, orchestra hits
    for i in range(16):
        bar = 36 + i
        sym = BUFFET_DROP_PROG[i % 4]
        b, v = s.V[sym]
        s.chord('spad', bar * 4, 4.05, v + [v[0] + 12], 82)
        for beat in range(4):
            s.note('sbass', bar * 4 + beat + .5, .4, p(b) + 12, 96, human=False)
            s.note('sbass', bar * 4 + beat, .2, p(b), 80, human=False)
        if i % 2 == 0:
            s.chord('brass', bar * 4, .6, v, 92)
            s.timp_hit(bar * 4, p(b) + 12, 88)
        kick(bar, 100, clap=True, hats=True, snare=False)
    s.pump('spad', 36, 16, lo=30, hi=112)
    s.mel('lead', 36, BUFFET_HOOK, 88, tr=SEMIS - 12, legato=.85)
    s.motif('lead', 40, motif('Bb4', 'major') + [('r', 1)], 88, form='stated (saw lead, the drop)', legato=.9)
    s.mel('lead', 44, BUFFET_HOOK, 92, tr=SEMIS - 12, legato=.85)
    s.line('vln', 44, BUFFET_HOOK, 74, tr=SEMIS - 24)
    s.motif('lead', 48, motif('Bb4', 'major') + [('r', 1)], 94, form='stated (saw lead + violins)', legato=.9)
    s.line('vln', 48, motif('Bb4', 'major'), 84)
    s.note('kit', 36 * 4, 3, 49, 96)
    s.note('kit', 44 * 4, 3, 49, 90)
    for k in range(16):
        s.note('kit', 51 * 4 + k * .25, .2, 38, 46 + k * 5, human=False)

    # FINALE 52-67: the theme tutti - violins 8va, brass, choir - with the kick still under it
    for i in range(16):
        bar = 52 + i
        sym = BUFFET_PROG[i]
        oompah(bar, sym, 90)
        drive(bar, sym, 66)
        s.chord('choir', bar * 4, 4.05, [x + 12 for x in s.V[sym][1]], 60)
        s.chord('brass', bar * 4 + 1.5, .35, s.V[sym][1], 74)
        s.chord('brass', bar * 4 + 3.5, .35, s.V[sym][1], 70)
        kick(bar, 84, clap=True, hats=i >= 8, snare=False)
    s.mel('vln', 52, BUFFET_THEME, 104, tr=SEMIS)
    s.line('mtpt', 52, BUFFET_THEME, 84, tr=SEMIS - 12)
    s.line('glock', 52, BUFFET_THEME_8, 56, tr=SEMIS)
    s.motif('hn', 60, augment(motif_head('Bb3', 'major'), 2) + [('r', 2)], 84, form='head augmented (horns, finale)', lead=False)
    s.note('kit', 52 * 4, 3, 49, 98)
    s.timp_roll(67 * 4, 4, s.V['C7'][0] + 12, 50, 92)

    intro(68)
    s.fade_vel(70, 72, 1.12, ['tuba', 'spic', 'kit'])     # seam: a small lift into the loop point
    return s
