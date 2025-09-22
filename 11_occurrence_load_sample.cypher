// 발생 이력 샘플 데이터 적재 (재실행 가능 MERGE)

UNWIND [
  {code:'A11011', date:'2025-09-15', lot:'L001', qty_ng:3, qty_total:120},
  {code:'A72001', date:'2025-09-15', lot:'L002', qty_ng:2, qty_total:200},
  {code:'A71006', date:'2025-09-16', lot:'L003', qty_ng:1, qty_total:150},
  {code:'AE0003', date:'2025-09-16', lot:'L004', qty_ng:4, qty_total:180},
  {code:'A80004', date:'2025-09-17', lot:'L005', qty_ng:5, qty_total:300},
  {code:'AC0008', date:'2025-09-17', lot:'L006', qty_ng:2, qty_total:160},
  {code:'A11011', date:'2025-09-18', lot:'L007', qty_ng:1, qty_total:90},
  {code:'A72001', date:'2025-09-18', lot:'L008', qty_ng:3, qty_total:220}
] AS row
MATCH (dc:DefectCode {code: row.code})
MERGE (o:Occurrence {lot: row.lot, code: row.code, date: date(row.date)})
  ON CREATE SET o.qty_ng = row.qty_ng, o.qty_total = row.qty_total
  ON MATCH  SET o.qty_ng = row.qty_ng, o.qty_total = row.qty_total
MERGE (o)-[:OF_CODE]->(dc);

