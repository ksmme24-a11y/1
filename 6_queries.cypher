// 운영 예시 쿼리 모음

// Q1. 특정 상세원인 → 잠재 발생 코드 Top 20
// 예: '치수 보정 오류'
MATCH (:DefectDetail {name:'치수 보정 오류'})-[:POTENTIALLY_TRIGGERS]->(dc:DefectCode)
RETURN dc.code, dc.desc LIMIT 20;

// Q2. 특정 코드의 상위 원인 트레이스
MATCH (dc:DefectCode {code:'A12010'})<-[:POTENTIALLY_TRIGGERS]-(dd:DefectDetail)-[:HAS_CAUSE]->(c:Cause)
RETURN dd.name AS detail, collect(c.text) AS causes;

// Q3. 공정/영역별로 많이 연결된 코드 수
MATCH (:Process {name:'측정'})<-[:INVOLVES_PROCESS]-(dd:DefectDetail)-[:POTENTIALLY_TRIGGERS]->(dc)
RETURN dc.code, count(*) AS hits ORDER BY hits DESC LIMIT 30;

// Q4. Feature-클래스별 코드 리스트
MATCH (dc:DefectCode)-[:BELONGS_TO_FEATURE]->(f:Feature),
      (dc)-[:HAS_CLASS]->(cls:Class)
RETURN f.name, cls.name, collect(dc.code) AS codes;

// Q5. 룰 적용 결과 요약: 코드 히트 상위 20
MATCH (c:Cause)-[i:IMPLIES]->(dc:DefectCode)
RETURN dc.code, count(*) AS hits ORDER BY hits DESC LIMIT 20;

// Q6. 룰 적용 결과 요약: 룰별 사용 빈도
MATCH (c:Cause)-[i:IMPLIES]->(:DefectCode)
RETURN i.via AS rule, count(*) AS cnt ORDER BY cnt DESC;

// Q7. 룰 미적용 원인 샘플(튜닝 대상)
MATCH (c:Cause)
WHERE NOT (c)-[:IMPLIES]->(:DefectCode)
RETURN c.text AS cause LIMIT 20;

// Q8. 신뢰도 가중치(confidence) 기반 Top 20 코드
MATCH (c:Cause)-[i:IMPLIES]->(dc:DefectCode)
RETURN dc.code, count(*) AS hits, round(avg(i.confidence)*100)/100 AS avg_conf
ORDER BY hits DESC, avg_conf DESC LIMIT 20;

// Q9. 특정 상세원인에 대한 코드/신뢰도 목록 예시
// 예: 좌표계 셋팅 불량
MATCH (:DefectDetail {name:'좌표계 셋팅 불량'})-[:HAS_CAUSE]->(c:Cause)-[i:IMPLIES]->(dc:DefectCode)
RETURN dc.code, round(avg(i.confidence)*100)/100 AS avg_conf, collect(i.via) AS via_rules
ORDER BY avg_conf DESC;
