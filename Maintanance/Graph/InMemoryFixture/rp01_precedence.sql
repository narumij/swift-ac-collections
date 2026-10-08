-- GRAPH-010 / RP-01: task pairs without a precedence edge in either direction.
-- From the repository root:  sqlite3 :memory: < Maintanance/Graph/InMemoryFixture/rp01_precedence.sql
-- Input transcribed from the Task Registry / Task precedence of Maintanance/PROGRESS_OVERVIEW.md at a31dbcb3.
-- Symbol sharing (task -> symbol scope) has no repository record and is not part of this fixture.
.bail on
.read Maintanance/Graph/InMemoryFixture/schema.sql

INSERT INTO node(id, kind, display, location, provenance, confidence, observed_at) VALUES
  ('RBT-001', 'task', 'Index完了ゲート',                              'Maintanance/PROGRESS_OVERVIEW.md', 'repo_text', 'confirmed', 'a31dbcb3'),
  ('RBT-004', 'task', 'Debug限定Comparable群・Balanced群',             'Maintanance/PROGRESS_OVERVIEW.md', 'repo_text', 'confirmed', 'a31dbcb3'),
  ('RBT-010', 'task', 'Index完了ゲートのうち公開Index表現と完了範囲',  'Maintanance/PROGRESS_OVERVIEW.md', 'repo_text', 'confirmed', 'a31dbcb3'),
  ('RBT-011', 'task', 'Indexの`Comparable`採否',                       'Maintanance/PROGRESS_OVERVIEW.md', 'repo_text', 'confirmed', 'a31dbcb3');

-- Task precedence rows "| `RBT-001` | `RBT-010` |" and "| `RBT-001` | `RBT-011` |": RBT-001 needs RBT-010 / RBT-011.
INSERT INTO edge(src, dst, relation, provenance, confidence, evidence) VALUES
  ('RBT-001', 'RBT-010', 'task_precedence', 'repo_text', 'confirmed', 'PROGRESS_OVERVIEW.md Task precedence: 前提taskの完了後に後続taskを完了できる'),
  ('RBT-001', 'RBT-011', 'task_precedence', 'repo_text', 'confirmed', 'PROGRESS_OVERVIEW.md Task precedence: 前提taskの完了後に後続taskを完了できる');

-- The task set under question (RP-01 / AI_GRAPH_SMELL_NOTES.md "S-1").
CREATE TABLE task_set (task TEXT PRIMARY KEY REFERENCES node(id));
INSERT INTO task_set VALUES ('RBT-001'), ('RBT-004'), ('RBT-010'), ('RBT-011');

CREATE VIEW missing_pair AS
SELECT a.task AS a, b.task AS b
FROM task_set a JOIN task_set b ON a.task < b.task
WHERE NOT EXISTS (SELECT 1 FROM edge e WHERE e.relation = 'task_precedence'
                    AND ((e.src = a.task AND e.dst = b.task) OR (e.src = b.task AND e.dst = a.task)));

.headers on
.mode column
.print == RP-01 pairs without a precedence edge ==
SELECT a, b FROM missing_pair ORDER BY a, b;

CREATE TABLE expected (a TEXT, b TEXT);
INSERT INTO expected VALUES ('RBT-001', 'RBT-004'), ('RBT-004', 'RBT-010'), ('RBT-004', 'RBT-011'), ('RBT-010', 'RBT-011');

.print
SELECT CASE WHEN count(*) = 0 THEN 'RP-01: PASS (4 pairs without a precedence edge)'
            ELSE 'RP-01: FAIL (' || count(*) || ' mismatch(es))' END AS result
FROM (SELECT * FROM (SELECT a, b FROM expected EXCEPT SELECT a, b FROM missing_pair)
      UNION ALL
      SELECT * FROM (SELECT a, b FROM missing_pair EXCEPT SELECT a, b FROM expected));
