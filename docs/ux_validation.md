# Bloom 검색/확장 UX 검증 시나리오

## 1. 준비
- `bloom/perspective.json`을 Bloom에 Import하고 기본 퍼스펙티브로 설정한다.
- `Occurrence`, `Order`, `Item`, `Operation`, `Resource`, `Worker`, `DefectCode` 노드가 최소 1건 이상 존재하도록 ETL을 실행한다.

## 2. 검색 및 초기 3홉 표시
1. Bloom 상단 검색창에 `request REQ20240213001` 입력
2. `InspectionRequest` 노드 1건과 연결된 `Occurrence` 노드 집합이 표시됨
3. Scene 패널 오른쪽 `Paths` 탭에서 depth=3이 기본값인지 확인 (Occurrence → Order → Operation/Resource/Item)

## 3. 더블클릭 확장
1. `Occurrence` 노드 중 1건을 더블클릭
2. 연결된 `Worker`, `DefectCode`, `InspType` 노드가 자동으로 확장되어 Scene에 추가됨
3. 추가로 `Order` 노드를 더블클릭하면 `HAS_OPERATION` 관계를 통해 다음 공정(Operation) 및 `REQUESTS_ORDER`를 통해 `InspectionRequest`까지 확장되는지 확인

## 4. 그래프 스타일 확인 포인트
- 색상: `Occurrence` 주황, `InspectionRequest` 남색, `DefectCode` 빨강, `Worker` 청록으로 표시되는지 확인
- 아이콘: Bloom 아이콘 라이브러리 기준으로 노드 타입별 지정 아이콘 적용 여부 확인
- Tooltips: 노드를 선택했을 때 Inspector에서 주요 속성(reqNo, orderNo 등)이 노출되는지 검증

## 5. 문제 발생 시 대응
- 검색 결과가 비어있다면 `ReqNo` 값이 정확한지 확인하고, `MATCH (n:InspectionRequest) RETURN n.reqNo LIMIT 5`를 Cypher 패널에서 실행
- 더블클릭 시 확장이 안 된다면 퍼스펙티브 설정에서 `Expand on Double Click` 옵션이 켜져 있는지 확인
- 색상이나 아이콘이 다르면 `Perspective > Categories`에서 수동으로 수정하고 `perspective.json`을 재-export하여 버전 관리

## 6. 기대 산출물
- Scene 캡처 이미지(예: `captures/bloom_request_REQ20240213001.png`)
- 발견된 이슈 및 조치 기록 (없을 경우 "이슈 없음" 명시)
