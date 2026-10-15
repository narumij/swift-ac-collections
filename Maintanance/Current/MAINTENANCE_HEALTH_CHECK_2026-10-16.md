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

Not returned.

## Return — DOC-031 (Claude only)

Not returned.
