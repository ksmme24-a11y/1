// Access ERP RAW → CSV(erp_raw.csv) 로드, Occurrence/연결 생성

LOAD CSV WITH HEADERS FROM 'file:///erp_raw.csv' AS row
WITH row,
     trim(row.ReqNo) AS reqNo,
     trim(row.OrderNo) AS orderNo,
     trim(row.ItemCode) AS itemCode,
     trim(row.RoutNo) AS routNo,
     trim(row.Codes) AS codes,
     trim(row.InspType) AS inspType,
     trim(row.Worker) AS workerId,
     trim(row.OpCode) AS opCode,
     trim(row.OpName) AS opName,
     trim(row.ResCode) AS resCode,
     trim(row.ResName) AS resName,
     trim(row.StartDate) AS startDate,
     trim(row.EndDate) AS endDate,
     coalesce(row.Note,'') AS note
WITH reqNo, orderNo, itemCode, routNo, inspType, workerId, opCode, opName, resCode, resName, startDate, endDate, note,
     CASE WHEN resCode IS NOT NULL AND resCode <> '' THEN resCode ELSE resName END AS resourceKey,
     [x IN split(codes,';') WHERE trim(x) <> ''] AS codeLines
UNWIND codeLines AS codeLine
WITH reqNo, orderNo, itemCode, routNo, inspType, workerId, opCode, opName, resCode, resName, startDate, endDate, note, resourceKey,
     trim(codeLine) AS cl
WITH reqNo, orderNo, itemCode, routNo, inspType, workerId, opCode, opName, resCode, resName, startDate, endDate, note, resourceKey,
     trim(coalesce(split(cl,':')[0],cl)) AS code
MATCH (dc:DefectCode {code: code})
MERGE (o:Occurrence {oid: reqNo+'|'+orderNo+'|'+itemCode+'|'+routNo+'|'+startDate+'|'+resourceKey+'|'+opCode+'|'+code})
  ON CREATE SET o.date = date(startDate), o.start = startDate, o.end = endDate, o.note = note,
                o.reqNo = reqNo, o.orderNo = orderNo, o.itemCode = itemCode, o.routNo = routNo,
                o.opCode = opCode, o.opName = opName, o.resCode = resCode, o.resName = resName,
                o.worker = workerId, o.inspType = inspType
MERGE (o)-[:HAS_DEFECT]->(dc)
MERGE (o)-[:OF_CODE]->(dc)
MERGE (it:InspType {name: inspType})
MERGE (o)-[:HAS_TYPE]->(it)
MERGE (mo:Order {orderNo: orderNo})
  ON CREATE SET mo.id = orderNo
  ON MATCH  SET mo.id = coalesce(mo.id, orderNo)
MERGE (o)-[:IN_ORDER]->(mo)
MERGE (itn:Item {itemCode: itemCode})
  ON CREATE SET itn.code = itemCode
  ON MATCH  SET itn.code = coalesce(itn.code, itemCode)
MERGE (o)-[:FOR_ITEM]->(itn)
MERGE (op:Operation {code: opCode})
  ON CREATE SET op.name = opName, op.routeNo = routNo
  ON MATCH  SET op.name = coalesce(op.name, opName), op.routeNo = coalesce(op.routeNo, routNo)
MERGE (o)-[:AT_OPERATION]->(op)
MERGE (res:Resource {code: resourceKey})
  ON CREATE SET res.name = resName, res.altCode = resCode
  ON MATCH  SET res.name = coalesce(res.name,resName), res.altCode = coalesce(res.altCode,resCode)
MERGE (o)-[:ON_RESOURCE]->(res)
MERGE (w:Worker {id: workerId})
  ON CREATE SET w.name = workerId
  ON MATCH  SET w.name = coalesce(w.name, workerId)
MERGE (o)-[:BY_WORKER]->(w)
MERGE (rq:InspectionRequest {reqNo: reqNo})
  ON CREATE SET rq.id = reqNo
  ON MATCH  SET rq.id = coalesce(rq.id, reqNo)
MERGE (o)-[:FROM_REQUEST]->(rq);
