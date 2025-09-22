// 추가 튠업 룰: 좌표/데이텀/간섭/공구/설비/원소재/척킹/자주검사 등 커버리지 확대

UNWIND [
  {name:'좌표/데이텀/기준-세팅', regex:'(좌표|좌표계|데이텀|기준면|기준경|기준\s*점|원점)', priority:92, confidence:0.85,
   codes:['A11011','A71010','A71002','A71006','A72001','A72006'], note:'좌표/데이텀/기준 문제 → ORIENTATION/위치/평면/직각'},
  {name:'간섭/돌출/체결압력', regex:'(간섭|돌출|체결\s*압력)', priority:75, confidence:0.7,
   codes:['AC0008','A80004'], note:'간섭/돌출 스크래치·단차'},
  {name:'공구-불출/장착/체결', regex:'(공구).*(불출|장착|방향|체결|압력|다름)', priority:78, confidence:0.75,
   codes:['AC0008','A11011'], note:'공구 상태/방향 문제 → 형상/ORIENTATION/가공불량'},
  {name:'OP/PG/작도/문서', regex:'(OP|PG|작도|프로그램).*(불량|누락|불일치|미적용|오류)', priority:82, confidence:0.8,
   codes:['AE0003','AE0008','AE0009'], note:'문서/REV/작업지시 계열'},
  {name:'설비-워밍업-누락', regex:'(설비).*(워밍.?업|warming).*(누락|미실시)', priority:70, confidence:0.65,
   codes:['A01001','A01002'], note:'초품 치수 흔들림'},
  {name:'원소재-기포/재질', regex:'(원소재|재질|기포)', priority:70, confidence:0.7,
   codes:['AF1004'], note:'원소재 품질 이슈(대표코드)'},
  {name:'제품-고정/척킹/밀착', regex:'(제품|공작물).*(고정|척킹|밀착|좌우|방향).*(불량|미흡)', priority:85, confidence:0.8,
   codes:['A11011','A72001','A71006'], note:'고정·척킹 문제 → ORIENTATION/평면/직각'},
  {name:'자주검사/최소/최대', regex:'(자주검사|최소|최대).*(합격|판정|치수)', priority:68, confidence:0.6,
   codes:['A01001','A01002'], note:'치수 상하한 이슈'},
  {name:'버-제거-지시-불량', regex:'(버|거스러미).*(제거|지시).*(불량|미흡|누락)', priority:72, confidence:0.75,
   codes:['A80003'], note:'버 발생/제거 관련 외관'}
] AS r
MERGE (rule:Rule {name:r.name})
  ON CREATE SET rule.regex=r.regex, rule.priority=r.priority, rule.confidence=r.confidence, rule.note=r.note
  ON MATCH  SET rule.regex=r.regex, rule.priority=r.priority, rule.confidence=r.confidence, rule.note=r.note
WITH r, rule
UNWIND r.codes AS code
OPTIONAL MATCH (dc:DefectCode {code: code})
WITH rule, dc WHERE dc IS NOT NULL
MERGE (rule)-[:MAPS_TO]->(dc);

