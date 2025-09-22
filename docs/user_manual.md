# Neo4j Bloom 사용자 매뉴얼 (관리자/리더용)

## 1. 목적
ERP 검사의뢰 기반의 부적합 이력을 Bloom에서 실시간으로 탐색하고, 부서 리더가 데이터 관계를 파악할 수 있도록 사용자 절차를 제공한다.

## 2. 사전 준비
- Neo4j Desktop 실행 및 `neo4j` 데이터베이스 시작
- Bloom 애플리케이션(Explore) 실행 후 `ERP Defect Monitoring` 퍼스펙티브 선택
- 계정 권한: Bloom `Reader` 역할 이상, Neo4j Bolt 접속 정보 확인

## 3. 기본 탐색 절차
1. **요청 검색**
   - 검색창에 `request REQ번호` 입력 (예: `request REQ20240213001`)
   - 해당 검사의뢰와 연결된 Occurrence, Order, Item 노드가 자동으로 표시됨
2. **결과 필터링**
   - 왼쪽 Filters 패널에서 `InspType`, `Worker`, `DefectCode`로 필터링 가능
   - 여러 조건을 선택하면 AND 조건으로 적용됨
3. **연속 확장**
   - 관심 있는 노드를 더블클릭하여 관련 관계를 확장 (최대 4홉)
   - `Occurrence` → `DefectCode` → `Order` → `Operation` 순으로 흐름을 파악
4. **세부 정보 확인**
   - 노드를 클릭하면 Inspector 패널에서 속성을 확인 (`reqNo`, `orderNo`, `itemCode`, `start`, `end` 등)
   - 필요 시 `Open in Browser` 버튼을 눌러 Neo4j Browser에서 추가 질의 수행 가능

## 4. 장표/보고서 활용
- `Scene Actions > Capture Image`로 그래프 이미지를 추출해 보고서 첨부
- `Perspective > Favorites`에 자주 사용하는 검색어를 저장하여 빠르게 접근
- 회의 시에는 `Auto-Layout > Flow`를 적용해 공정 흐름이 명확하게 보이도록 조정

## 5. 문제 해결 Q&A
| 증상 | 해결 방법 |
| --- | --- |
| 검색 결과 없음 | 입력한 ReqNo 확인 → ETL 로그에서 최근 적재 시점 확인 → 필요 시 IT에게 데이터 재적재 요청 |
| 노드 색상이 다르게 보임 | 최신 `bloom/perspective.json`을 Import 후 Bloom 재시작 |
| 더블클릭 확장 안 됨 | `Settings > Interaction > Expand on Double Click` 옵션 체크 |
| 특정 노드 속성이 비어있음 | Neo4j Browser에서 해당 노드 조회 후, Access View에 데이터 존재 여부 확인 |

## 6. 교육 체크리스트
- [ ] 검색어 문법 익히기 (`request`, `order`, `item`)
- [ ] Inspector 패널 속성 확인 방법
- [ ] Scene 캡처 및 Export 방법
- [ ] 필터/컬러 범례 이해
- [ ] 문제 발생 시 연락 채널 숙지

## 7. 참고 자료
- `docs/erp_graph_schema.md`: 그래프 스키마 상세
- `docs/ux_validation.md`: Bloom 검색/확장 검증 절차
- `docs/operations_guide.md`: 운영 및 장애 대응 가이드
- Neo4j 공식 문서: <https://neo4j.com/docs/bloom-user-guide/current/>
