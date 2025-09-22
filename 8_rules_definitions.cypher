// 대표 룰 정의 (정규식/키워드 → 특정 코드)
// 주의: codes에 포함된 일부 코드가 아직 미등록일 수 있습니다.
//       OPTIONAL MATCH로 존재하는 코드에만 매핑을 생성합니다.

UNWIND [
  // [A] 치수/길이/두께  (길이치수 - 일반/정밀)
  {name:'길이-전체길이-미달', regex:'(전체\s*길이).*(미달|부족)', priority:90, confidence:0.9,
   codes:['A01003','A02003'], note:'전체길이 미달(일반/정밀)'},
  {name:'길이-전체길이-초과', regex:'(전체\s*길이).*(초과|과다)', priority:90, confidence:0.9,
   codes:['A01004','A02004'], note:'전체길이 초과(일반/정밀)'},
  {name:'길이-두께-미달', regex:'(두께).*(미달|부족)', priority:90, confidence:0.9,
   codes:['A01005','A02005'], note:'두께 미달(일반/정밀)'},
  {name:'길이-두께-초과', regex:'(두께).*(초과|과다)', priority:90, confidence:0.9,
   codes:['A01006','A02006'], note:'두께 초과(일반/정밀)'},
  {name:'치수보정/영점/보정값-오류', regex:'(치수\s*보정|영점|보정값).*(오류|오타|누락|방향|계산)', priority:95, confidence:0.85,
   codes:['A01001','A01002','A02001','A02002'], note:'단진부위 공차 미달/초과로 귀결될 가능성'},

  // [B] 구멍/PCD/Hole/깊이/직경 (구멍치수 및 형상)
  {name:'구멍-직경-미달', regex:'(구멍|홀|hole).*(직경).*(미달|부족)', priority:95, confidence:0.9,
   codes:['A11007','A12005'], note:'직경 미달(일반/정밀)'},
  {name:'구멍-직경-초과', regex:'(구멍|홀|hole).*(직경).*(초과|과다)', priority:95, confidence:0.9,
   codes:['A11008','A12006'], note:'직경 초과(일반/정밀)'},
  {name:'구멍-깊이-미달', regex:'(구멍|홀|hole).*(깊이).*(미달|부족)', priority:95, confidence:0.9,
   codes:['A11009','A12007'], note:'깊이 미달(일반/정밀)'},
  {name:'구멍-깊이-초과', regex:'(구멍|홀|hole).*(깊이).*(초과|과다)', priority:95, confidence:0.9,
   codes:['A11010','A12008'], note:'깊이 초과(일반/정밀)'},
  {name:'PCD-공차', regex:'PCD.*(미달|부족|초과|과다|공차)', priority:80, confidence:0.75,
   codes:['A11005','A11006'], note:'PCD 공차 미달/초과(일반)'},
  {name:'카운터보어-직경/깊이', regex:'(카운트.?보어|counter.?bore).*(직경|깊이).*(미달|초과|부족|과다)', priority:85, confidence:0.8,
   codes:['A11001','A11002','A11003','A11004','A12001','A12002','A12003','A12004'], note:'카운터보어 이슈'},

  // [C] 내/외경 & 끼워맞춤
  {name:'내외경-공차-미달', regex:'(내경|외경).*(미달|부족|공차.*미달)', priority:90, confidence:0.85,
   codes:['A21001','A21003','A22001','A22003'], note:'내/외경 미달(일반/정밀)'},
  {name:'내외경-공차-초과', regex:'(내경|외경).*(초과|과다|공차.*초과)', priority:90, confidence:0.85,
   codes:['A21002','A21004','A22002','A22004'], note:'내/외경 초과(일반/정밀)'},
  {name:'끼워맞춤-내경/외경', regex:'(끼워맞춤|fit).*(내경|외경).*(미달|초과|부족|과다)', priority:85, confidence:0.85,
   codes:['A22005','A22006','A22007','A22008'], note:'끼워맞춤 허용치 벗어남'},

  // [D] 나사(탭, Gage)
  {name:'나사-GoGage-삽입불가', regex:'(나사).*Go\s*Gage.*(불가|안됨)', priority:95, confidence:0.95,
   codes:['A30006'], note:'나사 Go Gage 불가'},
  {name:'나사-NoGage-삽입', regex:'(나사).*No\s*Gage.*(삽입|가능)', priority:95, confidence:0.95,
   codes:['A30007'], note:'나사 No Gage 삽입'},
  {name:'나사-깊이-미달/초과', regex:'(나사|tap|탭).*?(드릴\s*깊이|깊이).*(미달|초과|부족|과다)', priority:90, confidence:0.9,
   codes:['A30009','A30010'], note:'나사 드릴 깊이 이슈'},

  // [E] 슬로트
  {name:'슬로트-폭/깊이', regex:'(슬로트|slot).*(폭|깊이).*(미달|초과|부족|과다)', priority:80, confidence:0.8,
   codes:['A41001','A41002','A41003','A41004','A42001','A42002','A42003','A42004'], note:'슬로트 치수 이슈'},

  // [F] 각도/면취/라운딩
  {name:'면취/라운딩/각도', regex:'(면취|C\s*면|라운딩|R\s*가공|각도).*(미달|초과|누락|오류)', priority:80, confidence:0.8,
   codes:['A50001','A50002','A50003','A50004','A50005','A50006'], note:'각/면취/R 정합 불량'},

  // [G] 오링그루브/그루브 (직경/폭/깊이)
  {name:'오링/그루브-치수', regex:'(오링|O\s*-?ring|그루브).*(직경|폭|깊이|내경|외경).*(미달|초과|부족|과다)', priority:85, confidence:0.85,
   codes:['A61001','A61002','A61003','A61004','A61005','A61006','A61007','A61008','A61009','A61010','A62001','A62002','A62003','A62004','A62005','A62006','A62007','A62008','A62009','A62010'], note:'오링/그루브 전반'},

  // [H] 기하공차(GD&T)
  {name:'GD&T-위치도', regex:'(위치도|true.*position|TP)', priority:95, confidence:0.95,
   codes:['A71010','A72010','A12010'], note:'위치도 일반/정밀'},
  {name:'GD&T-평면/평행/진원/동심/직각/경사/원통/흔들림/대칭/윤곽', regex:'(평면도|평행도|진직도|진원도|동심도|직각도|경사도|원통도|흔들림|대칭도|윤곽도)', priority:90, confidence:0.9,
   codes:['A71001','A71002','A71003','A71004','A71005','A71006','A71007','A71008','A71009','A71011','A71012','A72001','A72002','A72003','A72004','A72005','A72006','A72007','A72008','A72009','A72011','A72012'], note:'GD&T 전반'},

  // [I] 외관/취급 (스크래치/찍힘/거스러미/조도)
  {name:'외관-스크래치/찍힘/버/거스러미', regex:'(스크래치|찍힘|거스러미|버\s*발생)', priority:70, confidence:0.8,
   codes:['A80002','A80003','A80004','B09008','B09011','B09016','B09049'], note:'외관 계열'},
  {name:'조도-초과/미달', regex:'(조도).*(초과|미달|과다|부족)', priority:70, confidence:0.75,
   codes:['AB0001','AB0002','AB0003','AB0004','AB0005','F01005'], note:'조도군'},

  // [J] 가공/용접/세척/문서/누락
  {name:'가공누락', regex:'(가공\s*누락|미가공|누락.*가공)', priority:95, confidence:0.95,
   codes:['A90001','A90002','A90003','A90004','A90005','A90006','A90007'], note:'가공 누락 세분'},
  {name:'용접-누락/변색/롤오버', regex:'(용접).*(누락|변색|롤오버|일렁임)', priority:85, confidence:0.85,
   codes:['B04010','B04016','B04005','B04017'], note:'EF 군'},
  {name:'세척-후-변색/녹/건조부적합', regex:'(세척).*(후).*(변색|녹|건조.*부적합)', priority:80, confidence:0.8,
   codes:['B06003','B06011','F03010'], note:'세척 후 이슈'},
  {name:'문서/REV/작업지시', regex:'(작업지시|REV|도면|문서|Mill\s*Sheet|검사\s*기록).*(불량|누락|불일치)', priority:80, confidence:0.8,
   codes:['AE0003','AE0008','AE0009','AE0016','B09048'], note:'문서·기록·REV 계열'},

  // [K] 측정/장비 설정
  {name:'측정-영점/TIR/Q-SETTER', regex:'(영점|T\.?I\.?R|Q-\s*SETTER|측정\s*방법).*?(미흡|오류|누락|불이행)', priority:85, confidence:0.85,
   codes:['A71001','A71002','A72001','A72002','A11011','A12009'], note:'측정/세팅 문제 → 방향/위치/GD&T/ORIENTATION 쪽'}
] AS r
MERGE (rule:Rule {name:r.name})
  ON CREATE SET rule.regex=r.regex, rule.priority=r.priority, rule.confidence=r.confidence, rule.note=r.note
  ON MATCH  SET rule.regex=r.regex, rule.priority=r.priority, rule.confidence=r.confidence, rule.note=r.note
WITH r, rule
UNWIND r.codes AS code
OPTIONAL MATCH (dc:DefectCode {code: code})
WITH rule, dc WHERE dc IS NOT NULL
MERGE (rule)-[:MAPS_TO]->(dc);
