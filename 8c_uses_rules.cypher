// 특정 상세원인 → 강제 적용 룰 스코핑(:USES_RULE)

UNWIND [
  {detail:'치수 보정 오류', rules:['치수보정/영점/보정값-오류']},
  {detail:'좌표계 셋팅 불량', rules:['좌표/데이텀/기준-세팅','측정-영점/TIR/Q-SETTER']},
  {detail:'제품 고정 불량', rules:['제품-고정/척킹/밀착']},
  {detail:'PG REV 불일치 사용', rules:['문서/REV/작업지시']},
  {detail:'간섭 체크 미흡', rules:['간섭/돌출/체결압력']},
  {detail:'공구 장착 불량', rules:['공구-불출/장착/체결']},
  {detail:'설비 워밍업 누락', rules:['설비-워밍업-누락']},
  {detail:'원 소재 불량', rules:['원소재-기포/재질']},
  {detail:'스크래치', rules:['외관-스크래치/찍힘/버/거스러미']},
  {detail:'가공누락', rules:['가공누락']}
] AS row
MATCH (dd:DefectDetail {name: row.detail})
UNWIND row.rules AS rname
MATCH (rule:Rule {name: rname})
MERGE (dd)-[:USES_RULE]->(rule);

