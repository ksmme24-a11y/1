# ERP 부적합 그래프 스키마 정의서

## 1. 개요
Access ERP View Table에서 수집한 부적합 이력 데이터를 Neo4j 그래프 모델로 투영하기 위한 스키마 정의서이다. 검사의뢰번호(`ReqNo`)를 중심으로 모든 연관 엔터티를 노드와 관계로 연결하여 Bloom에서 실시간 탐색이 가능하도록 설계하였다.

## 2. 노드 라벨 및 속성 매핑
| ERP 컬럼 | 노드 라벨 | 기본 키 속성 | 부가 속성 | 비고 |
| --- | --- | --- | --- | --- |
| `ReqNo` | `InspectionRequest` | `reqNo` | `id`, `requestedAt`, `status` | Bloom 검색의 시작점. `reqNo` = `ReqNo` |
| `OrderNo` | `Order` | `orderNo` | `id`, `orderType`, `customerCode`, `dueDate` | 생산/공정 오더 |
| `ItemCode` | `Item` | `itemCode` | `code`, `name`, `spec`, `unit` | 품목 마스터 |
| `RoutNo`, `OpCode`, `OpName` | `Operation` | `code` | `name`, `routeNo`, `sequence` | 공정 라우팅 |
| `ResCode`, `ResName` | `Resource` | `code` | `name`, `workCenter`, `category` | 설비 또는 작업장 |
| `Worker` | `Worker` | `id` | `name`, `team`, `shift` | 사번 또는 배치 ID, `id`와 `name` 동시 보관 |
| `Codes` (파싱) | `DefectCode` | `code` | `name`, `severity`, `group` | `;` 분리 후 `:` 좌측 값을 코드로 사용 |
| `InspType` | `InspType` | `name` | `description` | 검사 유형 |
| `StartDate`, `EndDate` | `Occurrence` | `oid` | `reqNo`, `orderNo`, `itemCode`, `routNo`, `opCode`, `resCode`, `worker`, `inspType`, `start`, `end`, `note` | 검사 수행 단위. `oid`는 주요 칼럼을 합쳐 생성된 자연 키 |

## 3. 관계 정의
| 관계 타입 | 출발 노드 → 도착 노드 | 생성 조건 | 속성 | 설명 |
| --- | --- | --- | --- | --- |
| `FROM_REQUEST` | `Occurrence` → `InspectionRequest` | 동일 `ReqNo` | 없음 | 부적합 발생이 어느 검사의뢰에 속하는지 |
| `IN_ORDER` | `Occurrence` → `Order` | 동일 `OrderNo` | 없음 | 오더 단위로 묶기 |
| `FOR_ITEM` | `Occurrence` → `Item` | 동일 `ItemCode` | 없음 | 품목 기준 추적 |
| `HAS_OPERATION` | `Order` → `Operation` | 주문의 공정 라우팅 | `sequence` | 공정 순서 정의 (선행 로딩 프로세스 이용) |
| `AT_OPERATION` | `Occurrence` → `Operation` | 동일 `OpCode` | 없음 | 어느 공정에서 부적합 발생 |
| `ON_RESOURCE` | `Occurrence` → `Resource` | 동일 `ResCode` or `ResName` | 없음 | 설비/작업장 추적 |
| `BY_WORKER` | `Occurrence` → `Worker` | 동일 `Worker` | `role`, `shift` | 담당 작업자 |
| `HAS_DEFECT` | `Occurrence` → `DefectCode` | 파싱된 코드 | `qty`, `remark` | 부적합 코드 연결 (`OF_CODE` 보조 관계 병행 가능) |
| `HAS_TYPE` | `Occurrence` → `InspType` | 동일 `InspType` | 없음 | 검사 유형 |
| `ORDERED_FOR` | `Order` → `Item` | `OrderNo` ↔ `ItemCode` | 없음 | 오더-품목 정규화 |
| `REQUESTS_ORDER` | `InspectionRequest` → `Order` | ERP 매핑 테이블 | `requestDate` | 의뢰-오더 연결 |

## 4. 인덱스 및 제약 조건 요약
- `InspectionRequest(reqNo)` 고유 제약
- `Order(orderNo)` 고유 제약
- `Item(itemCode)` 고유 제약
- `Operation(code)` 고유 제약 및 `routeNo` 보조 인덱스
- `Resource(code)` 고유 제약
- `Worker(id)` 고유 제약, `name` 보조 인덱스
- `DefectCode(code)` 고유 제약
- `Occurrence(oid)` 고유 제약 및 `reqNo`, `orderNo`, `itemCode` 단일 인덱스

## 5. 시각화 가이드 요약
- Bloom 퍼스펙티브 기본 검색: `request {ReqNo}`
- 노드 유형별 색상: `InspectionRequest`(남색), `Occurrence`(주황), `Order`(진녹색), `Item`(하늘색), `Operation`(보라), `Resource`(회색), `Worker`(청록), `DefectCode`(빨강), `InspType`(노랑)
- 관계 표시 깊이: 초기 3홉, 더블클릭 확장 시 4홉까지 자동 탐색

## 6. 스케줄 및 운영 고려
- Access View 스냅샷을 10분 단위로 가져와 증분 로딩
- 로딩 실패 시 슬랙/메일 알림 및 `operations/load.log` 보존
- Bloom 퍼스펙티브 export는 `bloom/perspective.json` 파일로 버전 관리

