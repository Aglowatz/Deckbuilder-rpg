// Checks that an exported Godot .pck is complete and readable: header magic, the file directory, every entry inside the file, and
// (unless --no-md5) every entry's MD5 against the one stored in the directory. A pck cut short by a killed export fails here.
// Usage: node tools/verify_pck.js <file.pck> [--no-md5] [--min-mb=N] [--min-shaders=N] [--json]
// --min-shaders: at least N baked shaders (.godot/shader_cache/*) - a headless export skips the shader baker without an error.
// Exit 0 = good, 1 = broken (the reason is printed), 2 = usage.
// Reads in chunks (never the whole pack), so it is light on memory.
const fs = require("fs"), crypto = require("crypto");

const args = process.argv.slice(2);
const file = args.find((a) => !a.startsWith("--"));
if (!file) { console.error("usage: node tools/verify_pck.js <file.pck> [--no-md5] [--min-mb=N] [--json]"); process.exit(2); }
const noMd5 = args.includes("--no-md5");
const minArg = args.find((a) => a.startsWith("--min-mb="));
const minMb = minArg ? Number(minArg.split("=")[1]) : 0;
const shaderArg = args.find((a) => a.startsWith("--min-shaders="));
const minShaders = shaderArg ? Number(shaderArg.split("=")[1]) : 0;

function fail(msg) {
	if (args.includes("--json")) console.log(JSON.stringify({ ok: false, file, error: msg }));
	else console.log("PCK BROKEN: " + file + ": " + msg);
	process.exit(1);
}

let fd;
try { fd = fs.openSync(file, "r"); } catch (e) { fail("cannot open (" + e.code + ")"); }
const size = fs.fstatSync(fd).size;
if (size < 4096) fail("only " + size + " bytes");
if (minMb && size < minMb * 1024 * 1024) fail("only " + (size / 1048576).toFixed(1) + " MB, expected at least " + minMb + " MB");

function read(pos, len) {
	if (pos + len > size) fail("entry at " + pos + " (+" + len + ") runs past the end of the file (" + size + " bytes) - truncated");
	const buf = Buffer.alloc(len);
	let got = 0;
	while (got < len) {
		const n = fs.readSync(fd, buf, got, len - got, pos + got);
		if (n <= 0) fail("read error at " + (pos + got));
		got += n;
	}
	return buf;
}

// Header (core/io/file_access_pack.cpp): magic "GDPC", format version, engine major/minor/patch, flags, file base, [v3+] directory offset.
const head = read(0, 4 + 4 * 5 + 8 + 8);
if (head.toString("latin1", 0, 4) !== "GDPC") fail("no GDPC magic at the start (not a standalone pck, or overwritten)");
const format = head.readUInt32LE(4);
const engine = [head.readUInt32LE(8), head.readUInt32LE(12), head.readUInt32LE(16)].join(".");
const flags = head.readUInt32LE(20);
if (flags & 1) fail("directory is encrypted - this checker cannot read it");
// flag 2 (relative file base) needs no handling: a standalone pck starts at 0.
let fileBase = Number(head.readBigUInt64LE(24));
let dirPos;
if (format >= 3) dirPos = Number(head.readBigUInt64LE(32));
else dirPos = 4 + 4 * 5 + 8 + 16 * 4;
// Format 4 (Godot 4.7) keeps the v3 layout but stores paths without "res://".
if (format < 2 || format > 4) fail("unknown pck format version " + format);
if (dirPos <= 0 || dirPos >= size) fail("directory offset " + dirPos + " is outside the file (" + size + " bytes) - truncated");

let pos = dirPos;
const count = read(pos, 4).readUInt32LE(0); pos += 4;
if (count === 0 || count > 1000000) fail("implausible file count " + count);
const entries = [];
for (let i = 0; i < count; i++) {
	const slen = read(pos, 4).readUInt32LE(0); pos += 4;
	if (slen > 4096) fail("implausible path length " + slen + " at entry " + i);
	const name = read(pos, slen).toString("utf8").replace(/\0+$/, ""); pos += slen;
	const meta = read(pos, 8 + 8 + 16 + 4); pos += 36;
	entries.push({ name, ofs: fileBase + Number(meta.readBigUInt64LE(0)), size: Number(meta.readBigUInt64LE(8)), md5: meta.toString("hex", 16, 32), flags: meta.readUInt32LE(32) });
}
let payload = 0;
for (const e of entries) {
	if (e.flags & 2) continue; // removal entry (patch packs)
	if (e.ofs + e.size > size) fail(e.name + " ends at " + (e.ofs + e.size) + ", past the end of the file (" + size + " bytes) - truncated");
	payload += e.size;
}
for (const n of ["project.binary", ".godot/global_script_class_cache.cfg"]) {
	if (!entries.some((e) => e.name.replace(/^res:\/\//, "") === n)) fail("missing " + n);
}
const shaders = entries.filter((e) => e.name.replace(/^res:\/\//, "").startsWith(".godot/shader_cache/")).length;
if (shaders < minShaders) fail("only " + shaders + " baked shaders, expected at least " + minShaders + " (was the export headless? the shader baker needs a window)");

let checked = 0;
if (!noMd5) {
	const chunk = Buffer.alloc(4 * 1024 * 1024);
	for (const e of entries) {
		if (e.flags & 3) continue; // encrypted or removal
		const h = crypto.createHash("md5");
		let left = e.size, p = e.ofs;
		while (left > 0) {
			const n = fs.readSync(fd, chunk, 0, Math.min(chunk.length, left), p);
			if (n <= 0) fail(e.name + ": read error");
			h.update(n === chunk.length ? chunk : chunk.subarray(0, n));
			left -= n; p += n;
		}
		const got = h.digest("hex");
		if (e.md5 !== "00000000000000000000000000000000" && got !== e.md5) fail(e.name + ": MD5 mismatch (stored " + e.md5 + ", read " + got + ") - corrupt");
		checked++;
	}
}
fs.closeSync(fd);
const result = { ok: true, file, bytes: size, mb: +(size / 1048576).toFixed(1), files: count, shaders, payload_mb: +(payload / 1048576).toFixed(1), engine, format, md5_checked: checked };
if (args.includes("--json")) console.log(JSON.stringify(result));
else console.log("PCK OK: " + file + ": " + result.mb + " MB, " + count + " files, " + shaders + " baked shaders (Godot " + engine + ", pack format " + format + ")" + (noMd5 ? "" : ", " + checked + " MD5s match"));
