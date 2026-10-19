// Overnight Oct 18, Part 5: who speaks how much. Approximate line counts per speaking character, from the story .tres files (keys whose
// name carries the character's key word), the NPC barks in data/npcs/npcs.json and tools/npc_truth_input.json, and the portrait
// expressions that exist today in assets/art/portraits. Prints JSON to stdout. Usage: node tools/dialogue_audit.js > _logs/dialogue_audit.json
const fs = require('fs');
const path = require('path');
const root = path.join(__dirname, '..');
const npcs = JSON.parse(fs.readFileSync(path.join(root, 'data/npcs/npcs.json'), 'utf8'));
const portraits = fs.readdirSync(path.join(root, 'assets/art/portraits')).filter((f) => f.endsWith('.webp')).map((f) => f.replace('.webp', ''));

// Key words that name each character in dialogue keys (beyond the id suffix).
const EXTRA = {
	'NPC-PLAYER': ['wanderer', 'awakening', 'self', 'memory', 'hero'], 'NPC-ELDER': ['elder', 'maren', 'memory', 'cave_mouth'],
	'NPC-GATEKEEPER': ['guard', 'gatekeeper', 'brannoch'], 'V-SABLE': ['card_vendor', 'sable', 'town.vendor'], 'V-TONIC': ['item_vendor', 'tonic', 'tilly'],
	'V-BEETSWORTH': ['equipment_vendor', 'beetsworth', 'bertram', 'armory'], 'V-THREADWELL': ['tailor', 'threadwell'], 'V-FENWICK': ['pack_vendor', 'fenwick', 'pack.vendor'],
	'V-ALEMBIC': ['alchemist', 'alembic'], 'NPC-BELLOWS': ['arena', 'bellows'], 'NPC-HOB': ['graveyard', 'hob'], 'NPC-BRONSON': ['beefcake_npc', 'gate.beefcake', 'bronson'],
	'NPC-PALLOR': ['necrocrat_npc', 'gate.necrocrat', 'pallor'], 'NPC-GRAVOIS': ['gourmand_npc', 'gate.gourmand', 'gravois'], 'NPC-MULLIGAN': ['refusemancer_npc', 'gate.refusemancer', 'mulligan'],
	'NPC-ELOWEN': ['rescuer', 'elowen'], 'NPC-WARDEN': ['tutorial.warden', 'hollow_warden'], 'NPC-RIP': ['travel.rip', 'portal'], 'NPC-HURL': ['throw', 'hurl'],
	'NPC-PRIMM': ['primm', 'villain'], 'NPC-NINJA': ['ninja', 'shiro', 'oldest_trick'], 'NPC-AUTOMATON': ['vault'], 'NPC-SPOTLESS': ['spotless'],
};

function stringsIn(text) {
	// Returns [{key, count}] for every "key": [ "..", ".." ] array in a .tres dictionary, plus @export arrays (name = [..]).
	const out = [];
	const re = /"([A-Za-z0-9_.:-]+)":\s*\[((?:[^\]"]|"(?:[^"\\]|\\.)*")*)\]/g;
	let m;
	while ((m = re.exec(text))) out.push({ key: m[1].toLowerCase(), count: (m[2].match(/"(?:[^"\\]|\\.)*"/g) || []).length });
	const re2 = /^([a-z_]+_lines) = Array\[String\]\(\[((?:[^\]"]|"(?:[^"\\]|\\.)*")*)\]\)/gm;
	while ((m = re2.exec(text))) out.push({ key: m[1], count: (m[2].match(/"(?:[^"\\]|\\.)*"/g) || []).length });
	return out;
}

const arrays = [];
for (const f of fs.readdirSync(path.join(root, 'data/story'))) {
	if (!f.endsWith('.tres')) continue;
	for (const a of stringsIn(fs.readFileSync(path.join(root, 'data/story', f), 'utf8'))) arrays.push({ file: f, ...a });
}

const result = [];
for (const n of npcs) {
	const words = [n.id.replace(/^(NPC|V)-/, '').toLowerCase(), ...(EXTRA[n.id] || [])];
	let lines = 0;
	for (const a of arrays) if (words.some((w) => a.key.includes(w))) lines += a.count;
	const barks = (n.barks || []).length;
	const have = portraits.filter((p) => p === n.portrait_id || p.startsWith(n.portrait_id + '_')).map((p) => (p === n.portrait_id ? 'BASE' : p.slice(n.portrait_id.length + 1)));
	result.push({ id: n.id, name: n.name, role: n.role, location: n.location, lines, barks, planned: n.expressions || [], have, portrait_status: n.portrait_status, species: n.species || n.species_type });
}
result.sort((a, b) => b.lines + b.barks - (a.lines + a.barks));
console.log(JSON.stringify(result, null, 1));
