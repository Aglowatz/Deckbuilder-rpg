// Overnight Oct 22, Part 1: summarises balance-sim reports (docs/design/sim/*.md tables) by kind - fights, in band, too hard, too easy,
// mean win rate and turns - for the before/after table in balance_log.md.
// Usage: node tools/sim_summary.js <report.md> [more.md ...]   (rows with the same encounter title: the later file wins)
const fs = require('fs');
const rows = new Map();
for (const file of process.argv.slice(2)) {
	for (const line of fs.readFileSync(file, 'utf8').split(/\r?\n/)) {
		if (!line.startsWith('| ') || line.startsWith('| Encounter') || line.startsWith('|---')) continue;
		const c = line.split('|').map((x) => x.trim());
		const title = c[1];
		const kind = c[2];
		const all = parseFloat(c[9].replace(/\*|%/g, ''));
		const turns = parseFloat(c[10]);
		const verdict = c[12] || '';
		if (Number.isNaN(all)) continue;
		rows.set(title, { kind, all, turns, verdict });
	}
}
const kinds = ['Tutorial', 'Normal', 'Elite', 'Boss'];
console.log('| Kind | Fights | In band | Too hard | Too easy | Mean win | Mean turns |');
console.log('|---|---:|---:|---:|---:|---:|---:|');
for (const kind of kinds) {
	const list = [...rows.values()].filter((r) => r.kind === kind);
	if (!list.length) continue;
	const hard = list.filter((r) => r.verdict.startsWith('TOO HARD')).length;
	const easy = list.filter((r) => r.verdict.startsWith('too easy')).length;
	const mean = list.reduce((a, r) => a + r.all, 0) / list.length;
	const turns = list.reduce((a, r) => a + r.turns, 0) / list.length;
	console.log(`| ${kind} | ${list.length} | ${list.length - hard - easy} | ${hard} | ${easy} | ${mean.toFixed(0)}% | ${turns.toFixed(1)} |`);
}
