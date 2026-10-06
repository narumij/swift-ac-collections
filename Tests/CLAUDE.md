# Test Work Instructions

Use the Task Registry in `Maintanance/PROGRESS_OVERVIEW.md` as the project-level entry point. Use this
file as the test-specific instruction layer after a test task has been selected. Paths in this
document are relative to the repository root.

## Start Here

Before changing files:

1. Read only the Task Registry at the top of `Maintanance/PROGRESS_OVERVIEW.md` and identify the
   selected task. Do not scan all maintenance or Archived documents.
2. Read `Maintanance/CLAUDE_TASK.md`. If it contains an active assignment,
   treat it as the current task. Codex-to-Claude work requests in that file
   must be written in English.
3. Read only the task-relevant portions of `Tests/TESTING.md`.
4. Search `Tests/Archived/TESTING_REFERENCE.md` only when the current task requires
   historical context or a detailed legacy procedure. Do not read it from
   beginning to end by default.
5. Inspect the relevant implementation, tests, fixtures, and API matrices
   before deciding what is missing.

Do not begin unrelated cleanup while an explicit user request, an active task,
or a recorded priority is available.

## Priority Order

When instructions compete, use this order:

1. The user's current request
2. An active assignment in `Maintanance/CLAUDE_TASK.md`
3. The latest user-written priorities and stop conditions in
   `Tests/TESTING.md`
4. The current handoff in `Tests/TESTING.md`
5. Opportunistic test maintenance

Do not silently resolve an open design question. Record the evidence and ask
the user when the expected behavior, public API, internal-layer boundary, or
removal of existing coverage is unclear.

## Working Rules

- Keep changes limited to the selected task. Preserve unrelated user changes.
- For a suspected bug, first add or identify a test that demonstrates the
  observable failure. Do not change production code unless the task authorizes
  a fix.
- Treat the numbered tests in each public type directory as Test as
  Specification. Test public, observable behavior there.
- Put implementation and coverage tests in `_98_*.swift`, temporary
  unclassified Swift Testing tests in `_97_*.swift`, and public precondition or
  invalid-index process tests in `_99_DeathTests.swift`.
- Keep compatibility-only behavior in the compatibility tests. Check
  `API-Matrix.md`, `API-Matrix-View.md`, and `Quality-Checklist.md` when working
  on RedBlackTree public APIs or views.
- Consult `Tests/RedBlackTreeFixture/Fixtures.md` before adding or changing
  RedBlackTree fixtures, and update it when fixture behavior changes.
- Debug builds track RedBlackTree allocation, node, and payload lifetimes in
  process-global counters. An XCTest that creates RedBlackTree collections must
  inherit from `RedBlackTreeTestCase` when it belongs to `RedBlackTreeTests`.
  In another test target, where that test-only base class is unavailable, copy
  its counter setup/teardown discipline into the local XCTest case and add an
  explicit test dependency on `RedBlackTreeCollections` for `@testable import`.
  Always reset the counters after the local balance assertions: XCTest targets
  can run in the same process, so leaked counter state makes the next suite fail
  depending on test order. Do not work around this by weakening the next
  suite's setup assertions.
- The balance assertions are on by default and are the normal configuration.
  `SKIP_DEBUG_LIFETIME_SETUP_CHECKS` skips only the incoming-zero assertions,
  immediately resets the counters, and retains the same case's teardown balance
  assertions. Prefer this narrower mode when only prior test-runner contamination
  is expected.
  The test-only package trait `SKIP_DEBUG_LIFETIME_BALANCE_CHECKS`
  (`swift test --traits SKIP_DEBUG_LIFETIME_BALANCE_CHECKS`) skips only the
  counter equality assertions in the XCTest bases, for diagnosing hostile test
  scheduling or subprocess/Death Test runs. Counters are still reset at the start
  and end of every case, and singleton/fresh-pool/nullptr structural checks
  still run. A green run in this mode is not evidence of lifetime balance; any
  new XCTest base that owns the counters must follow the same policy.
- Use `EtcTests.swift` or `DeathTest.swift` for exploratory tests. Preserve
  `ABC`, `convenience`, `memoize`, and `EtcTests.swift` unless the user
  explicitly says otherwise.
- Do not guess how internal layers should be classified. Follow the current
  terminology and boundaries in `Tests/TESTING.md`.
- Compatibility-mode validation may be deferred while accumulating a series of
  small changes, but run it before completing work whose behavior depends on
  compatibility mode.
- When a usage limit is approaching, reserve time for validation, dashboard
  updates, and a retrospective instead of starting another large category.

## Validation

Run the narrowest relevant test first for fast feedback. Before reporting a
completed code change, run the broader affected test target. Use `swift test`
from the repository root for the authoritative full-suite result because the
Xcode `RunAllTests` integration has previously omitted tests while reporting
zero failures.

Also validate Release, compatibility mode, Death Tests, package traits, or
coverage when the changed behavior depends on them. If `Package.swift` is
temporarily modified to exercise a configuration, restore its original
configuration before finishing. Never infer success from a test count alone;
confirm that the intended tests actually ran.

Death Tests remain enabled by default on macOS. On Linux, use
`swift test -c debug --traits ENABLE_DEATH_TESTS,SKIP_DEBUG_LIFETIME_BALANCE_CHECKS`.
Linux Death Tests are currently opt-in and are not part of the normal GitHub Actions
Debug job. Do not infer Linux signal/exit behavior from a macOS run or from an
aggregate Linux run that discovered no exit tests.
Tests that require a Swift runtime trap use the target-local
`expectedSwiftTrapSignal`: `SIGTRAP` on Darwin and `SIGILL` on Linux. Keep this exact
signal contract separate from tests that intentionally accept a broader fatal failure,
and continue rejecting `SIGSEGV` where invalid memory access is not the intended stop.

## Finish and Handoff

Before ending a work session:

- Summarize changed files, verified behavior, commands run, and their results in the
  assigned task Markdown for Codex, not in a user-facing chat response.
- Record unresolved specification questions or implementation concerns in
  `保留中の判断・懸念` instead of guessing.
- Update the current handoff and its summary when the repository state changed.
  Keep entries concise; do not duplicate a long narrative already preserved by
  version control.
- Do not delete user-written requests or completed-request entries without the
  user's confirmation. Add completion status instead.
- Keep `Tests/TESTING.md` as a current-state dashboard. Replace stale status
  instead of appending a chronological narrative, and keep its recent handoff
  to no more than five concise items.
- Timestamp dashboard updates with date, time, and time zone, and record the
  model name and version used for the work.
- Do not declare the overall test-maintenance effort complete until the
  independent Codex and Claude reviews and the user's confirmation required by
  `Tests/TESTING.md` have all occurred.

For a task managed through `Maintanance/CLAUDE_TASK.md`, do not send the user the
above handoff, progress narration, or a completion summary. If a final chat response
is technically required after success, output exactly `完了`. Exceptions are limited
to a blocker, a safety issue, or a decision that only the user can make.
