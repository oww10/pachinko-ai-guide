#!/usr/bin/env swift
// 제조사 가이드북·보도자료 PDF의 쪽을 PNG로 렌더링한다(macOS PDFKit, 추가 설치 불필요).
// pdftoppm이 없는 환경에서 이미지로만 된 PDF를 읽거나 번역 원본을 만들 때 쓴다.
//
// 사용: swift scripts/render-pdf-pages.swift <PDF 경로> <출력 폴더> [긴 변 px=1500] [쪽번호 쉼표 목록=전체]
// 예:   swift scripts/render-pdf-pages.swift guide.pdf /tmp/guide 1500        # 전체 쪽, 읽기용
//       swift scripts/render-pdf-pages.swift guide.pdf /tmp/guide 2339 3,4    # 3·4쪽을 번역 원본 해상도로
//
// 출력: <출력 폴더>/gb-<쪽번호>.png
// 번역 원본은 PDF 안에 들어 있는 이미지의 원래 크기(보통 2339px)로 맞춘다. 더 크게 렌더링해도 선명해지지 않고 메모리만 쓴다.
import Foundation
import PDFKit
import AppKit

let args = CommandLine.arguments
guard args.count >= 3, let doc = PDFDocument(url: URL(fileURLWithPath: args[1])) else {
  print("사용: swift render-pdf-pages.swift <PDF> <출력 폴더> [긴 변 px] [쪽번호,쪽번호]")
  exit(1)
}
let outDir = args[2]
let target = args.count > 3 ? Double(args[3]) ?? 1500.0 : 1500.0
let pages: [Int] = args.count > 4
  ? args[4].split(separator: ",").compactMap { Int($0) }.map { $0 - 1 }
  : Array(0..<doc.pageCount)

try? FileManager.default.createDirectory(atPath: outDir, withIntermediateDirectories: true)
print("총 \(doc.pageCount)쪽")
for i in pages {
  guard let page = doc.page(at: i) else { print("건너뜀: \(i + 1)쪽 없음"); continue }
  let box = page.bounds(for: .mediaBox)
  let scale = target / max(box.width, box.height)
  let size = NSSize(width: box.width * scale, height: box.height * scale)
  let image = page.thumbnail(of: size, for: .mediaBox)
  guard let tiff = image.tiffRepresentation,
        let rep = NSBitmapImageRep(data: tiff),
        let png = rep.representation(using: .png, properties: [:]) else { continue }
  let path = "\(outDir)/gb-\(i + 1).png"
  try? png.write(to: URL(fileURLWithPath: path))
  print("저장: \(path) (\(Int(size.width))×\(Int(size.height)))")
}
