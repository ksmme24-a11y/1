// 원인 텍스트 키워드 기반 → Feature 매핑 → 해당 Feature의 모든 코드와 연결
// 필요 시 세분 키워드 → 특정 코드 매핑으로 고도화 권장

WITH [
  {kw:['치수','공차','두께','길이'], feature:'길이치수'},
  {kw:['구멍','Hole','PCD','직경','깊이'], feature:'구멍치수 및 형상'},
  {kw:['내경','외경','Taper','끼워맞춤'], feature:'내/외경 치수'},
  {kw:['나사','Tap','Gage'], feature:'나사'},
  {kw:['슬로트','Slot'], feature:'슬로트'},
  {kw:['면취','C면','라운딩','R가공','각도'], feature:'각도/면취/라운딩'},
  {kw:['오링','그루브'], feature:'오링그루브/그루브'},
  {kw:['위치도','평면도','평행도','진원도','동심도','직각도','경사도','원통도','흔들림','대칭도','윤곽도','ORIENTATION'], feature:'기하공차'},
  {kw:['스크래치','찍힘','거스러미','조도'], feature:'외관불량'},
  {kw:['가공 누락','누락','미가공'], feature:'가공누락'},
  {kw:['세척'], feature:'세척'},
  {kw:['용접'], feature:'EF'},
  {kw:['작업지시','도면','REV','문서','Mill Sheet'], feature:'문서'}
] AS map
MATCH (dd:DefectDetail)-[:HAS_CAUSE]->(c:Cause)
WITH dd, c, map
UNWIND map AS m
MATCH (f:Feature {name: m.feature})
WHERE any(kw IN m.kw WHERE toLower(c.text) CONTAINS toLower(kw))
WITH dd, c, f
MATCH (dc:DefectCode)-[:BELONGS_TO_FEATURE]->(f)
MERGE (dd)-[:POTENTIALLY_TRIGGERS {via:'keyword'}]->(dc);

