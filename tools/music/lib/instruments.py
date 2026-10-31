"""GM/GS programs as (bank, program) in FluidR3_GM. Bank 8/16 entries are FluidR3's GS variations; the renderer sends CC0 for them."""

GM = {
    'piano': (0, 0), 'bright_piano': (0, 1), 'harpsichord': (0, 6), 'harpsichord2': (8, 6), 'celesta': (0, 8), 'glock': (0, 9),
    'music_box': (0, 10), 'vibes': (0, 11), 'marimba': (0, 12), 'xylophone': (0, 13), 'bells': (0, 14), 'church_bell': (8, 14),
    'dulcimer': (0, 15), 'organ': (0, 19), 'reed_organ': (0, 20), 'accordion': (0, 21), 'accordion_it': (8, 21), 'bandoneon': (0, 23),
    'nylon': (0, 24), 'steel_gtr': (0, 25), 'mandolin': (16, 25), 'ukulele': (8, 24), 'clean_gtr': (0, 27),
    'ac_bass': (0, 32), 'fingered_bass': (0, 33),
    'violin': (0, 40), 'slow_violin': (8, 40), 'viola': (0, 41), 'cello': (0, 42), 'contrabass': (0, 43), 'tremolo': (0, 44),
    'pizz': (0, 45), 'harp': (0, 46), 'timpani': (0, 47),
    'strings': (0, 48), 'slow_strings': (0, 49), 'orch_pad': (8, 48), 'synth_strings': (0, 50),
    'choir': (0, 52), 'oohs': (0, 53), 'orch_hit': (0, 55),
    'trumpet': (0, 56), 'trombone': (0, 57), 'tuba': (0, 58), 'muted_tpt': (0, 59), 'horn': (0, 60), 'brass': (0, 61),
    'oboe': (0, 68), 'english_horn': (0, 69), 'bassoon': (0, 70), 'clarinet': (0, 71),
    'piccolo': (0, 72), 'flute': (0, 73), 'recorder': (0, 74), 'pan_flute': (0, 75), 'bottle': (0, 76), 'shakuhachi': (0, 77),
    'whistle': (0, 78), 'ocarina': (0, 79),
    'warm_pad': (0, 89), 'choir_pad': (0, 91), 'bowed_glass': (0, 92), 'halo_pad': (0, 94), 'sweep_pad': (0, 95),
    'crystal': (0, 98), 'atmosphere': (0, 99), 'star_theme': (0, 103),
    'banjo': (0, 105), 'kalimba': (0, 108), 'bagpipe': (0, 109), 'fiddle': (0, 110), 'tinkle': (0, 112),
    'woodblock': (0, 115), 'taiko': (0, 116), 'concert_bd': (8, 116), 'castanets': (8, 115), 'melodic_tom': (0, 117),
    'orch_kit': (128, 48), 'standard_kit': (128, 0), 'brush_kit': (128, 40),
    # Music Pass 3 (Lab techno, Capital): synth leads/basses/pads/FX and the GS drum kits (all drum kits share MIDI channel 10: one per score).
    'elec_piano': (0, 4), 'clavinet': (0, 7), 'synth_bass': (0, 38), 'synth_bass2': (0, 39), 'synth_strings2': (0, 51),
    'synth_brass': (0, 62), 'synth_brass2': (0, 63), 'square_lead': (0, 80), 'saw_lead': (0, 81), 'calliope': (0, 82), 'chiff_lead': (0, 83),
    'charang': (0, 84), 'voice_lead': (0, 85), 'fifths_lead': (0, 86), 'bass_lead': (0, 87), 'new_age': (0, 88), 'poly_pad': (0, 90),
    'metal_pad': (0, 93), 'fx_rain': (0, 96), 'fx_soundtrack': (0, 97), 'fx_goblin': (0, 101), 'fx_echo': (0, 102), 'synth_drum': (0, 118),
    'reverse_cymbal': (0, 119), 'room_kit': (128, 8), 'power_kit': (128, 16), 'electro_kit': (128, 24), 'tr808_kit': (128, 25),
}
