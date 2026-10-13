# Prime-to-Worker Codex Work Request

Status: Experimental file-based handoff. This interface is not yet adopted as routine operation.

This document is the repository-visible handoff from Prime Codex to a Worker Codex running in a
separate Xcode conversation. The fixed role and boundaries are defined in
`Orientation/WORKER_CODEX_BOOTSTRAP.md`. This file supplies only the current assignment, workspace,
evidence boundary, and return route.

Worker execution does not complete or accept a repository task. Prime Codex independently reviews
the returned result, integrates accepted work, and owns Task Registry updates and completion.

## Current job status

**終了: 5公開targetのDocC継続検証をPR CIへ追加**

The user may start this assignment by opening a separate Xcode Codex conversation and instructing it
to read this file. Do not infer a different assignment from old handoffs or Archived records.

This section alone determines whether this Worker handoff has a current job. Prime Codex updates it
before replacing or closing the assignment.

## Active assignment: add public-target DocC verification to PR CI

### Objective

Implement the accepted first stage of `DOCUMENTATION_CI_PLAN.md` in `.github/workflows/ci.yml` so an
Ubuntu pull-request run attempts DocC generation independently for all five public library targets
and preserves target-specific diagnostics without changing publication policy.

### Workspace and start state

- Workspace: the existing Xcode workspace for this repository.
- Expected branch: `develop/misc/64`.
- The branch may contain commits ahead of its remote; their number is not a stop condition.
- Expected existing changes: Prime Codex may have uncommitted changes to
  `Maintanance/WORKER_TASK.md` and `Maintanance/PROGRESS_OVERVIEW.md` that prepare this assignment.
- Change ownership: Prime Codex and the user retain ownership of the shared worktree.

Verify the branch before work. Preserve every existing change. Stop only when the branch differs or
when an unexpected change overlaps `.github/workflows/ci.yml` or the permitted return section.

### First reading

Read in this order:

1. `Orientation/WORKER_CODEX_BOOTSTRAP.md` in full.
2. This assignment in full.
3. Only the `DOC-024` row in `PROGRESS_OVERVIEW.md`.
4. `DOCUMENTATION_CI_PLAN.md` in full.
5. `.github/workflows/ci.yml` in full.

Read `Package.swift` only if exact target spelling or plugin availability must be rechecked. Do not
scan other Registry rows, maintenance documents, workflows, or Archived records.

### Required implementation

Add a distinct PR-CI verification job that uses a matrix containing exactly these targets:

- `AcCollections`
- `RedBlackTreeModule`
- `PermutationModule`
- `OptionalArrayModule`
- `BareArrayModule`

For each matrix entry:

- run DocC generation for only that target;
- use a target-specific output directory and diagnostic directory;
- capture environment information, the exact command output, and exit status;
- upload target-specific diagnostics with `if: always()` so failure evidence is retained;
- keep one target failure independent from the evidence produced by other matrix entries;
- make this first-stage observation job non-blocking while preserving each command's real exit status
  and visible failure conclusion.

Use the existing CI setup style where applicable. Keep artifact names distinct across matrix entries.

### Fixed decisions

- This is diagnostic generation, not GitHub Pages publication.
- Do not add `--warnings-as-errors`.
- Do not add static-hosting transformation or a hosting base path.
- Do not replace, rename, weaken, or otherwise modify the existing `documentation` job for
  `RedBlackTreeCollections`.
- Do not modify `.github/workflows/main.yml`, `.github/workflows/candidate.yml`, or another workflow.
- Do not repair documentation warnings or source files.
- Do not decide when the new job becomes required; first obtain Ubuntu evidence.

### Allowed changes

- `.github/workflows/ci.yml`
- the `Worker return` section of this file

No other tracked file may be modified. Generated temporary validation files must remain outside the
repository or under ignored `.build/` paths.

### Validation requirements

- Parse the resulting YAML with an available local parser when possible.
- Verify from the final diff that the matrix has exactly five assigned targets.
- Verify target-specific output, log, and artifact names derive from the matrix target.
- Verify diagnostics upload uses `if: always()`.
- Verify the new observation job is non-blocking, while the DocC command itself does not mask a
  nonzero status.
- Verify the existing `documentation` job is unchanged.
- Do not run the GitHub-hosted Ubuntu job locally and do not claim remote success.

If no trustworthy YAML parser is available, report that limitation and perform a structural diff
check without installing a dependency.

### Repository operation authority

- Branch creation or switching: not authorized.
- Commit: not authorized.
- Push: not authorized.
- Merge, rebase, reset, checkout restoration, or deletion: not authorized.
- Other-agent delegation: not authorized.

Writing an operation into this file does not grant authority. Repository operations remain subject
to the repository's user-authorization rules.

### Stop conditions

Stop and return the observed facts when:

- the current branch is not `develop/misc/64`;
- `.github/workflows/ci.yml` has an unexpected overlapping change;
- implementation requires changing an existing publication job or warning policy;
- GitHub Actions semantics cannot preserve both non-blocking observation and visible target failure
  without a new policy decision;
- another participant changes an overlapping file during the assignment.

### Return requirements

Write the result below. Report the workflow structure added, validation performed and its result,
the exact files changed, and any remote-only uncertainty. Do not update the Task Registry and do not
mark the repository task complete.

## Worker return

Status: Accepted by Prime Codex for local implementation and structural validation. Remote Ubuntu evidence is pending separately.

### Implemented workflow structure

Added the PR-only `public-target-documentation` job to `.github/workflows/ci.yml`.

- The matrix contains exactly, and in the assigned order: `AcCollections`, `RedBlackTreeModule`,
  `PermutationModule`, `OptionalArrayModule`, and `BareArrayModule`.
- `strategy.fail-fast: false` keeps the other matrix entries running when one target fails.
- Job-level `continue-on-error: true` makes this first-stage observation job non-blocking for the
  workflow.
- Each matrix entry derives its output directory, diagnostic directory, and artifact name from
  `matrix.target`.
- The environment step records `swift --version` and `uname -a` in the target-specific diagnostic
  directory.
- The DocC step records the displayed command in `command.txt`, captures combined command output in
  `full-console.log`, records SwiftPM's actual pipeline status from `PIPESTATUS[0]` in
  `exit-status.txt`, and exits with that same status. It does not use `--warnings-as-errors`, static
  hosting transformation, or a hosting base path.
- The target-specific artifact upload uses `if: always()` and therefore remains eligible after a
  failed DocC step.

### Local validation performed

- Parsed `.github/workflows/ci.yml` successfully with the locally available Ruby YAML parser.
- Ran structural assertions over the parsed result for the exact five-target matrix,
  `fail-fast: false`, job-level `continue-on-error: true`, target-derived output and diagnostic
  paths, target-derived artifact name, `if: always()`, and the preservation/re-emission of
  `PIPESTATUS[0]`. All assertions passed.
- `git diff --check -- .github/workflows/ci.yml` passed.
- `git diff --numstat -- .github/workflows/ci.yml` reported 66 additions and 0 deletions. The full
  diff contains only the new job inserted after the existing `documentation` job, so the existing
  `RedBlackTreeCollections` documentation job is unchanged.
- `actionlint` was not installed in the local environment, so no actionlint result is claimed and no
  dependency was installed.

### Changed files and evidence limits

- Worker-changed tracked files: `.github/workflows/ci.yml` and the `Worker return` section of
  `Maintanance/WORKER_TASK.md` only.
- The pre-existing change to `Maintanance/PROGRESS_OVERVIEW.md` was preserved without Worker edits.
- The GitHub-hosted Ubuntu matrix was not run locally. Runner behavior, artifact upload behavior, and
  remote job conclusions remain to be verified by a pull-request run after an authorized push.
- No source, documentation, package manifest, other workflow, or Task Registry update was made.
- No branch operation, commit, push, merge, rebase, reset, restoration, deletion, or delegation was
  performed.
