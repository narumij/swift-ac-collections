# Maintenance health check after archival

Author: Astra / 2026-10-16. Registry IDs: `OPS-045` and `DOC-031`.
The user requested these checks from Claude after permanent-task setup and archival. This is a bounded inspection, not authority to repair records or adopt proposals.

## Baseline and start condition

Permanent-task setup and the deferred CI investigation were committed as `4016cca5`. The archival and this request are subsequent working-tree changes; record actual HEAD and relevant file hashes when you begin. Do not assume HEAD alone identifies the inspected inputs.

Finish and formally release any currently occupied assignment scope before starting these checks. In particular, do not interrupt or overwrite the RBT-045 return. These checks do not require Astra's acceptance of RBT-045 and do not open the final cross-type review gate. Do not run them concurrently with your own modifications to the inspected records. If another person changes inspected inputs, identify the affected portion and recheck it or mark it unverified.

Read the selected Registry rows, applicable rules, and the inputs below. Perform OPS-045, then DOC-031; no intermediate acceptance is required between these two read-only checks. Their results remain separate. Do not reproduce past reviewer opinions as findings.

## Fixed inputs and scope

Paths below are repository-root relative.

- `Maintanance/ProgressV2/PROGRESS_OVERVIEW_V2.md`, `TASK_REGISTRY_V2.md`, `TASK_RULES_V2.md`, `TASK_REGISTRY_ARCHIVE.md`, and `README.md` (the latter four in the same ProgressV2 directory).
- `Maintanance/DOCUMENT.md`: permanent document-maintenance rules and categorized external-document entrances.
- `Maintanance/Archived/TASK_REGISTRY_ARCHIVED_2026-10-16.md`: eight original completed rows, unchanged. No precedence edges were removed.
- `Maintanance/Archived/PermutationMigration_2026-10-16/README.md`: ten moved documents and old-to-new path mapping, original hashes, and the worker-entry snapshot. Four worker return files were preserved byte-for-byte; navigation links in other moved documents were adjusted.
- `Maintanance/WORKER_TASK.md` and `Maintanance/CLAUDE_TASK.md`: compare dispatch status with Registry, without changing either.
- Only follow other detailed documents or history when needed to establish a specific finding. Do not bulk reread all Archived documents.

## OPS-045 — task integrity

Check unique IDs, supported states, precedence endpoints and cycles, numbering maxima (including already-used IDs absent from the current rows), and consistency among current conditions, assignments, and detailed evidence. Do not lower numbering or treat an absent current row as an unused ID. Look for lost user decisions and stale conditions where the cited evidence supports a concrete discrepancy; absence of evidence is not proof that a decision never existed.

Verify the eight archived rows against the pre-archival version, preservation of unfinished conditions and precedence, and navigation to their evidence. Check permanent tasks DOC-030, OPS-043, TEST-005 and OPS-044, their maintained documents and location protection. ACTIVE permanent nodes do not imply running jobs or permission to edit. Distinguish a surviving policy document from a completed task's historical output. A DONE row alone does not make every linked document archival material.

Expected return: findings with exact paths/sections or lines, evidence, impact and proposed correction; counts and methods actually checked; unverified areas. If no actionable finding is found, state the inspected scope rather than claiming global correctness.

## DOC-031 — document reference integrity

Check the current ProgressV2 entrances and rules, DOCUMENT.md, Current/README.md, the current worker/Claude entrances, and the external documents or document groups listed in DOCUMENT.md. Within listed documentation directories, enumerate the Markdown files you inspect; exclude third-party dependencies, build outputs and bulk benchmark result data. Check changed references to the ten archived files and the new DOCUMENT.md name. Check the archival index and paths back to current policy documents.

Separate file/directory links, images, reference-style links, heading anchors, code-formatted paths used as navigation, and external URLs. Distinguish an actual broken navigation link from a historical path, example, placeholder, DocC symbol reference, or intentionally generated output. Preserve original historical statements; propose mapping notes instead of blind replacements. A missing file and a stale claim in an existing file are different findings.

For external URLs, use available read-only access without requesting secrets or changing authentication. Report coverage and inaccessible URLs; a timeout, rate limit or authentication page is not proof of a broken link. Inspect DocC references statically only in this assignment; do not start a DocC build, tests, benchmarks, CI, or large network crawl. Explicitly leave generated symbol resolution unverified where not established. Repeated destinations may be deduplicated, but retain the reference locations.

Expected return: reproducible reference locations and intended destinations, classification, impact and proposed correction, inspected counts and exclusions. Do not alter production documents to fix findings.

## Editable scope and handoff

Edit only the two Return sections below. You may use temporary local scratch files for read-only checks, but do not add repository tools or reports elsewhere. Do not edit Registry, rules, numbering, requests, source, tests, fixed inputs, or archived answers. No commit, branch, push, merge, tag, CI dispatch, task acceptance or state change.

Each Return must identify actual HEAD, relevant input hashes, tools/commands and scope, findings, unverified areas, and an explicit statement that the assignment scope is released. Astra will independently check the evidence, decide acceptance within the delegated scope, and return the commit decision to the user. You are not being asked to certify the entire project or rewrite its system.

## Return — OPS-045 (Claude only)

Returned 2026-10-16 by Claude (Opus 5.5). Started after RBT-045 was returned, scope released, accepted and archived. HEAD `4f1b7e3c`, working tree clean at start and end. Nobody else changed the inspected inputs during the check (status re-checked before writing). Input SHA-256, first 16 hex digits:

| File | SHA-256 (16) |
| --- | --- |
| `ProgressV2/PROGRESS_OVERVIEW_V2.md` | `146715b8bbd994ee` |
| `ProgressV2/TASK_REGISTRY_V2.md` | `539fcf418ee7d56e` |
| `ProgressV2/TASK_RULES_V2.md` | `1945ce9506f93f4d` |
| `ProgressV2/TASK_REGISTRY_ARCHIVE.md` | `e3815e5e50b456b1` |
| `ProgressV2/README.md` | `f1337ba3b04fb55a` |
| `DOCUMENT.md` | `a69077a87ba0b2c1` |
| `Archived/TASK_REGISTRY_ARCHIVED_2026-10-16.md` | `7e5b655cd995e03f` |
| `Archived/PermutationMigration_2026-10-16/README.md` | `421a0166cab0216b` |
| `WORKER_TASK.md` | `2f2049fa01efc30f` |
| `CLAUDE_TASK.md` | `acb550d1097f02b5` |

Method: shell and awk over the Markdown tables, plus `git show <commit>^:<path>` comparisons. No repository tool was added.

**Checked, no discrepancy found**

- Current Registry: 34 task rows, IDs unique. States are 24 ACTIVE, 4 PROPOSED, 3 USER_ONLY, 2 WAITING_EXTERNAL and 1 FROZEN, all among the nine defined states.
- Precedence: 12 current edges, every endpoint a current row, no cycle (acyclic by inspection; longest chain QUALITY-005→DOC-026→DOC-027→QUALITY-001).
- Every backticked `.md`/`.swift`/`.yml`/directory path in the 34 rows' 詳細正本 column exists.
- Numbering: across the whole repository (`git grep` of 18 prefixes × 3 digits), the maximum used number per prefix equals the table value for all 18 prefixes. Other ID-like prefixes found: `REL-` (release-internal IDs, excluded by the rule) and template placeholders `AREA`/`CORE`/`IDEA` in `Archived/Orientation/PROGRESS_OVERVIEW_TEMPLATE.md`.
- `Archived/TASK_REGISTRY_ARCHIVED_2026-10-16.md` (added in `504b143b`, unchanged since): all 8 rows (RBT-033, PERM-073〜078, OPT-074) are byte-identical to `504b143b^`. The precedence table is identical before and after `504b143b`, so no edges were removed.
- Same check on the two later archives:
  - `TASK_REGISTRY_COMPLETED_AFTER_RECONCILIATION_2026-10-16.md` (`d6095cdd`): 10 rows identical, 13 edges present in the pre-version.
  - `TASK_REGISTRY_AFTER_USER_RECLASSIFICATION_2026-10-16.md` (`4f1b7e3c`): DOC-032, RBT-014, RBT-035 and RBT-004 are identical, and the RBT-041←RBT-045 edge is present. Its RBT-045 `WAITING_USER` row differs from the committed `ACTIVE` row by design: the file declares its base as `8053683a` plus uncommitted acceptance edits. That state cannot be verified byte-wise from git.
- Permanent nodes DOC-030, OPS-043, TEST-005 and OPS-044: all 17 maintained documents exist and are listed in 配置維持例外 (`TASK_RULES_V2.md`). Documents for GRAPH-001, HIST-001, OPS-046 and OPS-047 also exist.
- Dispatch: WORKER_TASK.md says no active worker assignment, consistent with PERM-073〜076 archived DONE. CLAUDE_TASK.md's status paragraph (RBT-043/044/045 accepted, RBT-045 DONE) is consistent with the Registry and archive.

**Findings**

1. **Task ID reuse before the numbering table (2026-10-14) leaves the same ID with different meanings; two of them are current rows.**
   - Evidence: `Archived/PROGRESS_OVERVIEW_COMPLETED_2026-10-11.md:50` has `QUALITY-002` DONE "品質プロファイル共通骨格の独立レビュー", and line 53 has `QUALITY-003` DONE "0.5.x品質アセスメントの対象環境". Commit `e5abf435` (2026-10-12) issued the same IDs to new tasks: "1.0品質保証CI…" and "Apple platforms 27提供境界…", now `TASK_REGISTRY_V2.md:58–59`.
   - Other reuse confined to history: `OPS-003` and `OPS-006` (four meanings each across `PROGRESS_OVERVIEW_COMPLETED_2026-10-09/11/12.md`), `PERM-029` (10-09 vs 10-11), `PERF-001` (10-07/09 vs 10-12 vs 10-13). Older reuse is likely more widespread; I listed only the clear cases.
   - Impact: a lookup by ID in history (including the OPS-036 SQLite index) can join unrelated tasks, and "QUALITY-002 DONE" in history can be misread as the current 1.0 CI task being done. The table maxima themselves are correct.
   - Proposed correction: do not renumber. Add a short note to `TASK_RULES_V2.md` (採番状態) or `TASK_REGISTRY_ARCHIVE.md` that IDs before 2026-10-14 are not unique across archived files and must be qualified by file and date. Optionally add a disambiguation remark to the QUALITY-002/003 rows.
2. **The permanent-node lists in the rules omit OPS-046 and OPS-047.**
   - Evidence: `TASK_RULES_V2.md` 状態の扱い names `GRAPH-001`・`HIST-001`・`DOC-030`・`OPS-043`・`TEST-005`・`OPS-044` as permanent ACTIVE nodes. The 配置維持例外 table likewise has no entry for `Maintanance/ProgressV2/COORDINATION_KNOW_HOW.md` (OPS-046) or `Maintanance/MILESTONES.md` (OPS-047). Registry lines 28–29 describe both tasks as 常設node.
   - Impact: a reader of the rules may treat OPS-046/047 ACTIVE as ordinary active work, and their documents lack the stated location protection.
   - Proposed correction: an owner decision on whether both are covered. If so, add them to both lists. Whether their documents should be location-protected is for the user or Codex to decide; I did not infer it.
3. **Stale gate text after RBT-045 closure.**
   - Evidence: `TASK_REGISTRY_V2.md:111` (受入済みの前提成果) says RBT-041 "これだけでは着手せず、RBT-045までの補完受入ゲートも必要", while line 48 and line 222 record that gate as satisfied. `CLAUDE_TASK.md:62` still reads "RBT-045 | Open: … Proceed with MM1–MM4", and the section is titled "Active assignment batch", while line 34 says RBT-045 is DONE.
   - Impact: low. A resuming reader could think MM1–MM4 is still open.
   - Proposed correction: update the line-111 sentence to past tense and the CLAUDE_TASK gate row to DONE. Moving the accepted RBT/PERM/OPT sections to history falls under the existing standing compression delegation, but I did not do it here.
4. **The Claude pending queue has an unreconciled entry whose stated status is stale.**
   - Evidence: `CLAUDE_PENDING_TASKS.md:43–63`, `CP-20261015-007`, is `AWAITING_CODEX`, says "Registry ID`PERM-072`（`ACTIVE`）", and records "Codex reconciliation: 未処理". PERM-072 is DONE in `Archived/TASK_REGISTRY_ARCHIVED_2026-10-15_2.md:29`.
   - Impact: low. The queue shows open work that has finished.
   - Proposed correction: Codex reconciles it to `RECONCILED` (→PERM-072) and moves it to the reconciled archive.

**Not verified**

- "Lost user decisions": no concrete loss found in the inspected rows. I did not reread chat history or all archives, so this is not proof of absence.
- Correctness of the condition text in each ACTIVE row against its detailed document (spot-checked RBT-026's link to the RBT-014 archive only).
- History-index (OPS-036) data.
- Pre-2026-10-07 archives beyond the ID grep.

Process note: I briefly wrote and deleted one scratch file in `/tmp` outside a `mktemp -d` directory during the ID count; it contained only ID/state pairs.

OPS-045 scope released. No Registry, rules, numbering or inspected file was edited.

## Return — DOC-031 (Claude only)

Returned 2026-10-16 by Claude (Opus 5.5), after OPS-045. Same HEAD `4f1b7e3c` and input hashes as above; `Current/README.md` `305958a8b7087e67`.

Method: a Python checker in a task-owned `mktemp -d` directory, removed afterwards. It parsed inline links and images, reference definitions, autolinks and bare URLs. It resolved relative paths from the document's own directory, decoded `%xx`, and computed GitHub-style heading slugs (Japanese kept, duplicate `-n` suffixes, code blocks skipped). It also resolved DocC `<doc:>` references within the same `.docc`, and backticked path-like strings from the repository root or the document directory.
- Negative control: a temporary fixture with a broken self anchor, a missing file, a missing cross-file anchor and a missing code path produced all four findings, and a valid Japanese anchor passed.
- External URLs were checked with `curl -L` GET and a 12 s timeout, with no credentials.

**Scope inspected (101 Markdown files)**

- ProgressV2 top level (9).
- Entrances (6): DOCUMENT.md, Current/README.md, WORKER_TASK.md, CLAUDE_TASK.md, CLAUDE_PENDING_TASKS.md, MILESTONES.md.
- Archival index (13): `Archived/README.md`, and the 12 files in `Archived/PermutationMigration_2026-10-16/`.
- External documents from DOCUMENT.md (58): README(.ja), CHANGELOG, AGENTS.md, CLAUDE.md, Tests/TESTING.md, Tests/CLAUDE.md, Fixtures.md, Benchmarks/Results.md, `Documentation/**`, `Sources/*/Documentation/**` (4 modules), `Benchmarks/QualityAssessment/macOS/**` (Markdown only), index_stale_check.md.
- DocC catalogs (15) under `Sources/*/*.docc/`.
- Excluded: `.build`, dependencies, non-Markdown benchmark data.

Counted references:

| Kind | Count |
| --- | --- |
| Local file/directory links | 279 |
| Cross-file heading anchors | 29 |
| Same-file anchors | 7 |
| Images | 0 |
| Reference-style definitions | 0 |
| DocC `<doc:>` | 5 |
| Path-like code spans | 333 |
| Unique external URLs | 15 |

**Result: no broken Markdown link or anchor.** All 279 local links, 36 anchors and 5 `<doc:>` references resolve. Of the 333 path-like code spans, 41 do not resolve; I classified each:

- **Actual stale navigation (2)**
  1. `Maintanance/Quality/Profiles/NextPermutationModule.md:42` cites `Maintanance/Current/PERMUTATION_MODULE_MIGRATION_ACCEPTANCE.md` as where to read "今回の受入範囲". The file moved to `Maintanance/Archived/PermutationMigration_2026-10-16/PERMUTATION_MODULE_MIGRATION_ACCEPTANCE.md`. Impact: a current quality profile points at a missing file. Proposed correction: point to the archived path, keeping the wording that it is a completed acceptance record. This is the only current, non-historical reference to the ten moved files that I found in a repository-wide `git grep`.
  2. `Tests/TESTING.md:32` cites `Maintanance/QUALITY_REQUIREMENTS.md`; the file is `Maintanance/Quality/QUALITY_REQUIREMENTS.md` (moved in `9d36da92`). Impact: the TEST-005 dashboard points at a missing path. Proposed correction: update the path. This is my own document (TEST-005), but I left it unchanged under this read-only assignment.
- **Historical paths, correct to keep (22)**
  - `Archived/PermutationMigration_2026-10-16/README.md:7–16`: the old-path column of the mapping table, by design.
  - Moved worker requests `…WORKER_{1,2,3}.md:45`: the original output paths.
  - Byte-preserved returns `…WORKER_{1,3}_RESULT.md:24` and `…IMPLEMENTATION.md:14`: the pre-migration `Sources/PermutationModule/`.
  - `Archived/README.md:82,85,111`: descriptions of moved or renamed locations.
  - `ProgressV2/README.md:36,74` and `TASK_HISTORY_INDEX_PROTOTYPE_NOTES.md:71`: the former `Maintanance/PROGRESS_OVERVIEW.md`, explicitly labelled 旧/当時.
  - Repository-wide, the archived Registry rows for PERM-073〜076 and the AgentTaskFit dispatch answers also keep old `Current/PERMUTATION_*` paths; they are original records, resolvable through the mapping table.
- **Resolve against a different base, not broken (17)**
  - `Design-RuntimeChecks.md:6,290` and `isValid.md:71` resolve from the module root `Sources/RedBlackTreeCollections/`.
  - `Fixtures.md` (13 paths) resolves partly from `Tests/` (`RedBlackTreeTests/RedBlackTreeTestSupport/…`, lines 70, 77, 106) and partly from `Tests/RedBlackTreeTests/` (the other 10); all targets exist.
  - `Benchmarks/QualityAssessment/macOS/BareArray/README.md:22` is a command to run from `Benchmarks/` (`Benchmarks/run-bare-array-assessment.sh` exists).
  - Proposed correction, optional: state the path base in those documents. Not urgent.

**Renamed and moved documents**

- `DOCUMENT.md` (former `MAINTENANCE.md`): no current navigation link uses the old name. The remaining mentions are observation and interview prose plus `RefactoringFromAtCoder2025/EVIDENCE.md:14,176`, which cite "`Maintanance/MAINTENANCE.md`のユーザー要望" as the source of a 証言. That text now lives in `Archived/MAINTENANCE_BEFORE_2026-10-16.md` and `Archived/MAINTENANCE_HISTORY_2026-10-07.md`, not in DOCUMENT.md.
  - Impact: low. The evidence pointer is now historical.
  - Proposed correction: a mapping note in EVIDENCE.md, not a replacement, because the cited text is historical.
- Archived Permutation set: all ten mapped targets exist.
  - Pre-move hashes recomputed from the parent of the adding commit match the table for `INVESTIGATION_ACCEPTANCE` (`d3a389c5…`) and `IMPLEMENTATION` (`eb8a3afc…`).
  - The current files differ only in the relative link to `../../Current/PERMUTATION_MODULE_MIGRATION_PLAN.md`; I diffed both.
  - The other eight current hashes equal the recorded values: the four returns byte-for-byte, plus the three worker requests and the acceptance record.
  - The README's links back to current policy (`Current/PERMUTATION_MODULE_MIGRATION_PLAN.md`, `Current/PUBLIC_API_NAMING_DECISIONS.md`) resolve.

**External URLs (15 unique, locations kept by the checker; first location shown)**

- 13 returned 200: atcoder.jp, Apple `mutableref`, the GitHub repo, `#usage` (anchor `user-content-usage` present), the CI badge, PR 196, the AtCoder 2025 branch, shields.io, keepachangelog, llvm LICENSE, the GitHub Pages RedBlackTreeCollections docs, semver, the Apache license.
- `http://localhost:8087/documentation/elementbuffermodule/` (`DOCUMENT.md:129`): a local example, excluded.
- **`https://docs.swift.org/swiftpm/documentation/packagemanagerdocs/addingdependencies/#Packages-with-Traits` (`README.md:69`, 2 references) currently ends in 404.** The server replies `301` to `https://docs.swift.org/latest/documentation/packagemanagerdocs/packagemanagerdocs/addingdependencies/` (a doubled segment), which is 404. The content exists: `https://docs.swift.org/latest/documentation/packagemanagerdocs/addingdependencies/` returns 200, and its data JSON contains the anchor `Packages-with-Traits`.
  - Impact: user-facing README link broken as of 2026-10-16, apparently because of an upstream redirect.
  - Proposed correction: point to the `/latest/…` URL, or re-check later in case upstream fixes the redirect. I did not test this in a browser.

**Not verified**

- DocC symbol links: 463 lines with double-backtick symbol references in 15 catalog files, plus Topics. These need a DocC build, which this assignment excludes.
- Anchors inside external pages, other than the two noted.
- Markdown outside the listed scope (most of `Archived/`, `Maintanance/*` interview and observation files, and `Current/*` beyond `Current/README.md`).
- Links rendered by GitHub with different slug rules for unusual punctuation.

DOC-031 scope released. No inspected document was edited.

## Astra acceptance — 2026-10-16

HEAD `db3ee2bd`から返却とscope releaseを確認。両検査を受入、commit確認待ち。QUALITY-002/003のID衝突は10-11 archiveとe5abf435のRegistryを独立比較して確認。番号は変更せず履歴の同定規則を追記した。恒久nodeの列挙・維持文書、RBT-045の古いgate文言、処理済みCP-20261015-007を修正した。queue原文はArchivedへ保存しPERM-072の回答・集約・DONE記録に照合した。

参照の移動漏れ2件を実ファイルと照合して修正。README日英のSwiftPM URLは代替の公式/latest/ページへの到達を独立確認して変更した。外部anchor・全URL・DocC生成は独立再検査していない。Claudeの101文書の全件検査や全履歴を繰り返したという意味ではなく、返却の方法・限界と具体的指摘の照合による受入である。履歴のパスは一括変更しない。任意提案の基準パス注記は今回必須修正にしない。

RBT-041は既に着手可能。次の仕事の選択と発注は現在のRegistryとユーザー依頼に従い、検査受入を製品品質全体の合格とは扱わない。

2026-10-16、ユーザーのcommit許可を受領。OPS-045・DOC-031をDONEとして受入記録と修正を保存する。
