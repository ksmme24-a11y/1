// Exact-equals pin mapping for four causes
// 날카로움(촉수 검사 시 걸림) → A80002
MATCH (c:Cause {text:'날카로움(촉수 검사 시 걸림)'}), (dc:DefectCode {code:'A80002'})
MERGE (c)-[:IMPLIES {via:'pin:eq',confidence:0.9}]->(dc);

// 노후로 인한 정밀도 저하 지그 사용 → GDT all
MATCH (c:Cause {text:'노후로 인한 정밀도 저하 지그 사용'})
MATCH (dc:DefectCode)-[:BELONGS_TO_FEATURE]->(:Feature {name:'기하공차'})
MERGE (c)-[:IMPLIES {via:'pin:eq',confidence:0.85}]->(dc);

// 재탭 중 파손 → AC0006
MATCH (c:Cause {text:'재탭 중 파손'}), (dc:DefectCode {code:'AC0006'})
MERGE (c)-[:IMPLIES {via:'pin:eq',confidence:0.9}]->(dc);

// 파손 된 지그 사용 → GDT all
MATCH (c:Cause {text:'파손 된 지그 사용'})
MATCH (dc:DefectCode)-[:BELONGS_TO_FEATURE]->(:Feature {name:'기하공차'})
MERGE (c)-[:IMPLIES {via:'pin:eq',confidence:0.85}]->(dc);
