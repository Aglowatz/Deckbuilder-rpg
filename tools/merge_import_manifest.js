// The art importers rewrite their import manifest (<ID>,file,bytes,md5) with only the files of THIS run's source folder. When a run used a
// narrowed source (a staging folder with just the new files), merge HEAD's rows back: rows of this run win, the rest come from HEAD, sorted by ID.
// Run: node tools/merge_import_manifest.js data/source/key_art_import_manifest.csv [more manifests]
const fs = require("fs");
const { execSync } = require("child_process");
for (const file of process.argv.slice(2)) {
	const head = execSync(`git show HEAD:${file}`).toString().split(/\r?\n/).filter(Boolean);
	const now = fs.readFileSync(file, "utf8").split(/\r?\n/).filter(Boolean);
	const rows = new Map();
	for (const line of head.slice(1)) rows.set(line.split(",")[0], line);
	for (const line of now.slice(1)) rows.set(line.split(",")[0], line);
	const ids = [...rows.keys()].sort();
	fs.writeFileSync(file, [head[0], ...ids.map((id) => rows.get(id))].join("\n") + "\n");
	console.log(`${file}: ${ids.length} rows (${now.length - 1} from this run)`);
}
