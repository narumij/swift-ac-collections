-- GRAPH-012 / RP-08: Release public API with no specification-test reference, excluding configuration-limited symbols.
-- From the repository root:  sqlite3 :memory: < Maintanance/Graph/InMemoryFixture/rp08_spec_gap.sql
-- Input transcribed by hand (no build): USRs and access from the symbol graph, the enclosing `#if` from the source,
-- and the specification-test reference added by 58aab943 ("Specify RedBlackTreeBoundExpression.find(_:) in Set bound
-- expression tests"). Before 58aab943 no specification test referenced find(_:), as recorded in AI_GRAPH_SMELL_NOTES.md.
.bail on
.read Maintanance/Graph/InMemoryFixture/schema.sql

INSERT INTO node VALUES
  ('s:23RedBlackTreeCollections0abC15BoundExpressionV4findyACyxGxFZ', 'symbol', 'RedBlackTreeBoundExpression.find(_:)',
   'Sources/RedBlackTreeCollections/Implements/BoundsExpression/RedBlackTreeBoundExpression.swift:179', 179, 179, NULL,
   'compiler_symbolgraph', 'confirmed', 'a31dbcb3'),
  ('s:23RedBlackTreeCollections0abC3SetV12freeCapacitySivp', 'symbol', 'RedBlackTreeSet.freeCapacity',
   'Sources/RedBlackTreeCollections/Implements/Protocol/BalancedSequence.swift:193', 193, 193, NULL,
   'compiler_symbolgraph', 'confirmed', 'a31dbcb3'),
  ('Tests/RedBlackTreeTests/RedBlackTreeSet/RedBlackTreeSet_16_BoundExpressionTests.swift', 'test', 'RedBlackTreeSet_16_BoundExpressionTests.swift',
   'Tests/RedBlackTreeTests/RedBlackTreeSet/RedBlackTreeSet_16_BoundExpressionTests.swift', NULL, NULL, 'spec',
   'compiler_index', 'confirmed', 'a31dbcb3'),
  ('58aab943', 'commit', '2026-10-07 Specify RedBlackTreeBoundExpression.find(_:) in Set bound expression tests',
   NULL, NULL, NULL, NULL, 'repo_git', 'confirmed', 'a31dbcb3');

-- Access level and the build condition a symbol exists under (NULL = every configuration).
CREATE TABLE symbol_config (
  symbol     TEXT PRIMARY KEY REFERENCES node(id),
  access     TEXT NOT NULL,
  condition  TEXT,
  provenance TEXT NOT NULL REFERENCES provenance(value),
  evidence   TEXT NOT NULL
);
INSERT INTO symbol_config VALUES
  ('s:23RedBlackTreeCollections0abC15BoundExpressionV4findyACyxGxFZ', 'public', NULL,
   'compiler_symbolgraph', 'symbol graph accessLevel'),
  ('s:23RedBlackTreeCollections0abC3SetV12freeCapacitySivp', 'public', 'DEBUG && !COMPATIBLE_ATCODER_2025',
   'syntax', 'Sources/RedBlackTreeCollections/Implements/Protocol/BalancedSequence.swift:188 #if DEBUG && !COMPATIBLE_ATCODER_2025');

INSERT INTO edge(src, dst, relation, provenance, confidence, evidence) VALUES
  ('Tests/RedBlackTreeTests/RedBlackTreeSet/RedBlackTreeSet_16_BoundExpressionTests.swift',
   's:23RedBlackTreeCollections0abC15BoundExpressionV4findyACyxGxFZ', 'test_references', 'compiler_index', 'confirmed', 'index store');

-- Edges that did not exist before a commit. A snapshot "before C" is the edge set minus what C introduced.
CREATE TABLE introduced_by (
  commit_id TEXT NOT NULL REFERENCES node(id),
  src       TEXT NOT NULL,
  dst       TEXT NOT NULL,
  relation  TEXT NOT NULL,
  PRIMARY KEY (commit_id, src, dst, relation),
  FOREIGN KEY (src, dst, relation) REFERENCES edge(src, dst, relation)
);
INSERT INTO introduced_by VALUES
  ('58aab943', 'Tests/RedBlackTreeTests/RedBlackTreeSet/RedBlackTreeSet_16_BoundExpressionTests.swift',
   's:23RedBlackTreeCollections0abC15BoundExpressionV4findyACyxGxFZ', 'test_references');

CREATE TABLE snapshot (name TEXT PRIMARY KEY, without_commit TEXT);
INSERT INTO snapshot VALUES ('before 58aab943', '58aab943'), ('after 58aab943', NULL);

-- Release public API = public or open, and not limited to a build condition that contains DEBUG.
CREATE VIEW spec_gap AS
SELECT sn.name AS snapshot, n.display AS symbol
FROM snapshot sn
CROSS JOIN symbol_config c
JOIN node n ON n.id = c.symbol
WHERE c.access IN ('public', 'open')
  AND NOT (coalesce(c.condition, '') GLOB '*DEBUG*' AND coalesce(c.condition, '') NOT GLOB '*!DEBUG*')
  AND NOT EXISTS (
    SELECT 1 FROM edge e JOIN node t ON t.id = e.src
    WHERE e.dst = c.symbol AND e.relation = 'test_references' AND t.role = 'spec'
      AND NOT EXISTS (SELECT 1 FROM introduced_by i
                      WHERE i.commit_id = sn.without_commit AND i.src = e.src AND i.dst = e.dst AND i.relation = e.relation));

CREATE VIEW excluded_by_condition AS
SELECT n.display AS symbol, c.condition FROM symbol_config c JOIN node n ON n.id = c.symbol
WHERE coalesce(c.condition, '') GLOB '*DEBUG*' AND coalesce(c.condition, '') NOT GLOB '*!DEBUG*';

.headers on
.mode column
.print == RP-08 Release public gaps ==
SELECT * FROM spec_gap ORDER BY snapshot DESC, symbol;
.print
.print == RP-08 excluded as configuration-limited ==
SELECT * FROM excluded_by_condition;

CREATE TABLE expected (snapshot TEXT, symbol TEXT);
INSERT INTO expected VALUES ('before 58aab943', 'RedBlackTreeBoundExpression.find(_:)');

.print
SELECT CASE WHEN count(*) = 0
              AND (SELECT count(*) FROM excluded_by_condition WHERE symbol = 'RedBlackTreeSet.freeCapacity') = 1
            THEN 'RP-08: PASS (before 58aab943: 1 gap find(_:), after: 0; freeCapacity excluded as DEBUG-only)'
            ELSE 'RP-08: FAIL (' || count(*) || ' mismatch(es))' END AS result
FROM (SELECT * FROM (SELECT snapshot, symbol FROM expected EXCEPT SELECT snapshot, symbol FROM spec_gap)
      UNION ALL
      SELECT * FROM (SELECT snapshot, symbol FROM spec_gap EXCEPT SELECT snapshot, symbol FROM expected));
