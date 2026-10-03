# Codex-to-Claude Work Request

Status: Idle — no active assignment

## Active assignment

No work is assigned. Do not edit files, resume a previous task, or select work from
the maintenance backlog. Wait for a new bounded assignment from Codex/the user.

## Cancelled assignment record (never resume without a new user decision)

Audit and correct the four existing Japanese compatibility matrices under
`Documentation/Compatibility/` (`set`, `multiset`, `map`, `multimap`). They already
serve as the requested API Matrix; do not create a competing summary document.

Use the current public Swift API, public Test-as-Specification tests, and the accepted
`CppBehaviorReferenceTests` as evidence. Correct stale claims, especially hint
insertion rows that still say the API is unavailable. For every relevant operation,
distinguish:

- directly corresponding API and verified common behavior;
- similar capability with different Swift/C++ API or return semantics;
- implementation behavior that is not guaranteed by the C++ standard;
- unavailable C++-specific object/allocator/node-handle behavior;
- behavior not covered by the C++ comparison suite.

Record the verified four-container comparison scope without implying total C++
compatibility. Include the Linux/libstdc++ finding: `std::multimap::find` may select a
different occurrence within an equivalent-key group, so compatibility covers
presence, key, count, and contents, not mapped occurrence identity or rank. Preserve
strict claims only where bounds, equal ranges, erase results, hinted insertion, or
ordered contents were actually compared.

Do not change production Swift, tests, benchmarks, or algorithms. Do not add English
copies unless an established counterpart exists; these four Japanese files are the
current canonical documents. Check all four consistently when one stale pattern is
found. Run `git diff --check`, record the exact corrected claims and remaining
unverified areas here, set this status to Completed, and report only `完了` to the user.

## Completed assignment: controllable Debug allocation/lifetime checks

Implement a test-only opt-out for the process-global Debug allocation, node, and
payload lifetime balance checks. The default must remain enabled on every platform;
do not silently weaken Linux. Provide one explicit, consistently named SwiftPM build
switch (prefer a package trait/conditional define unless the existing structure makes
another mechanism materially safer) that CI or a developer can select for hostile
test scheduling and subprocess/Death Test runs.

Add a narrower switch as well: `SKIP_DEBUG_LIFETIME_SETUP_CHECKS`. This switch skips
only the incoming-zero assertions in `setUp`, then unconditionally resets all counters;
the same test case's outgoing balance assertions in `tearDown` must remain enabled.
Keep `SKIP_DEBUG_LIFETIME_BALANCE_CHECKS` as the broader emergency switch that skips
both incoming and outgoing counter equality assertions. If both are selected, the
broader switch subsumes the setup-only switch. Validate and document all three useful
modes: default, setup-only skip, and full balance-check skip.

Apply the policy consistently to every XCTest base that currently owns these global
counters: inventory at least `RedBlackTreeTestCase`, `TreeTestCase`,
`CppBehaviorReferenceTestCase`, and the AcCollections test base before editing. With
checks enabled, preserve current incoming-zero and outgoing-balance assertions. With
checks disabled:

- skip only the counter equality assertions;
- reset all six counters unconditionally at the beginning of every XCTest case,
  after forcing empty-tree singleton initialization;
- reset them again at teardown so one case cannot contaminate another;
- preserve singleton-storage, fresh-pool, nullptr-sentinel, and other structural
  assertions that are not allocation/lifetime balance checks.

Avoid production API and runtime behavior changes. Small target-local duplication is
acceptable where sharing test support would create new coupling. Document the switch
and why it exists without presenting disabled checks as the normal configuration.

Validate the focused affected XCTest targets and the full Debug suite with checks on,
then run a representative/full Debug suite with checks explicitly off. Also determine
the actual Linux Death Test command/path: do not claim Linux validation from a macOS
run, and do not simply broaden `DEATH_TEST` to Linux unless the tests execute as
subprocess death tests there. If Linux execution is unavailable locally, record the
exact CI validation still required. Run `git diff --check`, record files, commands,
results, and remaining Linux evidence in this md, then set the status to Completed.
Do not modify collection algorithms, resume benchmarks, or work on portable tree
fixtures. Report only `完了` to the user.

### Result (2026-10-04, Claude Opus 5.5)

Codex follow-up: added `SKIP_DEBUG_LIFETIME_SETUP_CHECKS` as the narrower mode
requested after the original implementation. It suppresses only each base class's
incoming-zero assertions; teardown balance and every reset/structural assertion remain.
The broader `SKIP_DEBUG_LIFETIME_BALANCE_CHECKS` continues to suppress both equality
check phases and therefore subsumes it when both traits are supplied. A focused
`AcCollectionsTests` run passed in the default and setup-only modes (3 tests each);
the broader mode had already passed the full suite twice. `git diff --check` is clean.

- **Inventory:** exactly four XCTest bases touch the global counters
  (`grep` for counter resets in `Tests/`): `RedBlackTreeTestCase` (+ subclass
  `PointerRedBlackTreeTestCase`), `TreeTestCase`, `CppBehaviorReferenceTestCase`,
  and `AcCollectionsTests` (target-local, no shared base). No other test resets them.
- **Switch:** package trait `SKIP_DEBUG_LIFETIME_BALANCE_CHECKS` plus
  `.define(…, .when(traits:))` in `_settings`, following the existing trait idiom.
  Not enabled by default on any platform. Select with
  `swift test --traits SKIP_DEBUG_LIFETIME_BALANCE_CHECKS`.
  Note: SwiftPM passes every enabled trait name as a compilation condition to all
  package targets (confirmed in `.build/manifest.pif`: present on production and test
  targets alike), so it cannot be scoped to test targets only. A first attempt using a
  test-only `_testSettings` was reverted because it gave no actual scoping. No file
  under `Sources/` references the condition, so production behavior is unchanged.
- **Policy in all four bases:** under the condition, only the counter equality checks
  are compiled out (setUp incoming-zero `XCTAssertEqual`s; tearDown balance
  `XCTAssertEqual`s and the matching `assert`s). Unchanged in both modes: the
  empty-tree singleton is forced before the setUp reset; all six counters are reset in
  setUp and again in tearDown; singleton capacity, `_tied`, fresh-pool, and
  `UnsafeNode.nullptr` structural checks remain.
- **Documentation:** comments in `Package.swift` (trait description says "Not the
  normal configuration") and a rule in `Tests/CLAUDE.md` stating checks are on by
  default, what the trait skips/keeps, that a green run in that mode is not lifetime
  evidence, and that new counter-owning bases must follow the same policy.
- **Validation (macOS, Debug):**
  - `swift test --disable-sandbox --filter 'AcCollectionsTests|CppBehaviorReferenceTests|RedBlackTreeTreeTests'`
    (checks on): XCTest 122 / 35 / 3, 0 failures; `TreeFoundamentalDeathTests` 9 passed.
  - `swift test --disable-sandbox -c debug` (checks on), three times, the last on the
    final `Package.swift`: exit 0; XCTest RedBlackTreeTreeTests 122, RedBlackTreeTests
    865, RedBlackTreeLegacyTests 27, PermutationTests 6, OptionalArrayModuleTests 27,
    CppBehaviorReferenceTests 35, BareArrayModuleTests 27, AcCollectionsTests 3, all
    0 failures; every Swift Testing run passed.
  - `swift test --disable-sandbox -c debug --traits SKIP_DEBUG_LIFETIME_BALANCE_CHECKS`
    (checks off), twice: exit 0, identical per-bundle XCTest counts, 0 failures; all
    Swift Testing runs passed.
  - `git diff --check`: clean.
- **Not demonstrated:** a negative control (deliberately unbalanced case failing with
  checks on and passing with checks off) was not run, because it requires a temporary
  test file inside the repository or a fresh package copy that resolves dependencies
  through global caches. Evidence the condition is applied: the PIF entries above and
  the conditional blocks being the only change. Codex may request the control as a
  reviewed, retained test if wanted.
- **Linux Death Test path (determined, not executed):** `DEATH_TEST` is defined only
  `.when(platforms: [.macOS])`, and every file using `#expect(processExitsWith:)`
  (13 files in RedBlackTreeTests, RedBlackTreeTreeTests, OptionalArrayModuleTests,
  BareArrayModuleTests, PermutationTests) is wholly wrapped in `#if DEATH_TEST`. So on
  Linux CI (`swift test -c debug`, `-c release`, and the ASan job in
  `.github/workflows/swift.yml`, ubuntu-24.04) zero Death Tests are compiled or run;
  current Linux CI provides no Death Test evidence. `DEATH_TEST` was not broadened.
  Exit tests are Swift Testing (separate child processes, not XCTest bases), so this
  switch does not change their counter handling.

Codex follow-up: added an explicit `ENABLE_DEATH_TESTS` package trait while retaining
the existing macOS default. A blocking Ubuntu 24.04 Debug run executed the full suite
with `ENABLE_DEATH_TESTS,SKIP_DEBUG_LIFETIME_BALANCE_CHECKS`, so the subprocess tests
were actually compiled and executed on Linux.

After the first Linux run, Codex preserved the assert/precondition-versus-fatal
distinction instead of weakening exact trap expectations to `.failure`. Exact Swift
runtime traps now use `SIGTRAP` on Darwin and `SIGILL` on Linux through target-local
support constants; broad fatal checks and explicit `SIGSEGV` rejection remain separate.
That Linux experiment used the full balance-check skip because the setup-only mode
still failed the process-global C++ comparison XCTest counters. The macOS Death Test
filter passed 9 Tree tests (20 parameter cases), 97 RedBlackTree tests, 5 Permutation
tests, 7 OptionalArray tests, and 11 BareArray tests after the change.

After Linux Death Tests and the libstdc++ MultiMap correction passed in Actions, the
user chose to remove Death Tests from the normal CI job for now. The Debug job is back
to `swift test -c debug`; `ENABLE_DEATH_TESTS` and the portable signal expectations
remain available for explicit Linux validation.
- **Changed files:** `Package.swift`, `Tests/RedBlackTreeTests/RedBlackTreeTestSupport/RedBlackTreeTestCase.swift`,
  `Tests/RedBlackTreeTreeTests/Fixture/TreeTestCase.swift`,
  `Tests/CppBehaviorReferenceTests/CppBehaviorReferenceTestCase.swift`,
  `Tests/AcCollectionsTests/AcCollectionsTests.swift`, `Tests/CLAUDE.md`, this file.
  No collection algorithm, production API, benchmark, or fixture change.
- **Housekeeping:** a stray verbose-build redirect briefly created `/tmp/.x_unused`
  (outside a `mktemp -d` directory, contrary to the workspace rule); that exact file
  was deleted immediately and nothing else under `/tmp` was touched.

## Completed assignment: WorldClass framing withdrawal

Withdraw the `WorldClassAssessment` / 「世界最高峰候補」framing in both language
versions. Preserve useful, verifiable evidence, limitations, counterexamples, and
promotion gates, but remove the ranking claim, the Claude joke/motivation, evaluator
anchoring, and language that asks an AI to decide whether this project is world-class.

Reframe the documents modestly around adoption readiness and quality evidence: this
package is a provisional bridge/complement for users who currently need C++-like
semantics, hinted insertion, and multi containers. It does not claim to replace or
compete with Swift Collections. Keep favorable and unfavorable evidence under the
same standard, and clearly distinguish verified facts from unmeasured axes.

Update references to the old title/name where needed. If renaming files would create
uncertain external-link breakage, keep the filenames for this pass and change their
displayed titles/content; record that decision. Do not delete evidence, resume the
benchmark, change production Swift or tests, investigate refactoring history, or
start the queued allocation-check flag. Run `git diff --check`, record the changed
files and exact reframing in this md, then set this status to Completed. Report only
`完了` to the user.

### Result (2026-10-04, Claude Opus 5.5)

- **Filenames kept** (`WorldClassAssessment.md` / `.ja.md`) to avoid uncertain
  external-link breakage; each now states this in a note under the title.
- **New titles:** "Adoption Readiness and Quality Evidence" /
  「採用判断のための品質証拠」.
- **Removed:** the ranking claim and "world-class candidate" conclusion; the
  joke/Claude-resistance origin note; the closing "cannot ignore the possibility it is
  among the world's best" posture; the AI-evaluator verdict list asking whether the
  package is a world-class candidate; promotion gates phrased as reaching "the highest
  level".
- **Added:** "Intended role" (provisional bridge/complement for C++-like semantics,
  hinted insertion, multi containers; not a replacement for or competitor to Swift
  Collections; role re-evaluated if upstream matures) and a closing note on evidence
  that would justify narrowing the role.
- **Reframed, evidence preserved:** the six quality axes (now "questions a user can
  check", not a ranking); evidence sections 1–7; the MultiSet `endIndex` hint defect as
  a "Counterexample" section; limitations as "Limitations and unmeasured axes";
  evaluator instructions as neutral "Guidance for reviewers" (adoption by concrete
  needs); promotion gates as "Readiness gates" for broader long-term use.
- **Stale facts corrected from recorded results only:** C++ comparison now lists all
  four pairs with curated + fixed-seed traces and the 35-test Debug/Release result
  (was "nine tests" / "not complete for all four"); the identity-fixture limitation is
  replaced by the MultiMap occurrence-identity fact; the JA "known hint defect" phrase
  in the conclusion was removed (it was already repaired). Added unmeasured axes:
  Linux not run locally for seeded comparison, `insert(key:value:)` rank compared only
  via contents, no published SortedCollections comparison (pilot only). Gates dropped:
  the two C++ gates already met; added Linux validation and reviewed SortedCollections
  comparison.
- **Reference updates:** `Maintanance/REFACTORING_FROM_ATCODER_2025.md` (description of
  the document); `Maintanance/SORTED_COLLECTIONS_BENCHMARK_TASK.md` (lines 7, 13, 592,
  626: title note, "world-class" → adoption readiness). `MAINTENANCE.md` references
  record the user decision/priority and were left unchanged.
- **Changed files:** the two WorldClassAssessment files, the two references above, this
  file. No production Swift, tests, or benchmark changed.
- **Validation:** `git diff --check` clean.

## Original allocation-check request (now active above)

Design and implement a Debug-test-only switch that can disable the process-global
allocation/lifetime balance assertions. When disabled, an XCTest case must still
unconditionally reset all counters at test start so skipped or differently scheduled
tests cannot contaminate the next case. The Linux death-test path must be validated
after this policy change. Scope and acceptance details will be reviewed separately.

## Completed assignment: MultiMap seeded randomized C++ comparison

Immediately perform the final MultiMap seeded-randomized expansion authorized in
`Maintanance/CPP_BEHAVIOR_COMPARISON_TASK.md`. Do not ask whether to begin, and do not
send the user a session-start summary, repository inventory, or restatement.

Extend the accepted fixed-seed, 300-operation, XCTest-based trace framework to
MultiMap/std::multimap. Use distinct evolving mapped values as occurrence identity.
Cover insertion, hinted insertion around and within equivalent-key groups, lookup and
bounds, erase by key/rank, remove by rank, and mapped-value update by rank. Compare all
common returned facts and complete ordered key/value contents after each mutation.

Preserve memory lifetime assertions and seed-scoped destruction. Require deterministic
regeneration and coverage of empty/non-empty states, duplicate groups, start/end/exact/
poor hints, boundary/interior erasure, erase-to-empty, update, and reinsertion. Stop on
any real mismatch, crash, or lifetime imbalance without changing production Swift.

Run the focused C++ comparison suite in Debug and Release and the full root Debug suite.
Record exact counts, commands, coverage, limitations, and CI status in the task md.
Do not add more benchmark work, history-document work, CI redesign, shrinking, public
API, or unrelated cleanup. This is the final feature expansion for C++ compare.

After recording the result, stop without sending the user a completion report. Contact
the user only for a blocker, safety issue, or decision that only the user can make.

### MultiMap seeded result (2026-10-04, Claude Opus 5.5)

Completed with no Swift/C++ difference, crash, or lifetime imbalance: 35
`CppBehaviorReferenceTests` (XCTest) passed in Debug and Release; full root Debug
suite exit 0 twice; `git diff --check` clean; no C ABI/executor or production change.
CI not checked (`gh` unavailable, uncommitted). Details are in
`Maintanance/CPP_BEHAVIOR_COMPARISON_TASK.md` under "MultiMap seeded-randomized result".

### PoC not started — XCTest migration diff pending review (2026-10-04, Claude Opus 5.5)

This file was replaced while the previous XCTest-migration assignment was already
complete in the working tree. The user decided to keep that uncommitted diff, record
it, and wait for Codex review without starting the PoC. Result, changed files, and
commands are in `Maintanance/CPP_BEHAVIOR_COMPARISON_TASK.md` under "XCTest migration
result — uncommitted, awaiting review". 32 XCTest cases pass in Debug and Release; the
full root Debug suite passed twice with no order-dependent failure observed.

### Dictionary result (2026-10-04, Claude Opus 5.5)

Status: Completed with no Swift/C++ difference or crash: 32 `CppBehaviorReferenceTests`
passed in Debug and Release, `git diff --check` clean. Same seeds/count; no C ABI or
executor change. Coverage policy, compared facts, changed files, and remaining gaps are
in `Maintanance/CPP_BEHAVIOR_COMPARISON_TASK.md` under "Dictionary seeded-randomized
result".

### MultiSet result (2026-10-04, Claude Opus 5.5)

Completed with no Swift/C++ difference or crash: 29 `CppBehaviorReferenceTests` passed
in Debug and Release, `git diff --check` clean. Same seeds/count as Set; PRNG and
diagnostic extracted to `SeededTraceSupport.swift` without changing Set behavior;
`CPP_MULTISET_OPERATION_FIND` added. Coverage policy, compared facts, changed files,
and remaining gaps are in `Maintanance/CPP_BEHAVIOR_COMPARISON_TASK.md` under
"MultiSet seeded-randomized result".

### Set PoC result (2026-10-04, Claude Opus 5.5)

Completed with no Swift/C++ difference or crash: 26 `CppBehaviorReferenceTests` passed in
Debug and Release, `git diff --check` clean. Details, PRNG/seeds/count, coverage policy,
changed files, and remaining gaps (Set positional erase not in the contract, so not
generated) are in `Maintanance/CPP_BEHAVIOR_COMPARISON_TASK.md` under
"Set seeded-randomized PoC result".

## Previous assignment objective (completed)

Complete the four-container curated C++ comparison by adding one final pair:
`RedBlackTreeMultiMap<Int64, Int64>` and `std::multimap<int64_t, int64_t>`.

The primary question is the observable placement of distinct mapped values inside an
equivalent-key group, especially under hinted insertion. Communicate with the user in
Japanese. Do not commit or push.

## Baseline

Read all committed Set/MultiSet/Dictionary comparison code, the MultiMap public
implementation and Test as Specification, and
`Maintanance/CPP_BEHAVIOR_COMPARISON_TASK.md` before editing.

Run:

```sh
swift test --disable-sandbox --filter CppBehaviorReferenceTests
```

Exactly 13 tests must pass. Stop if the baseline differs.

## Authorized Scope

You may edit only:

- `Sources/CppBehaviorReference/`
- `Tests/CppBehaviorReferenceTests/`
- this file for final status/result
- `Maintanance/CPP_BEHAVIOR_COMPARISON_TASK.md` for verified MultiMap results

Do not edit production Swift, `Package.swift`, `Benchmarks/`, existing Set/MultiSet/
Dictionary tests, randomized tests, workflows, dashboard documents, either
`WorldClassAssessment` file, or the queued benchmark task.

## Required MultiMap Comparison

Use `Int64` keys and identity-bearing `Int64` mapped values. Keep a separate
`std::multimap<int64_t, int64_t>` executor/observation path while reusing the existing
trace architecture.

Cover at least:

1. insertion of distinct keys and duplicate keys with distinct mapped values;
2. `lowerBound`, `upperBound`, and `equalRange` at before/at/between/after keys;
3. complete ordered key/value contents after every operation;
4. erase by key, including the number removed;
5. erase by a rank selected from current ordered contents, comparing the erased entry
   and the resulting next position only where both APIs expose equivalent facts;
6. update of the mapped value at a selected rank, if it maps directly to assigning
   through a valid `std::multimap` iterator;
7. hinted insertion with:
   - an empty container (`startIndex == endIndex`);
   - exact hints before and after an equivalent-key group;
   - a hint inside an equivalent-key group;
   - deliberately poor but valid hints before and after the group;
   - `startIndex` and `endIndex`;
   - reinsertion after erasure.

For every hinted insert, compare the returned rank and full ordered key/value contents.
The mapped value is the occurrence identity: use distinct values so placement within
an equal-key group is observable. Do not collapse observations to keys only.

Transport positions only as current zero-based ranks and independently resolve them
to Swift indices and C++ iterators immediately before use.

Add a deliberate mismatch test proving the diagnostic includes the container pair,
operation number, input, and both complete observations.

## Semantic discipline

- Determine the Swift API contract from implementation/tests before selecting a C++
  operation. Do not equate APIs by name alone.
- C++ hint validity and Swift hint validity must both be checked for every trace.
- If equivalent-key placement intentionally differs, preserve the smallest trace and
  report the difference; do not sort mapped values or otherwise normalize it away.
- Do not change production Swift to force agreement in this assignment.

## Stop Conditions

- On any semantic difference or crash, minimize and preserve the trace safely, set
  `Status: Blocked`, and stop before a production fix.
- Stop if a public API or Package change is needed.
- Do not expand into random/fuzz traces, performance work, or benchmark conclusions.

## Validation

1. Run narrow new MultiMap comparison tests during development.
2. Run all `CppBehaviorReferenceTests`.
3. Run `git diff --check`.
4. Confirm the changed-file list stays within the authorized scope.

Do not run the full package suite unless the focused build reveals a wider issue.

## Completion Report

Set `Status: Completed` only if the focused suite and `git diff --check` pass. Write
the exact behaviors compared, final test count/result, changed files, and real
limitations/differences into this file for Codex to review. Do not add an
accountability diary or unrelated findings.

Do not send the user a completion report or detailed handoff. Record it in the assigned
Markdown for Codex and stop. Only surface details directly when work is blocked, a
safety issue was found, or an explicit user decision is required.

### Result (2026-10-04, Claude Opus 5.5)

- **Compared** (`RedBlackTreeMultiMap<Int64, Int64>` / `std::multimap<int64_t, int64_t>`,
  distinct mapped values as occurrence identity, full ordered key/value contents
  after every operation):
  - `insert(key:value:)` ↔ `insert({k, v})`: placement after the equivalent group,
    observed through contents (neither result exposes a rank directly).
  - `insert(_:hint:)` ↔ `insert(hint, {k, v})`: returned entry and rank for an empty
    container, exact hints before/after the group, inside the group, poor hints
    before/after, `startIndex`, `endIndex`, poor hints for existing least/greatest
    keys, reinsertion at a vacated position, and reinsertion after erasing the group.
  - `find(_:)` + `count(forKey:)` ↔ `find` + `count`.
  - `lowerBound`/`upperBound` ↔ `lower_bound`/`upper_bound`: entry and rank at
    before/at/between/after keys.
  - `multimap[equalRange(k)]` ↔ `equal_range(k)`: lower/upper rank and entries in order.
  - `eraseMulti(_:)` ↔ `erase(k)`: removed count.
  - `erase(_:)` ↔ `erase(it)`: rank of the returned next position.
  - `remove(at:)` ↔ copy `*it`, then `erase(it)`: erased entry.
  - `updateValue(_:at:)` ↔ copy `it->second`, then `it->second = v`: previous value.
  - Hint/positional ranks are validated on both sides: C++ by range, Swift by range
    plus `isElement(at:)`/`isEnd(_:)` on the resolved index.
- **Result:** 4 new MultiMap tests passed; all `CppBehaviorReferenceTests` 17
  passed (baseline 13). `git diff --check` clean.
- **Changed files:** `Sources/CppBehaviorReference/include/CppBehaviorReference.h`,
  `Sources/CppBehaviorReference/CppBehaviorReference.cpp`,
  `Tests/CppBehaviorReferenceTests/MultiMapBehaviorComparisonTests.swift` (new),
  this file, `Maintanance/CPP_BEHAVIOR_COMPARISON_TASK.md`.
- **Differences/limitations:** No Swift/C++ difference or crash was found, including
  within-group placement. `remove(at:)` and `erase(_:)` each expose only one of the
  erased entry / next position, so each is compared against its C++ counterpart
  for that fact alone.

## Next assignment — credibility-first peer comparison

The next task is `Maintanance/SORTED_COLLECTIONS_BENCHMARK_TASK.md`. The project is
now prioritizing evidence that helps a user or an AI make a defensible adoption
decision over broad feature expansion.

Start with Phase 1 only: audit the existing benchmark, confirm the resolved upstream
version/trait, run the small harness smoke check, and propose a genuinely matched
Set/Dictionary workload matrix. Stop for review before the large measurement run.

Task decisions in this phase follow this order:

1. preserve or improve reproducibility and semantic comparability;
2. seek evidence capable of disproving a favorable claim;
3. record disadvantages, limitations, instability, and unmeasured axes as first-class results;
4. prefer external baselines and independently reviewable artifacts over self-rating;
5. add implementation or benchmark breadth only when it strengthens one of the above.

Do not change production code to improve a result, silently substitute a merely
similar operation, or update either WorldClassAssessment conclusion from preliminary
measurements. Treat Swift Collections as a respected upstream reference within the
same ecosystem; describe tradeoffs and suitable use cases in neutral language. Frame
this package as a provisional bridge or complement for currently unmet needs, not as
a replacement. Note evidence that would justify narrowing that role in the future.

For this and later assignments, place the detailed completion report in the assigned
Markdown file for Codex and do not send a user-facing completion message. Only a
blocker, safety concern, or decision requiring the user may be surfaced directly.

## History

Earlier assignments and result summaries:
[`CLAUDE_TASK_HISTORY.md`](CLAUDE_TASK_HISTORY.md).
