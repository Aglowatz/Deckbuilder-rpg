#!/usr/bin/env node
// Freesound helper for the sound-effects pass (docs/audio/sfx_sources.md). CC0 only.
//   node tools/freesound.js search "<query>" [maxDurationSeconds] [page]
//       Lists CC0 results (id, seconds, downloads, rating, author, title, description).
//   node tools/freesound.js fetch <id> [<id> ...]
//       Checks the sound page says Creative Commons 0, downloads its high-quality OGG preview to _audio_source/fs_<id>.ogg
//       and records the title, author and licence in data/source/sfx_meta.json (committed, so the credits survive the cache being emptied).
// Only single previews are downloaded, never packs or originals; the build (tools/sfx_build.js) deletes each raw file after processing it.
const fs = require("fs");
const path = require("path");
const https = require("https");

const ROOT = path.resolve(__dirname, "..");
const CACHE = path.join(ROOT, "_audio_source");
const META = path.join(ROOT, "data", "source", "sfx_meta.json");
const UA = "Mozilla/5.0 (WaywardPath sound pass)";

function get(url, binary) {
	return new Promise((resolve, reject) => {
		https.get(url, { headers: { "User-Agent": UA } }, (res) => {
			if (res.statusCode >= 300 && res.statusCode < 400 && res.headers.location) {
				resolve(get(new URL(res.headers.location, url).toString(), binary));
				res.resume();
				return;
			}
			if (res.statusCode !== 200) {
				reject(new Error(`${res.statusCode} for ${url}`));
				res.resume();
				return;
			}
			const chunks = [];
			res.on("data", (c) => chunks.push(c));
			res.on("end", () => resolve(binary ? Buffer.concat(chunks) : Buffer.concat(chunks).toString("utf8")));
		}).on("error", reject);
	});
}

function decode(text) {
	return text.replace(/&amp;/g, "&").replace(/&quot;/g, '"').replace(/&#39;/g, "'").replace(/&lt;/g, "<").replace(/&gt;/g, ">").replace(/\s+/g, " ").trim();
}

function loadMeta() {
	return fs.existsSync(META) ? JSON.parse(fs.readFileSync(META, "utf8")) : {};
}

function saveMeta(meta) {
	const sorted = {};
	for (const key of Object.keys(meta).sort()) sorted[key] = meta[key];
	fs.writeFileSync(META, JSON.stringify(sorted, null, "\t") + "\n");
}

async function search(query, maxDur, page) {
	const filter = encodeURIComponent('license:"Creative Commons 0"' + (maxDur ? ` duration:[0 TO ${maxDur}]` : ""));
	const url = `https://freesound.org/search/?q=${encodeURIComponent(query)}&f=${filter}&s=${encodeURIComponent("Downloads (most first)")}&page=${page || 1}`;
	const html = await get(url, false);
	const blocks = html.split('class="bw-search__result"').slice(1);
	for (const block of blocks) {
		const attr = (name) => ((block.match(new RegExp(`data-${name}="([^"]*)"`)) || [])[1] || "");
		const rating = (block.match(/Average rating of ([0-9.]+)/) || [])[1] || "-";
		const count = (block.match(/bw-rating__count[^>]*>\((\d+)\)/) || [])[1] || "0";
		const desc = decode(((block.match(/max-h-60px-md-50px[^>]*>([\s\S]*?)<\/div>/) || [])[1] || "").replace(/<[^>]+>/g, " ")).slice(0, 110);
		console.log(`${attr("sound-id")}\t${Number(attr("duration")).toFixed(1)}s\t${attr("num-downloads")}dl\t${rating}(${count})\t${attr("username")}\t${decode(attr("title"))}\t| ${desc}`);
	}
}

async function fetchOne(id, meta) {
	const out = path.join(CACHE, `fs_${id}.ogg`);
	if (fs.existsSync(out) && meta[id]) {
		console.log(`cached ${id}`);
		return;
	}
	const page = await get(`https://freesound.org/s/${id}/`, false);
	if (!/publicdomain\/zero\/1\.0/.test(page) || !/Creative Commons 0/.test(page)) {
		throw new Error(`sound ${id} is not CC0 - not downloaded`);
	}
	const title = decode((page.match(/og:title" content="([^"]*)"/) || [])[1] || "");
	const preview = (page.match(/https:\/\/cdn\.freesound\.org\/previews\/[^"]*-hq\.ogg/) || [])[0];
	const lq = (page.match(/https:\/\/cdn\.freesound\.org\/previews\/[^"]*-lq\.ogg/) || [])[0];
	const url = preview || (lq ? lq.replace("-lq.ogg", "-hq.ogg") : null);
	if (!url) throw new Error(`no preview for ${id}`);
	const pageUrl = (page.match(/og:url" content="([^"]*)"/) || [])[1] || `https://freesound.org/s/${id}/`;
	const author = decodeURIComponent((pageUrl.match(/people\/([^/]+)\//) || [])[1] || title.split(" by ").pop());
	fs.mkdirSync(CACHE, { recursive: true });
	// Godot must never import the raw downloads.
	if (!fs.existsSync(path.join(CACHE, ".gdignore"))) fs.writeFileSync(path.join(CACHE, ".gdignore"), "");
	const data = await get(url, true);
	fs.writeFileSync(out, data);
	meta[id] = {
		title: title.endsWith(` by ${author}`) ? title.slice(0, -(` by ${author}`).length) : title,
		author,
		license: "CC0 1.0",
		url: `https://freesound.org/s/${id}/`,
	};
	console.log(`fetched ${id} (${(data.length / 1024).toFixed(0)} KB) ${meta[id].title} by ${author}`);
}

async function main() {
	const [cmd, ...args] = process.argv.slice(2);
	if (cmd === "search") {
		await search(args[0], args[1], args[2]);
	} else if (cmd === "fetch") {
		const meta = loadMeta();
		for (const id of args) {
			try {
				await fetchOne(id, meta);
			} catch (error) {
				console.error(String(error.message || error));
			}
		}
		saveMeta(meta);
	} else {
		console.log("usage: freesound.js search <query> [maxDur] [page] | fetch <id>...");
	}
}

main().catch((error) => {
	console.error(error);
	process.exit(1);
});
