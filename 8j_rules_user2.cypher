// 사용자 보정(6차): 휴먼에러(비코드) 지정, 전GDT 매핑, 코드 보강

// 0) 문서 코드 AE0001 보강
MERGE (fDoc:Feature {name:'문서'})
MERGE (clsNA:Class {name:'N/A'})
MERGE (dcAE0001:DefectCode {code:'AE0001'})
  ON CREATE SET dcAE0001.desc='청구 품목과 상이한 도면'
MERGE (dcAE0001)-[:BELONGS_TO_FEATURE]->(fDoc)
MERGE (dcAE0001)-[:HAS_CLASS]->(clsNA);

// 1) 휴먼에러: 비코드 지정(기존 매핑 제거 + 플래그)
CALL {
  WITH ['공정 초품 검사 절차 미 준수','도면 REV과 맞지 않는 PG 사용 가공','해당 품목 공정에 맞지 않는 PG 사용 가공'] AS texts
  UNWIND texts AS t
  MATCH (c:Cause)
  WHERE replace(replace(coalesce(c.text,''),'\n',' '),'\r',' ') CONTAINS t
  OPTIONAL MATCH (c)-[r:IMPLIES]->(:DefectCode)
  DELETE r
  SET c.non_code=true, c.category='휴먼에러'
  RETURN count(*) AS updated
}


// 2) 제거 대상: '일반공차 범위 이상 불량 시' → ignore 플래그 + 매핑 제거
CALL {
  MATCH (c:Cause)
  WHERE replace(replace(coalesce(c.text,''),'\n',' '),'\r',' ') CONTAINS '일반공차 범위 이상 불량 시'
  OPTIONAL MATCH (c)-[r:IMPLIES]->(:DefectCode)
  DELETE r
  SET c.ignore=true
  RETURN count(*) AS ignored
}


// 3) 지그 정밀도 저하/파손 → 기하공차 전 항목 매핑
CALL {
  WITH [
    {name:'지그-정밀도저하-전GDT', regex:'(지그).*(정밀도|정도).*(저하|불량)', priority:86, confidence:0.82},
    {name:'지그-파손-전GDT', regex:'(지그).*(파손)', priority:84, confidence:0.8}
  ] AS defs
  UNWIND defs AS d
  MERGE (r:Rule {name:d.name})
    ON CREATE SET r.regex=d.regex, r.priority=d.priority, r.confidence=d.confidence, r.note='GDT 전체'
    ON MATCH  SET r.regex=d.regex, r.priority=d.priority, r.confidence=d.confidence, r.note='GDT 전체'
  WITH r
  MATCH (dc:DefectCode)-[:BELONGS_TO_FEATURE]->(:Feature {name:'기하공차'})
  MERGE (r)-[:MAPS_TO]->(dc)
  RETURN count(*) AS links
}


// 4) 설계 변경 미적용 → AE0001로 매핑 룰
MERGE (fDoc2:Feature {name:'문서'})
MERGE (clsNA2:Class {name:'N/A'})
MERGE (dcAE0001b:DefectCode {code:'AE0001'})
  ON CREATE SET dcAE0001b.desc='청구 품목과 상이한 도면'
MERGE (dcAE0001b)-[:BELONGS_TO_FEATURE]->(fDoc2)
MERGE (dcAE0001b)-[:HAS_CLASS]->(clsNA2)
MERGE (rchg:Rule {name:'설계-변경-미적용→AE0001'})
  ON CREATE SET rchg.regex='(설계\s*변경).*(미적용|누락|미\\s*적용|누락|불이행)', rchg.priority=86, rchg.confidence=0.85, rchg.note='문서'
  ON MATCH  SET rchg.regex='(설계\s*변경).*(미적용|누락|미\\s*적용|누락|불이행)', rchg.priority=86, rchg.confidence=0.85, rchg.note='문서'
MERGE (rchg)-[:MAPS_TO]->(dcAE0001b);

