"""Overnight Oct 31 - Nov 1: the overlap fix (a re-strike of the same pitch must not be cut by the previous note's note_off).
Run: "$LOCALAPPDATA/Programs/Python/Python312/python.exe" -m unittest tools.music.tests.test_note_spans  (from the repo root)"""
import os
import sys
import unittest

sys.path.insert(0, os.path.join(os.path.dirname(__file__), '..'))
from lib.score import note_spans, TPB  # noqa: E402


def ev(s, d, n=60, v=80):
    return (s, d, n, v, None)


class NoteSpansTest(unittest.TestCase):
    def test_a_restrike_inside_a_held_note_lasts_its_full_length(self):
        # a 4-beat pad note, re-struck at beat 2 for 4 beats: the old note_off at beat 4 used to cut the new note to 2 beats
        spans = note_spans([ev(0, 4), ev(2, 4)])
        self.assertEqual(spans, [(0, 2 * TPB, 60, 80), (2 * TPB, 6 * TPB, 60, 80)])

    def test_a_short_restrike_inside_a_long_note_keeps_the_long_end(self):
        spans = note_spans([ev(0, 8), ev(2, 1)])
        self.assertEqual(spans[-1], (2 * TPB, 8 * TPB, 60, 80), "the pitch keeps sounding to the later end")

    def test_doubled_notes_merge_into_one_voice(self):
        spans = note_spans([ev(0, 2, v=70), ev(0, 4, v=90)])
        self.assertEqual(spans, [(0, 4 * TPB, 60, 90)])

    def test_back_to_back_and_other_pitches_are_unchanged(self):
        spans = note_spans([ev(0, 1), ev(1, 1), ev(0.5, 3, n=64)])
        self.assertEqual(spans, [(0, TPB, 60, 80), (TPB // 2, 7 * TPB // 2, 64, 80), (TPB, 2 * TPB, 60, 80)])

    def test_to_midi_writes_the_merged_spans(self):
        from lib.score import Score
        import inspect
        self.assertIn('note_spans(self.events[k])', inspect.getsource(Score.to_midi))


if __name__ == '__main__':
    unittest.main()
