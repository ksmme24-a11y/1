// GD&T 노드 생성 및 코드 설명 기반 연결

UNWIND ['위치도','평면도','평행도','진직도','진원도','동심도','직각도','경사도','원통도','흔들림','대칭도','윤곽도'] AS g
MERGE (:GDT {name:g});

// 코드 설명(dc.desc)에 GD&T 키워드가 있으면 연결
MATCH (g:GDT)
MATCH (dc:DefectCode)
WHERE toLower(coalesce(dc.desc,'')) CONTAINS toLower(g.name)
MERGE (dc)-[:RELATES_GDT]->(g);

