// Nov 13: builds a blind old/new reading sample for a no-context critic from the tier ledgers of a rewrite pass.
//   node tools/dialogue_blind_sample.js --prefix=docs/dialogue/rewrite_nov13_t --out=docs/review/dialogue_nov13 [--per=10] [--seed=13]
// Writes <out>/sample.md (40 conversations by default: 10 from each tier; tier 4 = barks; each shown as Version A and Version B in a
// random order, no hint which is older) and <out>/key.json (which version is the new one). A conversation is every changed line of one
// key or scene; conversations with at least 3 changed lines are preferred for tiers 1-3.
const fs = require('fs');
const path = require('path');
const { root } = require('./dialogue_ids');
const args = Object.fromEntries(process.argv.slice(2).map((a) => { const m = a.match(/^--([a-z-]+)(?:=(.*))?$/); return m ? [m[1], m[2] ?? true] : [a, true]; }));
const per = Number(args.per || 10);
let seed = Number(args.seed || 13);
const rnd = () => { seed = (seed * 1103515245 + 12345) % 2147483648; return seed / 2147483648; };
const prefix = path.resolve(root, args.prefix);
const dir = path.dirname(prefix), start = path.basename(prefix);
const tiers = { 1: [], 2: [], 3: [], 4: [] };
for (const name of fs.readdirSync(dir).sort()) {
	const ledger = path.join(dir, name, 'applied_ledger.json');
	if (!name.startsWith(start) || !fs.existsSync(ledger)) continue;
	const tier = Number(name.slice(start.length)[0]);
	for (const e of JSON.parse(fs.readFileSync(ledger, 'utf8'))) if (!e.reverted && tiers[tier]) tiers[tier].push(e);
}
// group: scenes by scene name, npc keys by "intro/return" family, everything else by key
const groupOf = (id) => {
	const [file, key] = id.split('::');
	const scene = key.match(/^scenes\/([^/]+)\//);
	if (scene) return `${file}::scene ${scene[1].replace(/_(after|first|freed)$/, '')}`;
	if (file.endsWith('npcs.json')) return `${file}::${key}`;
	return `${file}::${key.replace(/\.(offer|active|ready|done|intro|return|before|after|first|freed|\d+)(\.freed)?$/, '')}`;
};
const out = [], key = {};
let n = 0;
for (const tier of [1, 2, 3, 4]) {
	const groups = new Map();
	for (const e of tiers[tier]) {
		if (tier === 4 && !e.id.includes('npcs.json')) continue;
		const g = groupOf(e.id);
		if (!groups.has(g)) groups.set(g, []);
		groups.get(g).push(e);
	}
	let list = [...groups.entries()].filter(([, l]) => tier === 4 ? l.length >= 1 : l.length >= 3 && l.length <= 9);
	list = list.map((x) => [rnd(), x]).sort((a, b) => a[0] - b[0]).map((x) => x[1]).slice(0, per);
	for (const [g, lines] of list) {
		n++;
		const newIsA = rnd() < 0.5;
		key[n] = { tier, group: g, new: newIsA ? 'A' : 'B', ids: lines.map((l) => l.id) };
		const speaker = [...new Set(lines.map((l) => l.speaker).filter(Boolean))].join(' / ');
		out.push(`## Conversation ${n}`, '', `Speaker(s): ${speaker || '(narration)'}${tier === 4 ? ' (speech bubbles heard in passing)' : ''}`, '');
		for (const v of ['A', 'B']) {
			out.push(`**Version ${v}**`, '');
			for (const l of lines) out.push(`- ${(v === 'A') === newIsA ? l.after : l.before}`);
			out.push('');
		}
	}
}
const outDir = path.resolve(root, args.out);
fs.mkdirSync(outDir, { recursive: true });
fs.writeFileSync(path.join(outDir, 'sample.md'), `# Dialogue sample: ${n} conversations, two versions each\n\nEach conversation below is shown in two versions, A and B. The lines of a version are in the order a player hears them. \`{villain}\`, \`{town}\` and the like are name slots the game fills in.\n\n` + out.join('\n'));
fs.writeFileSync(path.join(outDir, 'key.json'), JSON.stringify(key, null, '\t') + '\n');
console.log(`${n} conversations -> ${path.join(args.out, 'sample.md')}`);
