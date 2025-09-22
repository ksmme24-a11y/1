// 고유키/검색 인덱스 및 제약 생성
// Neo4j 5.x 문법 기준

CREATE CONSTRAINT c_defecttype IF NOT EXISTS
FOR (n:DefectType) REQUIRE n.name IS UNIQUE;

CREATE CONSTRAINT c_defectdetail IF NOT EXISTS
FOR (n:DefectDetail) REQUIRE n.name IS UNIQUE;

CREATE CONSTRAINT c_feature IF NOT EXISTS
FOR (n:Feature) REQUIRE n.name IS UNIQUE;

CREATE CONSTRAINT c_class IF NOT EXISTS
FOR (n:Class) REQUIRE n.name IS UNIQUE;

CREATE CONSTRAINT c_defectcode IF NOT EXISTS
FOR (n:DefectCode) REQUIRE n.code IS UNIQUE;

CREATE INDEX i_cause IF NOT EXISTS FOR (n:Cause) ON (n.text);
CREATE INDEX i_process IF NOT EXISTS FOR (n:Process) ON (n.name);
CREATE INDEX i_gdt IF NOT EXISTS FOR (n:GDT) ON (n.name);

