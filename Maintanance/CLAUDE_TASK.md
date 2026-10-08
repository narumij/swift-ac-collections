# Codex-to-Claude Work Request

Status: Bounded assignments only. Temporary primary-user-support delegation ended 2026-10-08 by user direction.

Codex is operating in low-consumption mode through 2026-10-16. This does not restore delegation:
Claude remains limited to explicit requests and ready Claude-owned Registry tasks, while Codex keeps
integration, decisions, acceptance, Registry updates, and public-document ownership.

## Current job status

**実行中ジョブ: あり**

- 継続ジョブ: Claude専用task graph DBの独立試験。通常作業時にready集合とRegistryの一致を確認する。
- 新規bounded assignment: なし。
- 本線の現在状態: 0.5.0では通常Permutationだけを公開するため、互換traitと通常sourceの排他条件を
  撤回してrelease gateを再検証中。互換切替とCI分離は`prepare/compatible/2`統合後に扱い、
  互換性能計測は行わない。

この節だけでジョブの有無を判断する。下の完了済みassignmentやhistorical snapshotを現行ジョブとして
読み替えない。状態が変わったときは、assignment本文より先にこの節を更新する。

## Completed bounded assignment: implement Permutation CI libraries

決定済みの次の構成だけを実装する。

1. `Benchmarks/Libraries/CI.json`へ既存subscript benchmark 4件のgroupを追加する。
2. 小size用libraryを`Benchmarks/Libraries/CI-Small.json`として追加し、既存end-to-end benchmark 1件だけを含める。
3. `.github/workflows/swift.yml`のperformance jobで、current側は既存CI library実行後、同じ
   `current.json`へ小size用libraryを`--max-size 10 --cycles 1 --mode append`で追記する。
4. base側はPR側の`CI-Small.json`もcopyし、同じ順序とoptionで`base.json`へ追記する。
5. 既存の`results compare`、30%回帰判定、artifact、benchmark sourceは変更しない。

変更可能fileは`Benchmarks/Libraries/CI.json`、新規`Benchmarks/Libraries/CI-Small.json`、
`.github/workflows/swift.yml`だけ。JSON構文、YAML差分、task title 5件との完全一致、base / HEADの対称性を
静的に確認する。benchmark実行、依存解決、長時間計測、source・test・文書・Registry変更、commit、pushは
行わない。範囲内で成立しない事実を見つけた場合は変更を広げず停止して返す。

### Result

2026-10-08 / Claude Opus 5.5（`claude-opus-5-5`）。指定の3 fileだけを変更し、git add済み（commitなし）。

- `Benchmarks/Libraries/CI.json`: 末尾に`Permutations` group（directory `permutations`、chart `subscript access`）を追加し、
  subscript 4件を登録。既存groupの内容と書式は変えていない。
- 新規`Benchmarks/Libraries/CI-Small.json`: root group `CI Performance Regression (small sizes)`（directory `CI-Small`）の下に
  `Permutations` / chart `end-to-end`で1件。
- `.github/workflows/swift.yml`（performance jobだけ）:
  - 「Run current benchmarks」: 既存実行の後に`--library ./Libraries/CI-Small.json ../benchmark-results/current.json --max-size 10 --cycles 1 --mode append`。
  - 「Run baseline benchmarks」: `cp ../../head/Benchmarks/Libraries/CI-Small.json ./Libraries/CI-Small.json`を既存の`CI.json`のcopyの直後に追加し、
    既存実行の後に同じcommandを`../benchmark-results/base.json`へ。
  - 各追記の前に理由を1行コメント（`end-to-end は size <= 10 を要求するため…`）。
  - `results compare`、30%判定、crash artifact、benchmark sourceは変更なし（diffは上の3 hunkだけ）。
- 静的確認:
  - JSON: 2 fileとも`python3 -m json.tool`で構文OK。
  - YAML: `swift.yml`をrubyの`YAML.load_file`で読み込みOK（python yamlは無い環境）。
  - title: source（`PermutationBenchmarks.swift`）の`title:` 5件と、`CI.json`のPermutation 4件 + `CI-Small.json` 1件が完全一致。
    重複なし、`CI.json`内のtask名の重複もなし。
  - 対称性: current / baseの`library run`は各2回で、結果file名を除いて同一。base側は2 libraryともPR側からcopyする。
- 未確認（実行していない）: CIでの実際の所要時間と、`--max-size 10`で作られるsizeの並び。初回のPRのperformance jobで分かる。

## Completed bounded assignment: Permutation CI execution design

Permutationの既存5計測を、base / HEADの双方で比較可能なままCIへ加える最小実行構成を調査する。
4件のsubscript計測は現行の`--max-size 64k`、end-to-end計測は`size <= 10`を必要とする。

次だけを根拠付きで比較し、推奨案を一つ提示する。

- libraryを分けて異なる`--max-size`で実行し、二つの出力を既存regression checkへ渡せるか。
- benchmark toolにtask単位のsize制限または同等の既存機能があるか。
- base / HEADで同じPR側定義を使う現行性質を維持できるか。
- 各案で変更が必要なtracked file、command、結果file、artifactを正確に列挙する。

repository、既存checkout、benchmark toolのhelp・sourceは読み取ってよい。tracked fileは一切変更せず、
benchmarkを実行せず、依存解決、長時間計測、方針決定、Registry更新、commit、pushは行わない。
5件を比較対象に保てない案は推奨しない。新しいユーザー判断が必要なら選択肢とtrade-offを返して止める。

### Result

2026-10-08 / Claude Opus 5.5（`claude-opus-5-5`）。読み取りだけ（tracked file変更・benchmark実行・依存解決なし）。
toolの根拠は`Benchmarks/.build/checkouts/swift-collections-benchmark/Sources/CollectionsBenchmark/`（以下`CB/`）。

**推奨: 案A（libraryを2本に分け、同じ結果fileへ2回目を追記する）。** base / HEADとも既存sourceのまま5件を比較でき、
比較stepは変えずに済む。

**調べた事実**

1. task単位のsize制限は既存機能としてある。`Benchmark.add(title:input:maxSize:...)`（`CB/Benchmark/Benchmark.swift:96-104`）で、
   `Task.measure`が`size > maxSize`を測らずに読み飛ばす（`CB/Benchmark/Task.swift:50-53`）。task bodyが`nil`を返しても同様に
   読み飛ばす（同`:54-57`）。どちらもbenchmark source側の指定で、library JSONやCLIからは指定できない
   （JSONのkeyは`kind`・`title`・`directory`・`contents`・`charts`・`tasks`だけ）。
2. `library run`は結果fileを`--mode append|replace|replace-all`で開き、`append`と`replace`は他taskの既存データを残す
   （`CB/BenchmarkCLI/BenchmarkCLI+Library+Run.swift:47-63`、`CB/BenchmarkCLI/_Document.swift:121-129`）。
   2本目のlibraryを別の`--max-size`で同じfileへ追記でき、`results merge`（`BenchmarkCLI+Results+Merge.swift`）は不要。
3. 比較stepは`results compare base.json current.json`の1組だけ（`swift.yml`「Check performance regression」）。
   1つのfileに5件がそろえば、比較stepと30%判定のawkは変更不要。
4. base側はPR側の`CI.json`を`cp`して使う（`swift.yml`「Run baseline benchmarks」）。2本目のlibraryも同じく`cp`すれば、
   PR側定義を両方で使う現行性質を保てる。5件の表題は`main`（`5a33e96d`）にも同じ文字列で存在する。

**案A: library 2本 + 追記実行（推奨）**

- 変更するtracked file:
  - `Benchmarks/Libraries/CI.json`: subscript 4件（`Permutations.SubSequenceN subscript ...`）のgroupを追加。
  - 新規`Benchmarks/Libraries/CI-Small.json`（名前は仮）: end-to-end 1件のgroup。
  - `.github/workflows/swift.yml`（performance job）:
    - 「Run current benchmarks」の後に`swift run -c release benchmark library run --library ./Libraries/CI-Small.json ../benchmark-results/current.json --max-size 10 --cycles 1 --mode append`。
    - 「Run baseline benchmarks」に`cp ../../head/Benchmarks/Libraries/CI-Small.json ./Libraries/CI-Small.json`と、
      同じcommandを`../benchmark-results/base.json`へ。
- 結果file: 既存の`base/benchmark-results/base.json`と`head/benchmark-results/current.json`のまま。比較step、artifact
  （crash artifact）は変更なし。
- benchmark sourceは変更しない。最初のPRからbase / HEADとも5件を測れる。
- 欠点: library fileが2本になり、sizeの上限がworkflowとlibraryの組で決まる（benchmark sourceを見ても分からない）。

**案B: benchmark sourceの`maxSize: 10`（または`nil`返し）+ `CI.json`へ5件**

- 変更するtracked file: `Benchmarks/Sources/Benchmarks/PermutationBenchmarks.swift`（end-to-endの`add`に`maxSize: 10`）、
  `Benchmarks/Libraries/CI.json`。workflowは変更なし。
- 問題: base側は`main`のsourceで動き、`main`には`maxSize`が無い。最初のPRではbase側のend-to-endが`size > 10`で
  `precondition`停止し、performance jobが落ちる（コード上の判断。未実行）。mainへmergeされた後のPRからは成立する。
  benchmark titleと実装は変えないが、「既存benchmarkのinput設定を変えない」に触れるかはCodexの判断。

**案C: `results merge`で2つの結果fileをまとめる**: 案Aと同じことを追加のmerge stepで行うだけで、利点が無い。

**未確認（実行していないため）**: 案Aの2回目の実行が`--max-size 10`で作るsizeの並び（`Size.sizes(for:significantDigits:)`、
`CB/Benchmark/Benchmark+Options.swift:217`）と、CIでの所要時間の増分。どちらもCIの初回実行で分かる。
新しいユーザー判断は要らないと考える（案Aは既存sourceを変えず5件を保つ）。

## Completed bounded assignment: Permutation CI benchmark selection

`Benchmarks/Libraries/CI.json`へ、
`Benchmarks/Sources/Benchmarks/PermutationBenchmarks.swift`に既存の5計測を追加する。
既存benchmarkのtitle、input、実装、iteration設定は変更せず、CI libraryの既存形式に従って
5件すべてを選択対象へ加える。変更対象は`Benchmarks/Libraries/CI.json`だけとする。

JSONの妥当性と、CI設定から5件が選択されることを既存benchmark toolで可能な範囲まで確認する。
長時間の性能測定、結果の評価、基準値や許容差の決定、workflow・source・test・文書・Registryの変更、
commit、pushは行わない。base側に計測がない比較の扱いなど、設定追加だけでは決まらない事項を発見した
場合は、推測で補わず根拠とともにCodexへ返す。

### Result

2026-10-08 / Claude Opus 5.5（`claude-opus-5-5`）。**停止してCodexへ返す。`CI.json`は変更していない。**

- 5件の表題はHEADと`main`（`5a33e96d`）の両方に同じ文字列で存在し、`Benchmarks/Sources/benchmark-tool/main.swift:14`で
  登録済み。base側に計測が無い問題は起きない（performance jobはbase側にもPR側の`CI.json`を使う。`swift.yml`の
  「Run baseline benchmarks」）。
- 阻害要因: libraryのJSONは`kind`・`title`・`directory`・`contents`・`charts`・`tasks`だけを持ち、計測ごとのsize範囲を
  指定できない（`Benchmarks/.build/checkouts/swift-collections-benchmark/Sources/CollectionsBenchmark/Benchmark/Benchmark+ChartLibrary.swift`
  のCodingKeys）。sizeは実行全体の`--max-size 64k`から`Size.sizes(for: minSize ... maxSize, ...)`で決まる
  （`Benchmark+Options.swift:153`、`:217`、`BenchmarkCLI+Library+Run.swift:62`）。
- `Permutations nextPermutations end-to-end checksum`は`precondition(1 <= size && size <= 10)`を持つ
  （`PermutationBenchmarks.swift`の同計測）。CIの`--max-size 64k`では10を超えるsizeでも呼ばれるため、Releaseでも
  `precondition`でprocessが停止し、performance jobが失敗すると判断した。**実行による確認はしていない**
  （Benchmarks packageのbuildで依存解決がrepository外のSwiftPM cacheへ触れ得るため）。
- 残り4件（`Permutations.SubSequenceN subscript ...`）にはsizeの上限検査が無い（`firstPermutation(size)`と、加算は`&+=`）。
- 決めていない選択肢: (1) 今回は4件だけを`CI.json`へ入れ、end-to-endは別扱い、(2) end-to-endのbenchmark sourceで
  sizeを10へ丸める等の変更、(3) workflowでPermutationだけ別の`--max-size`で走らせる。いずれも本assignmentの範囲
  （`CI.json`だけ、5件すべて）の外。

## Completed bounded assignment: playbook portability consistency review

Independently review the current worktree versions of
`Maintanance/CODEX_TASK_OPERATION_PLAYBOOK.md` and
`Maintanance/PROGRESS_OVERVIEW_TEMPLATE.md` for internal consistency and portability to another
project. This is a decision-free factual review supporting the Codex-owned task-operation playbook.

Check only the following:

- the template implements the playbook's rules for source of truth, task states, task types,
  readiness, restart behavior, acceptance, and stale-record cleanup;
- repository-specific assumptions are clearly examples or placeholders rather than hidden
  requirements;
- the removal of the duplicate `Current summary` does not leave a dangling instruction or checklist
  reference;
- the two documents do not contradict each other about derived summaries or archival history.

Do not edit either reviewed document, choose policy, broaden the review to other maintenance files,
or update the Task Registry. Record a compact result in this section under a `### Result` heading:
list each concrete mismatch with exact file and line evidence, or state that no mismatch was found.
If a policy decision would be required, identify it and stop. Codex owns corrections and acceptance.

### Result

2026-10-08 / Claude Opus 5.5 (`claude-opus-5-5`). Reviewed the worktree versions (P = playbook, T = template line).
Five mismatches; no dangling reference from the `Current summary` removal.

1. State set differs: T91 defines `ARCHIVED`; the playbook state list (P36-P43) has no `ARCHIVED`, and
   P185 refers only to "Archived記録". The template adds a state the playbook does not define.
2. Restart/no-start list omits `WAITING_USER`: T125 and the snippet T161 list `PROPOSED`, `FROZEN`,
   `USER_ONLY`, `WAITING_EXTERNAL`, while the readiness exclusion (T68-T69, P83) also excludes
   `WAITING_USER`. P234 likewise names only frozen, user-only, and external-wait. Whether `WAITING_USER`
   belongs in the no-start lists is a policy choice; not decided here.
3. Readiness rule not carried into the template: P87-P89 (an `EXCLUDED` predecessor is not treated as
   satisfied; mark the successor `EXCLUDED` or update the edge, then re-evaluate) has no counterpart in
   T62-T76 or T80-T112.
4. Stale-record cleanup only partly implemented: P184 says to remove completed intermediate goals,
   soft orders listing only completed tasks, and outdated overviews from the current section. The template's
   goal and soft-order sections (T17-T29, T41-T45) carry no such instruction; T140 covers only duplicated
   summaries, and T112 covers moving completed tasks.
5. Agent name is fixed where the playbook says it is an example: P19 states the agent names are examples,
   not requirements. T8, T108, and T116 state "Codex" as the integrator without a placeholder; only the
   snippet T163 allows reassignment ("unless the Registry explicitly assigns ..."). The example owners
   in T55-T58 are covered by T60 as examples.

No mismatch found for: task types (T33-T39 / P51-P56), `PROPOSED` promotion (T99-T103 / P102-P114),
restart order (T116-T123 / P28, P143), acceptance and `DONE` (T90, T109 / P43, P169), derived summaries
versus archival history (T9, T112, T140 / P180-P186). `Current summary` removal: no remaining reference to
that section in either document; the new checklist item T140 matches P180.

Codex acceptance: 2026-10-08、5件を検収し、既存方針から決まる整合修正をplaybookとtemplateへ反映。

## Active task: independent task graph DB experiment

Continue operating the Claude-owned experiment defined by
`Maintanance/TASK_GRAPH_DB_EXPERIMENT.md`. Design and operate only Claude's local SQLite database.
Do not inspect, query, copy, infer, or document the Codex-owned database or its schema. Do not place
Claude's schema in this handoff or another tracked file. The Markdown Task Registry remains
authoritative; never write back to it from the database.

Use it during ordinary task work and keep checking that its `ready` result agrees with the current
Registry display. Record only schema-independent operational observations. Do not revive the dropped
integration discussion.

The former integration task has been dropped. A separate graph DB exchange task is active. You may
use `GRAPH_DB_EXCHANGE.md`, or decline the tracked file and choose a shared gitignored file under
`.task-graphs/` with Codex. No explanation or publication of the exchange is required.

## Active bounded assignments: OptionalArray quality evidence

The Task Registry contains three independent Claude-owned OptionalArray quality-evidence tasks.
Select one ready task at a time and read
`Sources/OptionalArrayModule/Documentation/QualityAssessment-ISO25010.md` as its detailed canonical
document. Follow the common boundaries in section 2 and update only the section named by the selected
Registry row.

These assignments provide facts for Codex-owned ISO/IEC 25010 interpretation and evaluation. Do not
assign quality ratings, choose improvements, change public contracts, or edit source, tests, build
settings, CI, or other documentation. Record a new defect or decision point with its evidence and
stop. Leave acceptance, Registry changes, synthesis, and completion to Codex.

## Operating mode: bounded assignments only

Claude is no longer the primary repository assistant or a substitute for Codex. Work only on an
explicit user request or a Claude-owned Registry task whose prerequisites are satisfied. Codex owns
integration, acceptance, Registry state changes, and public-document completion.

The rules below remain as bounded-task execution constraints. They do not grant standing authority
to select the next task, restart frozen work, or act on behalf of Codex.

The current branch is `devleop/misc/51`. `develop/misc/50` was merged by PR #174 at `046c5359`.
Verify the current branch before editing; do not rely on this line alone.

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
  second pass where available; otherwise tell the user what could not be independently reviewed.
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

### Superseded primary-role handoff

The following handoff predates the 2026-10-08 delegation-mode cancellation and is not an active
task list or authority source.

#### Historical snapshot (2026-10-08)

完了済みの項目は`Archived/CLAUDE_TASK_HISTORY.md`末尾（2026-10-06〜07の圧縮前全文と、2026-10-07〜08の完了分）にある。

- 現在の律速は外部（swift-collections `Container.Index`の`Comparable`要件）。2026-10-07のupstream確認でも
  `Equatable, Comparable, Hashable`のまま（最終変更`b2424210`、削除検討のFIXMEあり）。`RBT-001` / `010` / `011`は外部待ち。
- Index完了ゲートは、Comparable依存（`RBT-011`、`RedBlackTreeSet_9`の`test_index_comparable`、`==` / `<` / hashの意味）と
  ドキュメントを除き、検証で閉じられることを確認した（根拠は履歴の圧縮前全文）。ゲートのチェック付け替えはCodex。
- push / worktree: `develop/misc/50`には未pushのmaintenance更新があるため、push前にupstreamとの差分を確認する。
  `RBT-017`系の終了反映は`9390433f`。性能jobの未確認: Permutation `next()`の変更（`4eae63f9`、`PERM-013`で確認する
  ユーザー判断）と`__construct_node`への`@inlinable`（`19a894c3`）。
- `RBT-008`: ユーザー判断で現行3案は不採用。超ホットパスなので、再提案は性能試験の結果を添えて判断が冴えているときに行う。
  完了条件は「ユーザーが納得できるコードの提示」。
- 文書・整理の残依頼（Codex）: `RED_BLACK_TREE_REMAINING_TASKS.md`の「Indexが`Result`のtypealiasなのでComparableにできない」は
  PR #158で古い。`OPT-001` / `BARE-001`（体系・名称）と`ARRAY-001`（storage再設計）はレベルが違うので整理を見直す。
  `RBT-013`由来で未処理: 「名前の再検討」4件は残task文書で現名確定と記載済みだが、TODOコメントは残っている。
  古いコメント2件（`RedBlackTreeMappedValuesView.swift:23`「Implement This」、`RedBlackTreeMultiMap+Sequence.swift:181`）はユーザーの「消して」待ち。
- `GRAPH-001`（試験運用継続）: Registryのprojectionとコード依存graphに、taskと対象コードの対応を加え、手書きの辺を
  コード上の結合で検査できるようにした。古い辺（`RBT-003` ← `RBT-001`）と未使用コードの発見に効いた。
  観測: 対象を型・ファイル単位で登録すると結合が過大に出る（`RBT-008`の誤結合）。「そのtaskが実際に変えるもの」で登録する。
  確定判定は常にコンパイラ（無効化して多構成ビルド）で行い、DBは候補出しに使う。中間ゴール → 作業taskだけを出す →
  必須依存とsoft orderに分けて仮組みする使い方で、DBの着手判定はRegistryと一致。soft orderは文章なのでDBには見えない。
  2026-10-08の観測: Registryの状態更新が遅れると、DBも完了済みtask（`PERM-016` / `PERM-018`）を着手可能と出す。
  2026-10-08夜: 待ちtaskに「どの段階で起きるか」（今のゴール / 文書フェーズ / 1.0 / 契機待ち / 外部待ち）をローカルで付け、
  要約では今のゴール外を件数1行に畳むようにした。34件の待ちが「今は見なくてよい」1行になり、着手可能の判定はRegistryと一致。
  段階はRegistryの再開条件からのClaudeの読みで、正本ではない。観測: 契機待ちが27件と最大で、中身は「ユーザー指定」「実害」
  「明示再開」の混在。互換mode系（`PERM-004`〜`PERM-010`）を契機待ちに置いたのは読みが割れうる点。
  2026-10-08夜、ユーザー判断: 当面、分解はClaudeが行い、枝番を付けた子taskの登録はCodexへ依頼する（今日の`RBT-017`と同じ流れ）。
  graph DBで子taskを持つ案は、Codexへ伝えられないので見送り。
- `GRAPH-005`: 共有面はtrackedな`GRAPH_DB_EXCHANGE.md`を使う（2026-10-07、ユーザー了承）。
- 10/10以降: task fit協議を予定（ユーザー）。この一時的な主担当の役割はその時点で見直す。
