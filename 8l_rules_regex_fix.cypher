// Persist the 4 pinned cases as regex rules (high priority), so re-apply recreates them

UNWIND [
  {name:'EXACT-샤프/촉수-걸림', regex:'(날카로움\(촉수.*걸림\)|샤프.*걸림|촉수.*걸림)', priority:99, confidence:0.9, codes:['A80002'], note:'샤프엣지/촉수 걸림 → 거스러미'},
  {name:'EXACT-노후-정밀도저하-지그', regex:'(노후).*?(정밀도|정도).*?(저하|불량).*?(지그)', priority:98, confidence:0.85, codes:'GDT_ALL', note:'지그 노후 정밀도 저하 → GDT 전체'},
  {name:'EXACT-재탭-중-파손', regex:'(재\s*탭|re\s*-?tap).*?파손', priority:98, confidence:0.88, codes:['AC0006'], note:'재탭 중 파손 → AC0006'},
  {name:'EXACT-지그-파손', regex:'지그.*파손', priority:97, confidence:0.85, codes:'GDT_ALL', note:'지그 파손 → GDT 전체'}
] AS r
MERGE (rule:Rule {name:r.name})
  ON CREATE SET rule.regex=r.regex, rule.priority=r.priority, rule.confidence=r.confidence, rule.note=r.note
  ON MATCH  SET rule.regex=r.regex, rule.priority=r.priority, rule.confidence=r.confidence, rule.note=r.note
WITH r, rule
CALL {
  WITH r, rule
  WITH r, rule, r.codes AS cs
  WHERE cs <> 'GDT_ALL'
  UNWIND cs AS code
  MATCH (dc:DefectCode {code: code})
  MERGE (rule)-[:MAPS_TO]->(dc)
  RETURN count(*) AS x
}
CALL {
  WITH r, rule
  WITH r, rule WHERE r.codes = 'GDT_ALL'
  MATCH (dc:DefectCode)-[:BELONGS_TO_FEATURE]->(:Feature {name:'기하공차'})
  MERGE (rule)-[:MAPS_TO]->(dc)
  RETURN count(*) AS y
}
RETURN 'regex-fix-installed' AS info;

