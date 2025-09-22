// 룰 적용(배치) - 순정 Cypher + 스코프(:USES_RULE) 고려 버전

// (1) 기존 IMPLIES 제거
MATCH (:Cause)-[r:IMPLIES]->(:DefectCode) DELETE r;

// (2) 상세원인에 스코프가 지정되면 해당 룰만 적용, 아니면 모든 룰 대상
CALL {
  MATCH (c:Cause)<-[:HAS_CAUSE]-(dd:DefectDetail)
  OPTIONAL MATCH (dd)-[:USES_RULE]->(scopedRule:Rule)
  WITH c, dd, collect(DISTINCT scopedRule) AS scoped
  MATCH (r:Rule)-[:MAPS_TO]->(dc:DefectCode)
  WHERE c.text =~ ('(?i).*'+r.regex+'.*')
    AND (size(scoped) = 0 OR r IN scoped)
  WITH c, r, collect(DISTINCT dc) AS dcs
  ORDER BY r.priority DESC
  UNWIND dcs AS dc
  MERGE (c)-[i:IMPLIES {via:r.name}]->(dc)
    ON CREATE SET i.confidence = r.confidence
  RETURN count(*) AS applied
}
RETURN 'rules applied (scoped)';

