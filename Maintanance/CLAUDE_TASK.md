# Codex-to-Claude Work Request

Status: Bounded assignments only. Temporary primary-user-support delegation ended 2026-10-08 by user direction.

Task selection and start authority are defined in the root `CLAUDE.md`. This document records the
current job and bounded-task execution constraints. Codex integrates the results, performs Registry
acceptance and state updates, and owns public-document completion.
Repository evidence establishes factual correctness; product decisions remain with the user.

## Current job status

**完了: Public API名ballotのClaude独立採点**

ClaudeがUser・Codexの採点を読まず、固定済みArray命名ballot全29候補へ点数、理由、懸念を記録した。
Codexが件数、点数範囲、説明欄を検収した。候補生成、ballot修正、採用判断、統合は行っていない。

**完了: Array命名ballot draftの独立検査**

Claudeが候補網羅、意味分離、重複処理、契約変更の混入、現行sourceとの一致を独立検査した。
Codexは帰属、BareArray限定scope、後続候補の所在を修正した。review-informed Codex supplementを
独立提出と同じballotへ含めるかだけはユーザー判断として残す。

2026-10-13、ユーザーがreview-informed supplement 4件の包含を承認し、Codexがballotを固定した。
独立採点はまだ開始していない。

**完了: OptionalArray／BareArray deprecated公開面削除後の独立目視検査**

CodexがOptionalArrayとBareArrayの旧連鎖subscript・非所有Viewを削除し、現行の座標accessへtest・
benchmark・文書を移行した作業について、下記のbounded assignmentだけを独立に検査する。実装や文書を
修正せず、観測結果をこの文書のreturn節へ記録する。RedBlackTreeへは触れない。

- Claudeが旧公開面の残存と現行座標access・借用参照経路を横断確認した。
- 指摘されたQuality Profileの存在しない`mutable`表記をCodexが`reference(at:)`／`MutableRef.pointee`へ修正した。
- 追跡外の旧fixture空directoryを除去し、検査結果を受け入れた。

**凍結中: PERM-051 borrowed Span版PermutationのTest as Specification**

- runtime仕様test 25件はCodexが受け入れ、Xcode build-for-testingと対象25件成功を確認した。
- 借用寿命のcompiler診断証拠が未完了のため、task全体は完了扱いにしない。
- ユーザーが明示的に再開するまで着手しない。

この節だけでジョブの有無を判断する。Archived recordsを現行ジョブとして読み替えない。状態が変わった
ときは、assignment本文より先にこの節を更新する。

## Current assignment: Public API名ballotのClaude独立採点

### Objective

`PUBLIC_API_NAMING_BALLOT.md`の全候補を独立に評価し、`PUBLIC_API_NAMING_SCORE_CLAUDE.md`へ
1〜10の整数点、短い理由、重要な懸念を記録する。

### Inputs

Read only:

- Registryの`API-006`行;
- `Maintanance/PUBLIC_API_NAMING_BALLOT.md`;
- 現行の`Sources/BareArrayModule/BareArray.swift`;
- 現行の`Sources/OptionalArrayModule/OptinalArray.swift`;
- 両moduleの公開Quality Profile。

`PUBLIC_API_NAMING_SCORE_USER.md`と`PUBLIC_API_NAMING_SCORE_CODEX.md`は読まない。

### Evaluation

role accuracy、call-site readability、family coherence、necessary distinction、migration cost、
promise accuracy、Validation fitnessを総合的な観点として使う。機械的な加算は行わない。
各候補を同じsection内の代替案として評価し、他sectionの選択を勝手に確定しない。

### Boundaries

- 変更できるのは`Maintanance/PUBLIC_API_NAMING_SCORE_CLAUDE.md`だけ。
- 候補、ballot、source、test、Registry、User・Codex scoreを変更しない。
- 推奨winner、採用、平均、統合結果を作らない。
- build、test、benchmark、commitは行わない。

### Completion

全29候補のscore、reason、material concernを埋め、statusを完了へ変更する。結果の受入と統合はCodexが行う。

## Current assignment: Array命名ballot draftの独立検査

### Objective

`PUBLIC_API_NAMING_BALLOT.md`のArray部分が、現行公開面について一つの採点項目へ一つの命名判断だけを
置き、三者の候補を失わず、削除済み表面や契約変更を候補へ混入させていないか確認する。

### Inputs

Read only:

- Registryの`ARRAY-008`と`API-002`の行;
- `Maintanance/PUBLIC_API_NAMING_BALLOT.md`;
- `Maintanance/ArrayObjectAndAPINamingDraft.md`;
- 三者の`PUBLIC_API_NAMING_CANDIDATES_*.md`;
- `Sources/BareArrayModule/BareArray.swift`;
- `Sources/OptionalArrayModule/OptinalArray.swift`;
- 両moduleの公開Quality Profile。

### Inspection questions

- submit済みの命名だけの候補が、意味を変えず対応するballot sectionへ入っているか。
- exact duplicateが票数を増やさず、異なる意味が黙って統合されていないか。
- owner二family、1D suffix、copied value access、borrowed referenceのmethod・result・propertyが
  互いを不必要に決めない単位へ分かれているか。
- View、subscript、closure mutation、operation追加、BareArray製品除外、Permutationが正しく対象外か。
- 現行sourceに存在しないsurfaceや、現在の所有権・寿命契約を変える候補が命名だけの候補として
  紛れ込んでいないか。
- 候補不足があるなら、既存提出から機械的に導ける不足か、新しい候補提出を要する不足かを区別する。

### Boundaries

- ballot、候補文書、source、test、Registryを変更しない。
- 候補を採点、順位付け、推奨、採用しない。
- 新しい公開契約または製品範囲を決めない。
- PermutationとRedBlackTreeを調査しない。

### Validation and return

検索と目視照合だけを行い、build、test、commitは行わない。問題があればballot IDまたはsection、元の提出、
問題の種類、修正に必要な境界を列挙する。問題がなければ確認した範囲と残る限界を短く記録する。

結果はこのassignment末尾の`Claude return`へ追記する。受入と修正はCodexが行う。

### Claude return

2026-10-13 Claude（Opus 5.5）。検索と目視照合だけ。採点・推奨はしていない。

#### 指摘

- **RP-01（帰属の誤り）:** Sourceが「Current, Claude retention」だが、Claudeは`pointee`の維持を提出していない。
  `PUBLIC_API_NAMING_CANDIDATES_CLAUDE.md`のB表は「`MutableRef`を維持、`pointee`を`value`へ」で、Claudeの案はRP-02だけ。
  RP-01のSourceは「Current」だけにするのが正しい。
- **RT-03（帰属の欠落）:** Sourceが「Codex supplement, current concrete type」だが、Claudeも同じB表で`MutableRef`の
  維持を提出している。exact duplicateとしてClaudeを加えるべき（票数は増やさない）。
- **C節（帰属の欠落）:** DS-01〜DS-03にSource列がない。DS-01／DS-02はClaudeの`ARRAY_NAMING_CANDIDATES_CLAUDE.md`
  C-1a／C-1b（両方suffixなし／両方suffixあり）と同じ意味で、他者の提出にもあるかは未確認。提出元を残すと他節と揃う。
- **Codex supplementの扱い:** PO-09、PO-10、BR-03、RT-03は、Codex候補文書のF節で「review-informed supplement、
  他の候補とdeprecated削除の後に追加」と明記されている。ballotでも「Codex supplement」と表示されており隠れてはいない。
  ただし`ArrayObjectAndAPINamingDraft.md`の「候補生成は相互レビュー前に終える」という手順とは時点が違うので、
  独立提出の候補と同列に採点してよいかはユーザー判断（修正には候補の採否を決める境界が要る）。
- **E〜G節の適用範囲が書かれていない:** 借用参照（`reference(at:)`、`Reference`／`MutableRef`、`pointee`）は
  現行sourceでBareArrayにだけ存在し、OptionalArrayにはない。BareArrayは製品除外の判断が別にあるが、E〜Gがどちらのfamilyに
  適用されるかballotに一言ない。命名判断としての独立性は保たれているので、適用範囲の注記だけで足りる。

#### 候補不足（既存提出から機械的に導ける）

- Claudeの`OptionalArray1D.init(capacity:)`→`init(count:)`、`removeAll()`の`resetAll()`／`clear()`は命名だけの候補だが、
  Excluded表の「Initializer, `removeAll`, `indices`, shape labels — 後の命名scope」で一括除外されている。除外理由自体は
  妥当（owner名と要素accessの判断に不要）。後のscopeで拾えるよう、どこで扱うかの行き先があると取りこぼしにならない。
  新しい候補提出は要らない。

#### 問題なし（確認した範囲）

- 網羅: Userの`BareElements`／`OptionalCache`／現行4語、Codexの`ElementBuffer`系・`FixedShapeElements`系・現行・
  `mutableElement`／`MutableElementReference`、Claudeの`FixedArray`・`HeapArray`・`SlotArray`・`MemoTable`・現行・
  `value`／`setValue`・`value`（property）が、いずれかの行に意味を変えずに入っている。
- 重複: `element`／`setElement`、`reference`、`Reference`、`BareArray`、`OptionalArray`は1行に統合され、Sourceの併記で
  票数を増やしていない。
- 意味の分離: owner二family（A／B）、1D suffix（C）、copied value access（D）、借用参照のmethod・result・property（E〜G）が
  互いを決めない単位に分かれている。ClaudeのA-2は`value`／`setValue`（D）とclosure案（Excluded）に正しく分けられている。
- 対象外: View型名、多引数subscript（取り下げ済み）、`withMutableValue`、`removeElement`、参照resultの削除、BareArray製品除外、
  Permutationが、それぞれ理由付きでExcludedにある。
- 現行sourceとの一致: `element(at:)`、`setElement(_:at:)`（両family）、`reference(at:)`、`typealias Reference = MutableRef`、
  `MutableRef.pointee`（BareArrayだけ）が存在し、View型と`subscript`は存在しない。所有権・寿命契約を変える候補が
  命名候補の行に紛れ込んではいない（E節冒頭で`~Escapable`の寿命は変えないと明記）。

#### 限界

- `ARRAY_NAMING_CANDIDATES_USER.md`／`_CODEX.md`（object名の初回提出）はInputs外のため照合していない。DS節の提出元は未確認。

## Current assignment: OptionalArray／BareArray deprecated公開面削除後の独立目視検査

### Objective

OptionalArrayとBareArrayについて、削除された旧連鎖subscript・非所有Viewが現行公開面、test、benchmark、
利用例、および現在性を主張する文書へ残っていないかを横断的に検査する。同時に、削除後も残る座標value
accessとBareArrayのSwift 6.4向け借用参照APIが、誤って削除・旧扱いされていないかを確認する。

### Inputs

Read only:

- Registryの`OPT-060`と`BARE-036`の行;
- `Sources/OptionalArrayModule/`と`Sources/BareArrayModule/`;
- 対応する`Tests/`、`Benchmarks/Sources/Benchmarks/`、`Tests/AcCollectionsTests/`;
- `Sources/OptionalArrayModule/Documentation/Quality-Profile.md`;
- `Sources/BareArrayModule/Documentation/Quality-Profile.md`;
- `Maintanance/OptionalArrayModule/OptionalArrayAudit.md`と`CurrentQualityAssessment.md`;
- `Maintanance/BareArrayModule/BareArrayAudit.md`と`CurrentQualityAssessment.md`。

### Inspection questions

- 削除済み`OptionalArray*View`／`BareArray*View`型または所有型の旧連鎖subscriptが、production source、
  実行対象test、benchmark、利用例、facade testへ残っていないか。
- 旧View・連鎖subscriptを現行契約または現在評価として説明する記述が、公開Quality Profileまたは
  Current Quality Assessmentへ残っていないか。
- audit内の過去の棚卸し・判断・履歴は、削除漏れと誤認せず、現在状態との境界が読めるかだけ確認する。
- OptionalArrayの`element`／`setElement`、BareArrayの`element`／`setElement`が現行経路として保たれているか。
- BareArrayの`MutableRef`と`reference(at:)`というSwift 6.4向け借用参照経路が、現行APIとして
  production source、Test as Specification、compiler fixture、benchmark、文書で矛盾なく扱われているか。
- 削除された契約だけを観測するtest、Death Test、compiler fixture、benchmarkが残っていないか。

### Boundaries

- source、test、benchmark、公開文書、Current Quality Assessment、audit、Registryを変更しない。
- public API、命名、性能、互換性、借用参照の採否を判断しない。
- RedBlackTree、Permutation、およびUser folderを調査・変更しない。
- Archived記録やauditの歴史記述を、現行契約へ残った旧記述として機械的に報告しない。
- agreementや検索0件を完全性の証明にしない。確認した範囲と未確認範囲を分ける。

### Validation and return

検索と目視照合だけを行い、build、test、benchmark、commit、Registry更新は行わない。問題があれば、
`path:line`、該当記述またはsymbol、現行契約と衝突する理由を列挙する。問題がなければ、確認した領域と
残る限界を短く記録する。

結果はこのassignment末尾の`Claude return`へ追記する。完了判定と修正はCodexが行う。

### Claude return

2026-10-13 Claude（Opus 5.5）。検索と目視照合だけで、build・testは実行していない。

#### 指摘

- `Sources/BareArrayModule/Documentation/Quality-Profile.md:83` — 「`element`、`setElement`、`reference`、`mutable`が
  指定座標だけを読み書きすること」。`mutable`という公開APIは現行`BareArray.swift`に存在しない（`func mutable`／
  `mutable(at:`の検索0件）。現行の借用参照経路は`reference(at:)`だけ。旧Viewのdeprecated messageが存在しない
  `mutable(at:...)`を案内していた件（CurrentQualityAssessment「付随して見つかった文書不整合」）と同根の残りと見られる。
- `Utilities/Maintenance/CompilerDiagnostics/BareArrayOwnedWriteback/`と`BareArrayViewEscape/`が、中身のない
  directory（`Tests`／`Sources`の空subdirectoryだけ）として作業treeに残っている。gitの追跡対象ではなく
  （`git ls-files`で0件）、検証scriptからも参照されていないので契約上の問題ではないが、旧fixtureが残っているように
  見える。（Inputs外の`Utilities/`だが、問いの「削除された契約だけを観測するcompiler fixture」に関わるので記録）

#### 問題なし（確認した範囲）

- production source: `Sources/OptionalArrayModule/`、`Sources/BareArrayModule/`に`*1DView`〜`*3DView`型と
  `subscript(`は残っていない。
- test: `Tests/OptionalArrayModuleTests/`、`Tests/BareArrayModuleTests/`、`Tests/AcCollectionsTests/`に旧View型・連鎖
  subscriptは残っていない。`EDPC-J.swift`／`EDPC-L.swift`の利用例も`element(at:)`／`setElement(_:at:)`へ移行済み。
- benchmark: `Benchmarks/Sources/Benchmarks/`の`[y][x]`形は、`OptionalArrayBenchmarks.swift`のRigidArray比較、
  `RigidArrayOptimizationBenchmarks.swift`、`StandardArrayMultidimensionalBenchmarks.swift`だけで、どれも比較対象の
  標準Array／RigidArrayのsubscript。OptionalArray／BareArrayへの連鎖subscriptではない。
- 公開Quality Profile: OptionalArray（23行）、BareArray（22行）とも「旧連鎖subscriptと非所有View 1D〜3Dは削除済みで
  現行契約に含めない」と明記。
- CurrentQualityAssessment: OptionalArrayは削除を現在状態として記述。BareArrayは冒頭の「Deprecated公開面の削除」節で
  現在状態を述べ、21行で「以下の旧View導入・監査・受入記録は履歴として保持」と境界を明示している。以降の旧View記述は
  履歴として読める。
- 現行経路: OptionalArray・BareArrayとも`element`／`setElement`が残り、`indices`も4型ずつ公開されたまま。
  BareArrayの`MutableRef`（`BareArray.swift:426`）と`reference(at:)`は、Test as Specification（`_7_BorrowedReferenceTests`、
  `_96_BorrowedReferenceDeathTests`）、compiler fixture（`BareArrayMutableRefLifetime`、検証scriptはこのfixtureだけを参照）、
  benchmark（`BareArrayBenchmarks.swift`）に揃って存在する。

#### 限界

- 検索pattern（View型名、`subscript(`、`][…]`、`writeback`、`連鎖`）に合わない書き方の旧記述は見落としうる。
- `Benchmarks/Libraries/*.json`のbenchmark名、DocC、README、`Documentation/`の利用者向け文書は見ていない。
- auditの歴史記述は、現在状態との境界が読めるかだけを見た。

## Last completed assignment: PERM-056 public surface, coexistence, and reexport tests

### Objective

Implement the accepted G0 public-surface and G5 coexistence／exposure requirements for the current
runtime-checked `NextPermutations` implementation.

### Inputs

Read only:

- the `PERM-056` Registry row;
- `Maintanance/PermutationModule/RuntimeCheckedPermutationTestPlan.md`;
- `Sources/PermutationModule/NextPermutations.swift` and `GateKeeper.swift`;
- legacy `_0_PublicSurfaceTests.swift` and `_4_CoexistenceTests.swift` under
  `Tests/PermutationTests/NextPermutationsSequence/` only for G0／G5 inputs;
- accepted borrowed coexistence tests only as a test-technique reference, not as the runtime-check
  contract;
- the current package targets and any existing repository-local compiler-surface fixture mechanism
  needed to test negative compile requirements;
- the task-relevant instructions in `Tests/CLAUDE.md` and sections of `Tests/TESTING.md`.

Use the G0／G5 boundaries in the plan. Do not revive retired `Sendable`、value-semantics、COW、
`Equatable`、`Hashable` or presentation guarantees.

### Required implementation

- Add numbered G0 and G5 tests under `Tests/PermutationTests/NextPermutations/`.
- Fix the current public owner and nested View type names and construction through
  `Collection.nextPermutations()` for Array、Range、nonzero-start Slice and non-`Int` indexed input.
- Verify with compiler-backed evidence that direct public initialization remains unavailable, the
  owner is noncopyable, and it does not conform to `Sequence`. Preserve the repository's existing
  fixture style if one exists; do not treat commented-out source as evidence.
- Verify that importing `PermutationModule` and `Algorithms` together is unambiguous and that
  `nextPermutations()` yields only the current order and its lexicographic successors while
  `permutations()` yields every positional ordering.
- Verify that importing `AcCollections` exposes the intended runtime-check entry point without a
  direct `PermutationModule` import.
- Keep AtCoder 2025 compatibility mode outside this evidence path; it has a separate API and tests.

### Boundaries

- Do not modify production source, Quality Profile, Current Quality Assessment, Package.swift, CI,
  Registry, public documentation, or disabled legacy test files.
- Do not change G1、G2、G3、G4.
- Do not decide new public API, `Sendable`, `Equatable`, `Hashable`, description, availability,
  compatibility, or lifetime policy.
- Do not revive COW, persistent-result, iterator-copy, `Sequence`, or borrowed-`Span` requirements.
- If the repository has no durable negative compiler-fixture mechanism, report the exact unmet G0
  checks and stop instead of inventing a claim from runtime reflection or comments.
- If a listed requirement cannot be implemented from the accepted contract, report that exact item
  and stop rather than deciding a new contract.

### Validation and return

- Run the new runtime tests and the already-accepted numbered runtime-check tests in Debug and
  Release. Run compiler fixtures through their actual repository execution path and record both
  expected-success and expected-failure outcomes.
- Report exact files changed, test counts, commands or Xcode actions, and results in
  `Maintanance/PermutationModule/RuntimeCheckedPermutationTestPlan.md` under a `PERM-056 return`
  section.
- Do not mark `PERM-056` complete and do not update Registry. Codex performs acceptance.

## Operating mode: bounded assignments only

Apply the task-selection and start-authority rule in the root `CLAUDE.md`. Codex integrates the
result, performs Registry acceptance and state changes, and owns public-document completion. These
coordination responsibilities do not make Codex's agreement evidence of factual correctness.

The rules below remain as bounded-task execution constraints. They do not grant authority to restart
frozen work or act on behalf of Codex.

Verify the current branch from the repository before editing; do not preserve a branch name here as
current state.

### Communication

- Respond directly when the user selects a Claude task. Codex is the active integrator; durable
  evidence belongs in the selected task's canonical document.
- Default to low-information reports. Give the outcome, any actual problem, and the next user
  decision or action only. Do not proactively explain background, commands, evidence, or every
  consideration; the user will ask when more detail is wanted.
- `完了` alone is preferred for a routine task whose requested outcome and validation are
  unambiguous. Expand without being asked only for a blocker, safety/correctness problem, failed
  validation, irreversible action, or a decision that only the user can make.
- A formal evaluation of the user, or a requested impression record, is a frozen Registry task and
  runs only when the user explicitly asks to record it. Merely discussing an evaluation or impression
  is not a request to append it. Write formal evaluations to `USER_MANAGEMENT_INTERVIEW_CLAUDE.md`
  and requested impressions to `CLAUDE_OBSERVATIONS.md`.
- Claude may still append its own optional, spontaneous observation to `CLAUDE_OBSERVATIONS.md` when
  genuinely useful. Do not manufacture an entry or delay the main task for it.
- If prior intent is unclear, ask the user rather than attributing an unstated decision to Codex.

### Authority

For an explicit user request, you may inspect, edit, build, test, benchmark, and update relevant
documentation within the repository. Use the smallest task boundary that satisfies the request.

The following still require explicit user direction:

- choosing or changing public API, compatibility policy, product positioning, or completion scope;
- restarting any item marked frozen, deferred, optional, or waiting for a user decision;
- changing the Index contract, `Comparable`, facade re-export policy, Permutation compatibility
  mode, or the unsafe-storage/concurrency items currently on hold;
- deleting material code or records;
- commit, push, merge, PR close/reopen, branch creation/deletion/switching, or history rewriting;
- publishing private performance-tuning knowledge.

Codex is the primary owner for public documentation. When public-document work is delegated to
Claude, keep it to explicitly named sections, factual verification, independent review, or a bounded
correction. Do not expand a Compatibility-document request into a four-document audit or rewrite.

When the user explicitly requests a commit, first verify the branch and complete diff. When it is
a good commit boundary, say `コミットおすすめです`. Never infer push permission from commit
permission.

### Performance-sensitive boundaries

- Non-`public` protocol declarations use `@usableFromInline` uniformly.
- Do not add, remove, or move `@inlinable`, and do not convert an existing `@usableFromInline` to
  `@inlinable`, without direct user review.
- Do not change a boundary that deliberately removes generic type variables, including the
  `RawBuffer` / `BufferHeader` family, without direct user review.
- Compile and functional tests do not prove performance neutrality. A performance-sensitive
  access or generic/protocol change is not complete until the relevant performance job is green.
- Keep the general tuning rationale private. Public incident records may describe reproduction and
  bisection, but follow the user's chosen level of detail for the mechanism.

### Task execution

- Establish current state from the Task Registry at the top of `Maintanance/PROGRESS_OVERVIEW.md`.
  After selecting a task, read only the detailed canonical document linked from that row. Do not
  scan all maintenance or Archived documents at session start.
- Read only the task-specific portions of maintenance documents needed for the current request.
  Do not turn backlog discovery into authorization to implement it.
- Preserve unrelated worktree changes. Never reset or discard user work to make a task clean.
- For broad inventories, repetitive cross-checks, or a high-risk conclusion, use an independent
  evidence-oriented second pass where available; otherwise tell the user what could not be
  independently reviewed. Agreement between agents is not evidence by itself.
- For performance work, fix the environment and baseline, reproduce first, and distinguish CI
  history from new local measurements.
- For cross-branch work, identify symbols by branch, path, configuration, and meaning. Verify the
  current branch before editing and again before committing.
- Update the relevant canonical record for durable decisions. Do not expose a private note merely
  to improve agent continuity.
- When actual use reveals a possible improvement to the conversation reference ID rule, Claude may
  append a concrete proposed diff to `Maintanance/CONVERSATION_REFERENCE_IDS.md` under
  `運用中の改訂候補` without waiting for a separate assignment. A proposal does not change the
  active rule; integrate it into the adopted text only after the user approves it or explicitly
  asks Claude to apply it.

### Bounded-task reporting

For a bounded assignment, record durable evidence in the selected task's canonical document and
report the outcome directly to the user. Do not maintain a general repository handoff or independently
curate the overall backlog. Registry acceptance and state changes remain Codex-owned.

If a task reveals a defect or decision point outside its boundary, report and stop. Do not turn the
finding into implementation authority.
