"""MUS-SHOP-BENCHLEY - The gym pro shop (VS-BENCHLEY). Loop, 32 bars 4/4, 104 BPM, E Dorian (73.8 s). Gainlands rock Nov 3.
Still mystic and fun like every shop (score_bible section 9: celesta glints, pizzicato, a character clarinet, low busyness, calm enough to
browse for minutes), with a light rock groove instead of the old orchestral bounce: a muted electric guitar skanking the off-beats, a
clean electric guitar on the Gainlands answer phrase (it sits in E Dorian), finger bass, a soft power-kit groove (kick, side stick,
closed hat), a warm pad and one brass wink per half. The Crossroads motif (E B A G F# B) on the clarinet, its head on the celesta. Rock
render profile with NO guitar in the amp stem: the guitars stay clean.
"""
from lib import Song, p, motif, motif_head
from lib import rock as R

A_H = ['Em7', 'A7', 'Em7', 'A7', 'Cmaj7', 'D', 'Em7', 'A7']
B_H = ['Cmaj7', 'D', 'Bm7', 'Em7', 'Cmaj7', 'D', 'A7', 'A7']
C_H = ['Em7', 'A7', 'G', 'D', 'Cmaj7', 'D', 'Em7', 'A7']
ANSWER = R.ANSWER
LICK1 = R.LICK[:8]                               # the breakdown lick's first phrase (over E)


def build():
    s = Song('MUS-SHOP-BENCHLEY', bpm=104, bars=32, key='E dorian', seed=4505)
    s.jitter = 0.012
    s.channel('mgtr', 28, pan=40, reverb=50, vol=78)          # muted electric guitar
    s.channel('cgtr', 'clean_gtr', pan=70, reverb=70, vol=98)
    s.channel('bass', 'fingered_bass', pan=64, reverb=30, vol=96)
    s.channel('cel', 'celesta', pan=44, reverb=90, vol=70)
    s.channel('pizz', 'pizz', pan=80, reverb=70, vol=78)
    s.channel('cl', 'clarinet', pan=58, reverb=80, vol=68)
    s.channel('brass', 'brass', pan=74, reverb=85, vol=74)
    s.channel('pad', 'warm_pad', pan=64, reverb=90, vol=62)
    s.channel('kit', 'power_kit', pan=64, reverb=50, vol=86, chan=9)
    s.profile = 'rock'
    s.stem = set()
    s.stack_drums = True
    for bar, nm in ((0, 'A clean guitar'), (8, 'B clarinet and pizz'), (16, "A' guitar and celesta"), (24, 'C the motif')):
        s.section(bar, nm)
    s.notes.append('Mystic-and-fun shop with a light rock groove: muted-guitar skank, clean guitar on the Gainlands answer, soft kit.')

    def groove(bar, sym, vel=1.0):
        tn = s.chord_tones(sym, p('E3'), 3)
        for b in (.5, 1.5, 2.5, 3.5):
            s.chord('mgtr', s.B(bar, b), .2, tn, int(56 * vel))
        r = s.chord_tones(sym, p('E1'), 1)[0]
        s.note('bass', s.B(bar), 1.4, r, 76)
        s.note('bass', s.B(bar, 2.5), .45, r + 7, 66)
        s.note('bass', s.B(bar, 3.5), .45, r + 12, 60)
        s.note('kit', s.B(bar), .2, 36, 66, human=False)
        s.note('kit', s.B(bar, 2.5), .2, 36, 54, human=False)
        for b in (1, 3):
            s.note('kit', s.B(bar, b), .2, 37, 58, human=False)
        for k in range(8):
            s.note('kit', s.B(bar, k * .5), .1, 42, 40 if k % 2 else 48, human=False)
        s.chord('pad', s.B(bar), 3.9, s.chord_tones(sym, p('G3'), 3), 40)

    for k, prog in enumerate((A_H, B_H, A_H, C_H)):
        for i, sym in enumerate(prog):
            groove(8 * k + i, sym)

    # A: the Gainlands answer on clean guitar, celesta glints
    s.mel('cgtr', 0, ANSWER, 88)
    s.mel('cgtr', 2, [(p('E5'), 1.5), (p('D5'), .5), (p('B4'), 2), ('r', 4)], 82)
    s.mel('cgtr', 4, LICK1, 86)
    s.mel('cgtr', 6, [(p('E5'), 2), (p('G5'), 1), (p('F#5'), 1), (p('E5'), 3), ('r', 1)], 84)
    s.line('cel', 3, [('r', 2), (p('B6'), .5), (p('E7'), .5), (p('D7'), 1)], 52)
    s.line('cel', 7, [('r', 2), (p('F#6'), .5), (p('A6'), .5), (p('C#7'), 1)], 52)
    s.chord('brass', s.B(7, 3.5), .35, ['A3', 'C#4', 'G4'], 70)               # the wink

    # B: the Crossroads motif on the clarinet, pizz walking, celesta answering
    s.motif('cl', 8, motif('E4', 'dorian') + [('r', 1)], 84, form='stated (clarinet)')
    s.mel('cl', 10, [(p('B4'), 1), (p('A4'), .5), (p('G4'), .5), (p('F#4'), 1), (p('E4'), 1), (p('F#4'), 4)], 80)
    s.motif('cl', 12, motif('C5', 'lydian') + [('r', 1)], 82, form='sequenced on C (clarinet)')
    s.mel('cl', 14, [(p('A4'), 1), (p('C#5'), 1), (p('E5'), 1), (p('G5'), 1), (p('F#5'), 2), (p('E5'), 2)], 80)
    for i in range(8):
        tn = s.chord_tones(B_H[i], p('E4'), 4)
        for b, n in zip((0, 1, 2, 3), (tn[0], tn[2], tn[1], tn[3])):
            s.note('pizz', s.B(8 + i, b + .5), .3, n, 46)
    s.line('cel', 11, [('r', 3), (p('B6'), .5), (p('E7'), .5)], 50)
    s.line('cel', 15, [('r', 3), (p('E7'), .5), (p('A6'), .5)], 50)

    # A': guitar again, the celesta doubling it two octaves up, the brass wink
    s.mel('cgtr', 16, ANSWER, 90)
    s.line('cel', 16, ANSWER, 46, tr=24)
    s.mel('cgtr', 18, [(p('E5'), 1.5), (p('D5'), .5), (p('B4'), 2), ('r', 4)], 84)
    s.mel('cgtr', 20, LICK1, 88)
    s.line('cel', 20, LICK1, 44, tr=24)
    s.mel('cgtr', 22, [(p('E5'), 2), (p('G5'), 1), (p('F#5'), 1), (p('E5'), 3), ('r', 1)], 84)
    s.chord('brass', s.B(23, 3.5), .35, ['A3', 'C#4', 'G4'], 72)

    # C: the motif head on the celesta, the guitar answering, thinning back to bar 0's texture
    s.motif('cel', 24, motif_head('E5', 'dorian') + [('r', 2)], 70, form='head (celesta)')
    s.mel('cgtr', 25, [(p('G4'), .5), (p('A4'), .5), (p('B4'), 1), (p('D5'), 1), (p('E5'), 1)], 84)
    s.motif('cel', 26, motif_head('D5', 'mixolydian') + [('r', 2)], 68, form='head on D (celesta)')
    s.mel('cgtr', 27, [(p('F#4'), .5), (p('A4'), .5), (p('B4'), 1), (p('C#5'), 1), (p('D5'), 1)], 84)
    s.mel('cl', 28, [(p('G4'), 1), (p('B4'), 1), (p('E5'), 1), (p('D5'), 1), (p('B4'), 2), (p('A4'), 2)], 76)
    s.mel('cgtr', 30, [(p('B4'), 2), (p('A4'), 1), (p('G4'), 1), (p('F#4'), 2), (p('C#5'), 2)], 80)
    return s
