# Neo4j DB Quick Check & Search Snippets

이 문서는 Neo4j 운영 DB 상태를 신속히 점검하고, 주요 식별자/키워드 기반 탐색을 즉시 실행할 수 있는 Cypher 스니펫을 정리합니다. 
라벨/프로퍼티 명은 현재 ETL 스크립트(`etl/access_to_neo4j.py`)와 데이터 로딩 스크립트 기준으로 작성되었습니다.

## 1. 현재 그래프 요약 확인

```cypher
// 1-1) 라벨별 노드 카운트
CALL db.labels() YIELD label
CALL {
  WITH label
  CALL apoc.cypher.run('MATCH (n:`'+label+'`) RETURN count(n) AS c', {}) YIELD value
  RETURN label, value.c AS count
}
RETURN * ORDER BY count DESC;
```

```cypher
// 1-2) 주요 속성(컬럼) 분포
MATCH (n)
WITH labels(n) AS labs, keys(n) AS ks
UNWIND ks AS k
RETURN labs AS labels, k AS property, count(*) AS freq
ORDER BY freq DESC, property
LIMIT 200;
```

```cypher
// 1-3) 인덱스 & 제약 조건 리스트
CALL db.indexes();
CALL db.constraints();
```

## 2. 통합 풀텍스트 인덱스 확인/생성

다음 구문은 주요 라벨(`Occurrence`, `Order`, `Item`, `Operation`, `Resource`, `Worker`, `InspectionRequest`, `DefectCode`, `InspType`)의 대표 속성에 대해 통합 검색 인덱스를 생성합니다. 이미 존재하면 아무 작업도 하지 않습니다.

```cypher
CREATE FULLTEXT INDEX ft_all IF NOT EXISTS
FOR (n:Occurrence|Order|Item|Operation|Resource|Worker|InspectionRequest|DefectCode|InspType)
ON EACH [
  n.reqNo,
  n.orderNo,
  n.itemCode,
  n.routNo,
  n.opCode,
  n.opName,
  n.resCode,
  n.resName,
  n.worker,
  n.note,
  n.code,
  n.name,
  n.id,
  n.altCode,
  n.desc
];
```

> 참고: `Occurrence.worker`는 작업자 ID를 저장하며, `Worker` 노드는 `id`/`name` 속성을 사용합니다. `Resource`는 `code`(주 키)와 `altCode`(원본 코드)를 모두 보관합니다.

## 3. 컬럼별 검색 + 연관 노드 자동 확장

아래 쿼리는 `Occurrence` 중심 탐색을 전제로 하며, 1~2홉 이내의 연관 노드/관계를 자동으로 펼쳐 보여줍니다.

```cypher
// A. 검사의뢰번호(reqNo) 정확 일치 검색
WITH $reqNo AS reqNo
MATCH (o:Occurrence)
WHERE exists(o.reqNo) AND o.reqNo = reqNo
OPTIONAL MATCH p=(o)-[*1..2]-(n)
RETURN o, p
ORDER BY o.start DESC
LIMIT 200;
```

```cypher
// B. 제조오더번호(orderNo) 정확 일치 검색
WITH $orderNo AS orderNo
MATCH (o:Occurrence)
WHERE exists(o.orderNo) AND o.orderNo = orderNo
OPTIONAL MATCH p=(o)-[*1..2]-(n)
RETURN o, p
ORDER BY o.start DESC
LIMIT 200;
```

```cypher
// C. 품목코드 + 기간 필터 (start/end 문자열은 ISO-8601 형식)
WITH date($from) AS d1, date($to) AS d2, $item AS item
MATCH (o:Occurrence)
WHERE exists(o.itemCode) AND o.itemCode = item
  AND exists(o.start) AND exists(o.end)
  AND date(o.start) >= d1 AND date(o.end) <= d2
OPTIONAL MATCH p=(o)-[*1..2]-(n)
RETURN o, p
ORDER BY o.start
LIMIT 500;
```

```cypher
// D. 작업자/공정코드/자원명 교차 필터 (NULL 허용)
WITH $worker AS worker, $opCode AS opCode, $resName AS resName
MATCH (o:Occurrence)
WHERE (worker IS NULL OR (exists(o.worker) AND o.worker = worker))
  AND (opCode IS NULL OR (exists(o.opCode) AND o.opCode = opCode))
  AND (resName IS NULL OR (exists(o.resName) AND o.resName = resName))
OPTIONAL MATCH p=(o)-[*1..2]-(n)
RETURN o, p
LIMIT 300;
```

```cypher
// E. 불량 코드(DefectCode.code) → 발생 건 역추적
WITH $code AS code
MATCH (dc:DefectCode)
WHERE exists(dc.code) AND dc.code = code
MATCH (dc)<-[:OF_CODE]-(o:Occurrence)
OPTIONAL MATCH p=(o)-[*1..2]-(n)
RETURN dc, o, p
ORDER BY o.start DESC
LIMIT 300;
```

```cypher
// F. 통합 키워드 검색 (부분 검색)
CALL db.index.fulltext.queryNodes('ft_all', $q) YIELD node, score
WITH node, score
CALL {
  WITH node
  OPTIONAL MATCH p=(node)-[*1..2]-(n)
  RETURN collect(p) AS paths
}
RETURN node, score, paths
ORDER BY score DESC
LIMIT 200;
```

## 4. 파라미터 예시

```json
{"reqNo": "RQ220505984"}
{"orderNo": "PD210300167"}
{"item": "C007082051D", "from": "2022-05-01", "to": "2022-06-30"}
{"worker": "최규성", "opCode": "560", "resName": "*DBR1"}
{"code": "A01003"}
{"q": "검사대기 OR A01003 OR 최종검사"}
```

## 5. 검사의뢰번호 + 제조오더 교차 확인

```cypher
:param reqNo => 'RQ220505984';
:param orderNo => 'PD210300167';

MATCH (o:Occurrence)
WHERE exists(o.reqNo) AND o.reqNo = $reqNo
  AND exists(o.orderNo) AND o.orderNo = $orderNo
OPTIONAL MATCH p=(o)-[*1..2]-(n)
RETURN o, p
ORDER BY o.start;
```

Neo4j Browser/Bloom의 Favorites로 저장해 두면 운영자가 반복적으로 재사용할 수 있습니다.
