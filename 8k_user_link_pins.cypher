// 사용자 지정 고정 매핑(직결) — 규칙 매칭 실패 보정용

// 1) 날카로움(촉수 검사 시 걸림) → A80002
CALL {
  MATCH (c:Cause)
  WITH c, replace(replace(coalesce(c.text,''),'\n',' '),'\r',' ') AS t
  WHERE t CONTAINS '날카로움' OR t CONTAINS '샤프' OR t CONTAINS '촉수'
  MATCH (dc:DefectCode {code:'A80002'})
  MERGE (c)-[:IMPLIES {via:'pin:user',confidence:0.85}]->(dc)
  RETURN count(*)
}
RETURN 'pin A80002' AS info;

// 2) 노후로 인한 정밀도 저하 지그 사용 → 기하공차 전항목
CALL {
  MATCH (c:Cause)
  WITH c, replace(replace(coalesce(c.text,''),'\n',' '),'\r',' ') AS t
  WHERE t CONTAINS '노후' AND (t CONTAINS '정밀도' OR t CONTAINS '정도') AND t CONTAINS '지그'
  MATCH (dc:DefectCode)-[:BELONGS_TO_FEATURE]->(:Feature {name:'기하공차'})
  MERGE (c)-[:IMPLIES {via:'pin:user',confidence:0.82}]->(dc)
  RETURN count(*)
}
RETURN 'pin GDT all (aging jig)' AS info;

// 3) 파손 된 지그 사용 → 기하공차 전항목
CALL {
  MATCH (c:Cause)
  WITH c, replace(replace(coalesce(c.text,''),'\n',' '),'\r',' ') AS t
  WHERE t CONTAINS '지그' AND t CONTAINS '파손'
  MATCH (dc:DefectCode)-[:BELONGS_TO_FEATURE]->(:Feature {name:'기하공차'})
  MERGE (c)-[:IMPLIES {via:'pin:user',confidence:0.8}]->(dc)
  RETURN count(*)
}
RETURN 'pin GDT all (broken jig)' AS info;

// 4) 재탭 중 파손 → AC0006
CALL {
  MATCH (c:Cause)
  WITH c, replace(replace(coalesce(c.text,''),'\n',' '),'\r',' ') AS t
  WHERE (t CONTAINS '재탭' OR t CONTAINS 'retap' OR t CONTAINS 're tap') AND t CONTAINS '파손'
  MATCH (dc:DefectCode {code:'AC0006'})
  MERGE (c)-[:IMPLIES {via:'pin:user',confidence:0.88}]->(dc)
  RETURN count(*)
}
RETURN 'pin AC0006' AS info;

