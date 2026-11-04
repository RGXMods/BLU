// Uploads the packaged zip to the WoWInterface listing named by "## X-WoWI-ID" in the TOC.
// Skips (exit 0) when the TOC has no ID or WOWI_API_TOKEN is not set.
import fs from "node:fs";

const argOf = (name) => {
  const i = process.argv.indexOf(`--${name}`);
  if (i < 0 || !process.argv[i + 1]) throw new Error(`missing --${name}`);
  return process.argv[i + 1];
};
const tocPath = argOf("toc");
const archive = argOf("archive");
const notesPath = argOf("changelog-file");

const toc = fs.readFileSync(tocPath, "utf8");
const id = (toc.match(/^## X-WoWI-ID:\s*(\d+)/m) || [])[1];
const rawVersion = ((toc.match(/^## Version:\s*(.+)$/m) || [])[1] || "").trim();
// Listing labels carry the release tag form (v1.2.3) regardless of how the TOC writes it.
const version = rawVersion ? "v" + rawVersion.replace(/^v/i, "") : rawVersion;
const token = process.env.WOWI_API_TOKEN;
if (!id) { console.log("WoWInterface: no X-WoWI-ID in TOC; skipping"); process.exit(0); }
if (!token) { console.log("WoWInterface: WOWI_API_TOKEN not set; skipping"); process.exit(0); }

// Release notes come as Markdown; WoWInterface expects BBCode.
const toBBCode = (md) => {
  const out = [];
  let inList = false;
  for (const raw of md.split("\n")) {
    const line = raw.trimEnd();
    const item = line.match(/^- (.*)/);
    if (item) { if (!inList) { out.push("[list]"); inList = true; } out.push(`[*]${item[1]}`); continue; }
    if (inList) { out.push("[/list]"); inList = false; }
    const head = line.match(/^#+\s+(.*)/);
    if (head) { out.push(`[size="5"]${head[1]}[/size]`); continue; }
    out.push(line);
  }
  if (inList) out.push("[/list]");
  return out.join("\n").trim();
};

const form = new FormData();
form.append("id", id);
form.append("version", version);
form.append("changelog", toBBCode(fs.readFileSync(notesPath, "utf8")));
form.append("updatefile", new Blob([fs.readFileSync(archive)], { type: "application/zip" }), archive.split("/").pop());
const res = await fetch("https://api.wowinterface.com/addons/update", {
  method: "POST", headers: { "x-api-token": token }, body: form,
});
const body = await res.text();
console.log(`WoWInterface: HTTP ${res.status} ${body.slice(0, 200)}`);
if (res.status !== 202) process.exit(1);
