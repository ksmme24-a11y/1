// 룰 적용(배치) - APOC 사용 버전

// (1) 기존 IMPLIES 제거(재적용 시 깨끗하게)
MATCH (:Cause)-[r:IMPLIES]->(:DefectCode) DELETE r;

// (2) 룰 적용: Cause.text 정규식 매칭 → 코드 연결
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
  WHERE apoc.text.regexMatches(c.text, '(?i)'+rule.regex)
  WITH rule, dcs, c, apoc.text.regexGroups(c.text, '(?i)'+rule.regex) AS m
  UNWIND dcs AS dc
  MERGE (c)-[r:IMPLIES {via:rule.name}]->(dc)
    ON CREATE SET r.confidence = rule.confidence, r.matched = m
  RETURN count(*) AS applied
}
RETURN 'rules applied';

