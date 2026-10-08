-- GRAPH-007 entry point. From the repository root:
--   sqlite3 :memory: < Maintanance/AIGraphInMemoryFixture/run.sql
-- Starts from an empty in-memory database and reads no other database file.
.bail on
.headers on
.mode column
.read Maintanance/AIGraphInMemoryFixture/schema.sql
.read Maintanance/AIGraphInMemoryFixture/rbt017_fixture.sql
.read Maintanance/AIGraphInMemoryFixture/neighbors.sql

INSERT INTO query_input SELECT id FROM node WHERE kind = 'symbol';
.print == foreign key violations (expect none) ==
PRAGMA foreign_key_check;

.print
.print == neighbors ==
.mode list
.separator " | "
SELECT symbol_display, section, node, role, provenance, confidence, evidence
FROM neighbors ORDER BY symbol_display, ordinal, sort_key, node;

.print
.mode column
.print == counts ==
SELECT symbol_display, section, n, status FROM neighbor_counts ORDER BY symbol_display, ordinal;

.print
.print == expected counts (AI_GRAPH_SHARED_SCHEMA.md / AI_GRAPH_IN_MEMORY_FIXTURE.md) ==
CREATE TABLE expected (display TEXT, section TEXT, n INTEGER, status TEXT);
INSERT INTO expected VALUES
  ('RedBlackTreeMappedValuesView.subscript(_:)', 'test',     2, 'derived'),
  ('RedBlackTreeMappedValuesView.subscript(_:)', 'document', 9, 'derived'),
  ('RedBlackTreeMappedValuesView.subscript(_:)', 'commit',   6, 'derived'),
  ('RedBlackTreeMappedValuesView.subscript(_:)', 'task',     0, 'nothing to derive from'),
  ('RedBlackTreeMappedValuesView.swapAt(_:_:)',  'test',     4, 'derived'),
  ('RedBlackTreeMappedValuesView.swapAt(_:_:)',  'document', 8, 'derived'),
  ('RedBlackTreeMappedValuesView.swapAt(_:_:)',  'commit',   7, 'derived'),
  ('RedBlackTreeMappedValuesView.swapAt(_:_:)',  'task',     0, 'nothing to derive from');
SELECT CASE WHEN count(*) = 0 THEN 'PASS: all 8 section counts match' ELSE 'FAIL: ' || count(*) || ' mismatch(es)' END AS result
FROM (SELECT * FROM (SELECT display, section, n, status FROM expected
                     EXCEPT SELECT symbol_display, section, n, status FROM neighbor_counts)
      UNION ALL
      SELECT * FROM (SELECT symbol_display, section, n, status FROM neighbor_counts
                     EXCEPT SELECT display, section, n, status FROM expected));
