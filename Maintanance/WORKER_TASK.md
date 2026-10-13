# Prime-to-Worker Codex Work Request

Status: Experimental file-based handoff. This interface is not yet adopted as routine operation.

This document is the repository-visible handoff from Prime Codex to a Worker Codex running in a
separate Xcode conversation. The fixed role and boundaries are defined in
`Orientation/WORKER_CODEX_BOOTSTRAP.md`. This file supplies only the current assignment, workspace,
evidence boundary, and return route.

Worker execution does not complete or accept a repository task. Prime Codex independently reviews
the returned result, integrates accepted work, and owns Task Registry updates and completion.

## Current job status

**終了: 全公開targetのDocC個別生成と診断採取**

The user may start this experiment by opening a separate Xcode Codex conversation and instructing it
to read this file. Do not infer a different assignment from old handoffs or Archived records.

This section alone determines whether this Worker handoff has a current job. Prime Codex updates it
before replacing or closing the assignment.

## Active assignment: public-target DocC evidence acquisition

### Objective

Generate DocC separately for every public library target named below and return reproducible factual
evidence for each target: success or failure, diagnostics, command, and output location.

This assignment gathers evidence only. Do not decide which targets CI should enforce, their rollout
order, whether a warning is acceptable, or whether public documentation is complete.

### Workspace and start state

- Workspace: the existing Xcode workspace for this repository.
- Expected branch: `develop/misc/64`.
- The branch may contain commits ahead of its remote; their number is not a stop condition.
- Expected existing changes: Prime Codex may have uncommitted changes to
  `Maintanance/WORKER_TASK.md` and `Maintanance/PROGRESS_OVERVIEW.md` that prepare this assignment.
- Change ownership: Prime Codex and the user retain ownership of the shared worktree.

Verify the branch before work. Preserve every existing change. Stop only when the branch differs or
when an unexpected change overlaps a command input or the permitted return section.

### First reading

Read in this order:

1. `Orientation/WORKER_CODEX_BOOTSTRAP.md` in full.
2. This assignment in full.
3. Only the `DOC-023` row in `PROGRESS_OVERVIEW.md`.
4. `Package.swift` only as needed to verify exact target names and DocC plugin availability.

Do not scan other Registry rows, maintenance documents, or Archived records.

### Targets

Run a separate DocC generation for each target:

1. `AcCollections`
2. `RedBlackTreeModule`
3. `PermutationModule`
4. `OptionalArrayModule`
5. `BareArrayModule`

Use a distinct output directory and captured log for each target under `.build/worker-docc/`. Do not
reuse one target's output directory for another target. Include warnings in the captured evidence;
do not suppress or repair them.

### Allowed operations

- Read the files listed above and technical files directly named by a diagnostic.
- Run `swift package generate-documentation` separately for the five named targets.
- Create or replace generated evidence only below `.build/worker-docc/`.
- Write only the `Worker return` section of this file.

Do not modify source, tests, workflows, Package.swift, other maintenance documents, the Task
Registry, or public documentation. Do not run unrelated builds, tests, benchmarks, or formatters.

### Validation requirements

For each target, return:

- the exact command and exit status;
- whether DocC completed;
- warning and error counts, with the diagnostic text or log path;
- the target-specific output and log paths;
- any crash or environmental failure distinguished from a documentation diagnostic.

After all five attempts, verify that the five output and log locations are distinct. A failed target
does not authorize source repair and does not prevent attempting later targets unless the shared
environment itself is no longer usable.

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
- an unexpected shared-worktree change overlaps this assignment;
- the command would need to modify a tracked file;
- continuing requires a product, documentation-policy, CI-policy, or task-priority decision;
- the build environment becomes unusable for later independent attempts.

Do not stop merely because one target reports warnings, fails, or crashes. Preserve that result and
continue with the next independent target when the environment remains usable.

### Return requirements

Write the result below. Report the five targets in the assigned order and distinguish observed facts
from interpretation. Do not recommend CI scope or edit a diagnostic source.

The Worker must also state:

- changed tracked files: `Maintanance/WORKER_TASK.md` only;
- generated untracked or ignored evidence paths below `.build/worker-docc/`;
- commands and exit statuses;
- unverified areas and environmental limits;
- out-of-scope observations, if any.

## Worker return

Status: Accepted by Prime Codex as evidence acquisition. Repository task completion is recorded separately.

### Observed facts

All five assigned targets completed DocC generation with exit status 0 when SwiftPM was invoked with
`--disable-sandbox`. Each final log contains 8 warnings and 0 errors. The warnings are environmental
SwiftPM cache warnings, not DocC documentation diagnostics:

- the user-level configuration, security, and cache directories are not accessible or writable;
- the manifests for `swift-ac-collections`, `swift-algorithms`, `swift-docc-plugin`,
  `swift-numerics`, and `swift-docc-symbolkit` could not be stored in the read-only cache database.

The complete diagnostic text is preserved in each target-specific `generate.log` listed below.

1. `AcCollections`
   - Command: `swift package --disable-sandbox --allow-writing-to-directory .build/worker-docc/AcCollections/output generate-documentation --target AcCollections --output-path .build/worker-docc/AcCollections/output > .build/worker-docc/AcCollections/generate.log 2>&1`
   - Exit status: 0.
   - DocC completed: yes; the log reports `Finished building documentation for 'AcCollections'`.
   - Diagnostics: 8 warnings, 0 errors.
   - Output: `.build/worker-docc/AcCollections/output`
   - Log: `.build/worker-docc/AcCollections/generate.log`
2. `RedBlackTreeModule`
   - Command: `swift package --disable-sandbox --allow-writing-to-directory .build/worker-docc/RedBlackTreeModule/output generate-documentation --target RedBlackTreeModule --output-path .build/worker-docc/RedBlackTreeModule/output > .build/worker-docc/RedBlackTreeModule/generate.log 2>&1`
   - Exit status: 0.
   - DocC completed: yes; the log reports `Finished building documentation for 'RedBlackTreeModule'`.
   - Diagnostics: 8 warnings, 0 errors.
   - Output: `.build/worker-docc/RedBlackTreeModule/output`
   - Log: `.build/worker-docc/RedBlackTreeModule/generate.log`
3. `PermutationModule`
   - Command: `swift package --disable-sandbox --allow-writing-to-directory .build/worker-docc/PermutationModule/output generate-documentation --target PermutationModule --output-path .build/worker-docc/PermutationModule/output > .build/worker-docc/PermutationModule/generate.log 2>&1`
   - Exit status: 0.
   - DocC completed: yes; the log reports `Finished building documentation for 'PermutationModule'`.
   - Diagnostics: 8 warnings, 0 errors.
   - Output: `.build/worker-docc/PermutationModule/output`
   - Log: `.build/worker-docc/PermutationModule/generate.log`
4. `OptionalArrayModule`
   - Command: `swift package --disable-sandbox --allow-writing-to-directory .build/worker-docc/OptionalArrayModule/output generate-documentation --target OptionalArrayModule --output-path .build/worker-docc/OptionalArrayModule/output > .build/worker-docc/OptionalArrayModule/generate.log 2>&1`
   - Exit status: 0.
   - DocC completed: yes; the log reports `Finished building documentation for 'OptionalArrayModule'`.
   - Diagnostics: 8 warnings, 0 errors.
   - Output: `.build/worker-docc/OptionalArrayModule/output`
   - Log: `.build/worker-docc/OptionalArrayModule/generate.log`
5. `BareArrayModule`
   - Command: `swift package --disable-sandbox --allow-writing-to-directory .build/worker-docc/BareArrayModule/output generate-documentation --target BareArrayModule --output-path .build/worker-docc/BareArrayModule/output > .build/worker-docc/BareArrayModule/generate.log 2>&1`
   - Exit status: 0.
   - DocC completed: yes; the log reports `Finished building documentation for 'BareArrayModule'`.
   - Diagnostics: 8 warnings, 0 errors.
   - Output: `.build/worker-docc/BareArrayModule/output`
   - Log: `.build/worker-docc/BareArrayModule/generate.log`

### Environmental failure distinguished from documentation diagnostics

The first `AcCollections` attempt omitted `--disable-sandbox`:

`swift package --allow-writing-to-directory .build/worker-docc/AcCollections/output generate-documentation --target AcCollections --output-path .build/worker-docc/AcCollections/output > .build/worker-docc/AcCollections/environment-failure.log 2>&1`

It exited 1 during manifest evaluation with 3 cache-access warnings, 1 invalid-manifest error, and
`sandbox-exec: sandbox_apply: Operation not permitted`. DocC did not start. This was an execution
environment failure caused by nested sandboxing, not a documentation diagnostic. The evidence is at
`.build/worker-docc/AcCollections/environment-failure.log`. Adding SwiftPM's `--disable-sandbox`
allowed all five independent attempts above to complete.

### Location and change verification

- The five output directories and five final log paths resolve to distinct absolute locations under
  `.build/worker-docc/<target>/` and existed after generation.
- Generated ignored evidence paths: `.build/worker-docc/AcCollections/`,
  `.build/worker-docc/RedBlackTreeModule/`, `.build/worker-docc/PermutationModule/`,
  `.build/worker-docc/OptionalArrayModule/`, and `.build/worker-docc/BareArrayModule/`.
- Worker-changed tracked files: `Maintanance/WORKER_TASK.md` only. The pre-existing tracked change to
  `Maintanance/PROGRESS_OVERVIEW.md` was preserved without modification by the Worker.
- No branch creation or switching, commit, push, merge, rebase, reset, restoration, deletion, source
  repair, or other-agent delegation was performed.

### Evidence limits and out-of-scope observations

- Warning and error counts are literal counts of lines containing `warning:` and `error:` in each
  captured log. No policy judgment about warning acceptability or CI scope was made.
- No source, test, workflow, package-manifest, Registry, or public-documentation file was modified.
- No unrelated build, test, benchmark, or formatter was run.
- Documentation completeness and rendered-content quality were not inspected; the assignment verifies
  target-specific generation and captured diagnostics only.
- No additional out-of-scope product or documentation issue was observed.
