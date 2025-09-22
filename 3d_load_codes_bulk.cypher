// 표 기반 누락 코드 대량 보강 로더 (Feature/Class 자동 생성)

UNWIND [
  // 구멍치수 및 형상 - 일반 (추가)
  {feature:'구멍치수 및 형상', class:'일반공차', code:'A11012', desc:'구멍 GO GAGE 삽입불가(일반)'},
  {feature:'구멍치수 및 형상', class:'일반공차', code:'A11013', desc:'구멍 NO GAGE 삽입(일반)'},
  {feature:'구멍치수 및 형상', class:'일반공차', code:'A11014', desc:'HOLE 위치도 초과(일반)'},
  {feature:'구멍치수 및 형상', class:'일반공차', code:'A11015', desc:'구멍 타원점(일반)'},
  // 구멍치수 및 형상 - 정밀 (추가)
  {feature:'구멍치수 및 형상', class:'정밀공차(0.05이하)', code:'A12011', desc:'구멍 GO GAGE 삽입불가(정밀)'},
  {feature:'구멍치수 및 형상', class:'정밀공차(0.05이하)', code:'A12012', desc:'구멍 NO GAGE 삽입(정밀)'},

  // 내/외경 치수 - 일반 (추가)
  {feature:'내/외경 치수', class:'일반공차', code:'A21005', desc:'내경 Taper짐'},
  {feature:'내/외경 치수', class:'일반공차', code:'A21006', desc:'외경 Taper짐'},
  {feature:'내/외경 치수', class:'일반공차', code:'A21007', desc:'내경 단짐 발생'},
  {feature:'내/외경 치수', class:'일반공차', code:'A21008', desc:'외경 단짐 발생'},

  // 나사 (추가)
  {feature:'나사', class:'N/A', code:'A30001', desc:'나사 깊이 - 미달(Tap)'},
  {feature:'나사', class:'N/A', code:'A30002', desc:'나사 깊이 - 초과(Tap)'},
  {feature:'나사', class:'N/A', code:'A30003', desc:'나사 유효경 불량(숫나사)'},
  {feature:'나사', class:'N/A', code:'A30004', desc:'나사 골지름 불량(숫나사)'},
  {feature:'나사', class:'N/A', code:'A30005', desc:'나사 산지름 불량(숫나사)'},
  {feature:'나사', class:'N/A', code:'A30008', desc:'나사 Size 불량'},

  // 외관불량 (추가/설명 정정)
  {feature:'외관불량', class:'N/A', code:'A80001', desc:'그루브 홈 떨림'},
  {feature:'외관불량', class:'N/A', code:'A80002', desc:'거스러미(디버링 불량)'},
  {feature:'외관불량', class:'N/A', code:'A80003', desc:'찍힘'},
  {feature:'외관불량', class:'N/A', code:'A80005', desc:'척에 의한 눌림자국'},
  {feature:'외관불량', class:'N/A', code:'A80006', desc:'외관 수정 요청(검사원)'},
  {feature:'외관불량', class:'N/A', code:'A80007', desc:'과도한 다듬질로 형상 변형'},
  {feature:'외관불량', class:'N/A', code:'A80008', desc:'얼룩'},
  {feature:'외관불량', class:'N/A', code:'A80009', desc:'변색'},
  {feature:'외관불량', class:'N/A', code:'A80010', desc:'블랙라이트 부적합'},

  // 가공누락 (설명 보강)
  {feature:'가공누락', class:'N/A', code:'A90001', desc:'구멍 가공 누락'},
  {feature:'가공누락', class:'N/A', code:'A90002', desc:'나사 가공 누락'},
  {feature:'가공누락', class:'N/A', code:'A90003', desc:'슬로트 가공 누락'},
  {feature:'가공누락', class:'N/A', code:'A90004', desc:'면취 누락'},
  {feature:'가공누락', class:'N/A', code:'A90005', desc:'Weld Prep. 가공 누락'},
  {feature:'가공누락', class:'N/A', code:'A90006', desc:'라운딩 누락'},
  {feature:'가공누락', class:'N/A', code:'A90007', desc:'각도 누락'},

  // Weld Prep. 불량(신규 Feature)
  {feature:'Weld Prep', class:'N/A', code:'AA0001', desc:'Weld Prep. 폭 불량'},
  {feature:'Weld Prep', class:'N/A', code:'AA0002', desc:'Weld Prep. R 형상 불량'},
  {feature:'Weld Prep', class:'N/A', code:'AA0003', desc:'Weld Prep. R 폭 불량'},
  {feature:'Weld Prep', class:'N/A', code:'AA0004', desc:'Weld Prep. R 깊이 불량'},
  {feature:'Weld Prep', class:'N/A', code:'AA0005', desc:'Weld Prep. 각도 불량'},
  {feature:'Weld Prep', class:'N/A', code:'AA0006', desc:'Weld Prep. 언더컷 폭 불량'},
  {feature:'Weld Prep', class:'N/A', code:'AA0007', desc:'Weld Prep. 손상 및 파손'},
  {feature:'Weld Prep', class:'N/A', code:'AA0008', desc:'Weld Prep. 형상 불량'},

  // 조도 (설명 보강)
  {feature:'조도', class:'N/A', code:'AB0001', desc:'표면 조도/다듬질 정도 불량'},

  // 가공불량 (추가)
  {feature:'가공불량', class:'N/A', code:'AC0001', desc:'지시되지 않은 구멍 뚫림'},
  {feature:'가공불량', class:'N/A', code:'AC0002', desc:'구멍 가공 부위가 부풀거나 관통됨'},
  {feature:'가공불량', class:'N/A', code:'AC0003', desc:'지시되지 않은 나사 가공'},
  {feature:'가공불량', class:'N/A', code:'AC0004', desc:'슬로트 가공 불량'},
  {feature:'가공불량', class:'N/A', code:'AC0005', desc:'Slot 파손'},
  {feature:'가공불량', class:'N/A', code:'AC0006', desc:'나사 부위 파손'},
  {feature:'가공불량', class:'N/A', code:'AC0007', desc:'단짐 발생(Slot, O-ring groove)'},
  {feature:'가공불량', class:'N/A', code:'AC0009', desc:'센터마킹 규격 미달'},

  // 기타 (추가)
  {feature:'기타', class:'N/A', code:'AD0001', desc:'바이트 자국'},
  {feature:'기타', class:'N/A', code:'AD0002', desc:'파손된 공구의 부품 내 잔존'},
  {feature:'기타', class:'N/A', code:'AD0003', desc:'공구 선정 불량'},
  {feature:'기타', class:'N/A', code:'AD0004', desc:'부품 파손'},
  {feature:'기타', class:'N/A', code:'AD0005', desc:'부품 누락/미입고'},
  {feature:'기타', class:'N/A', code:'AD0006', desc:'청구와 다른 제품 혹은 서류'},
  {feature:'기타', class:'N/A', code:'AD0007', desc:'재질 불량'},
  {feature:'기타', class:'N/A', code:'AD0013', desc:'잘못된 공정에 의한 작업'},
  {feature:'기타', class:'N/A', code:'AD0014', desc:'공정 누락'},
  {feature:'기타', class:'N/A', code:'AD0015', desc:'원소재 불량'},
  {feature:'기타', class:'N/A', code:'AD0017', desc:'도금 불량'},
  {feature:'기타', class:'N/A', code:'AD0018', desc:'긴급납기로 인한 검수 누락'},
  {feature:'기타', class:'N/A', code:'AD0019', desc:'투자율 불량'},
  {feature:'기타', class:'N/A', code:'AD0020', desc:'재고 검사 불량'},
  {feature:'기타', class:'N/A', code:'AD0021', desc:'부식/녹'},
  {feature:'기타', class:'N/A', code:'AD0024', desc:'도장 두께 불량'},
  {feature:'기타', class:'N/A', code:'AD0025', desc:'협력업체 측정 기록 누락'},
  {feature:'기타', class:'N/A', code:'AD0028', desc:'외주 선삭 치수 불량(OP Drawing 치수)'},

  // 문서 (추가)
  {feature:'문서', class:'N/A', code:'AE0004', desc:'작업자 도면 불량'},
  {feature:'문서', class:'N/A', code:'AE0005', desc:'공정 불량'},
  {feature:'문서', class:'N/A', code:'AE0006', desc:'규정된 공정 순서 불이행'},
  {feature:'문서', class:'N/A', code:'AE0007', desc:'청구 불량'},
  {feature:'문서', class:'N/A', code:'AE0010', desc:'Mill Sheet 누락(창고불출)'},
  {feature:'문서', class:'N/A', code:'AE0011', desc:'Mill Sheet 누락(구매사급)'},
  {feature:'문서', class:'N/A', code:'AE0012', desc:'열처리 성적서 누락'},
  {feature:'문서', class:'N/A', code:'AE0013', desc:'거래명세표 누락'},
  {feature:'문서', class:'N/A', code:'AE0014', desc:'작업지시서 누락'},
  {feature:'문서', class:'N/A', code:'AE0015', desc:'OP Drawing 불량'},

  // 수입검사 메탈/구매품 (추가)
  {feature:'수입검사', class:'N/A', code:'B07001', desc:'수입검사_구매품 치수'},
  {feature:'수입검사', class:'N/A', code:'B07002', desc:'수입검사_구매품 외관'},
  {feature:'수입검사', class:'N/A', code:'B07003', desc:'수입검사_구매품 혼입'},
  {feature:'수입검사', class:'N/A', code:'B07005', desc:'수입검사_메탈 형상공차'},
  {feature:'수입검사', class:'N/A', code:'B07006', desc:'수입검사_메탈 재질'},
  {feature:'수입검사', class:'N/A', code:'B07008', desc:'수입검사_메탈 외관'},
  {feature:'수입검사', class:'N/A', code:'B07009', desc:'수입검사_메탈 불량 기타'},
  {feature:'수입검사', class:'N/A', code:'B07010', desc:'수입검사_메탈 가공 누락'},
  {feature:'수입검사', class:'N/A', code:'B07011', desc:'수입검사_메탈 얼룩'},
  {feature:'수입검사', class:'N/A', code:'B07012', desc:'수입검사_메탈 오리엔테이션 불량'}
] AS row
MERGE (f:Feature {name: row.feature})
MERGE (c:Class {name: row.class})
MERGE (d:DefectCode {code: row.code})
  ON CREATE SET d.desc = row.desc
  ON MATCH  SET d.desc = row.desc
MERGE (d)-[:BELONGS_TO_FEATURE]->(f)
MERGE (d)-[:HAS_CLASS]->(c);

