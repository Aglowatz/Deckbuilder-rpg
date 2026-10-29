// Art import Oct 29, Part 3: the kit sheet rows of the art batches 5-9 zone pieces (rows of docs/art/art_batch_oct28.csv), added to
// data/source/<zone>_kit.csv so "import zone kit <zone>" picks them up. Creates the two new sheets (openingforest, town) with the standard
// head rows. Idempotent: a row whose ID is already in its sheet is left alone. Run: node tools/kit_rows_oct29.js
const fs = require('fs');
const path = require('path');
const ROOT = path.join(__dirname, '..');
const HEAD = (zone) => [
	`STYLE TARGET,"Match the approved ${zone} art and the painted storybook look of the game (docs/art/art_direction_oct28.md)."`,
	'SURFACE LOCK,"See data/source/heap_kit.csv (the same locks for every zone kit)."',
	'CUTOUT LOCK,"See data/source/heap_kit.csv."',
	'SHEET LOCK,"See data/source/heap_kit.csv."',
	'TREE LOCK,"See data/source/heap_kit.csv."',
	'CONCEPT / BACKDROP LOCK,"See data/source/heap_kit.csv."',
	`HOW IT WORKS,"Created on 2026-10-29 (art import Oct 29) from the rows of docs/art/art_batch_oct28.csv; the descriptions live there."`,
	',,,,,,,,',
	'ID,Asset,Category,Lock,Image Description (paste STYLE TARGET + the Lock first),Size / Format,In-Game Use,Priority,Status',
];
// [sheet, ID, asset, category, lock, size, use]
const ROWS = [
	['openingforest', 'OF-HERO-CAVE-MOUTH', 'The Forgotten Cave mouth', 'Hero landmark', 'CUTOUT', '2048x2048 PNG, transparent', 'The clearing, the cave entrance spot'],
	['openingforest', 'OF-BD-TORCHLINE', 'Torch-line ridge', 'Sky / backdrop', 'BACKDROP', '2048x1024 PNG strip, transparent sky', 'The clearing\'s far treeline'],
	['openingforest', 'OF-TREE-GIANT-01', 'Giant mossy tree 1', 'Tree', 'TREE', '1024x1536 PNG, transparent', 'The clearing edge'],
	['openingforest', 'OF-TREE-GIANT-02', 'Giant mossy tree 2', 'Tree', 'TREE', '1024x1536 PNG, transparent', 'The clearing edge'],
	['openingforest', 'OF-TREE-GIANT-03', 'Giant mossy tree 3', 'Tree', 'TREE', '1024x1536 PNG, transparent', 'The clearing edge'],
	['openingforest', 'OF-PROP-LAB-HATCH', 'The Lab hatch', 'Prop', 'CUTOUT', '1024x1024 PNG, transparent', 'The clearing, after Rip reveals it (postgame)'],
	['town', 'TOWN-BD-HORIZON', 'Crosspath horizon', 'Sky / backdrop', 'BACKDROP', '2048x1024 PNG strip, transparent sky', 'Crosspath, the skyline ring'],
	['town', 'TOWN-HERO-FOUNTAIN', 'Royal-crest fountain', 'Hero landmark', 'CUTOUT', '2048x2048 PNG, transparent', 'The square'],
	['town', 'TOWN-SHEET-FREED-BANNERS', 'Freed-zone banners', 'Cutout sheet', 'SHEET', '2048x1365 PNG, transparent', 'Hung on the square after each freed zone'],
	['gainlands', 'GAIN-BD-HOUSE-OF-GAINS', 'House of Gains facade', 'Sky / backdrop', 'BACKDROP', '2048x1024 PNG strip, transparent sky', 'The Gainlands skyline, north'],
	['gainlands', 'GAIN-HERO-HAMSTER-WHEEL', 'Colossal Hamster Wheel', 'Hero landmark', 'CUTOUT', '2048x2048 PNG, transparent', 'Mill Fields'],
	['gainlands', 'GAIN-SHEET-FLOATING-ISLANDS', 'Floating islands', 'Cutout sheet', 'SHEET', '2048x1365 PNG, transparent', 'Delt Deck, Calf Cove, Pec Perch'],
	['gainlands', 'GAIN-DEC-REGIME-POSTERS', 'Regime posters', 'Cutout sheet', 'SHEET', '2048x1365 PNG, transparent', 'Walls and wheel frames'],
	['dna', 'DNA-BD-HALL-FACADE', 'Hall of Final Approvals facade', 'Sky / backdrop', 'BACKDROP', '2048x1024 PNG strip, transparent sky', 'The D.N.A. skyline'],
	['dna', 'DNA-SHEET-FILING-TOWERS', 'Filing-cabinet towers', 'Cutout sheet', 'SHEET', '2048x1365 PNG, transparent', 'Cubicle Fields, the Queue'],
	['dna', 'DNA-SHEET-GHOST-QUEUE', 'Queue of ghosts', 'Cutout sheet', 'SHEET', '2048x1365 PNG, transparent', 'The Queue, the lobby'],
	['dna', 'DNA-SHEET-PROPS', 'Ghost lamps and dead topiary', 'Cutout sheet', 'SHEET', '2048x1365 PNG, transparent', 'Lobby Plaza, Executive Approach'],
	['dna', 'DNA-DEC-FORMS', 'Forms and stamps', 'Cutout sheet', 'SHEET', '2048x1365 PNG, transparent', 'Walls, floors'],
	['buffet', 'BUFF-BD-CAKE-CATHEDRAL', 'Cake cathedral skyline', 'Sky / backdrop', 'BACKDROP', '2048x1024 PNG strip, transparent sky', 'The Buffet skyline'],
	['buffet', 'BUFF-BD-TEST-KITCHEN', 'Test Kitchen facade', 'Sky / backdrop', 'BACKDROP', '2048x1024 PNG strip, transparent sky', 'The far end of the zone'],
	['buffet', 'BUFF-SHEET-TASTING-STANDS', 'Tasting stands', 'Cutout sheet', 'SHEET', '2048x1365 PNG, transparent', 'The Grand Pantry approach'],
	['buffet', 'BUFF-DEC-ROSETTES', 'Crumb\'s rosettes', 'Cutout sheet', 'SHEET', '2048x1365 PNG, transparent', 'Walls'],
	['heap', 'DUMP-BD-ROTHEART-SKY', 'Rotheart with a transparent sky', 'Sky / backdrop', 'BACKDROP', '2048x1024 PNG strip, transparent sky', 'The far ravine wall (horizon band)'],
	['heap', 'DUMP-HERO-THRONE-DUMPSTER', 'Throne dumpster', 'Hero landmark', 'CUTOUT', '2048x1536 PNG, transparent', 'The Throne Approach'],
	['heap', 'DUMP-SHEET-ENTRANCE-FLAGS', 'Entrance pennants', 'Cutout sheet', 'SHEET', '2048x1365 PNG, transparent', 'The entrance bridge posts'],
	['heap', 'DUMP-DEC-CORRUPTION', 'Corruption decals', 'Cutout sheet', 'SHEET', '2048x1365 PNG, transparent', 'The Throne Approach, the Overgrown Plateau'],
	['capital', 'CAPI-BD-GREAT-WALL', 'The great white wall', 'Sky / backdrop', 'BACKDROP', '2048x1024 PNG strip, transparent sky', 'Outside the Capital, the skyline'],
	['capital', 'CAPI-BD-CASTLE', 'The castle on its hill', 'Sky / backdrop', 'BACKDROP', '2048x1024 PNG strip, transparent sky', 'Inside the wall, the palace approach skyline'],
	['capital', 'CAPI-DEC-LOST-PROPERTY', 'Lost-property posters', 'Cutout sheet', 'SHEET', '2048x1365 PNG, transparent', 'Walls inside and outside'],
	['capital', 'CAPI-SHEET-RIFTS', 'Rifts', 'Cutout sheet', 'SHEET', '2048x1365 PNG, transparent', 'The Rift Fields, the Transit Yards'],
	['capital', 'CAPI-PROP-PRIMM-STATUE', 'Gold Primm statue', 'Prop', 'CUTOUT', '1024x1536 PNG, transparent', 'The Showcase Quarter'],
	['capital', 'CAPI-PROP-STATUE-FALLEN', 'Fallen Primm statue', 'Prop', 'CUTOUT', '2048x1024 PNG, transparent', 'The Showcase Quarter after Primm falls'],
];
// The junk mountain redo (same ID) is a painted cut-out now, not a concept reference.
const LOCK_CHANGES = [['heap', 'DUMP-HERO-JUNK-MOUNTAIN', 'CONCEPT', 'CUTOUT']];

const sheets = {};
for (const row of ROWS) (sheets[row[0]] = sheets[row[0]] || []).push(row);
for (const [sheet, rows] of Object.entries(sheets)) {
	const file = path.join(ROOT, 'data', 'source', `${sheet}_kit.csv`);
	let text = fs.existsSync(file) ? fs.readFileSync(file, 'utf8') : HEAD(sheet).join('\n') + '\n';
	const nl = text.includes('\r\n') ? '\r\n' : '\n';
	if (!text.endsWith(nl)) text += nl;
	let added = 0;
	for (const r of rows) {
		if (text.split(/\r?\n/).some((l) => l.startsWith(r[1] + ','))) continue;
		text += [r[1], `"${r[2]}"`, r[3], r[4], '"See docs/art/art_batch_oct28.csv (art import Oct 29)."', `"${r[5]}"`, `"${r[6]}"`, '2', 'Approved'].join(',') + nl;
		added++;
	}
	fs.writeFileSync(file, text);
	console.log(`${sheet}_kit.csv: +${added}`);
}
for (const [sheet, id, from, to] of LOCK_CHANGES) {
	const file = path.join(ROOT, 'data', 'source', `${sheet}_kit.csv`);
	const lines = fs.readFileSync(file, 'utf8').split('\n');
	for (let i = 0; i < lines.length; i++) {
		if (!lines[i].startsWith(id + ',')) continue;
		const marker = `,${from},`;
		const at = lines[i].indexOf(marker);
		if (at >= 0) { lines[i] = lines[i].slice(0, at) + `,${to},` + lines[i].slice(at + marker.length); console.log(`${id}: ${from} -> ${to}`); }
	}
	fs.writeFileSync(file, lines.join('\n'));
}
