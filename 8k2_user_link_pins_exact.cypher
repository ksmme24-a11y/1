// Exact-text pin mapping for 4 remaining causes (normalized)
WITH [
  {norm:'날카로움(촉수검사시걸림)', codes:['A80002']},
  {norm:'노후로인한정밀도저하지그사용', codes:'GDT_ALL'},
  {norm:'재탭중파손', codes:['AC0006']},
  {norm:'파손된지그사용', codes:'GDT_ALL'}
] AS todo
UNWIND todo AS t
CALL {
  WITH t
  MATCH (c:Cause)
  WITH c, replace(replace(replace(replace(coalesce(c.text,''),'\s',''),'　',''),'(',''),')','') AS s, t
  WHERE s CONTAINS t.norm
  WITH c, t
  CALL {
    WITH t
    WITH t.codes AS cs
    RETURN cs AS arr
    UNION ALL
    WITH t
    MATCH (dc:DefectCode)-[:BELONGS_TO_FEATURE]->(:Feature {name:'기하공차'})
    WHERE t.codes = 'GDT_ALL'
    RETURN collect(dc.code) AS arr
  }
  WITH c, arr
  UNWIND arr AS code
  MATCH (dc:DefectCode {code:code})
  MERGE (c)-[:IMPLIES {via:'pin:exact', confidence:0.9}]->(dc)
  RETURN count(*) AS pinned
}
RETURN 'pinned-exact' AS info;
