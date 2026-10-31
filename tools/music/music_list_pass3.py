"""Music Pass 3 (Oct 31): bring data/source/music_list.csv in line with the approved directions (docs/audio/score_bible.md sections 8-9).

    python tools/music/music_list_pass3.py            rewrite the Music Description column of every row done in passes 1-3, and the
                                                      Instrument Palette + Implementation Notes columns of the 57 Pass 3 cues
    python tools/music/music_list_pass3.py --own MUS-VAULT-BOSS    drop the compatibility-alias note of a former alias (it has its own track now)

Former aliases keep their alias note until their own track is delivered (the importer reads "Compatibility alias" in the notes column).
"""
import csv
import io
import os
import sys

HERE = os.path.dirname(os.path.abspath(__file__))
PATH = os.path.join(HERE, '..', '..', 'data', 'source', 'music_list.csv')
COL_DESC, COL_PAL, COL_NOTES = 6, 7, 11

# ---------------------------------------------------------------- palettes (Pass 3 cues)
CAP = ('Capital palette (Music Pass 3): music box, harpsichord, glockenspiel, celesta, rigid strings, block brass (trumpets, trombones, tuba), '
       'orchestra-kit snare rudiments, timpani; quantised (human feel off)')
CAP_OUT = ('Capital outskirts (Music Pass 3): sparse wind-worn strings, solo cello, contrabass, distant music box / glockenspiel (the Primm motif '
           'as a far-off broadcast), low brass, timpani; quantised')
CREASE = 'Chamber (Music Pass 3): piano, clarinet, a few strings (violin, viola, cello), harp; human feel on - the one warm place in the Capital'
TUNNEL = ('Old-kingdom orchestra (Music Pass 3): warm strings, horns, harp, flute, oboe, cello/contrabass, timpani, choir; long echoing reverb; '
          'human feel on')
CASTLE = 'Baroque court (Music Pass 3): strings, harpsichord, choir, oboe, flute, trumpets, timpani; NO organ (organ is D.N.A.); quantised'
PRIMM = ('Capital palette, full orchestra (Music Pass 3): strings, brass, woodwinds, music box, harpsichord, glockenspiel, snare rudiments, '
         'timpani, choir; quantised until the unravelling')
PRIMM_TENDER = 'Story orchestra (Music Pass 3): piano, warm strings, cello, solo clarinet/oboe, horn, a slowed music box; human feel'
STORY = ('Story orchestra (Music Pass 3): gentle strings, harp, celesta, solo flute / oboe / clarinet, soft horns, piano, cello; warm and '
         'tender, human feel')
FINALE = ('Full orchestra (Music Pass 3): strings, horns, trumpets, trombones, woodwinds, harp, celesta, choir, timpani, plus each zone\'s '
          'colour (organ, showtune brass, fiddle, march snare); human feel')
LAB = ('Techno/EDM + cold orchestra (Music Pass 3): electronic drum kit (kick, clap, hats), saw/square leads, distorted synth bass, '
       'arpeggiators, sidechain-pumped pads, risers/FX, string and brass stabs, orchestra hit; layered and detuned; quantised, 150-170 BPM')
SHOP = ('Mystic-and-fun shop palette (Music Pass 3): pizzicato, celesta / music box, harp glissandi, clarinet, bassoon, oboe, flute, light '
        'percussion (triangle, woodblock, tambourine)')
VAULT = 'Core orchestra + ancient colour (Music Pass 3): low strings, horns, harp, celesta, choir, timpani, tubular bells; royal brass for clues'
GRAVE = ('Core orchestra + graveyard colour (Music Pass 3): bassoon, contrabassoon-range cello, oohs (Old Hob\'s hum), pizzicato, celesta, '
         'xylophone, harp, soft timpani')
ARENA = ('Core orchestra + showbiz (Music Pass 3): trumpets, horns, trombones, snare/bass drum/cymbals, timpani, strings, glockenspiel, '
         'choir; Grand Bellows\'s spectacle')
SHIRO = ('Core orchestra + trickster colour (Music Pass 3): pizzicato, piccolo, clarinet, xylophone, muted trumpet, taiko and woodblock, '
         'strings, timpani')

N = 'Music Pass 3 (Oct 31): '

# ---------------------------------------------------------------- the 57 Pass 3 cues: (description, palette, notes)
PASS3 = {
    'MUS-CAP-OUT-EXP': ('Depleted outskirts: sparse wind-worn strings and a lonely cello over a hesitant pulse, while the Primm motif plays far off '
                        'like a broadcast from the walls. Bleak but not hopeless; the Crossroads motif tries a phrase and fades.', CAP_OUT,
                        N + 'Capital direction - the Primm motif / Capital theme as a distant broadcast; quantised'),
    'MUS-CAP-OUT-BATTLE': ('The outskirts pulse driven into a grounded battle ostinato: dry drums, wind-worn strings and the Capital theme in a cold '
                           'minor far above. Determination under the bleakness.', CAP_OUT,
                           N + 'Capital direction - the Capital theme in minor, the Crossroads motif in the horns; quantised'),
    'MUS-CAP-FACADE-EXP': ('Everything is perfectly fine: music-box muzak in bright C major, rigid 120 BPM, harpsichord and glockenspiel on the '
                           'Capital theme over a low dread pedal. Occasional minor slips and frantic "imperfect" bursts snap straight back to '
                           'the smile.', CAP, N + 'Capital direction - Capital home key/tempo (C major 120), quantised, imperfect bursts'),
    'MUS-CAP-FACADE-BATTLE': ('The facade under strain: the same polished muzak driven by rigid strings and snare rudiments, the dread pedal '
                              'louder, the slips more frequent; the Crossroads motif keeps breaking through and being swallowed.', CAP,
                              N + 'Capital direction - the Capital theme under strain, quantised'),
    'MUS-CAP-ENFORCER': ('Every smudge is treason: a fussy snare-rudiment march (paradiddles, flams, drags), block brass and clipped strings on '
                         'the Capital theme. Pompous, then genuinely pressing.', CAP,
                         N + 'Capital direction - Captain Spotless / enforcers: snare-rudiment march, quantised'),
    'MUS-CREASE': ('Tea of dissent: the one warm, human place in the Capital. Chamber piano, clarinet and a few strings with human feel; the '
                   'Crossroads motif sung gently, people quietly resisting.', CREASE,
                   N + 'Capital exception - chamber, human feel ON, the Crossroads motif gentle'),
    'MUS-CAP-CORRECTION': ('Smiled incorrectly: a metronome and clinical high strings, isolated piano, the Capital theme reduced to a cold '
                           'exercise; an unfinished human melody in the silences. No comic accents.', CAP,
                           N + 'Capital direction - metronome, clinical high strings, quantised'),
    'MUS-CAP-RIFT': ('A seam in reality: the four zone themes (D.N.A. waltz, Buffet showtune, Dump jig, Gainlands march) glitching over each '
                     'other while the Capital theme tries to hold them on the grid. A steady pulse for readable combat.', CAP,
                     N + 'Capital direction - the four zone themes glitching, the Capital theme as the grid'),
    'MUS-TUNNEL-EXP': ('The old kingdom under the city: warmer, echoing orchestra, the Crossroads motif stated in full and answered by the Paths. '
                       'The Capital above is only a faint rumour.', TUNNEL,
                       N + 'Capital exception - warm, echoing, the Crossroads motif in full; human feel'),
    'MUS-TUNNEL-BATTLE': ('The tunnels fight back: a warm driving string and timpani ostinato under the Crossroads motif in the horns, echoing '
                          'stone. Old harmony against the new order.', TUNNEL,
                          N + 'Capital exception - warm, echoing, the Crossroads motif in full; human feel'),
    'MUS-TUNNEL-BOSS': ('Captain Spotless below ground: the rigid Capital march, quantised, snare rudiments and block brass forcing the echoing '
                        'tunnel into step; the Crossroads motif pushes back.', CAP,
                        N + 'own track (no longer an alias of MUS-TUNNEL-BATTLE): Captain Spotless keeps the rigid Capital march'),
    'MUS-CASTLE-EXP': ('Behind the white and gold: an elegant Baroque court - a minuet in strings and harpsichord, choir in the mirror halls, the '
                       'Capital theme dressed as a courtly dance; gilded symmetry with unease underneath.', CASTLE,
                       N + 'Castle direction - Baroque court, minuet, no organ'),
    'MUS-CASTLE-BATTLE': ('The mirror parquet: a driven gavotte where the hero\'s Crossroads motif is mirrored (inverted) against Primm\'s, '
                          'phrases answering across the stereo field; strings, harpsichord, choir.', CASTLE,
                          N + 'Castle direction - Baroque gavotte, the hero\'s motif mirrored against Primm\'s'),
    'MUS-PRIMM-01': ('Standardization: the whole orchestra in unison and octaves on the Primm motif, machine-like and quantised; every Path\'s '
                     'rhythm pressed into one pulse. Imposing, sincere, coercive.', PRIMM,
                     N + 'Primm direction - unison/octaves on the Primm motif; separate phase asset, transition on the actual phase state'),
    'MUS-PRIMM-02': ('Reflection: the Primm theme imitating each zone style in turn - a D.N.A. organ waltz, a Buffet showtune with an EDM drop, a '
                     'Dump fiddle jig, a Gainlands march - each slightly wrong.', PRIMM,
                     N + 'Primm direction - the Primm theme in each zone style, each slightly wrong'),
    'MUS-PRIMM-03': ('Unraveling: the rigidity breaks, human feel returns, and the four zone themes combine over the Crossroads motif - a heroic '
                     'climax for the whole journey.', FINALE,
                     N + 'Primm direction - rigid to human, the four zone themes over the Crossroads motif'),
    'MUS-PRIMM-BREAK': ('Rules between duels: sparse, the Primm motif on a slowed music box over a held string tone; dialogue stays clear and '
                        'the loop waits for the next phase.', PRIMM_TENDER, N + 'Primm direction - slowed music box, sparse'),
    'MUS-PRIMM-DEFEAT': ('Finally seeing: the Primm motif made tender and human, the sincere reformer he once was; piano and warm strings, the '
                         'Path voices standing apart, a quiet open-hearted ending.', PRIMM_TENDER,
                         N + 'Primm direction - the Primm motif tender and human'),
    'MUS-PRIMM-MOTIF': ('For their own good: Primm\'s motif master - the existing even-note civic melody, re-orchestrated in the Capital palette '
                        '(music box, harpsichord, strings, block brass). Plausible and sincere before it is coercive.', CAP,
                        N + 'motif master - melody kept, re-orchestrated in the Capital palette'),
    'MUS-ARCHIVE': ('Good intentions: Primm\'s early journals. The Primm motif tender and human on piano and cello, a young reformer\'s hope, '
                    'with only the faintest clockwork beginning underneath.', PRIMM_TENDER,
                    N + 'Primm direction - the Primm motif tender and human, the sincere reformer'),
    'MUS-GALLERY': ('Kept for reference: the painted-over royal portrait. Soft strings and harp, a lullaby fragment (its first notes only) with '
                    'a missing answering voice; tender and hopeful, never generic tragedy.', STORY,
                    N + 'story direction - hopeful; lullaby rule: at most its first four notes'),
    'MUS-CAP-RESTORED': ('Pathordia, many ways home: the Capital theme freed - human feel returns, the four Path colours woven in, the '
                         'Crossroads motif resolved. Warm, broad and adventurous.', FINALE,
                         N + 'restoration - human feel returns ONLY here in the Capital; resolved motif'),
    'MUS-THRONE': ('The Pathwork Throne: the complete lullaby for the first time, warm strings, harp, celesta and woodwinds, the four Path motifs '
                   'woven around it into a broad, hopeful arrangement.', STORY,
                   N + 'story direction - the whole lullaby allowed (after the reveal); resolved motif'),
    'MUS-REUNION': ('Alive. File complete.: the freed leaders gather and Maren calls him Tessar. A warm chamber orchestra, each Path\'s colour '
                    'in turn, the whole lullaby gently resolved; room for the final lines.', STORY,
                    N + 'story direction - the whole lullaby allowed (after the reveal)'),
    'MUS-CREDITS': ('Many ways forward: the Crosspath theme, then each zone theme in turn (Gainlands, D.N.A., Buffet, Dump), then the Lullaby, '
                    'then the Crossroads motif resolved as a grand finale.', FINALE,
                    N + 'credits order per the designer; the whole lullaby allowed; resolved finale'),
    'MUS-LAB-EXP': ('The subject\'s corridors: fast clinical techno - driving kick, saw bass, arpeggiators, glitch stutters and pumped pads, with '
                    'cold string stabs; the Crossroads motif appears as a glitched synth lead. Original, no quotes.', LAB,
                    N + 'Lab direction - techno/EDM action, original'),
    'MUS-LAB-BATTLE': ('Experiments still running: relentless techno at battle tempo - risers and drops, distorted synth bass, stuttering leads, '
                       'brass and string hits; the Crossroads motif glitched in the lead.', LAB, N + 'Lab direction - techno/EDM action, original'),
    'MUS-SIPHON-BOSS': ('A life\'s work: Dr. Ambrose Siphon\'s own villain idea over the heaviest Lab techno - layered detuned leads, '
                        'orchestral stabs, a huge drop; the Crossroads motif dissected and glitched.', LAB,
                        N + 'Lab direction - own track (no longer an alias of MUS-LAB-BATTLE)'),
    'MUS-LAB-CELL': ('Ten years of marks: NOT techno. Very sparse orchestral piano, cello and celesta with small childlike intervals; sadness '
                     'held gently, ending in quiet hope.', STORY, N + 'Lab story beat - orchestral, tender, hopeful'),
    'MUS-LAB-RESCUE': ('The hand that helped: NOT techno. Warm woodwinds and strings complete the prologue\'s unfinished rescue phrase; guilt, '
                       'courage and relief together, the ending breathes.', STORY, N + 'Lab story beat - orchestral, tender, hopeful'),
    'MUS-LULLABY': ('Concordia\'s lullaby, the motif master: the existing melody (opening rising fifth, full resolution) kept note for note and '
                    're-orchestrated for strings, harp, celesta and solo woodwinds.', STORY,
                    N + 'motif master - melody kept, re-orchestrated only'),
    'MUS-MEM-01': ('Warmth: a lullaby-like memory - harp, celesta and flute over protective cello; tender recognition and a soft, hopeful '
                   'ending.', STORY, N + 'story direction - hopeful; lullaby rule: at most its first four notes'),
    'MUS-MEM-02': ('The cells: darker - separated notes, cold gaps, a low string line - but a human cello and the Crossroads motif lead it toward '
                   'warmth, and it ends with hope.', STORY, N + 'story direction - may be darker, ends with hope; lullaby head at most'),
    'MUS-MEM-03': ('The coup: a royal phrase interrupted by Primm\'s rigid pulse and tense low strings, thinning out for Maren\'s admission; '
                   'serious, but it ends with hope.', STORY, N + 'story direction - may be darker, ends with hope; lullaby head at most'),
    'MUS-MEM-04': ('His name: the lullaby comes into clear focus - piano, flute and warm strings state it whole for the first time in the '
                   'memories. Starts uncertain, ends hopeful.', STORY, N + 'story direction - the whole lullaby allowed (the reveal)'),
    'MUS-QUEST-PELL': ('Widow Pell, a burial permit: a humane D.N.A. waltz phrase finally moving toward rest; strings, harp and clarinet, warm '
                       'grief with room for tired humour.', STORY, N + 'story direction - hopeful; nods to the D.N.A. theme'),
    'MUS-QUEST-ROLLO': ('Rollo Spokes, the wheel never stops: an exhausted Gainlands march finds a freer, breathing phrase; soft horns and '
                        'strings, courage under breathless jokes.', STORY, N + 'story direction - hopeful; nods to the Gainlands theme'),
    'MUS-QUEST-MARLO': ('Chef Marlo, the recipe box: a warm woodwind melody struggles against a mechanical accompaniment, then remembers the '
                        'Buffet theme - a real recipe, real flavour.', STORY, N + 'story direction - hopeful; nods to the Buffet theme'),
    'MUS-QUEST-FERN': ('Old Fern, untidy: a gentle 6/8 with flute and harp against a clipped regulation pulse; the Dump jig grows through it and '
                       'the ending is earthy and warm.', STORY, N + 'story direction - hopeful; nods to the Dump theme'),
    'MUS-SHOP-SABLE': ('Sable\'s velvet salon: mystic and fun with a sly velvet twist - swung pizzicato bass, low clarinet, celesta and harp '
                       'glissandi; glamorous and curious, calm enough to browse.', SHOP, N + 'shop direction - mystic and fun; sly velvet'),
    'MUS-SHOP-TONIC': ('Tilly\'s bubbling apothecary: bubbly chaos - bouncing pizzicato, music box and xylophone bubbles, cheeky woodwind '
                       'answers and the odd surprising chord; never frantic.', SHOP, N + 'shop direction - mystic and fun; bubbly chaos'),
    'MUS-SHOP-BEETSWORTH': ('Assistant to the regional merchant: stiff-but-odd - a very correct bassoon and pizzicato march that takes itself '
                            'seriously, with small wrong turns; understated comedy, low fatigue.', SHOP,
                            N + 'shop direction - mystic and fun; stiff-but-odd'),
    'MUS-SHOP-THREADWELL': ('Pip\'s tiny runway: a runway strut in pizzicato and oboe, harp sweeps for each entrance, calm browsing between '
                            'the poses.', SHOP, N + 'shop direction - mystic and fun; runway strut'),
    'MUS-SHOP-FENWICK': ('Foil, whispered reverently: collector\'s wonder - celesta and harp sparkle over warm strings, little anticipatory '
                         'pauses; bigger reveals are saved for the pack stings.', SHOP, N + 'shop direction - mystic and fun; collector\'s wonder'),
    'MUS-SHOP-ALEMBIC': ('Essences together: calm mystic blending - two woodwind voices converse over harp and celesta, glassy and nurturing, '
                         'never frantic.', SHOP, N + 'shop direction - mystic and fun; calm mystic blending'),
    'MUS-SHOP-ALEMBIC-POST': ('Three essences, new possibilities: the alchemist\'s music with more colours - three and four voices in flowing '
                              'counterpoint, brighter (Lydian) and still gentle for crafting.', SHOP,
                              N + 'shop direction - mystic and fun; Alembic with more colours'),
    'MUS-SHOP-FIGSLY': ('Off the books: a sly back-alley shop in the Crease - hushed swung pizzicato, low clarinet, a wink of celesta and a '
                        'warm resistance phrase underneath.', SHOP, N + 'shop direction - mystic and fun; sly back-alley'),
    'MUS-SHOP-BELLOWS': ('Browsing the prizes: the showman at rest - a soft brass flourish, then long calm pizzicato and woodwind stretches '
                         'for choosing encounters; the spectacle is saved for the arena.', SHOP,
                         N + 'shop direction - mystic and fun; showman at rest'),
    'MUS-QUIZ': ('Questions in triplicate: a mystic-and-fun 3/4 with pizzicato, celesta and question-and-answer woodwinds, warm low strings, no '
                 'ticking countdown.', SHOP, N + 'shop/quiz direction - mystic and fun'),
    'MUS-VAULT-EXP': ('Forgotten Vault: ancient chamber mystery - low strings, celesta and harp, a ticking stone pulse and royal brass clues '
                      'around a quiet phrase (the lullaby\'s first notes at most); discovery brightens the middle.', VAULT,
                      N + 'side area - ancient, royal clues'),
    'MUS-VAULT-BATTLE': ('The vault awakens: a driving string and timpani ostinato in an ancient mode, royal brass calls and the Crossroads '
                         'motif in the horns.', VAULT, N + 'side area - ancient, royal clues'),
    'MUS-VAULT-BOSS': ('The Vault Guardian (and the Warden of the Four Seals): its own ancient, heavy theme in low brass and choir, four colours '
                       'for four seals, royal clues in the climax.', VAULT,
                       N + 'side area - own track (no longer an alias of MUS-VAULT-BATTLE)'),
    'MUS-GRAVE-EXP': ('Old Hob\'s evening hum: creepy-cheerful graveyard waltz - bassoon and a hummed oohs tune, pizzicato and xylophone '
                      'bones, misty but kindly.', GRAVE, N + 'side area - creepy-cheerful, Old Hob\'s hum'),
    'MUS-GRAVE-BATTLE': ('Something beneath the stones: the graveyard tune driven into low string ostinatos, dry percussion and restless '
                         'woodwind echoes; distinct from the D.N.A.', GRAVE, N + 'side area - creepy-cheerful, driven'),
    'MUS-ARENA-BATTLE': ('The Grand Clashatorium: showbiz spectacle - brass fanfares, rolling drums, a broad adventurous melody, with quieter '
                         'strategic passages for long duels.', ARENA, N + 'side area - showbiz spectacle, Grand Bellows'),
    'MUS-ARENA-ELITE': ('The championship card: the arena theme bigger - contrapuntal strings, stronger harmony, a climactic middle and a '
                        'showstopper finish.', ARENA, N + 'side area - showbiz spectacle, championship'),
    'MUS-SHIRO-BOSS': ('The oldest trick in the book: a theatrical trickster - pizzicato feints, piccolo flourishes, taiko and woodblock, an '
                       'overconfident pose that slips, and a sincere chase section.', SHIRO, N + 'side area - theatrical trickster'),
}

# Former aliases: keep the alias note until the own track is delivered (python tools/music/music_list_pass3.py --own <ID>).
PENDING_OWN = {"MUS-VAULT-BOSS", "MUS-TUNNEL-BOSS"}  # MUS-SIPHON-BOSS own since Part 3

# ---------------------------------------------------------------- descriptions of the rows done in passes 1-2 (approved directions)
EARLIER = {
    'MUS-TITLE': 'An incomplete royal phrase opens into the full adventurous orchestra (D minor to F major): the Crossroads motif stated, a '
                 'gentle middle, a broad return. Mysterious, welcoming and memorable.',
    'MUS-FOREST': 'Night forest in 6/8: sparse woodwinds over open fifths, harp and celesta glimmers, a hesitant plucked pulse; the Crossroads '
                  'motif half-heard. Suggests a journey beyond the trees.',
    'MUS-TOWN': 'Crosspath, roads converging (the approved v04/v05 sound): flute melody, piano broken chords, cello and pizzicato counterlines, '
                'modal colour and the Crossroads motif as the town\'s tune.',
    'MUS-TOWN-FREED': 'The town theme rearranged with a solo voice from every Path (brass, celesta/harpsichord, accordion/mandolin, fiddle) in '
                      'warm interlocking countermelodies; the Crossroads motif resolved.',
    'MUS-TOWN-BATTLE': 'The town pulse turned into controlled momentum: pizzicato ostinato, snare accents, woodwind answers and the Crossroads '
                       'motif in the horns. Never frantic.',
    'MUS-DECK': 'A low-intensity town variation for long card planning: piano, pizzicato, warm suspended string chords and an occasional '
                'questioning phrase.',
    'MUS-TUT-EXP': 'Soft mossy mystery: plucked echoes, breathy flute and low strings around the Crossroads motif; ancient, not threatening.',
    'MUS-TUT-BATTLE': 'A modest rhythmic lift of the cave music: string ostinato, horns on the motif, clear phrases and room to learn the rules.',
    'MUS-TUT-BOSS': 'The Hollow Warden: stone-like drums and dignified strings answer a small royal phrase; challenge and recognition, not '
                    'apocalypse.',
    'MUS-BEEF-EXP': 'The Gainlands: a heroic orchestral march in Bb - horns and trumpets on the Gainlands theme, snare and timpani footsteps, '
                    'reckless good humour (a xylophone joke or two).',
    'MUS-BEEF-BATTLE': 'The Gainlands march at battle tempo: driving string and timpani ostinato, the Gainlands theme in the brass, the '
                       'Crossroads motif answering.',
    'MUS-BEEF-DUN-EXP': 'House of Gains: exuberance turned into compulsory repetitions - low strings, gym-clank percussion, the Gainlands theme '
                        'in a stern minor, a quieter contrasting section.',
    'MUS-BEEF-DUN-BATTLE': 'House of Gains in combat: a low string drive, deeper percussion and the Gainlands theme hammered in the brass.',
    'MUS-BEEF-BOSS': 'Chancellor Clench: his own theme over a wheel ostinato, stern brass and constricted phrases; the Gainlands theme and the '
                     'Crossroads motif strain against him.',
    'MUS-BEEF-FREED': 'The Gainlands restored: the march swung and breathing, warm horns, strength shared willingly; the Crossroads motif '
                      'resolved.',
    'MUS-BEEF-RELEASE': 'Flex\'s rescue: the march loosens into a swung, warm cue; the Gainlands theme slowed into a sincere character moment '
                        'and the resolved motif under a held chord.',
    'MUS-GOUR-EXP': 'The Endless Buffet (the approved demo): an original Broadway-style showtune in F with modern EDM drops - strings, brass, '
                    'clarinet, tuba oom-pah, glockenspiel, then kick, claps and synth bass. Festive, never folk.',
    'MUS-GOUR-BATTLE': 'The Buffet showtune at battle tempo with an EDM drop section; the Buffet theme in the brass, the Crossroads motif as a '
                       'guest.',
    'MUS-GOUR-DUN-EXP': 'Test Kitchen: a clockwork ostinato on the grid, cold harmony, the Buffet theme correct but lifeless.',
    'MUS-GOUR-DUN-BATTLE': 'Test Kitchen in combat: an assembly-line drive, walking bass and a machine drop under the Buffet theme.',
    'MUS-GOUR-BOSS': 'The Doppelganger: the Buffet theme in a canon that drifts out of tune, the hero\'s motif mirrored, a darker middle for the '
                     'disguise.',
    'MUS-GOUR-FREED': 'The Buffet restored: the full festive showtune, F to G major, a real feast; the Crossroads motif resolved.',
    'MUS-GOUR-RELEASE': 'The true Chef: the Buffet theme slowed into a warm, generous character moment, a name freely given; the resolved motif '
                        'under a held chord.',
    'MUS-NECRO-EXP': 'The D.N.A. (the approved demo): a dark orchestral 3/4 waltz in C minor with organ, choir, low brass and a ticking '
                     'woodblock clock. People doing a job, quietly absurd delayed cadences - never horror.',
    'MUS-NECRO-BATTLE': 'The D.N.A. waltz driven into a fast scherzo-waltz: the theme in the brass over the ticking clock.',
    'MUS-NECRO-DUN-EXP': 'Hall of Final Approvals: unresolved phrases passed desk to desk, stamps, layered pizzicato and organ, with a humane '
                         'quiet section.',
    'MUS-NECRO-DUN-BATTLE': 'Hall of Final Approvals in combat: a walking bass, deeper percussion and the waltz theme pushed harder.',
    'MUS-NECRO-BOSS': 'Mortimer Grimsby: his own stamp theme on organ and low brass, the waltz theme forced into a limping 4/4; calm, immovable '
                      'procedure, no screaming villain.',
    'MUS-NECRO-FREED': 'The D.N.A. restored: the long-postponed waltz theme finally resolves, C then Eb major, warm organ, dry humour kept; the '
                       'Crossroads motif resolved.',
    'MUS-NECRO-RELEASE': 'Agnes, help people: the waltz theme slowed into a sincere, humane moment; the resolved motif and a calm held ending.',
    'MUS-REF-EXP': 'The Verdant Dump (the approved demo): orchestral fairy folk in E Dorian 6/8 - a fast solo-violin jig, nylon guitar, harp, '
                   'celesta, chimes, flute and tambourine.',
    'MUS-REF-BATTLE': 'The Dump at battle tempo: a fast reel with a driving fiddle, the jig theme and the Crossroads motif trading phrases.',
    'MUS-REF-DUN-EXP': 'The Rotheart: a cello drone under tangled figures, fairy glimmers fading, growth that feels wrong; rare clear glimpses.',
    'MUS-REF-DUN-BATTLE': 'The Rotheart in combat: tangled 6/8 ostinatos, deeper percussion, the jig in a darker mode.',
    'MUS-REF-BOSS': 'Compostella: a dark fairy tale - the jig in minor, roots and decay, a human fragment trapped in dense strings; grief rather '
                    'than horror.',
    'MUS-REF-FREED': 'The Dump restored: spring returning - the jig in E major, chimes and harp, clear flute; the Crossroads motif resolved.',
    'MUS-REF-RELEASE': 'Compostella, let the seed return: the jig slowed into a sincere moment, flute and harp; the ending accepts loss, the motif '
                       'resolved.',
    'MUS-SWOLY-EXP': 'Mount Swolympus: a lone flute on the wind over stone drums, the Gainlands theme climbing in the horns, a broad summit vista.',
    'MUS-SWOLY-BATTLE': 'Mount Swolympus in combat: a climbing string ostinato under the Gainlands theme in C minor, brass calls answered.',
    'MUS-SWOLY-BOSS': 'The Ancient Spotter: his own hammered theme in trombones and tuba, the Gainlands theme in D minor and the hero\'s motif '
                      'over the count in the climax.',
    'MUS-OMAKASE-EXP': 'Omakase: exactness inside the Buffet showtune palette - restrained pizzicato, woodwind breaths, precise percussion and '
                       'koto/shakuhachi colour around the Buffet theme.',
    'MUS-OMAKASE-BATTLE': 'Omakase in combat: three escalating courses, the Buffet theme sharpened, precise percussion and an EDM edge.',
    'MUS-OMAKASE-BOSS': 'The Itamae Supreme: his own exacting theme against the Buffet theme, tension through precision, a full drop at the '
                        'climax.',
    'MUS-WAIT-EXP': 'Waiting Room of Eternity: a pleasant 3/4 waiting-room tune with discreet organ, an endlessly promised cadence and the '
                    'D.N.A. clock.',
    'MUS-WAIT-BATTLE': 'The waiting room in combat: the D.N.A. waltz driven, measured bass and crisp ticks.',
    'MUS-WAIT-BOSS': 'Betty Bones: her own theme over the waltz in Eb minor, organ and low brass, the cadence that never comes.',
    'MUS-PANDA-EXP': 'Trash Panda Throne: a swaggering fairy-folk procession, bottle-cap percussion and a nervous regal flourish on the Dump '
                     'theme; a chase section.',
    'MUS-PANDA-BATTLE': 'Trash Panda Throne in combat: the Dump jig driven with fiddle and tambourine, two contrasting phrases.',
    'MUS-PANDA-BOSS': 'His Majesty the Raccoon: a pompous scrap-heap royal theme against the Dump jig, the hero\'s motif in the climax.',
    'MUS-CAP-BEEF-BROKEN': 'Transit Yards, broken service: the Gainlands theme played thin and interrupted, a shadow horn ~15 cents flat, '
                           'missing beats, a faint rift pad.',
    'MUS-CAP-BEEF-RESTORED': 'Transit Yards, service returns: the Gainlands theme whole and in tune, the stiff Capital grid still underneath; '
                             'the motif resolved.',
    'MUS-CAP-GOUR-BROKEN': 'Hungry Quarter, broken service: the Buffet theme hollow and interrupted, a celesta ~15 cents flat, cold harmony.',
    'MUS-CAP-GOUR-RESTORED': 'Hungry Quarter, service returns: the Buffet theme warm and complete, kitchens feeding people; the motif resolved.',
    'MUS-CAP-NECRO-BROKEN': 'Grave Row, broken service: the D.N.A. theme thin and cut off, a second celesta ~15 cents flat, a clock that stalls.',
    'MUS-CAP-NECRO-RESTORED': 'Grave Row, service returns: the D.N.A. theme complete in C major, calm graves and humane resolution; the motif '
                              'resolved.',
    'MUS-CAP-REF-BROKEN': 'The Reek, broken service: the Dump jig cluttered and interrupted, the lead fiddle ~15 cents flat against an in-tune '
                          'violin.',
    'MUS-CAP-REF-RESTORED': 'The Reek, service returns: the Dump jig clear and breathing, flowers and honest compost; the motif resolved.',
    'MUS-MAREN': 'Maren, pie and secrets: clarinet, bassoon and cello with a gentle piano figure in 3/4; warm questions that do not resolve too '
                 'quickly.',
    'MUS-SHOP-BENCHLEY': 'The gym pro shop: a relaxed Gainlands groove - acoustic bass, brushes, horn and clarinet on the Gainlands theme, a '
                         'xylophone wink; motivational bounce, calm enough to browse.',
    'MUS-SHOP-LEDGERBONE': 'A correctly completed form: a miniature D.N.A. waltz with dry ticks, gentle organ and woodwinds, and a surprisingly '
                           'pleasing completed cadence.',
    'MUS-SHOP-MIREPOIX': 'Under the silver cloche: an intimate Buffet showtune arrangement in piano, pizzicato and refined woodwinds; formal, '
                         'then welcoming.',
    'MUS-SHOP-GRISTLE': 'Found, not stolen: a relaxed porch-side Dump jig in pizzicato, nylon guitar and flute, with little raccoon '
                        'counterphrases.',
    'MUS-MINIGAME-BEEF': 'Chet\'s revolutionary routine: a playful four-on-the-floor march groove, trumpet count-ins, the Gainlands theme and a '
                         'restrained retro synth wink.',
    'MUS-MINIGAME-NECRO': 'Kyle\'s memory matching: light 3/4 pizzicato and woodwind puzzle music on the D.N.A. theme, soft organ, a gently '
                          'unresolved cadence.',
    'MUS-MINIGAME-GOUR': 'Flambe\'s cooking show: the Buffet showtune as a TV cooking segment, precise and theatrical, kitchen percussion.',
    'MUS-MINIGAME-REF': 'Rhonda\'s sorting ribbons: a nimble Dump jig loop in pluck and flute, light hand drums and a county-fair banjo.',
    'STG-VICTORY': 'Battle won (~4 s): a timpani roll and string run, brass and strings sing the Crossroads motif\'s resolved tail, cymbal and a '
                   'held major chord.',
    'STG-DEFEAT': 'A setback, not the end: a brief descending woodwind and cello phrase that ends gently and leaves hope for the retry.',
    'STG-LEVEL': 'A little stronger: a rising pizzicato/harp figure answered by a warm orchestral chord.',
    'STG-QUEST': 'A promise kept: a compact woodwind cadence with a warm string response; understated and reusable.',
    'STG-DUNGEON': 'The way through: a broader victory cadence in strings and horns, ending cleanly.',
    'STG-ZONE-BEEF': 'The wheels breathe again: the Gainlands theme in warm brass with a snare flourish and the resolved motif tail.',
    'STG-ZONE-GOUR': 'A meal worth sharing: a showtune button on the Buffet theme ending with a kick, the resolved motif tail.',
    'STG-ZONE-NECRO': 'Approved: humanity - the D.N.A. cadence finally completed on organ in C major, the resolved motif tail.',
    'STG-ZONE-REF': 'Back to the soil: the Dump jig on fiddle with chimes, released into a warm resolved chord.',
    'STG-PACK-COMMON': 'A new possibility: a small celesta/harp sparkle with a clean resolution.',
    'STG-PACK-RARE': 'Something special: a richer rising figure and a warm suspended-to-resolved chord.',
    'STG-PACK-LEGEND': 'A legend in your hands: a grand rising figure opening into full strings, brass and choir.',
    'STG-CRAFT': 'Two Paths, one new card: two contrasting gestures answer and join in one chord.',
    'STG-CRAFT-POST': 'More than two: three short phrases combine and resolve together.',
    'STG-SECRET': 'An unexpected way: an upward woodwind question answered by a soft plucked sparkle.',
    'STG-PURCHASE': 'A good bargain: a tiny plucked two-note resolution, soft enough for frequent use.',
    'STG-ARENA': 'Grand Bellows presents: a brief horn-and-drum showbiz flourish.',
    'STG-SHIRO': 'Smoke bomb!: a smug rising pizzicato flourish that steps sideways into a cheeky woodwind cadence.',
    'STG-MINI-SUCCESS': 'Correctly sorted: two light notes resolving upward.',
    'STG-MINI-FAIL': 'Try another approach: a small descending woodwind phrase, kind rather than punitive.',
    'STG-RIFT': 'The seam closes: brief glassy instability settling into a warm string and harp chord.',
}


def load():
    raw = open(PATH, 'rb').read().decode('utf-8')
    return list(csv.reader(io.StringIO(raw)))


def save(rows):
    out = io.StringIO()
    csv.writer(out, lineterminator='\n').writerows(rows)
    open(PATH, 'wb').write(out.getvalue().rstrip('\n').encode('utf-8'))


def main():
    rows = load()
    by_id = {r[0]: r for r in rows if r and r[0].startswith(('MUS-', 'STG-'))}
    if len(sys.argv) > 2 and sys.argv[1] == '--own':
        for id in sys.argv[2:]:
            by_id[id][COL_NOTES] = PASS3[id][2]
            print('own track:', id)
        save(rows)
        return
    missing = [k for k in list(PASS3) + list(EARLIER) if k not in by_id]
    if missing:
        raise SystemExit(f'not in music_list: {missing}')
    for id, (desc, pal, notes) in PASS3.items():
        r = by_id[id]
        r[COL_DESC], r[COL_PAL] = desc, pal
        if id not in PENDING_OWN:
            r[COL_NOTES] = notes
    for id, desc in EARLIER.items():
        by_id[id][COL_DESC] = desc
    untouched = [k for k in by_id if k not in PASS3 and k not in EARLIER]
    save(rows)
    print(f'{len(PASS3)} Pass 3 rows (palette/description/notes), {len(EARLIER)} earlier descriptions; untouched: {untouched}')


if __name__ == '__main__':
    main()
