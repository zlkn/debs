#!/usr/bin/env python3
import html
import sys
from datetime import datetime, timezone
from pathlib import Path

APT_URL = "https://apt.zlkn.cc"
SUITE = "forky"
COMPONENT = "main"

root = Path(__file__).resolve().parent.parent
packages_file = root / "build/repo/dists" / SUITE / COMPONENT / "binary-amd64/Packages"
out_dir = root / "build/web"


def parse(text):
    stanzas = []
    for block in text.strip().split("\n\n"):
        fields, key = {}, None
        for line in block.splitlines():
            if line.startswith((" ", "\t")) and key:
                fields[key] += "\n" + line[1:]
            else:
                key, _, value = line.partition(":")
                fields[key] = value.strip()
        stanzas.append(fields)
    return stanzas


def size(n):
    n = float(n)
    for unit in ("B", "KiB", "MiB", "GiB"):
        if n < 1024:
            return f"{n:.0f} {unit}" if unit == "B" else f"{n:.1f} {unit}"
        n /= 1024
    return f"{n:.1f} TiB"


def row(p):
    e = html.escape
    summary = p.get("Description", "").split("\n")[0]
    name = e(p["Package"])
    if p.get("Homepage"):
        name = f'<a href="{e(p["Homepage"])}">{name}</a>'
    return (
        "<tr>"
        f"<td>{name}<div class=\"desc\">{e(summary)}</div></td>"
        f"<td><code>{e(p['Version'])}</code></td>"
        f"<td>{e(p['Architecture'])}</td>"
        f"<td>{size(p['Size'])}</td>"
        f'<td><a href="{APT_URL}/{e(p["Filename"])}">.deb</a></td>'
        "</tr>"
    )


if not packages_file.exists():
    sys.exit(f"{packages_file} not found, run make repo/index first")

packages = sorted(parse(packages_file.read_text()), key=lambda p: p["Package"])
rows = "\n".join(row(p) for p in packages)
count = f"{len(packages)} package{'' if len(packages) == 1 else 's'}"
updated = datetime.now(timezone.utc).strftime("%Y-%m-%d %H:%M UTC")

sources = "\\n".join([
    "Types: deb",
    f"URIs: {APT_URL}",
    f"Suites: {SUITE}",
    f"Components: {COMPONENT}",
    "Signed-By: /etc/apt/keyrings/zlkn.gpg",
])
setup = f"""sudo install -d -m755 /etc/apt/keyrings
sudo curl -fsSL {APT_URL}/zlkn.gpg -o /etc/apt/keyrings/zlkn.gpg
printf '{sources}\\n' | sudo tee /etc/apt/sources.list.d/zlkn.sources &gt;/dev/null
sudo apt update"""

page = f"""<!doctype html>
<html lang="en">
<head>
<meta charset="utf-8">
<meta name="viewport" content="width=device-width, initial-scale=1">
<title>zlkn apt repository</title>
<style>
:root {{ color-scheme: light dark; --fg: #1f2328; --bg: #fff; --muted: #656d76; --line: #d0d7de; --code: #f6f8fa; }}
@media (prefers-color-scheme: dark) {{
  :root {{ --fg: #e6edf3; --bg: #0d1117; --muted: #8d96a0; --line: #30363d; --code: #161b22; }}
}}
body {{ font: 15px/1.5 system-ui, sans-serif; color: var(--fg); background: var(--bg); max-width: 56rem; margin: 2rem auto; padding: 0 1rem; }}
h1 {{ font-size: 1.5rem; margin-bottom: 0; }}
h2 {{ font-size: 1.1rem; margin-top: 2rem; }}
.muted, .desc {{ color: var(--muted); }}
.desc {{ font-size: .85rem; }}
pre, code {{ font: 13px/1.45 ui-monospace, monospace; }}
pre {{ background: var(--code); border: 1px solid var(--line); border-radius: 6px; padding: .75rem 1rem; overflow-x: auto; }}
table {{ width: 100%; border-collapse: collapse; }}
th, td {{ text-align: left; padding: .5rem; border-bottom: 1px solid var(--line); vertical-align: top; }}
th {{ font-weight: 600; }}
a {{ color: #0969da; }}
@media (prefers-color-scheme: dark) {{ a {{ color: #4493f8; }} }}
</style>
</head>
<body>
<h1>zlkn apt repository</h1>
<p class="muted">Debian {SUITE} &middot; {count} &middot; updated {updated}</p>

<h2>Setup</h2>
<pre>{setup}</pre>

<h2>Packages</h2>
<table>
<thead><tr><th>Package</th><th>Version</th><th>Arch</th><th>Size</th><th></th></tr></thead>
<tbody>
{rows}
</tbody>
</table>
</body>
</html>
"""

out_dir.mkdir(parents=True, exist_ok=True)
(out_dir / "index.html").write_text(page)
print(f"{out_dir / 'index.html'}: {count}")
