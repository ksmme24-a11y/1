// 추가 룰(미매핑 보강 2차): 외주공정/간섭/설비수리후/연속생산변동/인식부족/소재관련

UNWIND [
  {name:'외주공정-OP-작도-불량', regex:'(외주|협력|외주\s*공정).*(OP|작도|드로잉).*(불량|오류|미흡)', priority:86, confidence:0.85,
   codes:['AE0015','AE0003'], note:'외주 OP 작도/문서 동기화 문제'},
  {name:'간섭/돌출-체크-미흡', regex:'(간섭|돌출|간섭\s*체크).*(미흡|누락)', priority:80, confidence:0.8,
   codes:['AC0008','A80004','A11011'], note:'단차/스크래치/ORIENTATION 위험'},
  {name:'설비-수리후-셋팅-불량', regex:'(설비).*(수리|정비).*(셋팅|세팅|점검).*(불량|누락|미흡)', priority:82, confidence:0.8,
   codes:['A01001','A01002','A71002'], note:'치수 흔들림/평행도 영향'},
  {name:'연속생산-치수-변동', regex:'(연속|지속).*(생산).*(갑작스런|급격한).*(치수|규격).*(변화|변동)', priority:78, confidence:0.75,
   codes:['A01001','A01002'], note:'치수 미달/초과로 표면화'},
  {name:'불량-인지-부족/선별-실패', regex:'(불량).*(인지|식별).*(부족|실패)|선별.*(실패)', priority:70, confidence:0.65,
   codes:['AE0003'], note:'절차/지시 미준수로 간주(문서)'},
  {name:'소재-절단-불량', regex:'(소재).*(절단).*(불량|편차|미절삭)', priority:76, confidence:0.72,
   codes:['AD0015'], note:'원소재 가공 전 품질 이슈'},
  {name:'소재-불출/수량-이슈', regex:'(소재).*(불출|수량).*(불량|부족|불일치)', priority:74, confidence:0.7,
   codes:['AD0005','AE0003'], note:'자재/문서 계열'}
] AS r
MERGE (rule:Rule {name:r.name})
  ON CREATE SET rule.regex=r.regex, rule.priority=r.priority, rule.confidence=r.confidence, rule.note=r.note
  ON MATCH  SET rule.regex=r.regex, rule.priority=r.priority, rule.confidence=r.confidence, rule.note=r.note
WITH r, rule
UNWIND r.codes AS code
MATCH (dc:DefectCode {code: code})
MERGE (rule)-[:MAPS_TO]->(dc);

