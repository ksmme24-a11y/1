// 불량유형/상세/원인 CSV 로더
// 파일: types_table.csv (UTF-8 권장)
// 컬럼: type, detail, cause, processes (선택, 쉼표/슬래시 구분)
// import 디렉터리에 파일 배치 후 실행

LOAD CSV WITH HEADERS FROM 'file:///types_table.csv' AS row
WITH row,
     trim(replace(replace(row.type,'　',' '),'－','-')) AS type,
     trim(row.detail) AS detail,
     trim(row.cause) AS cause,
     coalesce(row.processes,'') AS procs
WITH type, detail, cause,
     [p IN split(replace(replace(procs,'/',';'),',',';'), ';') WHERE trim(p) <> ''] AS plist
MERGE (t:DefectType {name: type})
MERGE (d:DefectDetail {name: detail})
MERGE (t)-[:HAS_DETAIL]->(d)
WITH d, cause, plist
MERGE (c:Cause {text: cause})
MERGE (d)-[:HAS_CAUSE]->(c)
WITH d, plist
UNWIND CASE WHEN size(plist)=0 THEN [null] ELSE plist END AS pname
WITH d, pname WHERE pname IS NOT NULL
MERGE (p:Process {name: trim(pname)})
MERGE (d)-[:INVOLVES_PROCESS]->(p);
