-- GRAPH-014 / RP-17: is an observation stale, given the commit it was observed at and the files changed since then?
-- From the repository root:  sqlite3 :memory: < Maintanance/AIGraphInMemoryFixture/rp17_staleness.sql
-- Input transcribed from `git diff --name-only b87c8428..bb77fafc -- Sources` (no Git extraction at run time).
-- The code graph observed at b87c8428 was shown as stale at the start of the 2026-10-08 session and rebuilt at bb77fafc.
.bail on
.read Maintanance/AIGraphInMemoryFixture/schema.sql

INSERT INTO node VALUES
  ('s:19OptionalArrayModule0A7Array4DV', 'symbol', 'OptionalArray4D', 'Sources/OptionalArrayModule/OptinalArray.swift:277',
   277, 277, NULL, 'compiler_symbolgraph', 'confirmed', 'bb77fafc');

-- One node observed at several commits. node.observed_at holds the latest one; this table keeps each observation.
CREATE TABLE observation (
  node        TEXT NOT NULL REFERENCES node(id),
  file        TEXT NOT NULL,
  observed_at TEXT NOT NULL,
  PRIMARY KEY (node, observed_at)
);
INSERT INTO observation VALUES
  ('s:19OptionalArrayModule0A7Array4DV', 'Sources/OptionalArrayModule/OptinalArray.swift', 'b87c8428'),
  ('s:19OptionalArrayModule0A7Array4DV', 'Sources/OptionalArrayModule/OptinalArray.swift', 'bb77fafc');

-- Commit ranges whose changed files were transcribed. A range listed here with no changed_file rows changed nothing;
-- a range not listed here is unknown, not unchanged.
CREATE TABLE diff_range (from_commit TEXT, to_commit TEXT, pathspec TEXT NOT NULL, PRIMARY KEY (from_commit, to_commit));
CREATE TABLE changed_file (
  from_commit TEXT NOT NULL,
  to_commit   TEXT NOT NULL,
  path        TEXT NOT NULL,
  PRIMARY KEY (from_commit, to_commit, path),
  FOREIGN KEY (from_commit, to_commit) REFERENCES diff_range(from_commit, to_commit)
);
INSERT INTO diff_range VALUES ('b87c8428', 'bb77fafc', 'Sources'), ('bb77fafc', 'bb77fafc', 'Sources');
INSERT INTO changed_file VALUES
  ('b87c8428', 'bb77fafc', 'Sources/OptionalArrayModule/OptinalArray.swift'),
  ('b87c8428', 'bb77fafc', 'Sources/PermutationModule/Documentation/QualityAssessment-ISO25010.md');

CREATE TABLE as_of (head TEXT NOT NULL);
INSERT INTO as_of VALUES ('bb77fafc');

CREATE VIEW staleness AS
SELECT n.display AS node, o.observed_at, a.head AS as_of,
       CASE
         WHEN NOT EXISTS (SELECT 1 FROM diff_range r WHERE r.from_commit = o.observed_at AND r.to_commit = a.head) THEN 'unknown'
         WHEN EXISTS (SELECT 1 FROM changed_file c
                      WHERE c.from_commit = o.observed_at AND c.to_commit = a.head AND c.path = o.file) THEN 'stale'
         ELSE 'not stale'
       END AS status,
       (SELECT group_concat(c.path, ', ') FROM changed_file c
        WHERE c.from_commit = o.observed_at AND c.to_commit = a.head AND c.path = o.file) AS evidence
FROM observation o JOIN node n ON n.id = o.node CROSS JOIN as_of a;

.headers on
.mode column
.print == RP-17 staleness ==
SELECT * FROM staleness ORDER BY observed_at;

CREATE TABLE expected (node TEXT, observed_at TEXT, status TEXT);
INSERT INTO expected VALUES ('OptionalArray4D', 'b87c8428', 'stale'), ('OptionalArray4D', 'bb77fafc', 'not stale');

.print
SELECT CASE WHEN count(*) = 0 THEN 'RP-17: PASS (observed at b87c8428: stale, at bb77fafc: not stale)'
            ELSE 'RP-17: FAIL (' || count(*) || ' mismatch(es))' END AS result
FROM (SELECT * FROM (SELECT * FROM expected EXCEPT SELECT node, observed_at, status FROM staleness)
      UNION ALL
      SELECT * FROM (SELECT node, observed_at, status FROM staleness EXCEPT SELECT * FROM expected));
