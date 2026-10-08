-- GRAPH-011 / RP-05: which test files count as specification files, under the old and the current file-name rule.
-- From the repository root:  sqlite3 :memory: < Maintanance/AIGraphInMemoryFixture/rp05_spec_role.sql
-- Input transcribed from `git ls-tree -r --name-only <commit> -- Tests/PermutationTests` at d784b91e and a31dbcb3.
-- Snapshot 'control' holds one RedBlackTree specification file at a31dbcb3, so that the old rule is shown to match something.
-- Whether the old rule also had the "< 90" condition is not recorded, so the control has no file numbered 90 or above.
.bail on
.read Maintanance/AIGraphInMemoryFixture/schema.sql

CREATE TABLE test_path (
  snapshot TEXT NOT NULL,
  path     TEXT NOT NULL,
  PRIMARY KEY (snapshot, path)
);
INSERT INTO test_path VALUES
  ('d784b91e', 'Tests/PermutationTests/DeathTestSignal.swift'),
  ('d784b91e', 'Tests/PermutationTests/PermutationDeathTests.swift'),
  ('d784b91e', 'Tests/PermutationTests/PermutationRemovedAPITests.swift'),
  ('d784b91e', 'Tests/PermutationTests/PermutationTests.swift'),
  ('a31dbcb3', 'Tests/PermutationTests/DeathTestSignal.swift'),
  ('a31dbcb3', 'Tests/PermutationTests/NextPermutationsSequence/NextPermutationsSequence_0_PublicSurfaceTests.swift'),
  ('a31dbcb3', 'Tests/PermutationTests/NextPermutationsSequence/NextPermutationsSequence_1_EnumerationTests.swift'),
  ('a31dbcb3', 'Tests/PermutationTests/NextPermutationsSequence/NextPermutationsSequence_2_ValueSemanticsTests.swift'),
  ('a31dbcb3', 'Tests/PermutationTests/NextPermutationsSequence/NextPermutationsSequence_3_PermutationCollectionTests.swift'),
  ('a31dbcb3', 'Tests/PermutationTests/NextPermutationsSequence/NextPermutationsSequence_4_CoexistenceTests.swift'),
  ('a31dbcb3', 'Tests/PermutationTests/NextPermutationsSequence/NextPermutationsSequence_98_InternalTests.swift'),
  ('a31dbcb3', 'Tests/PermutationTests/NextPermutationsSequence/NextPermutationsSequence_99_DeathTests.swift'),
  ('control',  'Tests/RedBlackTreeTests/RedBlackTreeSet/RedBlackTreeSet_16_BoundExpressionTests.swift');

-- File name split at its first two underscores: <prefix>_<number>_<rest>.swift
CREATE VIEW test_name AS
WITH b(snapshot, path, base) AS (
  SELECT snapshot, path, replace(path, rtrim(path, replace(path, '/', '')), '') FROM test_path),
p(snapshot, path, base, prefix, tail) AS (
  SELECT snapshot, path, base,
         CASE WHEN instr(base, '_') > 0 THEN substr(base, 1, instr(base, '_') - 1) END,
         CASE WHEN instr(base, '_') > 0 THEN substr(base, instr(base, '_') + 1) END
  FROM b)
SELECT snapshot, path, base, prefix,
       CASE WHEN instr(tail, '_') > 1 THEN substr(tail, 1, instr(tail, '_') - 1) END AS number
FROM p;

-- old rule: RedBlackTree<...>_<number>_*.swift (as recorded in AI_GRAPH_SMELL_NOTES.md; no number limit is recorded)
-- current rule: <PublicType>_<number>_*.swift with number < 90 (90 and above are non-spec, e.g. internal and death tests)
CREATE VIEW test_role AS
SELECT snapshot, path, number,
       CASE WHEN prefix GLOB 'RedBlackTree*' AND number <> '' AND number NOT GLOB '*[^0-9]*'
            THEN 'spec' ELSE 'non-spec' END AS old_role,
       CASE WHEN prefix GLOB '[A-Z]*' AND prefix NOT GLOB '*[^A-Za-z0-9]*'
                 AND number <> '' AND number NOT GLOB '*[^0-9]*' AND CAST(number AS INTEGER) < 90
            THEN 'spec' ELSE 'non-spec' END AS current_role
FROM test_name;

.headers on
.mode column
.print == RP-05 roles ==
SELECT snapshot, replace(replace(path, 'Tests/PermutationTests/', ''), 'Tests/RedBlackTreeTests/', '') AS path, number, old_role, current_role
FROM test_role ORDER BY snapshot DESC, path;

CREATE TABLE expected (snapshot TEXT, rule TEXT, spec INTEGER, non_spec INTEGER, spec_numbers TEXT, non_spec_numbers TEXT);
INSERT INTO expected VALUES
  ('d784b91e', 'old',     0, 4, '',          ''),
  ('d784b91e', 'current', 0, 4, '',          ''),
  ('a31dbcb3', 'old',     0, 8, '',          '0,1,2,3,4,98,99'),
  ('a31dbcb3', 'current', 5, 3, '0,1,2,3,4', '98,99'),
  ('control',  'old',     1, 0, '16',        ''),
  ('control',  'current', 1, 0, '16',        '');

CREATE VIEW actual AS
WITH r(snapshot, rule, role, number) AS (
  SELECT snapshot, 'old', old_role, number FROM test_role
  UNION ALL SELECT snapshot, 'current', current_role, number FROM test_role),
n(snapshot, rule, role, numbers) AS (
  SELECT snapshot, rule, role,
         coalesce((SELECT group_concat(number, ',') FROM (SELECT number FROM r r2
                   WHERE r2.snapshot = r.snapshot AND r2.rule = r.rule AND r2.role = r.role AND r2.number IS NOT NULL
                   ORDER BY CAST(number AS INTEGER))), '')
  FROM r GROUP BY snapshot, rule, role)
SELECT s.snapshot, s.rule,
       (SELECT count(*) FROM r WHERE r.snapshot = s.snapshot AND r.rule = s.rule AND r.role = 'spec')     AS spec,
       (SELECT count(*) FROM r WHERE r.snapshot = s.snapshot AND r.rule = s.rule AND r.role = 'non-spec') AS non_spec,
       coalesce((SELECT numbers FROM n WHERE n.snapshot = s.snapshot AND n.rule = s.rule AND n.role = 'spec'), '')     AS spec_numbers,
       coalesce((SELECT numbers FROM n WHERE n.snapshot = s.snapshot AND n.rule = s.rule AND n.role = 'non-spec'), '') AS non_spec_numbers
FROM (SELECT DISTINCT snapshot, rule FROM r) s;

.print
.print == RP-05 counts ==
SELECT * FROM actual ORDER BY snapshot DESC, rule DESC;

.print
SELECT CASE WHEN count(*) = 0 THEN 'RP-05: PASS (current rule: 0-4 spec, 98 and 99 non-spec)'
            ELSE 'RP-05: FAIL (' || count(*) || ' mismatch(es))' END AS result
FROM (SELECT * FROM (SELECT * FROM expected EXCEPT SELECT * FROM actual)
      UNION ALL
      SELECT * FROM (SELECT * FROM actual EXCEPT SELECT * FROM expected));
