-- GRAPH-007: the "隣を引く" query (AI_GRAPH_SHARED_SCHEMA.md section 4).
-- Input: symbol ids in query_input. Output: test, document, commit, task sections with provenance, confidence, evidence.

CREATE TABLE query_input (symbol TEXT PRIMARY KEY REFERENCES node(id));

-- One row per neighbor. Spec tests first, commits newest first.
CREATE VIEW neighbors AS
SELECT q.symbol,
       s.display                AS symbol_display,
       d.ordinal,
       d.section,
       n.id                     AS node,
       n.role,
       e.provenance,
       e.confidence,
       e.evidence,
       CASE d.relation
         WHEN 'test_references' THEN (n.role <> 'spec')
         WHEN 'commit_changes'  THEN e.rank
         ELSE 0
       END                      AS sort_key
FROM query_input q
JOIN node s       ON s.id = q.symbol
JOIN edge e       ON e.dst = q.symbol
JOIN derivation d ON d.relation = e.relation
JOIN node n       ON n.id = e.src;

-- One row per symbol and section, including empty sections.
-- status: "derived" = a source exists (0 means really none), "nothing to derive from" = no source for this relation.
CREATE VIEW neighbor_counts AS
SELECT q.symbol,
       s.display AS symbol_display,
       d.ordinal,
       d.section,
       (SELECT count(*) FROM edge e WHERE e.dst = q.symbol AND e.relation = d.relation) AS n,
       CASE d.available WHEN 1 THEN 'derived' ELSE 'nothing to derive from' END       AS status,
       d.note
FROM query_input q
JOIN node s ON s.id = q.symbol
CROSS JOIN derivation d;
