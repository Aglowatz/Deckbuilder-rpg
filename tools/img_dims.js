// Prints dimension histogram per folder. Usage: node tools/img_dims.js <dir> [depth]
const fs=require("fs"),path=require("path");
function dims(f){const fd=fs.openSync(f,"r");const b=Buffer.alloc(64);fs.readSync(fd,b,0,64,0);fs.closeSync(fd);
 if(b.toString("latin1",1,4)==="PNG")return[b.readUInt32BE(16),b.readUInt32BE(20)];
 if(b.toString("latin1",0,4)==="RIFF"){const t=b.toString("latin1",12,16);
  if(t==="VP8X")return[1+b.readUIntLE(24,3),1+b.readUIntLE(27,3)];
  if(t==="VP8 ")return[b.readUInt16LE(26)&0x3fff,b.readUInt16LE(28)&0x3fff];
  if(t==="VP8L"){const v=b.readUInt32LE(21);return[(v&0x3fff)+1,((v>>14)&0x3fff)+1];}}
 if(b[0]===0xff&&b[1]===0xd8){const buf=fs.readFileSync(f);let i=2;while(i<buf.length){if(buf[i]!==0xff){i++;continue;}const m=buf[i+1];if(m>=0xc0&&m<=0xc3)return[buf.readUInt16BE(i+7),buf.readUInt16BE(i+5)];i+=2+buf.readUInt16BE(i+2);}}
 return null;}
const root=process.argv[2],out={};
(function w(d){for(const e of fs.readdirSync(d,{withFileTypes:true})){const p=path.join(d,e.name);if(e.isDirectory())w(p);else if(/\.(png|webp|jpe?g)$/i.test(e.name)){const x=dims(p);const k=path.relative(root,d).split(path.sep).slice(0,+process.argv[3]||1).join("/")||".";(out[k]=out[k]||{})[x?x.join("x"):"?"]=((out[k]||{})[x?x.join("x"):"?"]||0)+1;}}})(root);
for(const[k,v]of Object.entries(out)){console.log("==",k);console.log("  "+Object.entries(v).sort((a,b)=>b[1]-a[1]).slice(0,8).map(([a,b])=>b+"x "+a).join(" | "));}
