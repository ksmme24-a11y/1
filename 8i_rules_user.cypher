// 사용자 제공 매핑(휴먼에러/절차/자재/외관/측정/PG 등) - 5차 보강

// 보조: 누락 코드 생성(안전하게 MERGE)
MERGE (fEtc:Feature {name:'기타'})
MERGE (fExt:Feature {name:'외관불량'})
MERGE (fLen:Feature {name:'길이치수'})
MERGE (fID:Feature {name:'내/외경 치수'})
MERGE (fHole:Feature {name:'구멍치수 및 형상'})
MERGE (fSlot:Feature {name:'슬로트'})
MERGE (fGdt:Feature {name:'기하공차'})
MERGE (clsNA:Class {name:'N/A'})
MERGE (clsN:Class {name:'일반공차'})
MERGE (clsP:Class {name:'정밀공차(0.05이하)'})

// 필요 코드 보강
MERGE (dB09032:DefectCode {code:'B09032'}) ON CREATE SET dB09032.desc='제품 혼입'
MERGE (dB09032)-[:BELONGS_TO_FEATURE]->(fEtc)
MERGE (dB09032)-[:HAS_CLASS]->(clsNA);

MERGE (dAD0007:DefectCode {code:'AD0007'}) ON CREATE SET dAD0007.desc='재질 불량'
MERGE (dAD0007)-[:BELONGS_TO_FEATURE]->(fEtc)
MERGE (dAD0007)-[:HAS_CLASS]->(clsNA);

// 사용자 룰 정의
UNWIND [
  {name:'휴먼에러-가공-오조준-오류', regex:'(가공).*(오\s*조준|오조준|조준.*오류)', priority:92, confidence:0.85, codes:['A11011','A71002','A71006'], note:'가공 오조준→ORIENTATION/평행/직각'},
  {name:'휴먼에러-공구번호/M코드-오류', regex:'(공구\s*번호|M\s*코드|M\s*code).*(오타|오류)', priority:90, confidence:0.85, codes:['AE0003','AE0015'], note:'설정/지시 오류'},
  {name:'휴먼에러-PG-부적합', regex:'(PG).*(맞지|부적합|해당.*품목.*공정.*맞지)', priority:88, confidence:0.85, codes:['AE0015','AE0003'], note:'PG 불일치/부적합'},
  {name:'설비-조작-미숙', regex:'(설비).*(조작).*(미숙|오류)', priority:80, confidence:0.75, codes:['AE0003'], note:'절차/지시 미이행'},
  {name:'식별-관리-미흡(제품 혼입)', regex:'(수정|제품).*?(식별|관리).*(미흡|부족)|제품.*혼입', priority:90, confidence:0.9, codes:['B09032'], note:'혼입'},
  {name:'재탭-중-파손', regex:'(재\s*탭|re-?tap).*(파손|깨짐)', priority:86, confidence:0.85, codes:['AC0006'], note:'나사부 파손'},
  {name:'자재-오불출/다른-소재', regex:'(지시|요청).*?(소재|자재).*(다른|오|틀린).*?(불출|사용)', priority:84, confidence:0.8, codes:['AD0007','AE0007'], note:'재질/청구 이슈'},
  {name:'눌림/취급/척/지그', regex:'(척|지그|취급).*(눌림|자국)', priority:82, confidence:0.8, codes:['A80005','A80006','A80003'], note:'눌림/수정/찍힘'},
  {name:'날카로움/샤프엣지', regex:'(샤프|Sharp|엣지|촉수).*?(걸림|날카로움)', priority:80, confidence:0.78, codes:['A80002'], note:'거스러미/날카로움'},
  {name:'초품-보정-불량→내/외경', regex:'(초품|공정\s*초품).*(보정).*(불량)', priority:88, confidence:0.85, codes:['A21001','A21002','A21003','A21004'], note:'초품 보정 영향'},
  {name:'초품-검사-절차-미준수', regex:'(초품).*(검사).*(절차).*(미준수|미이행)', priority:86, confidence:0.82, codes:['A21001','A21002','A21003','A21004'], note:'초품 검사 절차 이슈'},
  {name:'지그-노후/정밀도-저하', regex:'(지그).*(노후|정밀도).*(저하|불량)', priority:84, confidence:0.8, codes:['A71010','A71011'], note:'위치도/대칭도'},
  {name:'단면-미절삭', regex:'(단면).*(미절삭|미가공)', priority:82, confidence:0.8, codes:['A02005'], note:'두께 미달'},
  {name:'테이퍼-짐', regex:'(Taper|테이퍼).*(짐|불량)', priority:80, confidence:0.78, codes:['A21005','A21006'], note:'내/외경 Taper짐'},
  {name:'직경공차-미달/초과(일반)', regex:'(직경).*(공차).*(미달|초과)', priority:86, confidence:0.84, codes:['A11007','A11008'], note:'직경공차 일반'},
  {name:'카운터보어-직경-미달/초과(정밀)', regex:'(카운트.?보어|counter.?bore).*(직경).*(미달|초과)', priority:84, confidence:0.82, codes:['A12001','A12002'], note:'CB 직경 정밀'}
] AS r
MERGE (rule:Rule {name:r.name})
  ON CREATE SET rule.regex=r.regex, rule.priority=r.priority, rule.confidence=r.confidence, rule.note=r.note
  ON MATCH  SET rule.regex=r.regex, rule.priority=r.priority, rule.confidence=r.confidence, rule.note=r.note
WITH r, rule
UNWIND r.codes AS code
MATCH (dc:DefectCode {code: code})
MERGE (rule)-[:MAPS_TO]->(dc);

// 측정 숙련도 미달/미숙 → 길이/구멍/내외경/슬로트(일반공차) 전체 매핑
MERGE (ruleM:Rule {name:'측정-숙련도-미달/미숙(일반)'} )
  ON CREATE SET ruleM.regex='(측정).*(숙련|미숙)', ruleM.priority=78, ruleM.confidence=0.75, ruleM.note='일반공차 전반'
WITH ruleM
MATCH (dc:DefectCode)-[:BELONGS_TO_FEATURE]->(f:Feature)
MATCH (dc)-[:HAS_CLASS]->(cl:Class {name:'일반공차'})
WHERE f.name IN ['길이치수','구멍치수 및 형상','내/외경 치수','슬로트']
MERGE (ruleM)-[:MAPS_TO]->(dc);

