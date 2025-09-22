// 불량 유형/상세/원인 추가 적재 (표 확장분)

UNWIND [
  // 공정설계불량
  {type:'공정설계불량', detail:'공구 설계 불량', causes:['공구 설계 및 입고 검사 불량'], processes:['가공','자재']},

  // 공작물셋팅 불량
  {type:'공작물셋팅 불량', detail:'가공중 제품 이탈', causes:['가공중 제품 이탈(미세 회전, 빠짐)'], processes:['가공']},

  // 공구셋팅불량
  {type:'공구셋팅불량', detail:'공구 런아웃 셋팅 불량', causes:['공구실 공구 런아웃 셋팅 불량 및 누락'], processes:['가공']},
  {type:'공구셋팅불량', detail:'공구 교체 후 마모 보정 미흡', causes:['공구 교체 후 마모 보정 값 입력 및 초기화 누락'], processes:['가공']},

  // 공구파손
  {type:'공구파손', detail:'공구파손', causes:['가공중 공구 파손','재탭 중 파손','공구 수명 도달 전 파손'], processes:['가공']},

  // 지그셋팅불량
  {type:'지그셋팅불량', detail:'지그 고정 방향 불량', causes:['지그 고정 방향 불량'], processes:['가공']},
  {type:'지그셋팅불량', detail:'지그 불출 불량', causes:['지시 된 지그와 다른 지그 불출 사용'], processes:['가공','자재']},
  {type:'지그셋팅불량', detail:'지그 정도 불량', causes:['노후로 인한 정밀도 저하 지그 사용','파손 된 지그 사용'], processes:['가공','검사']},

  // 치수보정불량
  {type:'치수보정불량', detail:'치수 보정 값 불량', causes:['치수 보정 시 오타 입력','치수 보정 방향 착오 및 계산 오류','가공 오 조준 오류'], processes:['가공','측정']},
  {type:'치수보정불량', detail:'공정초품 치수 보정 미흡', causes:['공정 초품 가공 시 치수 보정으로 인한 불량'], processes:['가공','측정']},

  // 측정불량
  {type:'측정불량', detail:'측정 방법 불량', causes:['자주검사 VS 수입검사 방법 상이','측정 숙련도 미달 및 미숙'], processes:['측정']},
  {type:'측정불량', detail:'자주검사 미흡', causes:['자주 검사 절차 미준수','일반공차 범위 이상 불량 시'], processes:['측정','교육']},
  {type:'측정불량', detail:'측정기 영점 셋팅 미흡', causes:['측정기 영점 셋팅 미흡 및 누락'], processes:['측정']},
  {type:'측정불량', detail:'공정 초품 검사 미흡', causes:['공정 초품 검사 절차 미 준수'], processes:['측정']},

  // pg불량
  {type:'pg불량', detail:'작업자 PG 수정 불량', causes:['공구 번호/M코드 수정 중 오타 및 오류','품질 안정화를 위한 PG 수정 불량(버/단차/떨림/칩배출/절삭공정 추가)'], processes:['가공','문서']},
  {type:'pg불량', detail:'PG 전송 불량', causes:['해당 품목 공정에 맞지 않는 PG 사용 가공'], processes:['가공','문서']},

  // 소재불량
  {type:'소재불량', detail:'원 소재 절단 불량', causes:['소재 절단 시 편차 발생','단면 미절삭 발생'], processes:['자재','가공']},
  {type:'소재불량', detail:'소재 불출 불량', causes:['지시 된 소재와 다른 소재 불출 사용'], processes:['자재']},
  {type:'소재불량', detail:'소재 수량 부족', causes:['오더 수량과 소재 수량 불일치(미달, 초과)'], processes:['자재']},

  // 설비
  {type:'설비', detail:'설비 수리 후 셋팅 불량', causes:['설비 수리 후 지그/공구/치수 보정 점검 누락'], processes:['설비','가공']},
  {type:'설비', detail:'설비 동작 오류', causes:['연속 생산 중 갑작스런 치수 변화'], processes:['설비']},

  // 외관
  {type:'외관', detail:'눌림', causes:['척/지그/취급으로 인한 눌림'], processes:['취급','가공']},
  {type:'외관', detail:'버', causes:['디버링 미흡으로 버 발생'], processes:['가공','검사']},
  {type:'외관', detail:'뜯김', causes:['취급 부주의로 인한 뜯김'], processes:['취급']},
  {type:'외관', detail:'떨림', causes:['가공 중 떨림으로 표면 흔들림'], processes:['가공']},
  {type:'외관', detail:'배 나옴(살 올라옴)', causes:['재탭/홀 입구 배 나옴'], processes:['가공']},
  {type:'외관', detail:'샤프엣지', causes:['날카로움(촉수 검사 시 걸림)'], processes:['검사','가공']},
  {type:'외관', detail:'조도', causes:['도면 요구 조도 초과'], processes:['가공','검사']},

  // 휴먼 에러
  {type:'휴먼 에러', detail:'설비 조작 오류', causes:['설비 조작 미숙'], processes:['교육','설비']},
  {type:'휴먼 에러', detail:'취급부주의', causes:['제품 취급 부주의'], processes:['취급','교육']},
  {type:'휴먼 에러', detail:'수정 대기 품목 혼입', causes:['수정 제품 식별 관리 미흡'], processes:['검사','물류']},
  {type:'휴먼 에러', detail:'M00 제품 탈착', causes:['설비 충돌'], processes:['설비']}
] AS row
MERGE (t:DefectType {name: row.type})
MERGE (d:DefectDetail {name: row.detail})
MERGE (t)-[:HAS_DETAIL]->(d)
WITH d, row
UNWIND coalesce(row.causes,[]) AS ctext
MERGE (c:Cause {text: ctext})
MERGE (d)-[:HAS_CAUSE]->(c)
WITH d, row
UNWIND coalesce(row.processes,[]) AS pname
MERGE (p:Process {name: pname})
MERGE (d)-[:INVOLVES_PROCESS]->(p);

