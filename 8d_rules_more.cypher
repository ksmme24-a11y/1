// 추가 룰(미매핑 원인 보강)

UNWIND [
  {name:'설계변경-미적용/누락', regex:'(설계\s*변경).*(미적용|누락|불이행)', priority:82, confidence:0.8,
   codes:['AE0015','AE0003'], note:'설계 변경 미적용 → 문서/OP Drawing'},
  {name:'재고/유사품목-검토/사용-불량', regex:'(재고|유사\s*품목).*(검토|사용).*(불량|미흡)', priority:78, confidence:0.75,
   codes:['AD0020','AE0003'], note:'재고 검사/문서 지시 이슈'},
  {name:'PG-전송-불량', regex:'(PG|프로그램).*(전송).*(불량|오류|미흡)', priority:86, confidence:0.85,
   codes:['AE0015','AE0003'], note:'PG 전송/동기화 문제'},
  {name:'공구-설계/입고-검사-불량', regex:'(공구).*(설계|입고).*(검사).*(불량)', priority:80, confidence:0.75,
   codes:['AD0003'], note:'공구 선정/검사 문제'},
  {name:'자주검사/초품검사-미준수/방법상이', regex:'(자주\s*검사|초품\s*검사|검사\s*절차).*(미준수|미흡)|자주검사.*수입검사.*(상이)', priority:70, confidence:0.7,
   codes:['AE0003'], note:'절차/지시 불이행(문서)'}
] AS r
MERGE (rule:Rule {name:r.name})
  ON CREATE SET rule.regex=r.regex, rule.priority=r.priority, rule.confidence=r.confidence, rule.note=r.note
  ON MATCH  SET rule.regex=r.regex, rule.priority=r.priority, rule.confidence=r.confidence, rule.note=r.note
WITH r, rule
UNWIND r.codes AS code
MATCH (dc:DefectCode {code: code})
MERGE (rule)-[:MAPS_TO]->(dc);

