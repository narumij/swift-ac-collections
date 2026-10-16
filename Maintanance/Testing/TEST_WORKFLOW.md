# Test Work Procedure

Canonical test-specific procedure, maintained under TEST-005. Moved from
`Tests/CLAUDE.md` by user direction on 2026-10-16 (OPS-054, Astra).
Paths in this document are relative to the repository root.

Start authority, language, workspace boundaries, and communication follow root
[CLAUDE.md](../../CLAUDE.md). This procedure does not select or authorize work.
Read only the parts relevant to the selected task. Inspect the relevant implementation,
tests, fixtures, and API matrices before deciding what is missing.
Do not silently resolve an open design question: record evidence and return decisions
about expected behavior, public APIs, internal-layer boundaries, or coverage removal
to the user.

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
  `Sources/RedBlackTreeCollections/Documentation/API-Matrix.md`,
  `Sources/RedBlackTreeCollections/Documentation/API-Matrix-View.md`, and
  `Maintanance/Quality/Profiles/RedBlackTreeCollections.md` when working
  on RedBlackTree public APIs or views.
- Consult `Maintanance/Testing/Fixtures.md` before adding or changing
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
  terminology and boundaries in `Maintanance/Testing/TESTING.md`.
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

- Record changed files, verified behavior, commands run, and results in the assigned
  Return section for coordinator assignments, or the authorized queue entry for
  direct user requests before Registry registration. Follow root `CLAUDE.md` for
  user-facing communication; the coordinator-only final-response rule does not
  apply to all direct user requests.
- Record unresolved specification questions or implementation concerns in the
  assigned Return section (or the authorized queue entry for a direct user request)
  instead of guessing. Use `Maintanance/Testing/TESTING.md` section `判断待ち` only
  for ongoing test context within the assigned editing scope.
- Update the current handoff and its summary when the repository state changed.
  Keep entries concise; do not duplicate a long narrative already preserved by
  version control.
- Do not delete user-written requests or completed-request entries without the
  user's confirmation. Add completion status instead.
- Keep `Maintanance/Testing/TESTING.md` as a current-state dashboard. Replace stale status
  instead of appending a chronological narrative, and keep its recent handoff
  to no more than five concise items.
- Timestamp dashboard updates with date, time, and time zone, and record the
  model name and version used for the work.
- Report completion only against the selected task's recorded acceptance conditions.
  Permanent test maintenance is not completed by finishing one assignment. Review
  and user-confirmation gates come from the current task and its canonical document;
  do not infer a project-wide completion gate from the dashboard.
