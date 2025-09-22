// 추가 룰(미매핑 보강 3차)

UNWIND [
  {name:'지그-고정-방향-불량', regex:'(지그).*(고정|방향).*(불량|미흡)', priority:88, confidence:0.85,
   codes:['A11011','A71002','A71006'], note:'지그 고정/방향 → ORIENTATION/평행/직각'},
  {name:'재탭-중-파손', regex:'(재\s*탭|re-?tap).*(파손|깨짐)', priority:82, confidence:0.8,
   codes:['AC0006','A80003'], note:'재탭 과정 파손/찍힘'},
  {name:'원소재-기포/재질-이슈', regex:'(원\s*소재|소재).*(기포|재질).*(불량|이슈|문제|혼입)', priority:80, confidence:0.78,
   codes:['AD0015'], note:'원소재 불량(재질/기포)'}
] AS r
MERGE (rule:Rule {name:r.name})
  ON CREATE SET rule.regex=r.regex, rule.priority=r.priority, rule.confidence=r.confidence, rule.note=r.note
  ON MATCH  SET rule.regex=r.regex, rule.priority=r.priority, rule.confidence=r.confidence, rule.note=r.note
WITH r, rule
UNWIND r.codes AS code
MATCH (dc:DefectCode {code: code})
MERGE (rule)-[:MAPS_TO]->(dc);

