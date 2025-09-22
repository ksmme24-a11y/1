"""Access ERP View → Neo4j 실시간 동기화 스크립트.

주요 기능
- Access DB에서 지정한 뷰/쿼리를 10분 간격으로 조회
- Neo4j 드라이버를 통해 MERGE upsert 수행
- 수행 로그를 `operations/load.log` 파일에 남기고, 실패 시 알람 전송
- 마지막 성공 시점(`operations/last_success.txt`)을 이용해 증분 로딩

필수 패키지: pyodbc, neo4j, python-dotenv(optional)
"""
from __future__ import annotations

import argparse
import contextlib
import datetime as dt
import json
import logging
import os
import sys
import time
from pathlib import Path
from typing import Dict, Iterable, List, Optional

try:
    import pyodbc  # type: ignore
except ImportError as exc:  # pragma: no cover - 모듈이 없는 환경 대비
    raise SystemExit("pyodbc 패키지가 필요합니다. 'pip install pyodbc' 후 다시 실행하세요.") from exc

from neo4j import GraphDatabase
from neo4j.exceptions import Neo4jError
from urllib import request, error as urlerror

LOG_DIR = Path("operations")
LOG_DIR.mkdir(exist_ok=True)
LOG_FILE = LOG_DIR / "load.log"
STATE_FILE = LOG_DIR / "last_success.txt"

DEFAULT_INCREMENTAL_COLUMN = "UpdateDttm"
DEFAULT_POLL_SECONDS = 600


def setup_logging(level: int = logging.INFO) -> None:
    LOG_DIR.mkdir(exist_ok=True)
    formatter = logging.Formatter("%(asctime)s [%(levelname)s] %(message)s")
    handlers = [logging.FileHandler(LOG_FILE, encoding="utf-8"), logging.StreamHandler(sys.stdout)]
    logging.basicConfig(level=level, handlers=handlers, format="%(asctime)s [%(levelname)s] %(message)s")


def load_last_success() -> Optional[str]:
    if STATE_FILE.exists():
        return STATE_FILE.read_text(encoding="utf-8").strip() or None
    return None


def save_last_success(value: str) -> None:
    STATE_FILE.write_text(value, encoding="utf-8")


def send_alert(message: str) -> None:
    webhook = os.getenv("ERP_ALERT_WEBHOOK")
    if not webhook:
        logging.warning("알림 Webhook 이 설정되지 않았습니다: %s", message)
        return

    payload = json.dumps({"text": message}).encode("utf-8")
    req = request.Request(webhook, data=payload, headers={"Content-Type": "application/json"})
    try:
        with contextlib.closing(request.urlopen(req, timeout=10)):
            logging.info("알림 전송 완료")
    except urlerror.URLError as exc:  # pragma: no cover - 네트워크 실패 대비
        logging.error("알림 전송 실패: %s", exc)


def build_access_connection_string(path: str, user: Optional[str], password: Optional[str]) -> str:
    parts = ["DRIVER={Microsoft Access Driver (*.mdb, *.accdb)}", f"DBQ={path}"]
    if user:
        parts.append(f"UID={user}")
    if password:
        parts.append(f"PWD={password}")
    return ";".join(parts)


def fetch_access_rows(
    connection: pyodbc.Connection,
    view_name: str,
    incremental_column: str,
    last_value: Optional[str],
) -> List[Dict[str, Optional[str]]]:
    cursor = connection.cursor()
    base_query = f"""
        SELECT ReqNo, OrderNo, ItemCode, RoutNo, Codes, InspType, Worker,
               OpCode, OpName, ResCode, ResName, StartDate, EndDate, Note,
               {incremental_column} AS IncrementalValue
        FROM {view_name}
    """
    params: List[str] = []
    if last_value:
        base_query += f" WHERE {incremental_column} > ?"
        params.append(last_value)

    base_query += f" ORDER BY {incremental_column}"
    logging.debug("Access 조회 쿼리: %s", base_query)
    rows = cursor.execute(base_query, params).fetchall()
    columns = [column[0] for column in cursor.description]
    return [dict(zip(columns, row)) for row in rows]


def transform_row(raw: Dict[str, Optional[str]]) -> Dict[str, Optional[str]]:
    codes = raw.get("Codes") or ""
    parsed_codes = [part.strip() for part in codes.split(";") if part and part.strip()]
    note = raw.get("Note") or ""
    start_date = (raw.get("StartDate") or "").strip()
    end_date = (raw.get("EndDate") or "").strip()

    return {
        "reqNo": (raw.get("ReqNo") or "").strip(),
        "orderNo": (raw.get("OrderNo") or "").strip(),
        "itemCode": (raw.get("ItemCode") or "").strip(),
        "routNo": (raw.get("RoutNo") or "").strip(),
        "codes": parsed_codes,
        "inspType": (raw.get("InspType") or "").strip(),
        "workerId": (raw.get("Worker") or "").strip(),
        "opCode": (raw.get("OpCode") or "").strip(),
        "opName": (raw.get("OpName") or "").strip(),
        "resCode": (raw.get("ResCode") or "").strip(),
        "resName": (raw.get("ResName") or "").strip(),
        "startDate": start_date,
        "endDate": end_date,
        "note": note.strip(),
        "incrementalValue": (raw.get("IncrementalValue") or "").strip(),
    }


CYPHER_MERGE = """
UNWIND $rows AS row
WITH row WHERE size(row.codes) > 0
UNWIND row.codes AS codeLine
WITH row,
     trim(codeLine) AS cl,
     CASE WHEN row.resCode <> '' THEN row.resCode ELSE row.resName END AS resourceKey
WITH row,
     cl,
     resourceKey,
     trim(coalesce(split(cl, ':')[0], cl)) AS defectCode
MERGE (dc:DefectCode {code: defectCode})
MERGE (o:Occurrence {oid: row.reqNo+'|'+row.orderNo+'|'+row.itemCode+'|'+row.routNo+'|'+row.startDate+'|'+resourceKey+'|'+row.opCode+'|'+defectCode})
  ON CREATE SET o.date = date(row.startDate),
                o.start = row.startDate,
                o.end = row.endDate,
                o.note = row.note,
                o.reqNo = row.reqNo,
                o.orderNo = row.orderNo,
                o.itemCode = row.itemCode,
                o.routNo = row.routNo,
                o.opCode = row.opCode,
                o.opName = row.opName,
                o.resCode = row.resCode,
                o.resName = row.resName,
                o.worker = row.workerId,
                o.inspType = row.inspType
MERGE (o)-[:HAS_DEFECT]->(dc)
MERGE (o)-[:OF_CODE]->(dc)
MERGE (it:InspType {name: row.inspType})
MERGE (o)-[:HAS_TYPE]->(it)
MERGE (ord:Order {orderNo: row.orderNo})
  ON CREATE SET ord.id = row.orderNo
  ON MATCH  SET ord.id = coalesce(ord.id, row.orderNo)
MERGE (o)-[:IN_ORDER]->(ord)
MERGE (itm:Item {itemCode: row.itemCode})
  ON CREATE SET itm.code = row.itemCode
  ON MATCH  SET itm.code = coalesce(itm.code, row.itemCode)
MERGE (o)-[:FOR_ITEM]->(itm)
MERGE (op:Operation {code: row.opCode})
  ON CREATE SET op.name = row.opName, op.routeNo = row.routNo
  ON MATCH  SET op.name = coalesce(op.name, row.opName), op.routeNo = coalesce(op.routeNo, row.routNo)
MERGE (o)-[:AT_OPERATION]->(op)
MERGE (res:Resource {code: resourceKey})
  ON CREATE SET res.name = row.resName, res.altCode = row.resCode
  ON MATCH  SET res.name = coalesce(res.name, row.resName), res.altCode = coalesce(res.altCode, row.resCode)
MERGE (o)-[:ON_RESOURCE]->(res)
MERGE (w:Worker {id: row.workerId})
  ON CREATE SET w.name = row.workerId
  ON MATCH  SET w.name = coalesce(w.name, row.workerId)
MERGE (o)-[:BY_WORKER]->(w)
MERGE (req:InspectionRequest {reqNo: row.reqNo})
  ON CREATE SET req.id = row.reqNo
  ON MATCH  SET req.id = coalesce(req.id, row.reqNo)
MERGE (o)-[:FROM_REQUEST]->(req);
"""


def push_to_neo4j(driver: GraphDatabase.driver, rows: Iterable[Dict[str, Optional[str]]]) -> None:
    filtered = [row for row in rows if row["reqNo"] and row["orderNo"] and row["itemCode"]]
    if not filtered:
        logging.info("업데이트할 데이터가 없습니다.")
        return

    with driver.session(database="neo4j") as session:
        session.write_transaction(lambda tx: tx.run(CYPHER_MERGE, rows=filtered))
    logging.info("Neo4j 반영 완료 (rows=%d)", len(filtered))


def run_etl_once(args: argparse.Namespace) -> Optional[str]:
    conn_str = build_access_connection_string(args.access_path, args.access_user, args.access_password)
    logging.debug("Access 연결 문자열: %s", conn_str)

    with pyodbc.connect(conn_str, timeout=5) as connection:
        raw_rows = fetch_access_rows(connection, args.view_name, args.incremental_column, args.last_success)
    logging.info("Access에서 %d건 조회", len(raw_rows))

    if not raw_rows:
        return args.last_success

    transformed = [transform_row(row) for row in raw_rows]
    last_incremental = transformed[-1]["incrementalValue"] or args.last_success

    auth = (args.neo4j_user, args.neo4j_password)
    driver = GraphDatabase.driver(args.neo4j_uri, auth=auth)
    try:
        push_to_neo4j(driver, transformed)
    finally:
        driver.close()

    return last_incremental


def parse_args(argv: Optional[List[str]] = None) -> argparse.Namespace:
    parser = argparse.ArgumentParser(description="ERP 부적합 이력 Access → Neo4j 동기화")
    parser.add_argument("--access-path", required=True, help="Access DB 파일(.mdb/.accdb) 경로")
    parser.add_argument("--view-name", required=True, help="조회할 View 또는 Query 이름")
    parser.add_argument("--access-user", help="Access 사용자 ID (옵션)")
    parser.add_argument("--access-password", help="Access 암호 (옵션)")
    parser.add_argument("--neo4j-uri", default="bolt://localhost:7687", help="Neo4j Bolt URI")
    parser.add_argument("--neo4j-user", default=os.getenv("NEO4J_USER", "neo4j"), help="Neo4j 계정 ID")
    parser.add_argument("--neo4j-password", default=os.getenv("NEO4J_PASSWORD", "neo4j"), help="Neo4j 계정 암호")
    parser.add_argument("--incremental-column", default=DEFAULT_INCREMENTAL_COLUMN, help="증분 비교용 칼럼명")
    parser.add_argument("--poll-seconds", type=int, default=DEFAULT_POLL_SECONDS, help="실행 주기(초)")
    parser.add_argument("--once", action="store_true", help="단일 실행 후 종료")
    return parser.parse_args(argv)


def main(argv: Optional[List[str]] = None) -> int:
    args = parse_args(argv)
    setup_logging()

    last_success = load_last_success()
    args.last_success = last_success
    logging.info("마지막 성공 기준값: %s", last_success)

    while True:
        cycle_start = dt.datetime.now()
        try:
            latest_value = run_etl_once(args)
            if latest_value:
                save_last_success(latest_value)
                logging.info("성공 기준값 업데이트: %s", latest_value)
        except (pyodbc.Error, Neo4jError, OSError) as exc:
            logging.exception("ETL 실행 실패")
            send_alert(f"ERP→Neo4j 적재 실패: {exc}")
        except Exception as exc:  # pragma: no cover - 예상치 못한 오류 대비
            logging.exception("예상치 못한 오류")
            send_alert(f"ERP→Neo4j 스크립트에서 알 수 없는 오류: {exc}")
        finally:
            if args.once:
                break
            elapsed = (dt.datetime.now() - cycle_start).total_seconds()
            sleep_for = max(args.poll_seconds - int(elapsed), 5)
            logging.info("다음 실행까지 %s초 대기", sleep_for)
            time.sleep(sleep_for)

    return 0


if __name__ == "__main__":
    sys.exit(main())
