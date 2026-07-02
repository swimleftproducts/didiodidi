#!/usr/bin/env python3
"""Dev-only: render a contract fixture through the real ingest template and
write it to functions/scripts/output/preview.html for a fast, no-deploy
visual check. Usage:

    python functions/scripts/render_preview.py [fixture_name]

Defaults to with_images.json (has both images and a completed/incomplete mix).
"""
import sys
from pathlib import Path

REPO_ROOT = Path(__file__).parent.parent.parent
FIXTURES_DIR = REPO_ROOT / "contract" / "fixtures"
TEMPLATES_DIR = (
    REPO_ROOT / "functions" / "packages" / "didiodidi" / "ingest" / "templates"
)
OUTPUT_DIR = Path(__file__).parent / "output"

sys.path.insert(0, str(REPO_ROOT / "functions" / "packages" / "didiodidi" / "ingest"))


def main():
    import json

    from jinja2 import Environment, FileSystemLoader, select_autoescape

    fixture_name = sys.argv[1] if len(sys.argv) > 1 else "with_images.json"
    fixture_path = FIXTURES_DIR / fixture_name
    payload = json.loads(fixture_path.read_text())

    env = Environment(
        loader=FileSystemLoader(str(TEMPLATES_DIR)),
        autoescape=select_autoescape(["html", "j2"]),
    )
    html = env.get_template("snapshot.html.j2").render(**payload)

    OUTPUT_DIR.mkdir(exist_ok=True)
    out_path = OUTPUT_DIR / "preview.html"
    out_path.write_text(html)
    print(f"Rendered {fixture_name} -> {out_path}")


if __name__ == "__main__":
    main()
