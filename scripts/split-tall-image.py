#!/usr/bin/env python3
"""세로로 긴 대당첨 비율 이미지(p-town hit_rate.jpg 등)를 읽기 좋은 조각으로 자른다.

사용: python3 scripts/split-tall-image.py <이미지 경로> <출력 폴더> [조각 높이 px=1000]
출력: <출력 폴더>/part0.jpg, part1.jpg ...  (위에서 아래 순서, 겹침 없음)

- 조각을 하나씩 열어 비율 합계가 100%인지 확인한다. 긴 이미지를 통째로 열면 작은 글자가 뭉개진다.
- `sips -c <높이> <폭> --cropOffset <y> 0`은 오프셋이 입력과 다르게 해석돼 엉뚱한 구간이 나오고, 이미지 끝에 닿으면 조용히 원본을 그대로 저장한다. 쓰지 않는다.
필요: Pillow
"""
import sys
from pathlib import Path

from PIL import Image


def main() -> None:
    if len(sys.argv) < 3:
        sys.exit(__doc__)
    src, out_dir = Path(sys.argv[1]), Path(sys.argv[2])
    step = int(sys.argv[3]) if len(sys.argv) > 3 else 1000
    out_dir.mkdir(parents=True, exist_ok=True)
    image = Image.open(src).convert("RGB")
    width, height = image.size
    print(f"원본 {width}×{height}")
    index, top = 0, 0
    while top < height:
        bottom = min(top + step, height)
        path = out_dir / f"part{index}.jpg"
        image.crop((0, top, width, bottom)).save(path, quality=92)
        print(f"저장: {path} (y {top}-{bottom})")
        index, top = index + 1, bottom


if __name__ == "__main__":
    main()
