# Prime-to-Worker Codex Work Request

Status: Experimental file-based handoff. This interface is not yet adopted as routine operation.

The fixed role and boundaries are defined in `Orientation/WORKER_CODEX_BOOTSTRAP.md`. Worker
execution does not accept or complete the repository task. Prime Codex independently reviews the
return and owns every correction, Registry update, and completion decision.

## Current job status

**受入完了: Array owner rename残存の独立監査**

The user may start this assignment by opening the existing Worker Xcode conversation and saying
`やって`. The Worker must reread this file and execute only the assignment below.

Prime acceptance (2026-10-13): Workerの分類と変更範囲を独立に照合し、唯一の
`CURRENT-DEFECT`を受け入れた。旧`OPT-044`は`ARRAY-009`の判断に吸収済みとし、Registry、
0.6.0 release計画、OptionalArray監査記録から未解決判断としての残留を解消した。

## Active assignment: Array owner rename residue audit

### Objective

Independently audit the accepted owner-family rename from `BareArray*` and `OptionalArray*` to
`ElementBuffer*` and `OptionalElementBuffer*`. Identify current executable surfaces or current
authoritative records that still use an obsolete type name or obsolete source path. Distinguish them
from legitimate module names, test-file grouping names, benchmark evidence directories, and
historical records that must retain the vocabulary they actually observed.

This is a read-only audit. Do not fix any finding.

### Workspace and start state

- Workspace: the existing Xcode workspace for this repository.
- Expected branch: `develop/misc/64`.
- Expected HEAD: `c00e79ff` (`Rename OptionalArray owners to OptionalElementBuffer`).
- Expected worktree changes: this assignment in `Maintanance/WORKER_TASK.md`; Prime Codex may
  concurrently correct already-known obsolete source paths in `Maintanance/PROGRESS_OVERVIEW.md`.
- Prime Codex and the user retain ownership of the shared worktree.

Verify branch, HEAD, and worktree before auditing. The two expected files above are not a stop
condition. If another difference exists, record it in the return section and stop. Commits ahead of
the remote are not a stop condition.

### First reading

Read in this order:

1. `Orientation/WORKER_CODEX_BOOTSTRAP.md` in full.
2. This assignment in full.
3. The decisions table in `PUBLIC_API_NAMING_DECISIONS.md`.
4. Only the `ARRAY-007`, `ARRAY-014`, `BARE-036`, `OPT-060`, and `OPT-058` Registry rows in
   `PROGRESS_OVERVIEW.md`.
5. Current files needed to test the search categories below.

Do not read Archived records merely because a search finds an old name there. Do not reconstruct an
older task from history.

### Audit scope

Check these current surfaces:

- production declarations and references under `Sources/`;
- active tests under `Tests/`, excluding `Tests/Archived/`;
- benchmark source and active library configuration under `Benchmarks/Sources/` and
  `Benchmarks/Libraries/`;
- active compiler fixtures under `Utilities/Maintenance/CompilerDiagnostics/`;
- public Quality Profiles under `Sources/*/Documentation/`;
- the current Task Registry and naming decision/handoff documents.

Search for at least:

- `BareArray`, `BareArray2D`, `BareArray3D`, `BareArray4D`;
- `OptionalArray1D`, `OptionalArray2D`, `OptionalArray3D`, `OptionalArray4D`;
- `Sources/BareArrayModule/BareArray.swift`;
- `Sources/OptionalArrayModule/OptinalArray.swift`.

Classify every reported finding as exactly one of:

1. `CURRENT-DEFECT`: current executable surface, current public documentation, current selector, or
   current authoritative reference that should use the adopted name/path;
2. `LEGITIMATE-CURRENT`: module/product-area name, test grouping/file name, script or evidence
   directory whose identity was not part of the owner-type rename;
3. `HISTORICAL`: deliberation, score, audit snapshot, past evidence, or archived material that must
   keep the old name to remain truthful;
4. `UNCERTAIN`: classification needs a product or maintenance decision.

Do not report raw search output without classification. For each `CURRENT-DEFECT` or `UNCERTAIN`
finding, provide file, line, exact text, and why it belongs in that category. Summarize
`LEGITIMATE-CURRENT` and `HISTORICAL` by pattern unless an individual example is needed to establish
the distinction.

### Allowed changes

- Only the `Worker return` section of this file.

No source, test, benchmark, fixture, documentation, Registry, or decision record may be changed by
Worker. Prime's permitted concurrent Registry path correction does not authorize Worker edits.

### Validation boundary

This assignment does not rerun builds or tests. Prime already has build and test evidence and will
decide whether a finding requires revalidation. Do not claim semantic correctness from search
results alone.

### Repository operation authority

- Branch creation or switching: not authorized.
- Commit, push, merge, rebase, reset, restoration, or deletion: not authorized.
- Other-agent delegation: not authorized.

### Stop conditions

Stop and return observed facts if the branch, HEAD, or initial worktree differs beyond the two
expected files; another participant changes a file other than Prime's permitted Registry path
correction; classification requires reading broad Archived history; or a finding cannot be classified
without changing the accepted public naming decision. Re-read the five assigned Registry rows before
returning so a path already corrected by Prime is not reported as an unresolved defect.

### Return requirements

Write the result below. Include the checked scope, exact `CURRENT-DEFECT` and `UNCERTAIN` findings,
summaries of legitimate and historical residue, limitations, and the exact files changed by Worker.
Do not update the Task Registry or mark the rename task complete.

## Worker return

Status: audit executed; one `CURRENT-DEFECT`, no `UNCERTAIN` findings.

### Start state

- Branch: `develop/misc/64`.
- HEAD: `c00e79ff`.
- Initial worktree: only `Maintanance/WORKER_TASK.md` was modified. During the audit,
  `Maintanance/PROGRESS_OVERVIEW.md` acquired the explicitly permitted Prime corrections to the
  `OPT-060`, `ARRAY-014`, and `BARE-036` source paths. No other concurrent difference was observed.

### Checked scope

- Production declarations and references under `Sources/`.
- Active tests under `Tests/`, excluding `Tests/Archived/`.
- `Benchmarks/Sources/`, `Benchmarks/Libraries/`, and
  `Utilities/Maintenance/CompilerDiagnostics/`.
- Public Quality Profiles under `Sources/*/Documentation/`.
- The current Task Registry, `PUBLIC_API_NAMING_DECISIONS.md`, the current naming handoff, current
  quality assessments, and residue in current maintenance records needed to classify the required
  search terms and paths.
- The assigned five Registry rows were re-read after Prime's permitted corrections. Their source
  paths now use `ElementBuffer.swift` or `OptionalElementBuffer.swift` where applicable.

### CURRENT-DEFECT

- `Maintanance/PROGRESS_OVERVIEW.md:195`: ``| `OPT-044` | `FROZEN` | User | [DECISION]
  OptionalArray 1D所有型名の再判断 | 0.6.0の到達範囲判断前に、`OptionalArray1D`を維持するか、AI間で整理した選択肢から一つ判断。0.5.2のコメントドック作業は現行名で先行する | ... |``
  is a current authoritative Registry row that still presents the old 1D owner-name choice as an
  unresolved frozen decision. The authoritative naming decision has since adopted unsuffixed
  `OptionalElementBuffer`, and the implementation row records that rename as done. This is not a
  historical quotation or a grouping identity; the current task state and text are stale.

### UNCERTAIN

- None.

### LEGITIMATE-CURRENT

- `BareArrayModule` / `OptionalArrayModule` module and product-area names, their imports, and paths
  remain current identities outside the owner-type rename.
- Active test file names, test-suite type names, and test method names retain `BareArray` or
  `OptionalArray` as grouping vocabulary; their executable owner-type expressions use the adopted
  names.
- Benchmark source names, workload/display grouping, and
  `Benchmarks/QualityAssessment/macOS/BareArray/` evidence paths are stable identities rather than
  owner declarations.
- `Maintanance/Graph/InMemoryFixture/rp17_staleness.sql` intentionally uses the old
  `OptionalArray4D` symbol and `OptinalArray.swift` path as data for a staleness-detection fixture.

### HISTORICAL

- Candidate, ballot, scoring, round reports, and the pre-implementation sections of the naming
  handoff retain the names that were actually evaluated. The handoff's explicit old-to-new mapping
  also requires both spellings to document the completed rename.
- Completed Claude handoffs, audit inventories, strict-memory-safety batch records, and dated quality
  evidence retain old declarations or source filenames where those were the observed subjects. In
  particular, the `BareArray.swift` mentions in the dated evidence sections of
  `BareArrayModule/CurrentQualityAssessment.md` describe the file that was actually typechecked; they
  do not identify the current source path.
- Archived records were not opened or reconstructed; archive search hits were excluded from the
  active-test audit as required.

### Limitations

- This was a classified residue search, not a semantic proof. No build, test, DocC generation, or
  compiler fixture was rerun.
- No finding was fixed, and no Task Registry state was changed.

### Files changed by Worker

- `Maintanance/WORKER_TASK.md` only (this return section).
- No commit or other repository operation was performed.
