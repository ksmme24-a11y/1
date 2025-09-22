// 문서/검사/취급/설비 충돌 관련 룰 보강

UNWIND [
  // 문서/증빙 누락
  {name:'문서-MillSheet-누락', regex:'(Mill\s*Sheet).*(누락|미첨부|미제출)', priority:90, confidence:0.9,
   codes:['AE0009','AE0010','AE0011'], note:'Mill Sheet 누락(일반/창고불출/구매사급)'},
  {name:'문서-열처리성적서-누락', regex:'(열처리).*(성적서).*(누락|미첨부|미제출)', priority:88, confidence:0.9,
   codes:['AE0012'], note:'열처리성적서 누락'},
  {name:'문서-거래명세표-누락', regex:'(거래|명세|명세표).*(누락|미첨부|미제출)', priority:88, confidence:0.85,
   codes:['AE0013'], note:'거래명세표 누락'},
  {name:'문서-작업지시서-누락', regex:'(작업지시서).*(누락|미첨부|미제출)', priority:88, confidence:0.85,
   codes:['AE0014'], note:'작업지시서 누락'},
  {name:'문서-OPDrawing-불량', regex:'(OP\s*Drawing|OP\s*드로잉|OP\s*도면).*(불량|오류)', priority:86, confidence:0.85,
   codes:['AE0015'], note:'OP Drawing 불량'},
  {name:'문서-검사기록-누락', regex:'(검사).*(기록).*(누락|미작성)', priority:86, confidence:0.85,
   codes:['AE0016'], note:'검사 기록 누락'},

  // 검사 절차/방법 상이
  {name:'검사-절차/방법-상이', regex:'(자주\s*검사|초품\s*검사|검사\s*절차|검사\s*방법).*(상이|미준수|미흡)', priority:82, confidence:0.8,
   codes:['AE0003'], note:'검사 지시/절차 이슈'},

  // 취급/외관
  {name:'취급-부주의', regex:'(취급).*(부주의|미흡)', priority:78, confidence:0.75,
   codes:['A80003','A80004','A80005'], note:'찍힘/스크래치/눌림'},
  {name:'샤프엣지/면취-미달/누락', regex:'(샤프|Sharp|엣지|Edge).*|(면취).*?(미달|누락)', priority:78, confidence:0.78,
   codes:['A50004','A90004'], note:'면취 미달/누락'},

  // 설비 충돌 / M00 탈착
  {name:'설비-충돌/M00-탈착', regex:'(M00|탈착|설비).*(충돌|멈춤|탈락)', priority:80, confidence:0.75,
   codes:['A80003','A80004','AC0008'], note:'충돌로 인한 외관/단차'}
] AS r
MERGE (rule:Rule {name:r.name})
  ON CREATE SET rule.regex=r.regex, rule.priority=r.priority, rule.confidence=r.confidence, rule.note=r.note
  ON MATCH  SET rule.regex=r.regex, rule.priority=r.priority, rule.confidence=r.confidence, rule.note=r.note
WITH r, rule
UNWIND r.codes AS code
MATCH (dc:DefectCode {code: code})
MERGE (rule)-[:MAPS_TO]->(dc);

// 스코프 보강: 해당 상세원인에 룰 고정
UNWIND [
  {detail:'취급부주의', rules:['취급-부주의']},
  {detail:'샤프엣지', rules:['샤프엣지/면취-미달/누락']},
  {detail:'M00 제품 탈착', rules:['설비-충돌/M00-탈착']},
  {detail:'공정 초품 검사 미흡', rules:['검사-절차/방법-상이']},
  {detail:'자주검사 미흡', rules:['검사-절차/방법-상이']}
] AS row
MATCH (dd:DefectDetail {name: row.detail})
UNWIND row.rules AS rname
MATCH (rule:Rule {name: rname})
MERGE (dd)-[:USES_RULE]->(rule);

