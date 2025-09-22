// 발생/PPM 분석 예시 쿼리

// O1. 코드별 발생/PPM 상위
MATCH (o:Occurrence)-[:OF_CODE]->(dc:DefectCode)
WITH dc.code AS code, sum(o.qty_ng) AS ng, sum(o.qty_total) AS tot
RETURN code, ng, tot, toInteger(1e6 * toFloat(ng) / case when tot=0 then 1 else tot end) AS ppm
ORDER BY ppm DESC, ng DESC LIMIT 20;

// O2. 주차별(주간) 트렌드 - PPM
MATCH (o:Occurrence)-[:OF_CODE]->(dc:DefectCode)
WITH date.truncate('week', o.date) AS wk, sum(o.qty_ng) AS ng, sum(o.qty_total) AS tot
RETURN wk, ng, tot, round(1e6 * toFloat(ng) / case when tot=0 then 1 else tot end) AS ppm
ORDER BY wk;

// O3. Feature별 PPM 집계
MATCH (o:Occurrence)-[:OF_CODE]->(dc:DefectCode)-[:BELONGS_TO_FEATURE]->(f:Feature)
WITH f.name AS feature, sum(o.qty_ng) AS ng, sum(o.qty_total) AS tot
RETURN feature, ng, tot, toInteger(1e6 * toFloat(ng) / case when tot=0 then 1 else tot end) AS ppm
ORDER BY ppm DESC;

