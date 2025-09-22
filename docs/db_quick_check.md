# Neo4j DB Quick Check & Search Snippets

운영 Neo4j 인스턴스에서 즉시 사용할 수 있는 상태 점검·검색 스니펫 모음입니다. 모든 쿼리는 비파괴(idempotent)이며 Neo4j Browser, Bloom, NeoDash 등 어디에서든 붙여 넣어 실행할 수 있습니다.

## 0. 스키마/데이터 스냅샷 (빠른 상태 확인)

```cypher
// 라벨별 노드 개수
CALL db.labels() YIELD label
CALL {
  WITH label
  CALL apoc.cypher.run('MATCH (n:`'+label+'`) RETURN count(n) AS c', {}) YIELD value
  RETURN label AS l, value.c AS c
}
RETURN label, c ORDER BY c DESC;
```

```cypher
// 인덱스와 제약 조건 목록
CALL db.indexes();
CALL db.constraints();
```

## 1. ft_all 생성/검증

```cypher
// 1-1) 통합 풀텍스트 인덱스 생성 (이미 있으면 패스)
CREATE FULLTEXT INDEX ft_all IF NOT EXISTS
FOR (n:Occurrence|Order|Item|Operation|Resource|Worker|InspectionRequest|DefectCode)
ON EACH [
  n.reqNo,
  n.orderNo,
  n.itemCode,
  n.routNo,
  n.code,
  n.desc,
  n.opCode,
  n.opName,
  n.resCode,
  n.resName,
  n.worker,
  n.workerName,
  n.note
];
```

```cypher
// 1-2) 인덱스 구성 확인
CALL db.indexes() YIELD name, type, entityType, labelsOrTypes, properties, state
WHERE name = 'ft_all'
RETURN name, type, entityType, labelsOrTypes, properties, state;
```

```cypher
// 1-3) 키워드 검색 테스트
CALL db.index.fulltext.queryNodes('ft_all', $q) YIELD node, score
RETURN labels(node) AS labels, node, score
ORDER BY score DESC
LIMIT 10;
```

> 라벨/속성 명칭은 ETL 스크립트 기준입니다. `worker`는 작업자 ID, `workerName`은 가공된 이름, `resCode`/`resName`은 자원 코드/명칭을 나타냅니다.

## 2. 파라미터 샘플 (재사용)

```cypher
:param reqNo => 'RQ220505984';
:param orderNo => 'PD210300167';
:param itemCode => 'C007082051D';
:param fromDate => '2022-05-01';
:param toDate   => '2022-06-30';
:param worker   => '최규성';
:param opCode   => '560';
:param resName  => '*DBR1';
:param defectCode => 'A01003';
:param q => '검사대기 OR A01003 OR 최종검사';
```

## 3. 스모크 테스트 (Occurrence 중심 탐색)

```cypher
// 3A. ReqNo 묶음이 그래프 상에서 연결 확장되는지
MATCH (o:Occurrence {reqNo: $reqNo})
OPTIONAL MATCH p=(o)-[*1..2]-(n)
RETURN o, p
ORDER BY o.start DESC
LIMIT 50;
```

```cypher
// 3B. OrderNo로도 동일하게 연결 확장되는지
MATCH (o:Occurrence {orderNo: $orderNo})
OPTIONAL MATCH p=(o)-[*1..2]-(n)
RETURN o, p
ORDER BY o.start DESC
LIMIT 50;
```

```cypher
// 3C. ItemCode + 기간 필터 동작 여부
MATCH (o:Occurrence {itemCode: $itemCode})
WHERE exists(o.start) AND exists(o.end)
  AND date(o.start) >= date($fromDate) AND date(o.end) <= date($toDate)
RETURN o
ORDER BY o.start
LIMIT 50;
```

```cypher
// 3D. 원인코드 역추적
MATCH (dc:DefectCode {code: $defectCode})<-[:OF_CODE]-(o:Occurrence)
RETURN dc, o
ORDER BY o.start DESC
LIMIT 50;
```

```cypher
// 3E. 키워드(부분) 검색 → 연관 노드까지
CALL db.index.fulltext.queryNodes('ft_all', $q) YIELD node, score
CALL {
  WITH node
  OPTIONAL MATCH p=(node)-[*1..2]-(m)
  RETURN collect(p) AS paths
}
RETURN labels(node) AS labels, node, score, paths
ORDER BY score DESC
LIMIT 20;
```

## 4. 정확성 체크리스트

- 라벨/속성 명칭이 문서와 일치하는지 (`worker` vs `workerName`, `resCode`/`resName`, `opCode`/`opName` 등).
- 핵심 관계: `(:Occurrence)-[:OF_CODE]->(:DefectCode)`, `(:Occurrence)-[:HAS_TYPE]->(:InspType)`, `(:Occurrence)-[:IN_ORDER]->(:Order)`, `(:Occurrence)-[:FOR_ITEM]->(:Item)`, `(:Occurrence)-[:AT_OPERATION]->(:Operation)`, `(:Occurrence)-[:ON_RESOURCE]->(:Resource)`, `(:Occurrence)-[:BY_WORKER]->(:Worker)`, `(:Occurrence)-[:FROM_REQUEST]->(:InspectionRequest)`가 샘플에서 최소 1건 이상 존재하는지.
- `ft_all` 질의로 요청번호, 오더번호, 코드, 설명, 작업자, 공정, 자원, 비고가 모두 검색되는지.

## 5. 성능 빠른 점검 (문제 있을 때만)

```cypher
PROFILE
CALL db.index.fulltext.queryNodes('ft_all', $q) YIELD node, score
RETURN node
LIMIT 5;
```

> Cardinality가 과도하게 크다면 인덱스 속성 범위를 재검토하거나 `ft_occurrence` 등 보조 인덱스를 병행하는 것을 권장합니다.

## 6. 엣지 케이스

- 날짜 타입이 문자열과 섞여 있다면 `date(o.start)` 변환 시 오류가 발생할 수 있으므로 ISO-8601 문자열(`YYYY-MM-DD`)을 권장합니다.
- 전각/특수문자가 포함된 텍스트(예: `전체길이－미달`)도 `ft_all`에서 적절히 검색되는지 확인합니다. 필요하면 정규화 필드를 추가하여 인덱스에 포함합니다.
- 작업자/공정/자원 필터에서 NULL 허용이 필요할 경우 `WHERE (param IS NULL OR ...)` 패턴을 활용합니다.

## 7. 선택 개선 (원클릭 UX)

- Neo4j Bloom 또는 NeoDash 카드로 3A~3E 쿼리를 버튼화하여 제공.
- 필요한 경우 `CYPHER runtime=pipelined` 힌트를 명시적으로 추가.
- `ft_all` 외에 `ft_defectcode`, `ft_occurrence` 등 특화 인덱스를 병행 노출하여 탐색 속도를 최적화.
