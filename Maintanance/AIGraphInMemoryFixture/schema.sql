-- GRAPH-007: shared schema candidate from AI_GRAPH_SHARED_SCHEMA.md (sections 1-3), for SQLite :memory: only.
PRAGMA foreign_keys = ON;

-- Where a node or edge came from.
CREATE TABLE provenance (
  value   TEXT PRIMARY KEY,
  meaning TEXT NOT NULL
);

-- How certain it is. Independent of provenance.
CREATE TABLE confidence (
  value   TEXT PRIMARY KEY,
  meaning TEXT NOT NULL
);

CREATE TABLE node (
  id          TEXT PRIMARY KEY,  -- symbol: USR / test, document: repository path / commit: short hash / task: task ID
  kind        TEXT NOT NULL CHECK (kind IN ('symbol', 'test', 'document', 'commit', 'task')),
  display     TEXT NOT NULL,
  location    TEXT,              -- repository-relative path, with ":line" for a symbol
  span_start  INTEGER,           -- symbol only: declaration line
  span_end    INTEGER,           -- symbol only: line of the closing brace of the body (= span_start without a body)
  role        TEXT CHECK (role IS NULL OR role IN ('spec', 'other')),  -- test only
  provenance  TEXT NOT NULL REFERENCES provenance(value),
  confidence  TEXT NOT NULL REFERENCES confidence(value),
  observed_at TEXT NOT NULL,     -- commit at which it was observed
  CHECK ((kind = 'symbol') = (span_start IS NOT NULL)),
  CHECK ((kind = 'test') = (role IS NOT NULL))
);

CREATE TABLE edge (
  src        TEXT NOT NULL REFERENCES node(id),
  dst        TEXT NOT NULL REFERENCES node(id),
  relation   TEXT NOT NULL CHECK (relation IN ('test_references', 'document_mentions', 'commit_changes', 'task_scopes')),
  provenance TEXT NOT NULL REFERENCES provenance(value),
  confidence TEXT NOT NULL REFERENCES confidence(value),
  evidence   TEXT NOT NULL,      -- file:line, commit, or a command that reproduces the edge
  rank       INTEGER,            -- order given by the derivation itself (commit_changes: git log order, 1 = newest)
  PRIMARY KEY (src, dst, relation)
);
CREATE INDEX edge_dst ON edge(dst, relation);

-- Whether each relation has a source to derive it from. Distinguishes "0 results" from "nothing to derive from".
CREATE TABLE derivation (
  relation  TEXT PRIMARY KEY,
  section   TEXT NOT NULL UNIQUE,
  ordinal   INTEGER NOT NULL UNIQUE,
  available INTEGER NOT NULL CHECK (available IN (0, 1)),
  note      TEXT NOT NULL
);

INSERT INTO provenance VALUES
  ('compiler_symbolgraph', 'swift package dump-symbol-graph output'),
  ('compiler_index',       'index store occurrence'),
  ('syntax',               'lexical scan of source'),
  ('repo_git',             'git history'),
  ('repo_text',            'string match in a tracked document'),
  ('runtime',              'observed by running tests or code'),
  ('ai_inference',         'correspondence inferred by an AI from evidence');

INSERT INTO confidence VALUES
  ('confirmed',  'same result when the derivation is rerun'),
  ('candidate',  'has evidence, but the meaning of the relation is unchecked'),
  ('hypothesis', 'inference with partial evidence'),
  ('refuted',    'disproved; kept with the counter-evidence in evidence');

INSERT INTO derivation VALUES
  ('test_references',   'test',     1, 1, 'index store occurrences with the reference role'),
  ('document_mentions', 'document', 2, 1, 'member name (word) and owner type name both in a Markdown file'),
  ('commit_changes',    'commit',   3, 1, 'git log -L<span>:<file> --no-patch'),
  ('task_scopes',       'task',     4, 0, 'no repository record maps tasks to symbols');
