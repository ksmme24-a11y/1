// ERP 연계용 노드 제약/인덱스

// --- 고유 제약 ---
CREATE CONSTRAINT c_occurrence_oid IF NOT EXISTS
FOR (n:Occurrence) REQUIRE n.oid IS UNIQUE;

CREATE CONSTRAINT c_occurrence_req IF NOT EXISTS
FOR (n:InspectionRequest) REQUIRE n.reqNo IS UNIQUE;

CREATE CONSTRAINT c_order IF NOT EXISTS
FOR (n:Order) REQUIRE n.orderNo IS UNIQUE;

CREATE CONSTRAINT c_item IF NOT EXISTS
FOR (n:Item) REQUIRE n.itemCode IS UNIQUE;

CREATE CONSTRAINT c_operation IF NOT EXISTS
FOR (n:Operation) REQUIRE n.code IS UNIQUE;

CREATE CONSTRAINT c_resource IF NOT EXISTS
FOR (n:Resource) REQUIRE n.code IS UNIQUE;

CREATE CONSTRAINT c_worker IF NOT EXISTS
FOR (n:Worker) REQUIRE n.id IS UNIQUE;

CREATE CONSTRAINT c_defect IF NOT EXISTS
FOR (n:DefectCode) REQUIRE n.code IS UNIQUE;

CREATE CONSTRAINT c_insptype IF NOT EXISTS
FOR (n:InspType) REQUIRE n.name IS UNIQUE;

// --- 조회용 인덱스 ---
CREATE INDEX occurrence_req_idx IF NOT EXISTS
FOR (n:Occurrence) ON (n.reqNo);

CREATE INDEX occurrence_order_idx IF NOT EXISTS
FOR (n:Occurrence) ON (n.orderNo);

CREATE INDEX occurrence_item_idx IF NOT EXISTS
FOR (n:Occurrence) ON (n.itemCode);

CREATE INDEX worker_name_idx IF NOT EXISTS
FOR (n:Worker) ON (n.name);

CREATE INDEX operation_route_idx IF NOT EXISTS
FOR (n:Operation) ON (n.routeNo);
