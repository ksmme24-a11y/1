// 추가 룰(미매핑 보강 4차): 고정 반대/척킹압력/좌표 계산오류/면취C↔R/배나옴/외주 공정 설계 불량/측정 오차

UNWIND [
  {name:'제품-반대로-고정', regex:'(제품|공작물).*(반대|반대로).*(고정)', priority:88, confidence:0.85,
   codes:['A11011','A71006'], note:'반대 방향 고정 → ORIENTATION/직각'},
  {name:'척킹-압력-불량', regex:'(척킹).*(압력).*(불량|미흡)', priority:80, confidence:0.75,
   codes:['A80005','A11011'], note:'눌림자국/ORIENTATION'},
  {name:'좌표-계산오류/기준미지시', regex:'(좌표|좌표계).*(계산|오류)|기준(경|면).*(미지시|미표시|미사용)|지시\s*되지\s*않은\s*기준', priority:90, confidence:0.88,
   codes:['A11011','A71002','A71006'], note:'좌표 계산/기준 문제'},
  {name:'면취-C↔R-혼동', regex:'(면취|C\s*면).*(R\s*가공)|\bR\b.*(면취|C\s*면)', priority:82, confidence:0.8,
   codes:['A50004','A50006'], note:'C↔R 혼동'},
  {name:'배-나옴/살-올라옴', regex:'(배\s*나옴|살\s*올라옴)', priority:72, confidence:0.7,
   codes:['A80003'], note:'외관 찍힘/돌출'},
  {name:'외주공정-설계-불량', regex:'(외주|협력).*(공정).*(설계).*(불량|미흡|오류)', priority:80, confidence:0.75,
   codes:['AE0003'], note:'문서/지시'},
  {name:'측정-오차', regex:'(측정).*(오차|편차)', priority:70, confidence:0.7,
   codes:['A71001','A72001'], note:'평면도(일반/정밀) 근사 매핑'}
] AS r
MERGE (rule:Rule {name:r.name})
  ON CREATE SET rule.regex=r.regex, rule.priority=r.priority, rule.confidence=r.confidence, rule.note=r.note
  ON MATCH  SET rule.regex=r.regex, rule.priority=r.priority, rule.confidence=r.confidence, rule.note=r.note
WITH r, rule
UNWIND r.codes AS code
MATCH (dc:DefectCode {code: code})
MERGE (rule)-[:MAPS_TO]->(dc);

