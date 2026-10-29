// Art import Oct 29, Part 3: the sky-transparent backdrop strips of art batches 5-9 as kit_cards in data/art/zone_looks.json (WorldScenery
// _build_kit_card: {id, angle from north in degrees, width in degrees, ring 0 near / 1 hills / 2 mountains, distance (share of the ring's
// radius), lift}). Idempotent: every mood's entries with these ids, or the ids they replace, are rewritten. Run: node tools/kit_looks_oct29.js
const fs = require('fs');
const path = require('path');
const FILE = path.join(__dirname, '..', 'data', 'art', 'zone_looks.json');
const card = (id, angle, width, ring, distance, lift = 0) => ({ id, angle, width, ring, distance, lift });
// mood -> { replace: ids whose old entries go, add: new entries }
const PLAN = {
	// the ridge with five torches above the treeline north of the clearing (the pursuers Elowen talks about)
	start: { replace: [], add: [card('OF-BD-TORCHLINE', 352, 70, 0, 0.4, 16)] },
	// the Capital's white castle far north and the zones' silhouettes on the skyline (one strip: the castle is its middle)
	town: { replace: [], add: [card('TOWN-BD-HORIZON', 0, 72, 2, 0.9)] },
	// the House of Gains on the north rim, in front of the mesas
	gainlands: { replace: [], add: [card('GAIN-BD-HOUSE-OF-GAINS', 0, 46, 1, 0.9)] },
	// the Hall of Final Approvals' facade north, in front of the filing-tower ring
	dna: { replace: [], add: [card('DNA-BD-HALL-FACADE', 0, 50, 0, 0.62)] },
	// the cake cathedral skyline and the Test Kitchen's factory roofs replace the old blurry cake strip
	buffet: { replace: ['BUFF-BD-CAKE'], add: [card('BUFF-BD-CAKE-CATHEDRAL', 300, 58, 2, 0.95), card('BUFF-BD-TEST-KITCHEN', 0, 58, 2, 0.95), card('BUFF-BD-CAKE-CATHEDRAL', 60, 58, 2, 0.95)] },
	// the Rotheart over the far ravine wall, north (replaces the valley strip there; DUMP-BD-ROTHEART with its baked sky stays unused)
	heap: { replace: [], replaceAt: [['DUMP-BD-VALLEY', 0]], add: [card('DUMP-BD-ROTHEART-SKY', 0, 66, 2, 0.95)] },
	// outside: the great white wall runs on along the skyline either side of the real wall
	capital_outskirts: { replace: [], add: [card('CAPI-BD-GREAT-WALL', 315, 56, 2, 0.93), card('CAPI-BD-GREAT-WALL', 45, 56, 2, 0.93)] },
	// inside: the castle on its hill at the end of the palace approach
	capital_inside: { replace: [], add: [card('CAPI-BD-CASTLE', 0, 44, 1, 0.9)] },
};
const looks = JSON.parse(fs.readFileSync(FILE, 'utf8'));
for (const [mood, plan] of Object.entries(PLAN)) {
	const scenery = (looks[mood].scenery = looks[mood].scenery || {});
	const newIds = plan.add.map((c) => c.id);
	let cards = (scenery.kit_cards || []).filter((c) => !newIds.includes(c.id) && !plan.replace.includes(c.id));
	for (const [id, angle] of plan.replaceAt || []) cards = cards.filter((c) => !(c.id === id && c.angle === angle));
	scenery.kit_cards = cards.concat(plan.add);
	console.log(`${mood}: ${scenery.kit_cards.map((c) => `${c.id}@${c.angle}`).join(', ')}`);
}
fs.writeFileSync(FILE, JSON.stringify(looks, null, '\t') + '\n');
