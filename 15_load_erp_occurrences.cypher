// Access ERP RAW → CSV(erp_raw.csv) 로드, Occurrence/연결 생성

LOAD CSV WITH HEADERS FROM 'file:///erp_raw.csv' AS row
WITH row,
     trim(row.ReqNo) AS reqNo,
     trim(row.OrderNo) AS orderNo,
     trim(row.ItemCode) AS itemCode,
     trim(row.RoutNo) AS routNo,
     trim(row.Codes) AS codes,
     trim(row.InspType) AS inspType,
     trim(row.Worker) AS worker,
     trim(row.OpCode) AS opCode,
     trim(row.OpName) AS opName,
     trim(row.ResCode) AS resCode,
     trim(row.ResName) AS resName,
     trim(row.StartDate) AS startDate,
     trim(row.EndDate) AS endDate,
     coalesce(row.Note,'') AS note
WITH reqNo, orderNo, itemCode, routNo, inspType, worker, opCode, opName, resCode, resName, startDate, endDate, note,
     [x IN split(codes,';') WHERE trim(x) <> ''] AS codeLines
UNWIND codeLines AS codeLine
WITH reqNo, orderNo, itemCode, routNo, inspType, worker, opCode, opName, resCode, resName, startDate, endDate, note,
     trim(codeLine) AS cl
WITH reqNo, orderNo, itemCode, routNo, inspType, worker, opCode, opName, resCode, resName, startDate, endDate, note,
     trim(coalesce(split(cl,':')[0],cl)) AS code
MATCH (dc:DefectCode {code: code})
MERGE (o:Occurrence {oid: reqNo+'|'+orderNo+'|'+itemCode+'|'+routNo+'|'+startDate+'|'+resName+'|'+opCode+'|'+code})
  ON CREATE SET o.date = date(startDate), o.start = startDate, o.end = endDate, o.note = note,
                o.reqNo = reqNo, o.orderNo = orderNo, o.itemCode = itemCode, o.routNo = routNo,
                o.opCode = opCode, o.opName = opName, o.resCode = resCode, o.resName = resName,
                o.worker = worker, o.inspType = inspType
MERGE (o)-[:OF_CODE]->(dc)
MERGE (it:InspType {name: inspType})
MERGE (o)-[:HAS_TYPE]->(it)
MERGE (mo:Order {id: orderNo})
MERGE (o)-[:IN_ORDER]->(mo)
MERGE (itn:Item {code: itemCode})
MERGE (o)-[:FOR_ITEM]->(itn)
MERGE (op:Operation {code: opCode})
  ON CREATE SET op.name = opName
  ON MATCH  SET op.name = coalesce(op.name, opName)
MERGE (o)-[:AT_OPERATION]->(op)
MERGE (res:Resource {code: coalesce(resName,resCode)})
  ON CREATE SET res.name = resName, res.altCode = resCode
  ON MATCH  SET res.name = coalesce(res.name,resName), res.altCode = coalesce(res.altCode,resCode)
MERGE (o)-[:ON_RESOURCE]->(res)
MERGE (w:Worker {name: worker})
MERGE (o)-[:BY_WORKER]->(w)
MERGE (rq:InspectionRequest {id: reqNo})
MERGE (o)-[:FROM_REQUEST]->(rq);

