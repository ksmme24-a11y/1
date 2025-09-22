// Fulltext indexes for user-friendly search

// Defect code/description search
CREATE FULLTEXT INDEX ft_defectcode IF NOT EXISTS
FOR (d:DefectCode) ON EACH [d.code, d.desc];

// ERP occurrence search by identifiers
CREATE FULLTEXT INDEX ft_occurrence IF NOT EXISTS
FOR (o:Occurrence) ON EACH [o.oid, o.reqNo, o.orderNo, o.itemCode, o.resName, o.opName, o.note];

// Consolidated search across major ERP labels
CREATE FULLTEXT INDEX ft_all IF NOT EXISTS
FOR (n:Occurrence|Order|Item|Operation|Resource|Worker|InspectionRequest|DefectCode)
ON EACH [
  n.reqNo,
  n.orderNo,
  n.itemCode,
  n.routNo,
  n.code,
  n.desc,
  n.opCode,
  n.opName,
  n.resCode,
  n.resName,
  n.worker,
  n.workerName,
  n.note
];

// Simple indexes for lookups (already partially present via constraints)
CREATE INDEX i_item_code IF NOT EXISTS FOR (n:Item) ON (n.code);
CREATE INDEX i_order_id IF NOT EXISTS FOR (n:Order) ON (n.id);
CREATE INDEX i_inspreq_id IF NOT EXISTS FOR (n:InspectionRequest) ON (n.id);

