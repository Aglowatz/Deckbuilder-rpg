"""Compare the notes and controllers of two .mid files (used to prove a score port matches its original).

    python tools/music/compare_midi.py original.mid tools/music/midi/MUS-TOWN.mid
"""
import sys
import mido


def events(path):
    mid = mido.MidiFile(path)
    out = []
    for tr in mid.tracks:
        t = 0
        for m in tr:
            t += m.time
            if m.type in ('note_on', 'note_off', 'control_change', 'program_change'):
                if m.type == 'control_change' and m.control in (0, 32):
                    continue
                out.append((t, m.channel, m.type, m.bytes()[1:]))
    return sorted(out), mid.length


a, la = events(sys.argv[1])
b, lb = events(sys.argv[2])
notes_a = [e for e in a if e[2] == 'note_on']
notes_b = [e for e in b if e[2] == 'note_on']
print(f'A: {len(notes_a)} notes, {len(a)} events, {la:.3f} s | B: {len(notes_b)} notes, {len(b)} events, {lb:.3f} s')
diff = [x for x, y in zip(a, b) if x != y]
print('identical' if a == b else f'DIFFERENT: {len(diff)} of {len(a)} events differ, first {diff[:3]}')
sys.exit(0 if a == b else 1)
