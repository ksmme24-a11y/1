// 발생 이력 스키마 및 제약/인덱스

CREATE CONSTRAINT c_occurrence_key IF NOT EXISTS
FOR (n:Occurrence) REQUIRE (n.lot, n.code, n.date) IS UNIQUE;

CREATE INDEX i_occurrence_date IF NOT EXISTS FOR (n:Occurrence) ON (n.date);
CREATE INDEX i_occurrence_lot  IF NOT EXISTS FOR (n:Occurrence) ON (n.lot);
CREATE INDEX i_occurrence_code IF NOT EXISTS FOR (n:Occurrence) ON (n.code);

