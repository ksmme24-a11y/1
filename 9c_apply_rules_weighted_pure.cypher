// 룰 적용(배치) - 순정 Cypher + 스코프 + 가중치(confidence) 반영

// (1) 기존 IMPLIES 제거
MATCH (:Cause)-[r:IMPLIES]->(:DefectCode) DELETE r;

// (2) 프로세스 매핑 테이블(룰명 → 관련 프로세스)
WITH [
  {rule:'측정-영점/TIR/Q-SETTER', processes:['측정']},
  {rule:'문서/REV/작업지시', processes:['문서']},
  {rule:'용접-누락/변색/롤오버', processes:['설비','가공']},
  {rule:'가공누락', processes:['공정','가공']},
  {rule:'좌표/데이텀/기준-세팅', processes:['측정','가공']},
  {rule:'제품-고정/척킹/밀착', processes:['가공']},
  {rule:'간섭/돌출/체결압력', processes:['가공']},
  {rule:'OP/PG/작도/문서', processes:['문서','가공']},
  {rule:'설비-워밍업-누락', processes:['설비','가공']},
  {rule:'원소재-기포/재질', processes:['자재','수입검사']},
  {rule:'버-제거-지시-불량', processes:['가공','문서']},
  {rule:'외관-스크래치/찍힘/버/거스러미', processes:['취급','검사']},
  {rule:'조도-초과/미달', processes:['가공','검사']},
  {rule:'치수보정/영점/보정값-오류', processes:['측정','가공']},
  // 구멍/PCD/카운터보어 계열은 가공/측정 교차 영향
  {rule:'구멍-직경-미달', processes:['가공','측정']},
  {rule:'구멍-직경-초과', processes:['가공','측정']},
  {rule:'구멍-깊이-미달', processes:['가공','측정']},
  {rule:'구멍-깊이-초과', processes:['가공','측정']},
  {rule:'PCD-공차', processes:['가공','측정']},
  {rule:'카운터보어-직경/깊이', processes:['가공','측정']}
] AS procMap

// (3) 스코프(:USES_RULE)와 프로세스 보너스를 고려하여 적용
CALL {
  WITH procMap
  MATCH (c:Cause)<-[:HAS_CAUSE]-(dd:DefectDetail)
  OPTIONAL MATCH (dd)-[:USES_RULE]->(scopedRule:Rule)
  WITH c, dd, collect(DISTINCT scopedRule) AS scoped, procMap
  MATCH (r:Rule)-[:MAPS_TO]->(dc:DefectCode)
  WITH c, dd, scoped, procMap, r, dc,
       replace(replace(coalesce(c.text,''), '\n',' '), '\r',' ') AS ctext
  WHERE ctext =~ ('(?is).*'+r.regex+'.*')
    AND (size(scoped) = 0 OR r IN scoped)
  OPTIONAL MATCH (dd)-[:INVOLVES_PROCESS]->(p:Process)
  WITH c, dd, r, collect(DISTINCT p.name) AS pnames, procMap, collect(DISTINCT dc) AS dcs, scoped
  // 보너스 계산
  WITH c, dd, r, dcs, scoped,
       (CASE WHEN size(scoped) > 0 AND r IN scoped THEN 0.15 ELSE 0.0 END) AS bonus_scope,
       [pr IN procMap WHERE pr.rule = r.name][0] AS prule,
       pnames
  WITH c, dd, r, dcs, bonus_scope, pnames, coalesce(prule.processes,[]) AS relProcs
  WITH c, dd, r, dcs, bonus_scope, pnames,
       size([pp IN pnames WHERE pp IN relProcs]) AS procHits, relProcs
  WITH c, dd, r, dcs, bonus_scope,
       (CASE WHEN procHits > 0 THEN 0.05 ELSE 0.0 END) AS bonus_proc,
       [pp IN pnames WHERE pp IN relProcs] AS procMatched
  WITH c, r, dcs, bonus_scope, bonus_proc, procMatched,
       round((r.confidence + bonus_scope + bonus_proc)*100.0)/100.0 AS confRaw
  WITH c, r, dcs, bonus_scope, bonus_proc, procMatched,
       CASE WHEN confRaw > 1.0 THEN 1.0 ELSE confRaw END AS conf
  UNWIND dcs AS dc
  MERGE (c)-[i:IMPLIES {via:r.name}]->(dc)
    ON CREATE SET i.confidence = conf, i.scope = (bonus_scope > 0), i.procMatched = procMatched
    ON MATCH  SET i.confidence = conf, i.scope = (bonus_scope > 0), i.procMatched = procMatched
  RETURN count(*) AS applied
}
RETURN 'rules applied (weighted)';
