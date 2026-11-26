# 상세페이지 이미지 출처·재사용 절차

이미지를 찾은 뒤 번역본을 만들고 리제로와 같은 화면에 배치하는 전체 순서는 [상세페이지 제작 플레이북](machine-detail-production-playbook.md)을 따른다.

## 리제로 오니가카리 2의 실제 제작 순서

2026-11-03 최초 상세 화면(`f54909c`)은 [パチマガスロマガFREE 리제로 오니가카리 2 기종 페이지](https://pachimaga.com/free/mach/maker-p/daitogiken/e_rezero_onigakari2.php)를 참고하고, 아래 네 이미지를 해당 사이트의 URL로 직접 표시했다. 제조사 공식 사이트에서 처음부터 이미지를 가져왔다는 설명은 잘못된 기록이다.

| 화면 용도 | 최초 이미지 URL |
|---|---|
| 기기 외관 | `https://pachimaga.com/free/2026/e_rezero_onigakari2/e_rezero_onigakari2_kyoutai.webp` |
| 백경 챌린지 | `https://pachimaga.com/free/2026/e_rezero_onigakari2/e_rezero_onigakari2_hakugeichallenge.webp` |
| 챌린지 보너스 | `https://pachimaga.com/free/2026/e_rezero_onigakari2/e_rezero_onigakari2_challengebonus_v2.webp` |
| RUSH 화면 | `https://pachimaga.com/free/2026/e_rezero_onigakari2/e_rezero_onigakari2_rushchuicustom.webp` |

같은 날 `cab1124`에서 이 외부 이미지 참조를 대도기연 공식 제품 자료의 로컬 JPG로 교체했고, `0987af6`에서 기기·RUSH용 PNG를 추가했다. `8daba1b`에서 PhotoCraft 한국어 오버레이를 별도 제작했다. 따라서 **최초 발견·사용 출처는 パチマガスロマガFREE, 현재 리제로 상세페이지의 이미지 출처 표기는 이후 교체한 대도기연 공식 자료**다. 현재 JSON의 `sourceUrl`만 보면 이 이력을 알 수 없다.

## 다음 기종에서 반복할 조사·제작 순서

1. 파치마가 같은 전문 기종 페이지에서 기기 외관, 통상시, 초당첨, RUSH 장면의 후보를 모은다. 페이지 URL과 **이미지별 실제 URL**을 각각 기록한다. 전문 매체는 이미지 탐색과 보조 설명 출처로 구분한다.
2. 확률·배분·게임 흐름과 제품명은 제조사 공식 자료로 대조한다. 전문 매체와 공식 자료가 다르면 수치를 임의로 합치지 않고 `verification.needsReviewFields`에 남긴다.
3. 사용할 이미지마다 게시자, 원저작권자, 원본 페이지, 이미지 직접 URL, 확인일, 이용 조건, 사용 범위(내부 시안/공개)를 적는다. 전문 매체에 실린 제조사 이미지도 매체의 재게시 허가가 자동으로 생기지 않는다.
4. 이미지 사용이 허용된 범위에서 원본을 보존하고 사이트용 크롭·형식 변환본을 별도로 만든다. 한국어 설명은 원본을 덮어쓰지 않고 `*-ko.png`로 생성한다. 실제 이미지 출처를 `credit`·`sourceUrl`에 적으며, 전문 매체에서 가져온 이미지를 공식 사이트에서 직접 받은 것으로 표기하지 않는다.
5. 기종 JSON의 `visualGuide`에 로컬 이미지 경로·`alt`·크레딧을 연결한다. 이미지 파일이 없거나 공개 이용 조건이 확인되지 않으면 공개 화면은 자체 제작 도식·원그래프·표로 구성한다. 외부 이미지 URL을 그대로 연결하는 최초 리제로 방식은 **과거 구현 기록**이며 현행 배포 절차로 사용하지 않는다. 공식 이미지가 없는 기종도 `keyStats`·`flowDiagram`·`steps`·원그래프는 데이터만으로 만든다(자체 도식이 기본, 공식 이미지 번역은 추가). 제조사별 공식 자료를 찾는 경로와 PDF·긴 이미지 처리 도구는 [플레이북](machine-detail-production-playbook.md) 3·4장에 있다.
6. 데스크톱·모바일 상세 화면에서 이미지 비율, 번역 가독성, 출처 링크, 로딩을 확인한다. 공개 전에는 [인수인계 문서](project-handoff.md)의 이미지 이용 조건과 현재 미결 결정을 다시 확인한다.

새 기종 작업 기록에는 아래 항목을 이미지별로 남긴다.

```text
기종 / 화면 용도:
발견 페이지 URL:
이미지 직접 URL:
게시자 / 원저작권자:
공식 자료 대조 URL:
확인일 / 이용 조건 / 허용 범위:
원본 로컬 경로 / 가공본 경로:
JSON credit / sourceUrl:
```

이미지 이용 방침은 프로젝트 오너의 결정에 따른다. 권리자의 요청이 있으면 해당 이미지를 즉시 제거한다.
