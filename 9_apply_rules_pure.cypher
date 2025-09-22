// 룰 적용(배치) - 순정 Cypher 버전 (APOC 미사용)

// (1) 기존 IMPLIES 제거(재적용 시 깨끗하게)
MATCH (:Cause)-[r:IMPLIES]->(:DefectCode) DELETE r;

// (2) 룰 적용: Cause.text 정규식 매칭 → 코드 연결 (case-insensitive)
CALL {
  MATCH (rule:Rule)-[:MAPS_TO]->(dc:DefectCode)
  WITH rule, collect(distinct dc) AS dcs
  ORDER BY rule.priority DESC
  RETURN collect({rule:rule, dcs:dcs}) AS pack
}
CALL {
  WITH pack
  UNWIND pack AS item
  WITH item.rule AS rule, item.dcs AS dcs
  MATCH (c:Cause)
  // Java regex: String.matches는 전체일치이므로 부분일치 보장을 위해 .* .. .* 래핑
  WHERE c.text =~ ('(?i).*'+rule.regex+'.*')
  UNWIND dcs AS dc
  MERGE (c)-[r:IMPLIES {via:rule.name}]->(dc)
    ON CREATE SET r.confidence = rule.confidence
  RETURN count(*) AS applied
}
RETURN 'rules applied';
