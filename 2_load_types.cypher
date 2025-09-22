// 1차 분류-2차 상세-원인 텍스트 로딩 (+ 공정 태깅)

UNWIND [
  {
    type:'공정설계불량', detail:'가공기술 OP 불량',
    causes:[
      'OP 작도 불량 및 업데이트 누락'
    ], processes:['가공','문서']
  },
  {
    type:'공정설계불량', detail:'가공기술 PG 불량',
    causes:[
      'PG 작성 불량 및 REV 관리 불량'
    ], processes:['가공','문서']
  },
  {
    type:'공정설계불량', detail:'지그 설계 불량',
    causes:[
      '지그 설계 및 정도 관리 불량'
    ], processes:['가공','측정']
  },
  {
    type:'공정설계불량', detail:'공정간 누적 공차 발생',
    causes:[
      '전공정 치수 관리 미흡 시, 대체 데이텀 규제 미흡'
    ], processes:['측정','공정']
  },
  {
    type:'공정설계불량', detail:'측정 방법 지시 불량',
    causes:[
      '측정 방법 지시 누락 및 부적절한 측정 방법 지시(최대한 PQP 동기화)'
    ], processes:['측정','문서']
  },
  {
    type:'공정설계불량', detail:'버 제거 지시 불량',
    causes:[
      '버 발생 예측 미흡 제거 지시 미흡'
    ], processes:['가공','문서']
  },
  {
    type:'공정설계불량', detail:'가공 변형 발생',
    causes:[
      '가공 변형 예측 미흡, 변형 제거 공정 설계 미흡'
    ], processes:['가공']
  },
  {
    type:'공정설계불량', detail:'외주 공정 설계 불량',
    causes:[
      '외주 공정 OP 작도 불량'
    ], processes:['공정','문서']
  },
  {
    type:'공정설계불량', detail:'간섭 체크 미흡',
    causes:[
      '공구&지그 간섭 체크 미흡 (공구 돌출 길이 포함)'
    ], processes:['가공']
  },
  {
    type:'공정설계불량', detail:'설계 변경 누락',
    causes:[
      '설계 변경 사항 미 적용'
    ], processes:['문서']
  },
  {
    type:'공정설계불량', detail:'재고 사용 검토 불량',
    causes:[
      '재고 사용 품목 검토 불량','유사 품목 사용 검토 불량'
    ], processes:['공정','구매']
  },
  {
    type:'공정설계불량', detail:'공작물 셋팅 방법 지시 불량',
    causes:[
      '잘못된 공작물 좌표 셋팅 기준 지시'
    ], processes:['가공','문서']
  },
  {
    type:'공작물셋팅 불량', detail:'제품 고정 불량',
    causes:[
      '제품 반대로 고정, 좌우 방향 고정 불량, 단면 밀착 미흡, 척킹 압력 불량'
    ], processes:['가공']
  },
  {
    type:'공작물셋팅 불량', detail:'좌표계 셋팅 불량',
    causes:[
      'X,Y,Z,B,C축 좌표계 셋팅 불량(좌표값 계산오류/지시되지 않은 기준경&기준면 사용)'
    ], processes:['가공']
  },
  {
    type:'공구셋팅불량', detail:'공구 불출 불량',
    causes:['지시 된 공구와 다른 공구 불출 사용'], processes:['가공','자재']
  },
  {
    type:'공구셋팅불량', detail:'공구 장착 불량',
    causes:['공구 장착 방향 불량, 체결 압력 불량'], processes:['가공']
  },
  {
    type:'공구셋팅불량', detail:'Q-SETTER 측정 불량',
    causes:['Q-SETTER 측정 오류 및 누락'], processes:['측정','가공']
  },
  {
    type:'공구셋팅불량', detail:'공구 보정값 불량',
    causes:['보정값 입력 오타/누락, 보정 값 방향 및 계산오류'], processes:['가공']
  },
  {
    type:'지그셋팅불량', detail:'지그 T.I.R 셋팅 불량',
    causes:['지그 T.I.R 셋팅 미흡 및 누락'], processes:['가공','측정']
  },
  {
    type:'치수보정불량', detail:'치수 보정 오류',
    causes:['정상적으로 보정했으나 미달 또는 초과 발생'], processes:['측정','가공']
  },
  {
    type:'측정불량', detail:'측정 오차',
    causes:['치수 불량 범위 0.02이내 불량 시(자주검사 시 최소/최대 치수 합격)'], processes:['측정']
  },
  {
    type:'측정불량', detail:'측정 지시 불이행',
    causes:['지정된 측정 방법 불이행'], processes:['측정','문서']
  },
  {
    type:'pg불량', detail:'PG REV 불일치 사용',
    causes:['도면 REV과 맞지 않는 PG 사용 가공'], processes:['가공','문서']
  },
  {
    type:'소재불량', detail:'원 소재 불량',
    causes:['원소재 기포, 다른 재질 소재 입고'], processes:['자재','수입검사']
  },
  {
    type:'설비', detail:'설비 워밍업 누락',
    causes:['설비 유휴 후 워밍업 누락으로 초품 치수 불량'], processes:['설비','가공']
  },
  {
    type:'가공누락', detail:'가공누락',
    causes:['라우팅 지시 공정 누락, 식별 없이 후공정 이동 등'], processes:['공정','가공']
  },
  {
    type:'형상불량', detail:'형상불량',
    causes:['일부 형상 미가공/면취 C 요구인데 R 가공 등'], processes:['가공','검사']
  },
  {
    type:'외관', detail:'스크래치',
    causes:['표면 스크래치'], processes:['취급','검사']
  },
  {
    type:'휴먼 에러', detail:'불량 인지 부족',
    causes:['검사했으나 불량 인지 부족으로 선별 실패'], processes:['검사','교육']
  }
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

