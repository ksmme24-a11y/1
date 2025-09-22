// 설비 자원 리스트 CSV 로딩
// 파일: file:///resources.csv (import 폴더)

LOAD CSV WITH HEADERS FROM 'file:///resources.csv' AS row
WITH row,
     trim(row.EquipCode) AS code,
     trim(row.EquipName) AS name,
     trim(row.Model) AS model,
     trim(row.Maker) AS maker,
     trim(row.Type) AS type,
     trim(row.Axes) AS axes,
     trim(row.Line) AS line,
     trim(row.Dept) AS dept
MERGE (r:Resource {code: code})
  ON CREATE SET r.name = name, r.model=model, r.maker=maker, r.type=type, r.axes=axes, r.line=line, r.dept=dept
  ON MATCH  SET r.name = coalesce(r.name,name), r.model=coalesce(r.model,model), r.maker=coalesce(r.maker,maker), r.type=coalesce(r.type,type), r.axes=coalesce(r.axes,axes), r.line=coalesce(r.line,line), r.dept=coalesce(r.dept,dept);

