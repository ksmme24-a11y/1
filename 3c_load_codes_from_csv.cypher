// 표(불량유형명, 원인코드, 원인내용) CSV 로더
// 파일 인코딩은 UTF-8 권장. Neo4j import 디렉터리에 codes_table.csv 배치 필요.
// 컬럼: typeRaw, code, desc
// 예) typeRaw: "구멍치수　및　형상－일반공차" (전각 공백/하이픈 포함 가능)

LOAD CSV WITH HEADERS FROM 'file:///codes_table.csv' AS row
WITH row,
     replace(replace(replace(replace(row.typeRaw,'　',' '),'／','/'),'–','-'),'－','-') AS norm,
     trim(row.code) AS code,
     trim(row.desc) AS desc
WITH row, code, desc, trim(norm) AS norm
WITH row, code, desc, split(norm,'-') AS parts
WITH code, desc,
     trim(parts[0]) AS featureName,
     (CASE WHEN size(parts)>1 THEN trim(parts[1]) ELSE 'N/A' END) AS className
MATCH (f:Feature {name: featureName})
MATCH (c:Class {name: className})
MERGE (d:DefectCode {code: code})
  ON CREATE SET d.desc = desc
  ON MATCH  SET d.desc = desc
MERGE (d)-[:BELONGS_TO_FEATURE]->(f)
MERGE (d)-[:HAS_CLASS]->(c);

