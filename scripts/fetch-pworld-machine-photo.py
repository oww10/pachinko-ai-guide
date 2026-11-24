#!/usr/bin/env python3
"""P-WORLD 기종 DB의 기기 사진을 받아 흰 배경을 투명하게 만들고 PNG로 저장한다.

사용: python3 scripts/fetch-pworld-machine-photo.py <P-WORLD 기종 ID> <저장할 PNG 경로> [--crop-bottom 픽셀]
예:   python3 scripts/fetch-pworld-machine-photo.py 10570 dist/assets/images/official/mhrsb/machine.png

- 이미지 서버는 기종 페이지를 Referer로 요구하므로 해당 페이지 주소를 Referer로 보낸다.
- 가장자리와 이어진 흰색 영역만 투명 처리하고(기기 안쪽 흰색은 유지), 내용 영역으로 잘라 긴 변 1000px로 줄인다.
- 원본은 저장하지 않는다(필요하면 같은 명령으로 다시 받는다).
필요: Pillow
"""
import io
import subprocess
import sys
from collections import deque

from PIL import Image

MAX_SIDE = 1000
WHITE = 244  # 이 값 이상(RGB 모두)이면 배경 후보


def fetch(machine_id: str) -> Image.Image:
    page = f"https://www.p-world.co.jp/machine/database/{machine_id}"
    url = f"https://idn.p-world.co.jp/machines/{machine_id}/image/original.jpg"
    # 시스템 curl 사용(파이썬 기본 인증서 저장소가 없는 환경에서도 TLS 검증을 유지)
    data = subprocess.run(
        ["curl", "-sfL", "-m", "60", "-A", "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7)", "-e", page, url],
        check=True, capture_output=True,
    ).stdout
    return Image.open(io.BytesIO(data)).convert("RGBA")


def remove_edge_white(image: Image.Image) -> Image.Image:
    w, h = image.size
    px = image.load()
    seen = bytearray(w * h)
    queue = deque()
    for x in range(w):
        queue.append((x, 0)); queue.append((x, h - 1))
    for y in range(h):
        queue.append((0, y)); queue.append((w - 1, y))
    while queue:
        x, y = queue.popleft()
        if x < 0 or y < 0 or x >= w or y >= h or seen[y * w + x]:
            continue
        seen[y * w + x] = 1
        r, g, b, _ = px[x, y]
        if r >= WHITE and g >= WHITE and b >= WHITE:
            px[x, y] = (255, 255, 255, 0)
            queue.extend(((x + 1, y), (x - 1, y), (x, y + 1), (x, y - 1)))
    return image


def main() -> None:
    args = sys.argv[1:]
    if len(args) < 2:
        sys.exit(__doc__)
    machine_id, dest = args[0], args[1]
    crop_bottom = int(args[args.index("--crop-bottom") + 1]) if "--crop-bottom" in args else 0
    image = fetch(machine_id)
    if crop_bottom:
        image = image.crop((0, 0, image.width, image.height - crop_bottom))
    image = remove_edge_white(image)
    box = image.getchannel("A").getbbox()
    if box:
        image = image.crop(box)
    image.thumbnail((MAX_SIDE, MAX_SIDE), Image.LANCZOS)
    image.save(dest, optimize=True)
    print(f"OK {machine_id} -> {dest} {image.width}x{image.height}")


if __name__ == "__main__":
    main()
