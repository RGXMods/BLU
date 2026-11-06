// node tests/deep-user-sounds.test.mjs
// The manifest tool must find sounds at ANY depth and BLU must load what it writes.
import fs from "node:fs";
import os from "node:os";
import path from "node:path";
import assert from "node:assert/strict";
import { spawnSync } from "node:child_process";
import { findSounds, renderManifest } from "../tools/generate-user-sound-manifest.mjs";

const root = fs.mkdtempSync(path.join(os.tmpdir(), "blu-deep-"));
const touch = (...p) => { const f = path.join(root, ...p); fs.mkdirSync(path.dirname(f), { recursive: true }); fs.writeFileSync(f, "x"); };
touch("MySounds", "a.ogg");
touch("MySounds", "Packs", "Fantasy", "Battle", "Boss", "Final", "roar.OGG");   // 6 folders deep
touch("Other", "deep", "er", "and", "deeper", "still", "x", "song.mp3");
touch("Other", "readme.txt");
touch("BLU", "media", "sounds", "own.ogg");              // BLU's own files are skipped
touch("BLU_Forever", "media", "sounds", "own2.ogg");
touch("Blizzard_Foo", "bar.ogg");

const all = findSounds(root);
const files = all.map((s) => s.file);
assert.ok(files.includes("Interface\\AddOns\\MySounds\\Packs\\Fantasy\\Battle\\Boss\\Final\\roar.OGG"), "finds a file six folders deep");
assert.ok(files.includes("Interface\\AddOns\\Other\\deep\\er\\and\\deeper\\still\\x\\song.mp3"), "finds a file seven folders deep");
assert.ok(files.includes("Interface\\AddOns\\MySounds\\a.ogg"), "finds a top-level file");
assert.equal(files.filter((f) => /BLU|Blizzard_/i.test(f)).length, 0, "skips BLU's own and Blizzard folders");
assert.equal(files.filter((f) => f.endsWith(".txt")).length, 0, "only sound files");

assert.equal(findSounds(root, { include: ["Other"] }).length, 1, "--include narrows to one folder");
assert.equal(findSounds(root, { exclude: ["Other"] }).every((s) => !s.file.includes("\\Other\\")), true, "--exclude skips a folder");
assert.equal(findSounds(root, { max: 2 }).length, 2, "--max caps the result");

// The generated manifest is valid Lua BLU can read, without overwriting an existing manifest.
const lua = renderManifest(all);
const script = `BLU_UserCustomSoundManifest = { "existing" }\n${lua}\nassert(#BLU_UserCustomSoundManifest == ${all.length + 1}, "appends to an existing manifest")\nassert(BLU_UserCustomSoundManifest[1] == "existing")\nlocal last = BLU_UserCustomSoundManifest[#BLU_UserCustomSoundManifest]\nassert(last.file:find("Interface\\\\AddOns\\\\", 1, true) == 1, "paths start at Interface\\\\AddOns")\n`;
const r = spawnSync("lua5.1", ["-e", script], { encoding: "utf8" });
assert.equal(r.status, 0, r.stderr);
fs.rmSync(root, { recursive: true, force: true });
console.log("deep-user-sounds test OK");
