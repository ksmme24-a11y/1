# ERP 부적합 그래프 운영 가이드

## 1. 개요
본 문서는 Access ERP View → Neo4j 그래프 적재 배치의 운영 절차와 장애 대응 방법을 정리한다.

## 2. 구성 요소
- **ETL 스크립트**: `etl/access_to_neo4j.py`
- **Neo4j DB**: Desktop Enterprise, 데이터베이스 이름 `neo4j`
- **로그/상태 파일**: `operations/load.log`, `operations/last_success.txt`
- **알림 채널**: Slack Incoming Webhook (`ERP_ALERT_WEBHOOK` 환경변수)
- **시각화 도구**: Neo4j Bloom (퍼스펙티브: `ERP Defect Monitoring`)

## 3. 배포 및 스케줄 설정
1. Windows 작업 스케줄러 또는 Linux systemd timer에서 10분 간격 실행
   - Windows 예시: `python C:\neo4j-etl\etl\access_to_neo4j.py --access-path D:\ERP\Quality.accdb --view-name vw_QMS_Defect`
   - Linux 예시: `*/10 * * * * /usr/bin/python3 /opt/erp-graph/etl/access_to_neo4j.py --access-path /data/Quality.accdb --view-name vw_QMS_Defect`
2. 최초 실행 전에 `python etl/access_to_neo4j.py --once ...`로 초기 적재 수행 후 스케줄러 활성화
3. Neo4j Desktop이 항상 실행 중인지 확인하고, 서비스 모드(Neo4j Windows Service) 사용 권장

## 4. 모니터링
- **로그 확인**: 매일 오전 9시 이전에 `operations/load.log`에서 오류 메시지 검색
- **상태 지표**: `metrics/neo4j.database.neo4j.transaction.committed.csv`를 통해 트랜잭션 증가 추이 확인
- **Bloom Dashboards**: Request 기준 북마크를 생성하여 일일 회의 중 공유

## 5. 장애 대응 프로세스
| 상황 | 조치 |
| --- | --- |
| Access 연결 실패 | 로그의 ODBC 에러 메시지 확인 → Access 파일 잠금 여부 확인 → 필요 시 IT 지원팀에 파일 공유 해제 요청 |
| Neo4j 연결 실패 | Neo4j Desktop 서비스 상태 확인 → `neo4j start` 재시작 → 필요 시 Bolt 포트 방화벽 체크 |
| 데이터 누락 | `operations/last_success.txt` 값을 확인하여 해당 시점 이후 데이터를 Access에서 재조회 → `--once` 모드로 재수행 |
| Bloom 탐색 지연 | Neo4j Browser에서 `CALL db.stats.retrieve.all()`로 통계 확인 → 필요시 `CALL db.index.fulltext. ...` 재작성 |

## 6. 백업 및 롤백
- Neo4j DB는 주 1회 `neo4j-admin database dump neo4j --to=backup/neo4j_YYYYMMDD.dump`
- Bloom 퍼스펙티브는 변경 시마다 `bloom/perspective.json`으로 내보내어 Git에 커밋
- ETL 로그는 30일 보관 후 아카이브 (`7z a load_YYYYMM.zip load.log`)

## 7. 보안/권한
- Access DB는 읽기 전용 공유 폴더로 제공, ETL 서버 계정에만 읽기 권한 부여
- Neo4j는 최소 권한 원칙 적용: `neo4j` 관리자, `reader` 역할의 Bloom 사용자 계정 구분
- Slack Webhook URL은 Windows Credential Manager 또는 Linux 환경변수로 암호화 저장

## 8. 변경 관리
- 스키마 변경 시 `docs/erp_graph_schema.md` 업데이트 후 Change Review 회의 진행
- ETL 수정은 테스트 환경(별도 Neo4j DB)에서 검증 후 운영 반영
- 운영 배포 후 `operations/load.log`에 "DEPLOY YYYY-MM-DD" 주석을 남겨 추적

## 9. 연락처
- 품질기획팀: quality_planning@example.com
- IT 인프라: it_infra@example.com
- Neo4j 운영 담당: neo4j_ops@example.com
