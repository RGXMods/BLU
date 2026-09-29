#!/usr/bin/env node
// RGX in-house release publisher — the BigWigsMods/packager replacement.
//
// Publishes the deterministic archive built by the in-house packager:
//   1. Creates the GitHub release and uploads the zip + release.json.
//   2. Uploads to CurseForge when X-Curse-Project-ID and CF_API_KEY exist.
//   3. Uploads to Wago when X-Wago-ID and WAGO_API_TOKEN exist.
//
// Upload protocols verified against BigWigsMods/packager release.sh:
//   - CurseForge: GET  https://wow.curseforge.com/api/game/wow/versions
//                 POST https://wow.curseforge.com/api/projects/<id>/upload-file
//   - Wago:       GET  https://addons.wago.io/api/data/game
//                 POST https://addons.wago.io/api/projects/<id>/version
//
// Zero npm dependencies: Node >= 18 builtins only.
//
// Usage:
//   node tools/release/publish-release.mjs \
//     --toc RGX-Framework.toc \
//     --archive artifacts/RGX-Framework-v2.7.9.zip \
//     --tag v2.7.9 \
//     --release-type release \
//     --changelog-file notes.md \
//     [--out artifacts]
import { execFileSync } from "node:child_process";
import { existsSync, mkdirSync, readdirSync, readFileSync, writeFileSync } from "node:fs";
import { basename, dirname, join } from "node:path";
import process from "node:process";

function arg(name, fallback = null) {
  const index = process.argv.indexOf(`--${name}`);
  if (index === -1) return fallback;
  const value = process.argv[index + 1];
  if (!value || value.startsWith("--")) throw new Error(`--${name} requires a value`);
  return value;
}

function fail(message) {
  console.error(`PUBLISH ERROR  ${message}`);
  process.exit(1);
}

// ── TOC metadata ─────────────────────────────────────────────────────────────

function tocField(text, key) {
  return text.match(new RegExp(`^## ${key}:\\s*(.+?)\\s*$`, "m"))?.[1] ?? null;
}

function readToc(path) {
  return readFileSync(path, "utf8");
}

// Flavor names follow the convention checked by tools/ci/release-metadata-check.mjs:
// mainline / classic / forever / bcc / wrath / titan / cata / mists. Ranges
// mirror BigWigsMods/packager's toc_to_type classification so interface bumps
// do not require editing a literal map.
function flavorForInterface(interfaceValue) {
  const value = Number(interfaceValue);
  if (!Number.isInteger(value) || value < 10000) {
    fail(`unrecognized TOC Interface value "${interfaceValue}"`);
  }
  if (value >= 11000 && value <= 11999) return "classic";
  if (value >= 16000 && value <= 16999) return "forever";
  if (value >= 20000 && value <= 20999) return "bcc";
  if (value >= 30000 && value <= 30999) return "wrath";
  if (value >= 38000 && value <= 38999) return "titan";
  if (value >= 40000 && value <= 40999) return "cata";
  if (value >= 50000 && value <= 50999) return "mists";
  if (value >= 100000) return "mainline";
  fail(`unrecognized TOC Interface value "${interfaceValue}"`);
}

// CurseForge gameVersionTypeID values (BigWigsMods/packager release.sh).
const CF_GAME_TYPE_ID = new Map([
  ["mainline", 517],
  ["classic", 67408],
  ["bcc", 73246],
  ["wrath", 73713],
  ["titan", 81212],
  ["cata", 77522],
  ["mists", 79434],
  ["forever", 88568],
]);

// Wago patch keys (verified against https://addons.wago.io/api/data/game):
// retail, classic, bc, wotlk, mop, cata, titan, forever.
function wagoType(flavor) {
  if (flavor === "mainline") return "retail";
  if (flavor === "bcc") return "bc";
  if (flavor === "wrath") return "wotlk";
  if (flavor === "mists") return "mop";
  return flavor;
}

function collectFlavors(tocPath) {
  const primary = readToc(tocPath);
  const stem = basename(tocPath).replace(/\.toc$/, "");
  const interfaces = new Set();
  for (const value of (tocField(primary, "Interface") ?? "").split(",")) {
    const trimmed = value.trim();
    if (trimmed) interfaces.add(trimmed);
  }
  // Multi-flavor addons ship sibling TOCs like RGX-Framework_Wrath.toc; pick up
  // their Interface values too so release.json covers every shipped flavor.
  const directory = dirname(tocPath);
  for (const entry of readdirSync(directory)) {
    if (!entry.endsWith(".toc")) continue;
    if (entry === basename(tocPath)) continue;
    if (!entry.startsWith(`${stem}_`) && !entry.startsWith(`${stem}-`)) continue;
    for (const value of (tocField(readToc(join(directory, entry)), "Interface") ?? "").split(",")) {
      const trimmed = value.trim();
      if (trimmed) interfaces.add(trimmed);
    }
  }
  if (interfaces.size === 0) fail(`${basename(tocPath)} declares no Interface values`);
  const flavors = [...interfaces]
    .map((value) => ({ flavor: flavorForInterface(value), interface: Number(value) }))
    .sort((left, right) => left.flavor.localeCompare(right.flavor));
  return flavors;
}

// ── HTTP with retry ──────────────────────────────────────────────────────────

async function fetchWithRetry(url, options = {}, attempts = 3) {
  let lastError;
  for (let attempt = 1; attempt <= attempts; attempt++) {
    try {
      const response = await fetch(url, options);
      return response;
    } catch (error) {
      lastError = error;
      if (attempt < attempts) {
        await new Promise((resolve) => setTimeout(resolve, attempt * 10_000));
      }
    }
  }
  throw lastError;
}

// ── GitHub release ───────────────────────────────────────────────────────────

function publishGitHub({ tag, archive, releaseJson, title, changelogFile, prerelease }) {
  if (!process.env.GH_TOKEN && !process.env.GITHUB_TOKEN) {
    fail("GH_TOKEN (or GITHUB_TOKEN) is required to create the GitHub release");
  }
  let releaseExists = false;
  try {
    execFileSync("gh", ["release", "view", tag], { stdio: ["ignore", "ignore", "ignore"] });
    releaseExists = true;
  } catch {
    releaseExists = false;
  }
  if (releaseExists) {
    // Idempotent rerun: refresh metadata and overwrite assets.
    const editArgs = ["release", "edit", tag, "--title", title, "--notes-file", changelogFile];
    if (prerelease) editArgs.push("--prerelease");
    execFileSync("gh", editArgs, { stdio: "inherit" });
    execFileSync("gh", ["release", "upload", tag, archive, releaseJson, "--clobber"], { stdio: "inherit" });
  } else {
    const createArgs = [
      "release", "create", tag, archive, releaseJson,
      "--title", title, "--notes-file", changelogFile,
    ];
    if (prerelease) createArgs.push("--prerelease");
    execFileSync("gh", createArgs, { stdio: "inherit" });
  }
  console.log(`GITHUB OK  release ${tag} with ${basename(archive)} and release.json`);
}

// ── CurseForge ────────────────────────────────────────────────────────────────

async function publishCurseForge({ projectId, apiKey, flavors, version, releaseType, changelog, archive }) {
  if (!projectId) {
    console.log("CURSEFORGE SKIP  no X-Curse-Project-ID in TOC");
    return;
  }
  if (!apiKey) fail("CF_API_KEY secret is missing but X-Curse-Project-ID is set");
  if (releaseType === "dev" || releaseType === "alpha-branch" || releaseType === "unknown") {
    fail(`unsupported CurseForge release type "${releaseType}"`);
  }

  const versionsUrl = "https://wow.curseforge.com/api/game/wow/versions";
  const response = await fetchWithRetry(versionsUrl, { headers: { "x-api-token": apiKey } });
  if (!response.ok) fail(`CurseForge version lookup failed (HTTP ${response.status})`);
  const versionRows = await response.json();

  const gameVersions = [];
  for (const { flavor, interface: wowInterface } of flavors) {
    const typeId = CF_GAME_TYPE_ID.get(flavor);
    if (!typeId) fail(`no CurseForge gameVersionTypeID known for flavor "${flavor}"`);
    const typed = versionRows.filter((row) => row.gameVersionTypeID === typeId);
    if (!typed.length) fail(`CurseForge reports no game versions for flavor "${flavor}"`);
    const exact = typed.find((row) => row.name === String(wowInterface));
    if (exact) {
      gameVersions.push(exact.id);
    } else {
      const highest = typed.reduce((best, row) => (row.id > best.id ? row : best), typed[0]);
      console.warn(`WARNING: no CurseForge version "${wowInterface}" for ${flavor}; using "${highest.name}"`);
      gameVersions.push(highest.id);
    }
  }

  const metadata = JSON.stringify({
    displayName: `v${version}`,
    gameVersions,
    releaseType,
    changelog,
    changelogType: "markdown",
  });
  const form = new FormData();
  form.append("metadata", new Blob([metadata], { type: "application/json" }));
  form.append("file", new Blob([readFileSync(archive)]), basename(archive));

  const uploadUrl = `https://wow.curseforge.com/api/projects/${projectId}/upload-file`;
  const upload = await fetchWithRetry(uploadUrl, {
    method: "POST",
    headers: { "x-api-token": apiKey },
    body: form,
  });
  if (upload.status !== 200) {
    let detail = "";
    try { detail = (await upload.text()).slice(0, 2000); } catch { /* body unavailable */ }
    fail(`CurseForge upload failed (HTTP ${upload.status}) ${detail}`);
  }
  console.log(`CURSEFORGE OK  project ${projectId}, v${version} (${releaseType})`);
}

// ── Wago ──────────────────────────────────────────────────────────────────────

async function publishWago({ projectId, token, flavors, version, releaseType, changelog, archive }) {
  if (!projectId) {
    console.log("WAGO SKIP  no X-Wago-ID in TOC");
    return;
  }
  if (!token) {
    console.log("WAGO SKIP  WAGO_API_TOKEN secret is missing");
    return;
  }

  const response = await fetchWithRetry("https://addons.wago.io/api/data/game");
  if (!response.ok) fail(`Wago patch lookup failed (HTTP ${response.status})`);
  const patches = (await response.json())?.patches;
  if (!patches || typeof patches !== "object") fail("Wago patch lookup returned no patch data");

  const payload = {
    label: `v${version}`,
    stability: releaseType === "release" ? "stable" : releaseType,
    changelog,
  };
  for (const { flavor } of flavors) {
    const type = wagoType(flavor);
    const list = patches[type];
    if (!Array.isArray(list) || !list.length) {
      fail(`Wago reports no patches for flavor type "${type}"`);
    }
    // Ship the latest patch per flavor — our TOC interfaces track live clients.
    payload[`supported_${type}_patches`] = [list.reduce((best, value) => (value > best ? value : best))];
  }

  const form = new FormData();
  form.append("metadata", new Blob([JSON.stringify(payload)], { type: "application/json" }));
  form.append("file", new Blob([readFileSync(archive)]), basename(archive));

  const uploadUrl = `https://addons.wago.io/api/projects/${projectId}/version`;
  const upload = await fetchWithRetry(uploadUrl, {
    method: "POST",
    headers: { authorization: `Bearer ${token}`, accept: "application/json" },
    body: form,
  });
  if (upload.status !== 200 && upload.status !== 201) {
    let detail = "";
    try { detail = (await upload.text()).slice(0, 2000); } catch { /* body unavailable */ }
    fail(`Wago upload failed (HTTP ${upload.status}) ${detail}`);
  }
  console.log(`WAGO OK  project ${projectId}, v${version} (${payload.stability})`);
}

// ── Main ─────────────────────────────────────────────────────────────────────

const tocPath = arg("toc");
const archive = arg("archive");
const tag = arg("tag");
const releaseType = arg("release-type");
const changelogFile = arg("changelog-file");
const out = arg("out", "artifacts");
for (const [name, value] of [["toc", tocPath], ["archive", archive], ["tag", tag], ["release-type", releaseType], ["changelog-file", changelogFile]]) {
  if (!value) fail(`--${name} is required`);
}
if (!["release", "beta", "alpha"].includes(releaseType)) {
  fail(`--release-type must be release, beta, or alpha (got "${releaseType}")`);
}
if (!existsSync(archive)) fail(`archive does not exist: ${archive}`);
if (!existsSync(changelogFile)) fail(`changelog file does not exist: ${changelogFile}`);

const tocText = readToc(tocPath);
const tocVersion = (tocField(tocText, "Version") ?? "").replace(/^v/, "");
if (!tocVersion) fail(`${basename(tocPath)} declares no Version`);
// Release names use the color-cleaned TOC Title (BigWigs parity, e.g. BLU
// publishes as "Better Level-Up!"); fall back to the TOC file stem.
const tocTitle = (tocField(tocText, "Title") ?? "")
  .replace(/\|c[0-9a-fA-F]{8}/g, "")
  .replace(/\|r/g, "")
  .trim();
const addonName = tocTitle || basename(tocPath).replace(/\.toc$/, "");
const curseId = tocField(tocText, "X-Curse-Project-ID");
const wagoId = tocField(tocText, "X-Wago-ID");
const flavors = collectFlavors(tocPath);
const changelog = readFileSync(changelogFile, "utf8");

mkdirSync(out, { recursive: true });
const releaseJsonPath = join(out, "release.json");
const releaseJson = {
  releases: [{
    name: addonName,
    version: `v${tocVersion}`,
    filename: basename(archive),
    nolib: false,
    metadata: flavors,
  }],
};
writeFileSync(releaseJsonPath, `${JSON.stringify(releaseJson, null, 2)}\n`);
console.log(`RELEASE.JSON OK  ${addonName} v${tocVersion}, ${flavors.length} flavor(s)`);

publishGitHub({
  tag,
  archive,
  releaseJson: releaseJsonPath,
  title: `${addonName} v${tocVersion}`,
  changelogFile,
  prerelease: releaseType !== "release",
});

await publishCurseForge({
  projectId: curseId,
  apiKey: process.env.CF_API_KEY,
  flavors,
  version: tocVersion,
  releaseType,
  changelog,
  archive,
});

await publishWago({
  projectId: wagoId,
  token: process.env.WAGO_API_TOKEN,
  flavors,
  version: tocVersion,
  releaseType,
  changelog,
  archive,
});

console.log(`PUBLISH OK  ${addonName} v${tocVersion} live on GitHub${curseId ? " + CurseForge" : ""}${wagoId ? " + Wago" : ""}`);
