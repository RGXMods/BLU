#!/usr/bin/env node
// RGX in-house addon packager — deterministic, dependency-free replacement
// for BigWigsMods/packager in the RGX Mods addon repos.
//
//   node tools/release/packager.mjs --toc BLU.toc [--out artifacts]
//
// Package policy:
//   - The file set is `git ls-files` (tracked files only), so untracked local
//     junk (skills/, .release/, artifacts/) can never enter a package.
//   - `.pkgmeta` ignore entries are removed (exact path or directory prefix).
//   - Structural hard-excludes that never ship: .git, .github, .gitlab,
//     .gitignore, .gitattributes, .pkgmeta, node_modules, artifacts, tools,
//     skills.
//   - Fails closed on script/executable extensions anywhere in the package:
//     .sh .ps1 .bat .cmd .py .js .mjs .cjs .exe .dll — CI tooling is never
//     player payload.
//   - The zip is deterministic: sorted entries and fixed 1980 timestamps, so
//     the same tree always rebuilds byte-identically.
//
// Zero npm dependencies: Node >= 18 builtins only.
import { execFileSync } from "node:child_process";
import { createHash } from "node:crypto";
import { existsSync, mkdirSync, readFileSync, rmSync, statSync, writeFileSync } from "node:fs";
import { basename, join, resolve } from "node:path";
import { deflateRawSync } from "node:zlib";
import process from "node:process";

const SCRIPT_EXTENSIONS = new Set([
  ".sh", ".ps1", ".bat", ".cmd", ".py", ".js", ".mjs", ".cjs", ".exe", ".dll",
]);
const STRUCTURAL_FILES = new Set([".gitignore", ".gitattributes", ".pkgmeta"]);
const STRUCTURAL_DIRS = new Set([
  ".git", ".github", ".gitlab", "node_modules", "artifacts", "tools", "skills",
]);

function arg(name, fallback = null) {
  const index = process.argv.indexOf(`--${name}`);
  if (index === -1) return fallback;
  const value = process.argv[index + 1];
  if (!value || value.startsWith("--")) throw new Error(`--${name} requires a value`);
  return value;
}

function fail(message) {
  console.error(`PACKAGE ERROR  ${message}`);
  process.exit(1);
}

// Minimal .pkgmeta subset: package-as, ignore, plain-copy, manual-changelog.
// The vendored copy ships in every addon repo, so no YAML dependency is
// allowed; our pkgmeta files never use deeper YAML features.
function parsePkgmeta(root) {
  const path = join(root, ".pkgmeta");
  const parsed = { packageAs: null, ignore: [], plainCopy: [], manualChangelog: null };
  if (!existsSync(path)) return parsed;
  let section = null;
  let inManual = false;
  for (const rawLine of readFileSync(path, "utf8").split(/\r?\n/)) {
    const line = rawLine.replace(/#.*$/, "").trimEnd();
    if (!line.trim()) continue;
    if (!line.startsWith(" ") && !line.startsWith("-")) {
      inManual = false;
      const [key, ...rest] = line.split(":");
      const value = rest.join(":").trim();
      if (key === "ignore") section = "ignore";
      else if (key === "plain-copy") section = "plainCopy";
      else if (key === "package-as") parsed.packageAs = value || null;
      else if (key === "manual-changelog") { section = null; inManual = true; }
      else if (inManual && key === "filename") parsed.manualChangelog = value || null;
      else section = null;
      continue;
    }
    const item = line.trim();
    if (!item.startsWith("-")) continue;
    const value = item.slice(1).trim();
    if (!value) continue;
    if (section === "ignore") parsed.ignore.push(value.replace(/\/+$/, ""));
    else if (section === "plainCopy") parsed.plainCopy.push(value.replace(/\/+$/, ""));
  }
  return parsed;
}

function isExcluded(path, ignores) {
  if (STRUCTURAL_FILES.has(path)) return true;
  if (STRUCTURAL_DIRS.has(path.split("/")[0])) return true;
  return ignores.some((entry) => path === entry || path.startsWith(`${entry}/`));
}

function trackedFiles(root) {
  const output = execFileSync("git", ["ls-files", "-z"], { cwd: root });
  return output.toString("utf8").split("\0").filter(Boolean);
}

// ── Deterministic ZIP writer (STORED-free, DEFLATE, fixed 1980 timestamps) ──

const CRC_TABLE = (() => {
  const table = new Int32Array(256);
  for (let index = 0; index < 256; index++) {
    let value = index;
    for (let bit = 0; bit < 8; bit++) {
      value = (value & 1) ? (0xEDB88320 ^ (value >>> 1)) : (value >>> 1);
    }
    table[index] = value;
  }
  return table;
})();

function crc32(buffer) {
  let crc = -1;
  for (let index = 0; index < buffer.length; index++) {
    crc = (crc >>> 8) ^ CRC_TABLE[(crc ^ buffer[index]) & 0xFF];
  }
  return (crc ^ -1) >>> 0;
}

const DOS_TIME = 0;      // 00:00:00
const DOS_DATE = 0x0021; // 1980-01-01

function buildZip(entries) {
  const local = [];
  const central = [];
  let offset = 0;
  for (const entry of entries) {
    const name = Buffer.from(entry.path, "utf8");
    const compressed = deflateRawSync(entry.data, { level: 9 });
    const crc = crc32(entry.data);

    const header = Buffer.alloc(30);
    header.writeUInt32LE(0x04034b50, 0);
    header.writeUInt16LE(20, 4);        // version needed
    header.writeUInt16LE(0, 6);         // flags
    header.writeUInt16LE(8, 8);         // method: deflate
    header.writeUInt16LE(DOS_TIME, 10);
    header.writeUInt16LE(DOS_DATE, 12);
    header.writeUInt32LE(crc, 14);
    header.writeUInt32LE(compressed.length, 18);
    header.writeUInt32LE(entry.data.length, 22);
    header.writeUInt16LE(name.length, 26);
    header.writeUInt16LE(0, 28);        // extra length
    local.push(header, name, compressed);

    const directory = Buffer.alloc(46);
    directory.writeUInt32LE(0x02014b50, 0);
    directory.writeUInt16LE(0x0314, 4); // made by: unix
    directory.writeUInt16LE(20, 6);      // needed
    directory.writeUInt16LE(0, 8);       // flags
    directory.writeUInt16LE(8, 10);      // method
    directory.writeUInt16LE(DOS_TIME, 12);
    directory.writeUInt16LE(DOS_DATE, 14);
    directory.writeUInt32LE(crc, 16);
    directory.writeUInt32LE(compressed.length, 20);
    directory.writeUInt32LE(entry.data.length, 24);
    directory.writeUInt16LE(name.length, 28);
    directory.writeUInt16LE(0, 30);      // extra
    directory.writeUInt16LE(0, 32);      // comment
    directory.writeUInt16LE(0, 34);      // disk
    directory.writeUInt16LE(0, 36);      // internal attrs
    directory.writeUInt32LE(0o644 << 16, 38);
    directory.writeUInt32LE(offset, 42);
    central.push(directory, name);

    offset += header.length + name.length + compressed.length;
  }
  const centralBuffer = Buffer.concat(central);
  const eocd = Buffer.alloc(22);
  eocd.writeUInt32LE(0x06054b50, 0);
  eocd.writeUInt16LE(0, 4);
  eocd.writeUInt16LE(0, 6);
  eocd.writeUInt16LE(entries.length, 8);
  eocd.writeUInt16LE(entries.length, 10);
  eocd.writeUInt32LE(centralBuffer.length, 12);
  eocd.writeUInt32LE(offset, 16);
  eocd.writeUInt16LE(0, 20);
  return Buffer.concat([...local, centralBuffer, eocd]);
}

// ── Main ─────────────────────────────────────────────────────────────────────

const root = process.cwd();
const tocPath = arg("toc");
const out = resolve(arg("out", "artifacts"));
if (!tocPath) fail("--toc is required");
if (!existsSync(tocPath)) fail(`TOC does not exist: ${tocPath}`);

const toc = readFileSync(tocPath, "utf8");
const tocField = (key) => toc.match(new RegExp(`^## ${key}:\\s*(.+?)\\s*$`, "m"))?.[1] ?? null;
const addonName = basename(tocPath).replace(/\.toc$/, "");
const version = (tocField("Version") ?? "").replace(/^v/, "");
if (!version) fail(`${basename(tocPath)} declares no Version`);

const pkgmeta = parsePkgmeta(root);
const packageAs = pkgmeta.packageAs || addonName;

const ignores = pkgmeta.ignore;
const included = [];
const offenders = [];
for (const path of trackedFiles(root)) {
  if (isExcluded(path, ignores)) continue;
  const extension = path.slice(path.lastIndexOf(".")).toLowerCase();
  if (SCRIPT_EXTENSIONS.has(extension)) offenders.push(path);
  included.push(path);
}
if (offenders.length) {
  for (const path of offenders) console.error(`PACKAGE ERROR  script/executable in package: ${path}`);
  process.exit(1);
}
if (!included.length) fail("package file set is empty");

included.sort((left, right) => Buffer.compare(Buffer.from(left), Buffer.from(right)));
const entries = included.map((path) => {
  const full = join(root, path);
  if (!statSync(full).isFile()) fail(`tracked path is not a file: ${path}`);
  // git ls-files always emits forward slashes; keep them verbatim.
  return { path: `${packageAs}/${path}`, data: readFileSync(full) };
});

const zip = buildZip(entries);
rmSync(out, { recursive: true, force: true });
mkdirSync(out, { recursive: true });
const archiveName = `${packageAs}-v${version}.zip`;
writeFileSync(join(out, archiveName), zip);
const checksum = createHash("sha256").update(zip).digest("hex");
writeFileSync(join(out, `${packageAs}-v${version}.sha256`), `${checksum}  ${archiveName}\n`);

console.log(`PACKAGE OK  ${archiveName} (${included.length} files, ${(zip.length / 1024 / 1024).toFixed(1)} MB)`);
console.log(`PACKAGE SHA256  ${checksum}`);
