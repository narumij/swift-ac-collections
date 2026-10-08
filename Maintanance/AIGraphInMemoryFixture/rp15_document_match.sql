-- GRAPH-013 / RP-15: how many documents a member name matches, by match method.
-- From the repository root:  sqlite3 :memory: < Maintanance/AIGraphInMemoryFixture/rp15_document_match.sql
-- Input transcribed from `git grep` at two commits (no filesystem extraction):
--   word:  git grep -l -w -F subscript <commit> -- 'Sources/*.md' 'Documentation/*.md' 'Maintanance/*.md' README.md ':!Maintanance/Archived'
--   owner: the same file also matches git grep -F RedBlackTreeMappedValuesView
-- Baseline snapshot is bb77fafc (36 / 9). f6f84d6c is the commit that recorded the trial itself; its two notes mention
-- `subscript`, so the word-only count grows to 38. That self-reference is kept as a separate snapshot, not the baseline.
.bail on
.read Maintanance/AIGraphInMemoryFixture/schema.sql

CREATE TABLE document_match (
  snapshot   TEXT NOT NULL,
  path       TEXT NOT NULL,
  with_owner INTEGER NOT NULL CHECK (with_owner IN (0, 1)),  -- 1: the owner type name is in the same file
  PRIMARY KEY (snapshot, path)
);
CREATE TABLE snapshot (name TEXT PRIMARY KEY, role TEXT NOT NULL);
INSERT INTO snapshot VALUES ('bb77fafc', 'baseline'), ('f6f84d6c', 'self-reference');

-- every row matches the member name `subscript` as a word
INSERT INTO document_match VALUES
  ('bb77fafc', 'Documentation/Compatibility/map.ja.md', 0),
  ('bb77fafc', 'Documentation/Compatibility/multimap.ja.md', 0),
  ('bb77fafc', 'Documentation/Compatibility/multiset.ja.md', 0),
  ('bb77fafc', 'Documentation/Compatibility/set.ja.md', 0),
  ('bb77fafc', 'Documentation/RedBlackTreeMultiMap.ja.md', 1),
  ('bb77fafc', 'Documentation/RedBlackTreeMultiMap.md', 1),
  ('bb77fafc', 'Maintanance/AGENT_TASK_FIT_INTERVIEW.md', 0),
  ('bb77fafc', 'Maintanance/CLAUDE_OBSERVATIONS.md', 0),
  ('bb77fafc', 'Maintanance/OptionalArrayModule/OptionalArrayAudit.md', 0),
  ('bb77fafc', 'Maintanance/PERFORMANCE_REGRESSION_BISECTION.md', 0),
  ('bb77fafc', 'Maintanance/PROGRESS_OVERVIEW.md', 0),
  ('bb77fafc', 'Maintanance/PermutationModule/DocumentationHandoffAudit.md', 0),
  ('bb77fafc', 'Maintanance/PermutationModule/ProductReadinessAssessment.md', 0),
  ('bb77fafc', 'Maintanance/RED_BLACK_TREE_REMAINING_TASKS.md', 1),
  ('bb77fafc', 'Maintanance/StrictMemorySafetyReadiness.md', 0),
  ('bb77fafc', 'Maintanance/USER_MANAGEMENT_INTERVIEW_CLAUDE.md', 0),
  ('bb77fafc', 'Sources/RedBlackTreeCollections/Documentation/API-Matrix-View.md', 1),
  ('bb77fafc', 'Sources/RedBlackTreeCollections/Documentation/API-Matrix.md', 1),
  ('bb77fafc', 'Sources/RedBlackTreeCollections/Documentation/AtCoder2025_compatibility_api_matrix.md', 0),
  ('bb77fafc', 'Sources/RedBlackTreeCollections/Documentation/AtCoder2025_diff.md', 0),
  ('bb77fafc', 'Sources/RedBlackTreeCollections/Documentation/Cpp-Matrix.md', 0),
  ('bb77fafc', 'Sources/RedBlackTreeCollections/Documentation/Design/Design-InternalArchitecture.md', 0),
  ('bb77fafc', 'Sources/RedBlackTreeCollections/Documentation/Design/Design-NodeStorage.md', 0),
  ('bb77fafc', 'Sources/RedBlackTreeCollections/Documentation/Head/Outlines/RedBlackTreeDictionary.outline.md', 0),
  ('bb77fafc', 'Sources/RedBlackTreeCollections/Documentation/Head/Outlines/RedBlackTreeMultiMap.outline.md', 1),
  ('bb77fafc', 'Sources/RedBlackTreeCollections/Documentation/Head/Outlines/RedBlackTreeMultiSet.outline.md', 0),
  ('bb77fafc', 'Sources/RedBlackTreeCollections/Documentation/Head/Outlines/RedBlackTreeSet.outline.md', 0),
  ('bb77fafc', 'Sources/RedBlackTreeCollections/Documentation/Head/RedBlackTreeMultiMap.ja.md', 1),
  ('bb77fafc', 'Sources/RedBlackTreeCollections/Documentation/Head/RedBlackTreeMultiMap.md', 1),
  ('bb77fafc', 'Sources/RedBlackTreeCollections/Documentation/MEMO.md', 0),
  ('bb77fafc', 'Sources/RedBlackTreeCollections/Documentation/isValid.md', 0),
  ('bb77fafc', 'Sources/RedBlackTreeCollections/RedBlackTreeCollections.docc/RedBlackTreeDictionary.md', 0),
  ('bb77fafc', 'Sources/RedBlackTreeCollections/RedBlackTreeCollections.docc/RedBlackTreeMappedValuesView.md', 1),
  ('bb77fafc', 'Sources/RedBlackTreeCollections/RedBlackTreeCollections.docc/RedBlackTreeMultiMap.md', 0),
  ('bb77fafc', 'Sources/RedBlackTreeCollections/RedBlackTreeCollections.docc/RedBlackTreeMultiSet.md', 0),
  ('bb77fafc', 'Sources/RedBlackTreeCollections/RedBlackTreeCollections.docc/RedBlackTreeSet.md', 0),
  ('f6f84d6c', 'Documentation/Compatibility/map.ja.md', 0),
  ('f6f84d6c', 'Documentation/Compatibility/multimap.ja.md', 0),
  ('f6f84d6c', 'Documentation/Compatibility/multiset.ja.md', 0),
  ('f6f84d6c', 'Documentation/Compatibility/set.ja.md', 0),
  ('f6f84d6c', 'Documentation/RedBlackTreeMultiMap.ja.md', 1),
  ('f6f84d6c', 'Documentation/RedBlackTreeMultiMap.md', 1),
  ('f6f84d6c', 'Maintanance/AGENT_TASK_FIT_INTERVIEW.md', 0),
  ('f6f84d6c', 'Maintanance/AI_GRAPH_SMELL_NOTES.md', 0),
  ('f6f84d6c', 'Maintanance/CLAUDE_OBSERVATIONS.md', 0),
  ('f6f84d6c', 'Maintanance/GRAPH_DB_EXCHANGE.md', 0),
  ('f6f84d6c', 'Maintanance/OptionalArrayModule/OptionalArrayAudit.md', 0),
  ('f6f84d6c', 'Maintanance/PERFORMANCE_REGRESSION_BISECTION.md', 0),
  ('f6f84d6c', 'Maintanance/PROGRESS_OVERVIEW.md', 0),
  ('f6f84d6c', 'Maintanance/PermutationModule/DocumentationHandoffAudit.md', 0),
  ('f6f84d6c', 'Maintanance/PermutationModule/ProductReadinessAssessment.md', 0),
  ('f6f84d6c', 'Maintanance/RED_BLACK_TREE_REMAINING_TASKS.md', 1),
  ('f6f84d6c', 'Maintanance/StrictMemorySafetyReadiness.md', 0),
  ('f6f84d6c', 'Maintanance/USER_MANAGEMENT_INTERVIEW_CLAUDE.md', 0),
  ('f6f84d6c', 'Sources/RedBlackTreeCollections/Documentation/API-Matrix-View.md', 1),
  ('f6f84d6c', 'Sources/RedBlackTreeCollections/Documentation/API-Matrix.md', 1),
  ('f6f84d6c', 'Sources/RedBlackTreeCollections/Documentation/AtCoder2025_compatibility_api_matrix.md', 0),
  ('f6f84d6c', 'Sources/RedBlackTreeCollections/Documentation/AtCoder2025_diff.md', 0),
  ('f6f84d6c', 'Sources/RedBlackTreeCollections/Documentation/Cpp-Matrix.md', 0),
  ('f6f84d6c', 'Sources/RedBlackTreeCollections/Documentation/Design/Design-InternalArchitecture.md', 0),
  ('f6f84d6c', 'Sources/RedBlackTreeCollections/Documentation/Design/Design-NodeStorage.md', 0),
  ('f6f84d6c', 'Sources/RedBlackTreeCollections/Documentation/Head/Outlines/RedBlackTreeDictionary.outline.md', 0),
  ('f6f84d6c', 'Sources/RedBlackTreeCollections/Documentation/Head/Outlines/RedBlackTreeMultiMap.outline.md', 1),
  ('f6f84d6c', 'Sources/RedBlackTreeCollections/Documentation/Head/Outlines/RedBlackTreeMultiSet.outline.md', 0),
  ('f6f84d6c', 'Sources/RedBlackTreeCollections/Documentation/Head/Outlines/RedBlackTreeSet.outline.md', 0),
  ('f6f84d6c', 'Sources/RedBlackTreeCollections/Documentation/Head/RedBlackTreeMultiMap.ja.md', 1),
  ('f6f84d6c', 'Sources/RedBlackTreeCollections/Documentation/Head/RedBlackTreeMultiMap.md', 1),
  ('f6f84d6c', 'Sources/RedBlackTreeCollections/Documentation/MEMO.md', 0),
  ('f6f84d6c', 'Sources/RedBlackTreeCollections/Documentation/isValid.md', 0),
  ('f6f84d6c', 'Sources/RedBlackTreeCollections/RedBlackTreeCollections.docc/RedBlackTreeDictionary.md', 0),
  ('f6f84d6c', 'Sources/RedBlackTreeCollections/RedBlackTreeCollections.docc/RedBlackTreeMappedValuesView.md', 1),
  ('f6f84d6c', 'Sources/RedBlackTreeCollections/RedBlackTreeCollections.docc/RedBlackTreeMultiMap.md', 0),
  ('f6f84d6c', 'Sources/RedBlackTreeCollections/RedBlackTreeCollections.docc/RedBlackTreeMultiSet.md', 0),
  ('f6f84d6c', 'Sources/RedBlackTreeCollections/RedBlackTreeCollections.docc/RedBlackTreeSet.md', 0)
;

CREATE VIEW match_count AS
SELECT s.name AS snapshot, s.role,
       (SELECT count(*) FROM document_match d WHERE d.snapshot = s.name)                    AS word_only,
       (SELECT count(*) FROM document_match d WHERE d.snapshot = s.name AND d.with_owner = 1) AS with_owner
FROM snapshot s;

-- documents that are in the later snapshot only
CREATE VIEW added_after_baseline AS
SELECT path FROM document_match WHERE snapshot = 'f6f84d6c'
EXCEPT SELECT path FROM document_match WHERE snapshot = 'bb77fafc';

.headers on
.mode column
.print == RP-15 counts ==
SELECT * FROM match_count ORDER BY snapshot;
.print
.print == RP-15 added by the self-referencing commit ==
SELECT * FROM added_after_baseline ORDER BY path;

CREATE TABLE expected (snapshot TEXT, role TEXT, word_only INTEGER, with_owner INTEGER);
INSERT INTO expected VALUES ('bb77fafc', 'baseline', 36, 9), ('f6f84d6c', 'self-reference', 38, 9);
CREATE TABLE expected_added (path TEXT);
INSERT INTO expected_added VALUES ('Maintanance/AI_GRAPH_SMELL_NOTES.md'), ('Maintanance/GRAPH_DB_EXCHANGE.md');

.print
SELECT CASE WHEN count(*) = 0 THEN 'RP-15: PASS (baseline bb77fafc: word 36, with owner 9; f6f84d6c: 38 / 9)'
            ELSE 'RP-15: FAIL (' || count(*) || ' mismatch(es))' END AS result
FROM (SELECT * FROM (SELECT * FROM expected EXCEPT SELECT * FROM match_count)
      UNION ALL
      SELECT * FROM (SELECT * FROM match_count EXCEPT SELECT * FROM expected)
      UNION ALL
      SELECT * FROM (SELECT path, NULL, NULL, NULL FROM expected_added EXCEPT SELECT path, NULL, NULL, NULL FROM added_after_baseline)
      UNION ALL
      SELECT * FROM (SELECT path, NULL, NULL, NULL FROM added_after_baseline EXCEPT SELECT path, NULL, NULL, NULL FROM expected_added));
