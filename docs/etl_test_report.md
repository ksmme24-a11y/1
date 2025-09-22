# Access → Neo4j ETL 단건 검증 보고서

## 1. 테스트 목적
- Access ERP View에서 추출한 단건 데이터를 Neo4j에 적재할 때 중복 없이 정상 반영되는지 확인한다.
- Bloom에서 `request {ReqNo}` 검색 시 3홉까지 자동으로 탐색되는지 검증한다.

## 2. 테스트 환경
- Access 파일: `\\fileserver\erp\Quality.accdb`
- View 이름: `vw_QMS_Defect`
- Neo4j Desktop 5.12 (Enterprise), Local DB `neo4j`
- ETL 스크립트: `etl/access_to_neo4j.py --once`
- Bloom 버전: 2.9.x

## 3. 단건 적재 절차
1. Access View에서 `ReqNo = 'REQ20240213001'` 레코드만 필터링하여 CSV로 추출
2. Neo4j에서 `MATCH (o:Occurrence) DETACH DELETE o`를 실행해 초기화
3. ETL 스크립트를 단일 실행
   ```bash
   python etl/access_to_neo4j.py \
     --access-path "\\\fileserver\erp\Quality.accdb" \
     --view-name vw_QMS_Defect \
     --incremental-column UpdateDttm \
     --once
   ```
4. Cypher 검증 쿼리 실행
   ```cypher
   MATCH (req:InspectionRequest {reqNo: 'REQ20240213001'})-[:FROM_REQUEST]-(occ:Occurrence)
   RETURN req.reqNo, count(occ) AS occCnt, collect(occ.orderNo) AS orders;
   ```

## 4. 결과 요약
| 항목 | 기대값 | 결과 |
| --- | --- | --- |
| Occurrence 생성 수 | 1개 Defect Code 당 1건 | PASS (3개 코드 → 3건 생성) |
| 중복 생성 여부 | 없음 | PASS |
| `Order` 재사용 | 동일 orderNo 1건만 유지 | PASS |
| Bloom 검색 | `request REQ20240213001` 입력 시 Occurrence/Order/Item/Operation/Resource 표시 | PASS |
| 더블클릭 확장 | Worker/DefectCode/연관 Order-Hop 확장 | PASS |

## 5. 추가 확인 사항
- ETL 로그에서 `Neo4j 반영 완료 (rows=1)` 출력 확인
- `operations/last_success.txt`가 `UpdateDttm` 값으로 갱신되는지 확인
- Bloom에서 `Layout > Hierarchical` 사용 시 공정 흐름 파악 용이

## 6. 추후 조치
- 1시간 대량 배치 데이터(>10K rows)로 부하 테스트
- Access 연결 지연 발생 시 재시도 로직(최대 3회) 추가 검토
- Slack 알림 Webhook 연결 후 운영자에게 공유
