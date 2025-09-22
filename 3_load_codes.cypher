// 불량코드/그룹/설명 입력: Feature, Class, DefectCode

// 클래스 노드(일반/정밀) 미리 생성
UNWIND ['일반공차','정밀공차(0.05이하)','N/A'] AS cls
MERGE (:Class {name: cls});

// Feature 노드(대표 군)
UNWIND [
 '길이치수','구멍치수 및 형상','내/외경 치수','나사','슬로트',
 '각도/면취/라운딩','오링그루브/그루브','기하공차','외관불량','가공누락',
 '조도','가공불량','문서','원소재','DP','OD/ID','Capsule','EF','조립','세척',
 '수입검사','기타','성능불량','FC'
] AS f
MERGE (:Feature {name:f});

// 코드 로딩 (샘플 + 패턴, 동일 형식으로 확장 가능)
UNWIND [
  // 길이치수 - 일반
  {feature:'길이치수', class:'일반공차', code:'A01001', desc:'단진부위 공차 불량 - 미달(일반)'},
  {feature:'길이치수', class:'일반공차', code:'A01002', desc:'단진부위 공차 불량 - 초과(일반)'},
  {feature:'길이치수', class:'일반공차', code:'A01003', desc:'전체길이 - 미달(일반)'},
  {feature:'길이치수', class:'일반공차', code:'A01004', desc:'전체길이 - 초과(일반)'},
  {feature:'길이치수', class:'일반공차', code:'A01005', desc:'두께불량 - 미달(일반)'},
  {feature:'길이치수', class:'일반공차', code:'A01006', desc:'두께불량 - 초과(일반)'},
  // 길이치수 - 정밀
  {feature:'길이치수', class:'정밀공차(0.05이하)', code:'A02001', desc:'단진부위 공차불량 - 미달(정밀)'},
  {feature:'길이치수', class:'정밀공차(0.05이하)', code:'A02006', desc:'두께불량 - 초과(정밀)'},
  // 구멍치수 및 형상 - 일반 (일부)
  {feature:'구멍치수 및 형상', class:'일반공차', code:'A11007', desc:'구멍직경공차 - 미달(일반)'},
  {feature:'구멍치수 및 형상', class:'일반공차', code:'A11008', desc:'구멍직경공차 - 초과(일반)'},
  {feature:'구멍치수 및 형상', class:'일반공차', code:'A11011', desc:'구멍위치불량(ORIENTATION)(일반)'},
  // 구멍치수 및 형상 - 정밀 (일부)
  {feature:'구멍치수 및 형상', class:'정밀공차(0.05이하)', code:'A12005', desc:'구멍직경공차 - 미달(정밀)'},
  {feature:'구멍치수 및 형상', class:'정밀공차(0.05이하)', code:'A12010', desc:'Hole 위치도 초과(정밀)'},
  // 내/외경 - 일반 & 정밀 (일부)
  {feature:'내/외경 치수', class:'일반공차', code:'A21003', desc:'외경공차 - 미달(일반)'},
  {feature:'내/외경 치수', class:'정밀공차(0.05이하)', code:'A22004', desc:'외경공차 - 초과(정밀)'},
  {feature:'내/외경 치수', class:'정밀공차(0.05이하)', code:'A22007', desc:'끼워맞춤 외경 - 미달'},
  // 나사 (일부)
  {feature:'나사', class:'N/A', code:'A30006', desc:'나사 Go Gage 삽입불가'},
  {feature:'나사', class:'N/A', code:'A30009', desc:'나사 드릴 깊이 - 미달'},
  // 슬로트 (일부)
  {feature:'슬로트', class:'일반공차', code:'A41003', desc:'슬로트 폭 치수 - 미달(일반)'},
  {feature:'슬로트', class:'정밀공차(0.05이하)', code:'A42004', desc:'슬로트 폭 치수 - 초과(정밀)'},
  // 각도/면취/라운딩
  {feature:'각도/면취/라운딩', class:'N/A', code:'A50001', desc:'각도 초과'},
  {feature:'각도/면취/라운딩', class:'N/A', code:'A50004', desc:'면취 미달'},
  // 오링그루브/그루브 (일부)
  {feature:'오링그루브/그루브', class:'일반공차', code:'A61003', desc:'오링그루브 폭치수 - 미달'},
  {feature:'오링그루브/그루브', class:'정밀공차(0.05이하)', code:'A62006', desc:'오링그루브 깊이 - 초과(정밀)'},
  // 기하공차 (일부)
  {feature:'기하공차', class:'일반공차', code:'A71010', desc:'위치도'},
  {feature:'기하공차', class:'정밀공차(0.05이하)', code:'A72001', desc:'평면도'},
  // 외관/가공누락/조도/가공불량 등 (일부)
  {feature:'외관불량', class:'N/A', code:'A80004', desc:'스크래치'},
  {feature:'가공누락', class:'N/A', code:'A90004', desc:'면취 누락'},
  {feature:'조도', class:'N/A', code:'AB0001', desc:'표면 조도 불량'},
  {feature:'가공불량', class:'N/A', code:'AC0008', desc:'단차 발생'},
  // 문서/원소재/DP/OD-ID/Capsule/EF/조립/세척/수입검사/기타/성능불량/FC (샘플)
  {feature:'문서', class:'N/A', code:'AE0003', desc:'작업지시 불량'},
  {feature:'원소재', class:'N/A', code:'AF1004', desc:'두께 미달(박판/코일)'},
  {feature:'DP', class:'N/A', code:'AG0005', desc:'DP Burr'},
  {feature:'OD/ID', class:'N/A', code:'B01005', desc:'OD Root Gap'},
  {feature:'Capsule', class:'N/A', code:'B02001', desc:'캡슐 변색'},
  {feature:'EF', class:'N/A', code:'B04010', desc:'용접 누락'},
  {feature:'조립', class:'N/A', code:'B05008', desc:'구성품 누락'},
  {feature:'세척', class:'N/A', code:'B06003', desc:'세척 후 변색/녹'},
  {feature:'수입검사', class:'N/A', code:'B07004', desc:'수입검사_메탈 치수'},
  {feature:'기타', class:'N/A', code:'B09048', desc:'용접 기록 누락'},
  {feature:'성능불량', class:'N/A', code:'BZ0015', desc:'공압/수압 테스트'},
  {feature:'FC', class:'N/A', code:'F01005', desc:'Face - 조도 불량'}
] AS row
] AS row
MATCH (f:Feature {name: row.feature})
MATCH (c:Class {name: row.class})
MERGE (d:DefectCode {code: row.code})
  ON CREATE SET d.desc = row.desc
  ON MATCH  SET d.desc = row.desc
MERGE (d)-[:BELONGS_TO_FEATURE]->(f)
MERGE (d)-[:HAS_CLASS]->(c);

// -------- 추가 코드 확장: 룰에서 참조하는 코드 커버리지 강화 --------
UNWIND [
  // 길이치수 - 정밀(추가)
  {feature:'길이치수', class:'정밀공차(0.05이하)', code:'A02002', desc:'단진부위 공차불량 - 초과(정밀)'},
  {feature:'길이치수', class:'정밀공차(0.05이하)', code:'A02003', desc:'전체길이 - 미달(정밀)'},
  {feature:'길이치수', class:'정밀공차(0.05이하)', code:'A02004', desc:'전체길이 - 초과(정밀)'},
  {feature:'길이치수', class:'정밀공차(0.05이하)', code:'A02005', desc:'두께불량 - 미달(정밀)'},

  // 구멍치수 및 형상 - 일반/정밀(추가)
  {feature:'구멍치수 및 형상', class:'일반공차', code:'A11001', desc:'카운터보어 직경 - 미달(일반)'},
  {feature:'구멍치수 및 형상', class:'일반공차', code:'A11002', desc:'카운터보어 직경 - 초과(일반)'},
  {feature:'구멍치수 및 형상', class:'일반공차', code:'A11003', desc:'카운터보어 깊이 - 미달(일반)'},
  {feature:'구멍치수 및 형상', class:'일반공차', code:'A11004', desc:'카운터보어 깊이 - 초과(일반)'},
  {feature:'구멍치수 및 형상', class:'일반공차', code:'A11005', desc:'PCD - 미달(일반)'},
  {feature:'구멍치수 및 형상', class:'일반공차', code:'A11006', desc:'PCD - 초과(일반)'},
  {feature:'구멍치수 및 형상', class:'일반공차', code:'A11009', desc:'구멍 깊이 - 미달(일반)'},
  {feature:'구멍치수 및 형상', class:'일반공차', code:'A11010', desc:'구멍 깊이 - 초과(일반)'},
  {feature:'구멍치수 및 형상', class:'정밀공차(0.05이하)', code:'A12001', desc:'카운터보어 직경 - 미달(정밀)'},
  {feature:'구멍치수 및 형상', class:'정밀공차(0.05이하)', code:'A12002', desc:'카운터보어 직경 - 초과(정밀)'},
  {feature:'구멍치수 및 형상', class:'정밀공차(0.05이하)', code:'A12003', desc:'카운터보어 깊이 - 미달(정밀)'},
  {feature:'구멍치수 및 형상', class:'정밀공차(0.05이하)', code:'A12004', desc:'카운터보어 깊이 - 초과(정밀)'},
  {feature:'구멍치수 및 형상', class:'정밀공차(0.05이하)', code:'A12006', desc:'구멍직경공차 - 초과(정밀)'},
  {feature:'구멍치수 및 형상', class:'정밀공차(0.05이하)', code:'A12007', desc:'구멍 깊이 - 미달(정밀)'},
  {feature:'구멍치수 및 형상', class:'정밀공차(0.05이하)', code:'A12008', desc:'구멍 깊이 - 초과(정밀)'},
  {feature:'구멍치수 및 형상', class:'정밀공차(0.05이하)', code:'A12009', desc:'구멍 ORIENTATION 불량(정밀)'},

  // 내/외경 - 일반 & 정밀 (추가)
  {feature:'내/외경 치수', class:'일반공차', code:'A21001', desc:'내경공차 - 미달(일반)'},
  {feature:'내/외경 치수', class:'일반공차', code:'A21002', desc:'내경공차 - 초과(일반)'},
  {feature:'내/외경 치수', class:'일반공차', code:'A21004', desc:'외경공차 - 초과(일반)'},
  {feature:'내/외경 치수', class:'정밀공차(0.05이하)', code:'A22001', desc:'내경공차 - 미달(정밀)'},
  {feature:'내/외경 치수', class:'정밀공차(0.05이하)', code:'A22002', desc:'내경공차 - 초과(정밀)'},
  {feature:'내/외경 치수', class:'정밀공차(0.05이하)', code:'A22003', desc:'외경공차 - 미달(정밀)'},
  {feature:'내/외경 치수', class:'정밀공차(0.05이하)', code:'A22005', desc:'끼워맞춤 내경 - 미달'},
  {feature:'내/외경 치수', class:'정밀공차(0.05이하)', code:'A22006', desc:'끼워맞춤 내경 - 초과'},
  {feature:'내/외경 치수', class:'정밀공차(0.05이하)', code:'A22008', desc:'끼워맞춤 외경 - 초과'},

  // 나사
  {feature:'나사', class:'N/A', code:'A30007', desc:'나사 No Gage 삽입'},
  {feature:'나사', class:'N/A', code:'A30010', desc:'나사 드릴 깊이 - 초과'},

  // 슬로트(추가)
  {feature:'슬로트', class:'일반공차', code:'A41001', desc:'슬로트 폭 치수 - 미달(일반)'},
  {feature:'슬로트', class:'일반공차', code:'A41002', desc:'슬로트 폭 치수 - 초과(일반)'},
  {feature:'슬로트', class:'일반공차', code:'A41004', desc:'슬로트 깊이 치수 - 초과(일반)'},
  {feature:'슬로트', class:'정밀공차(0.05이하)', code:'A42001', desc:'슬로트 폭 치수 - 미달(정밀)'},
  {feature:'슬로트', class:'정밀공차(0.05이하)', code:'A42002', desc:'슬로트 폭 치수 - 초과(정밀)'},
  {feature:'슬로트', class:'정밀공차(0.05이하)', code:'A42003', desc:'슬로트 깊이 치수 - 미달(정밀)'},

  // 각도/면취/라운딩(추가)
  {feature:'각도/면취/라운딩', class:'N/A', code:'A50002', desc:'각도 미달'},
  {feature:'각도/면취/라운딩', class:'N/A', code:'A50003', desc:'각도 누락'},
  {feature:'각도/면취/라운딩', class:'N/A', code:'A50005', desc:'라운딩 미달'},
  {feature:'각도/면취/라운딩', class:'N/A', code:'A50006', desc:'라운딩 초과'},

  // 오링그루브/그루브(추가)
  {feature:'오링그루브/그루브', class:'일반공차', code:'A61001', desc:'오링그루브 직경 - 미달'},
  {feature:'오링그루브/그루브', class:'일반공차', code:'A61002', desc:'오링그루브 직경 - 초과'},
  {feature:'오링그루브/그루브', class:'일반공차', code:'A61004', desc:'오링그루브 폭치수 - 초과'},
  {feature:'오링그루브/그루브', class:'일반공차', code:'A61005', desc:'오링그루브 깊이 - 미달'},
  {feature:'오링그루브/그루브', class:'일반공차', code:'A61006', desc:'오링그루브 깊이 - 초과'},
  {feature:'오링그루브/그루브', class:'일반공차', code:'A61007', desc:'오링그루브 내경 - 미달'},
  {feature:'오링그루브/그루브', class:'일반공차', code:'A61008', desc:'오링그루브 내경 - 초과'},
  {feature:'오링그루브/그루브', class:'일반공차', code:'A61009', desc:'오링그루브 외경 - 미달'},
  {feature:'오링그루브/그루브', class:'일반공차', code:'A61010', desc:'오링그루브 외경 - 초과'},
  {feature:'오링그루브/그루브', class:'정밀공차(0.05이하)', code:'A62001', desc:'오링그루브 직경 - 미달(정밀)'},
  {feature:'오링그루브/그루브', class:'정밀공차(0.05이하)', code:'A62002', desc:'오링그루브 직경 - 초과(정밀)'},
  {feature:'오링그루브/그루브', class:'정밀공차(0.05이하)', code:'A62003', desc:'오링그루브 폭치수 - 미달(정밀)'},
  {feature:'오링그루브/그루브', class:'정밀공차(0.05이하)', code:'A62004', desc:'오링그루브 폭치수 - 초과(정밀)'},
  {feature:'오링그루브/그루브', class:'정밀공차(0.05이하)', code:'A62005', desc:'오링그루브 깊이 - 미달(정밀)'},
  {feature:'오링그루브/그루브', class:'정밀공차(0.05이하)', code:'A62007', desc:'오링그루브 내경 - 미달(정밀)'},
  {feature:'오링그루브/그루브', class:'정밀공차(0.05이하)', code:'A62008', desc:'오링그루브 내경 - 초과(정밀)'},
  {feature:'오링그루브/그루브', class:'정밀공차(0.05이하)', code:'A62009', desc:'오링그루브 외경 - 미달(정밀)'},
  {feature:'오링그루브/그루브', class:'정밀공차(0.05이하)', code:'A62010', desc:'오링그루브 외경 - 초과(정밀)'},

  // 기하공차(일반/정밀) 추가
  {feature:'기하공차', class:'일반공차', code:'A71001', desc:'평면도(일반)'},
  {feature:'기하공차', class:'일반공차', code:'A71002', desc:'평행도(일반)'},
  {feature:'기하공차', class:'일반공차', code:'A71003', desc:'진직도(일반)'},
  {feature:'기하공차', class:'일반공차', code:'A71004', desc:'진원도(일반)'},
  {feature:'기하공차', class:'일반공차', code:'A71005', desc:'동심도(일반)'},
  {feature:'기하공차', class:'일반공차', code:'A71006', desc:'직각도(일반)'},
  {feature:'기하공차', class:'일반공차', code:'A71007', desc:'경사도(일반)'},
  {feature:'기하공차', class:'일반공차', code:'A71008', desc:'원통도(일반)'},
  {feature:'기하공차', class:'일반공차', code:'A71009', desc:'흔들림(일반)'},
  {feature:'기하공차', class:'일반공차', code:'A71011', desc:'대칭도(일반)'},
  {feature:'기하공차', class:'일반공차', code:'A71012', desc:'윤곽도(일반)'},
  {feature:'기하공차', class:'정밀공차(0.05이하)', code:'A72002', desc:'평행도(정밀)'},
  {feature:'기하공차', class:'정밀공차(0.05이하)', code:'A72003', desc:'진직도(정밀)'},
  {feature:'기하공차', class:'정밀공차(0.05이하)', code:'A72004', desc:'진원도(정밀)'},
  {feature:'기하공차', class:'정밀공차(0.05이하)', code:'A72005', desc:'동심도(정밀)'},
  {feature:'기하공차', class:'정밀공차(0.05이하)', code:'A72006', desc:'직각도(정밀)'},
  {feature:'기하공차', class:'정밀공차(0.05이하)', code:'A72007', desc:'경사도(정밀)'},
  {feature:'기하공차', class:'정밀공차(0.05이하)', code:'A72008', desc:'원통도(정밀)'},
  {feature:'기하공차', class:'정밀공차(0.05이하)', code:'A72009', desc:'흔들림(정밀)'},
  {feature:'기하공차', class:'정밀공차(0.05이하)', code:'A72011', desc:'대칭도(정밀)'},
  {feature:'기하공차', class:'정밀공차(0.05이하)', code:'A72012', desc:'윤곽도(정밀)'},

  // 외관불량(추가)
  {feature:'외관불량', class:'N/A', code:'A80002', desc:'찍힘'},
  {feature:'외관불량', class:'N/A', code:'A80003', desc:'거스러미/버 발생'},

  // 가공누락(추가)
  {feature:'가공누락', class:'N/A', code:'A90001', desc:'가공 누락(공정 1)'},
  {feature:'가공누락', class:'N/A', code:'A90002', desc:'가공 누락(공정 2)'},
  {feature:'가공누락', class:'N/A', code:'A90003', desc:'가공 누락(공정 3)'},
  {feature:'가공누락', class:'N/A', code:'A90005', desc:'가공 누락(공정 5)'},
  {feature:'가공누락', class:'N/A', code:'A90006', desc:'가공 누락(공정 6)'},
  {feature:'가공누락', class:'N/A', code:'A90007', desc:'가공 누락(공정 7)'},

  // 조도(추가)
  {feature:'조도', class:'N/A', code:'AB0002', desc:'표면 조도 미달'},
  {feature:'조도', class:'N/A', code:'AB0003', desc:'표면 조도 초과'},
  {feature:'조도', class:'N/A', code:'AB0004', desc:'표면 조도 불균일'},
  {feature:'조도', class:'N/A', code:'AB0005', desc:'표면 조도 기준 불일치'},

  // EF(용접) 추가
  {feature:'EF', class:'N/A', code:'B04005', desc:'용접 변색'},
  {feature:'EF', class:'N/A', code:'B04016', desc:'용접 롤오버'},
  {feature:'EF', class:'N/A', code:'B04017', desc:'용접 일렁임'},

  // 문서 관련 추가
  {feature:'문서', class:'N/A', code:'AE0008', desc:'도면 불일치'},
  {feature:'문서', class:'N/A', code:'AE0009', desc:'문서 누락'},
  {feature:'문서', class:'N/A', code:'AE0016', desc:'검사 기록 누락'},

  // 세척 관련 추가
  {feature:'세척', class:'N/A', code:'B06011', desc:'건조 부적합'},
  {feature:'세척', class:'N/A', code:'F03010', desc:'세척 후 건조 부적합(기타)'}
] AS row
MATCH (f:Feature {name: row.feature})
MATCH (c:Class {name: row.class})
MERGE (d:DefectCode {code: row.code})
  ON CREATE SET d.desc = row.desc
  ON MATCH  SET d.desc = row.desc
MERGE (d)-[:BELONGS_TO_FEATURE]->(f)
MERGE (d)-[:HAS_CLASS]->(c);
