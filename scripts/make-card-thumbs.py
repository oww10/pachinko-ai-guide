#!/usr/bin/env python3
"""기종 목록 카드용 축소 썸네일을 만든다.

각 기종 JSON의 visualGuide.mainImage.url 원본을 읽어 긴 변 480px의 WebP(알파 유지)로
dist/assets/images/thumbs/<기종 id>.webp 에 저장한다. 원본은 건드리지 않는다.
필요: Pillow (pip install pillow)
사용: python3 scripts/make-card-thumbs.py
"""
import json
import sys
from pathlib import Path

from PIL import Image

ROOT = Path(__file__).resolve().parent.parent
DIST = ROOT / "dist"
OUT = DIST / "assets" / "images" / "thumbs"
MAX_SIDE = 480
QUALITY = 82

OUT.mkdir(parents=True, exist_ok=True)
failed = 0
for path in sorted((DIST / "data").glob("*/*.json")):
    if path.name == "index.json":
        continue
    data = json.loads(path.read_text(encoding="utf-8"))
    url = data.get("visualGuide", {}).get("mainImage", {}).get("url")
    if not url:
        print(f"SKIP  {data['id']}: mainImage 없음")
        continue
    src = DIST / url.removeprefix("./")
    if not src.exists():
        print(f"FAIL  {data['id']}: 원본 없음 {src}", file=sys.stderr)
        failed += 1
        continue
    with Image.open(src) as image:
        image = image.convert("RGBA")
        image.thumbnail((MAX_SIDE, MAX_SIDE), Image.LANCZOS)
        dest = OUT / f"{data['id']}.webp"
        image.save(dest, "WEBP", quality=QUALITY, method=6)
    print(f"OK    {data['id']}: {image.width}x{image.height} {dest.stat().st_size // 1024}KB")
sys.exit(1 if failed else 0)
