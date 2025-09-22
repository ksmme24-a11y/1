// 소규모 누락 코드 보강
UNWIND [
  {feature:'기하공차', class:'정밀공차(0.05이하)', code:'A72010', desc:'위치도(정밀)'}
] AS row
MERGE (f:Feature {name: row.feature})
MERGE (c:Class {name: row.class})
MERGE (d:DefectCode {code: row.code})
  ON CREATE SET d.desc = row.desc
  ON MATCH  SET d.desc = row.desc
MERGE (d)-[:BELONGS_TO_FEATURE]->(f)
MERGE (d)-[:HAS_CLASS]->(c);

