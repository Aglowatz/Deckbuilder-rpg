// The art importers rewrite their import manifest (<ID>,file,bytes,md5) with only the files of THIS run's source folder. When a run used a
// narrowed source (a staging folder with just the new files), merge HEAD's rows back: rows of this run win, in HEAD's order; new IDs go after them.
// Run: node tools/merge_import_manifest.js data/source/key_art_import_manifest.csv [more manifests]
const fs = require("fs");
const { execSync } = require("child_process");
for (const file of process.argv.slice(2)) {
	const head = execSync(`git show HEAD:${file}`).toString().split(/\r?\n/).filter(Boolean);
	const now = fs.readFileSync(file, "utf8").split(/\r?\n/).filter(Boolean);
	// a row this run wrote as MISSING (its file was not in the narrowed source; the texture manifest does this) keeps HEAD's row
	const fresh = new Map(now.slice(1).filter((line) => !line.includes(",MISSING,")).map((line) => [line.split(",")[0], line]));
	const ids = head.slice(1).map((line) => line.split(",")[0]);
	const rows = head.slice(1).map((line) => fresh.get(line.split(",")[0]) ?? line);
	for (const [id, line] of fresh) if (!ids.includes(id)) { ids.push(id); rows.push(line); }
	fs.writeFileSync(file, [head[0], ...rows].join("\n") + "\n");
	console.log(`${file}: ${ids.length} rows (${now.length - 1} from this run)`);
}
