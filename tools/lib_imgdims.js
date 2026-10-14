// Reads [width, height] from the header of a PNG, WebP or JPEG file (no decoding). Returns null if unknown.
const fs = require("fs");
module.exports = function dims(f) {
	const fd = fs.openSync(f, "r");
	const b = Buffer.alloc(64);
	fs.readSync(fd, b, 0, 64, 0);
	fs.closeSync(fd);
	if (b.toString("latin1", 1, 4) === "PNG") return [b.readUInt32BE(16), b.readUInt32BE(20)];
	if (b.toString("latin1", 0, 4) === "RIFF") {
		const t = b.toString("latin1", 12, 16);
		if (t === "VP8X") return [1 + b.readUIntLE(24, 3), 1 + b.readUIntLE(27, 3)];
		if (t === "VP8 ") return [b.readUInt16LE(26) & 0x3fff, b.readUInt16LE(28) & 0x3fff];
		if (t === "VP8L") { const v = b.readUInt32LE(21); return [(v & 0x3fff) + 1, ((v >> 14) & 0x3fff) + 1]; }
	}
	if (b[0] === 0xff && b[1] === 0xd8) {
		const buf = fs.readFileSync(f);
		let i = 2;
		while (i < buf.length) {
			if (buf[i] !== 0xff) { i++; continue; }
			const m = buf[i + 1];
			if (m >= 0xc0 && m <= 0xc3) return [buf.readUInt16BE(i + 7), buf.readUInt16BE(i + 5)];
			i += 2 + buf.readUInt16BE(i + 2);
		}
	}
	return null;
};
