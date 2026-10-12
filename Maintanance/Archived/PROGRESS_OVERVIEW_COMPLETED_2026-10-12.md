# Task Registry completed history — 2026-10-12

This file preserves task rows and precedence edges removed when the active Registry was compressed.
Detailed evidence remains in each row's canonical document. IDs remain permanent and must not be reused.
Earlier snapshots and completed-history files remain unchanged.

## Completed and excluded tasks

| ID | 状態 | 担当 | 項目 | 再開・完了条件 | 詳細正本 |
| --- | --- | --- | --- | --- | --- |
| `OPS-002` | `DONE` | User / Codex | [DISCOVERY] Codex task運用playbookの改訂 | task分解、必須依存の発見、runtime停止、判断削減、受入境界をV2へ再構成して現行正本に採用。graph追試から、依存根拠、未確定Flow、`EXCLUDED`時の再評価を反映し、2026-10-12の再レビューで修正必須なしを確認 | `Orientation/CODEX_TASK_OPERATION_PLAYBOOK_V2.md` / `Graph/AI_GRAPH_RETROSPECTIVE_REPLAY.md` |
| `OPS-008` | `DONE` | User / Codex | [DECISION] 旧Codex task運用playbookのアーカイブ判断 | 2026-10-12、現行正本V2への参照切替を維持したまま、ユーザー判断により旧版をArchivedへ移動 | `Archived/Orientation/CODEX_TASK_OPERATION_PLAYBOOK_V1.md` / `Orientation/CODEX_TASK_OPERATION_PLAYBOOK_V2.md` |
| `OPS-003` | `DONE` | Codex | [EXECUTION] タスク依存変化による作業中停止の明文化 | 実行中も依存関係とreadyを再評価し、新しい必須前提、Flow、完了条件、および委任権限に応じて停止範囲を導く原則を独立文書へ記録 | `Orientation/TASK_DEPENDENCY_RUNTIME_STOP.md` |
| `OPS-004` | `DONE` | Codex | [EXECUTION] タスク分解と再構成の明文化 | 見えない作業から本質的判断を抽出し、task境界、依存、Flow、ready集合、優先順を再構成する原則を独立文書へ記録し、ユーザー指示により完了 | `Orientation/TASK_DECOMPOSITION_AND_REORGANIZATION.md` |
| `OPS-005` | `DONE` | Codex | [EXECUTION] AI task process posterの更新 | 完了した分解・再構成文書と作業中停止文書を入力に、判断整理、task境界、graph再構成、ready、委任を中心とするV2へ生成script、SVG、PNGを更新し、ユーザーが受入 | `AI_TASK_PROCESS_POSTER.png` / `Utilities/Maintenance/GenerateAITaskProcessPoster.py` |
| `OPS-006` | `DONE` | Codex | [EXECUTION] task依存判断の軽量draft | 後続taskの成立に現在欠けている前提を探し、依存の見落としによる破綻・片手落ち・手戻りを避けるための短い観点整理を独立文書へ記録し、ユーザーレビューで修正必須なしを確認。文書はdraftのまま維持 | `Orientation/TASK_DEPENDENCY_IDENTIFICATION_DRAFT.md` |
| `OPS-007` | `DONE` | Codex | [EXECUTION] AI task process poster V2への依存発見反映 | V2の構造を維持したまま、後続の成立条件、欠けた必須前提、並行依存、未確定候補を入口へ追加し、生成script、SVG、PNGを上書き。ユーザーが受入 | `AI_TASK_PROCESS_POSTER.png` / `Utilities/Maintenance/GenerateAITaskProcessPoster.py` |
| `PERM-047` | `EXCLUDED` | Claude | [DISCOVERY] runtime-check View版Permutationの旧Test as Specification・実験test棚卸し | 2026-10-12、ユーザー判断により詳細棚卸しは行わず、現行の有効testが通ることだけを暫定確認。Debug・Releaseとも手動列挙2件と失効Death Test 2件が成功した。将来の正式品質再評価で必要になった場合は、その時点の契約から別途task化する | `PermutationModule/BorrowedPermutationTestPlan.md` / `Sources/PermutationModule/Documentation/Quality-Profile.md` |
| `PERM-048` | `DONE` | Codex | [EXECUTION] Swift 6.2互換runtime-check View通常経路の成立確認 | 単一bufferと共有`GateKeeper`の世代番号で旧Viewを失効させる通常実装へ切替。Swift 6.2 strict typecheck・列挙実行、Swift 6.4 Debug／Release build、次回`next()`後・所有者破棄後のtrapを確認。5-cycle測定は28要素で21.61ms対C++ 19.24ms、32要素で66.39ms対61.24ms。Span版は無効化した特殊経路へ退避 | `PermutationModule/CurrentQualityAssessment.md` / `PermutationModule/NextPermutationsImplementationExploration.md` / `Sources/PermutationModule/NextPermutations.swift` / `Sources/PermutationModule/BorrowedNextPermutations.swift` |
| `PERM-049` | `DONE` | Codex | [DISCOVERY] 実提出チューニング成果の製品候補への収束 | DSU再利用・単一`unite`・反復leaderを提出固有最適化へ分離し、GateKeeper除去とpointer直接取得をunsafeな上限実験として製品候補から除外。runtime-check付きViewへ戻したSwift 6.4 Releaseの7回測定は各構成とも中央値0.46秒で、今回の探索を理由とする製品source変更なしと確定 | `PermutationModule/HumanAITuningReport.md` / `PermutationModule/CurrentQualityAssessment.md` / `Maintanance/User/PermutationBorrowedSpanExperiment.swift` |
| `PERM-050` | `DONE` | Codex | [EXECUTION] Swift 6.4 borrowed Span版の別名有効化 | `#if compiler(>=6.4)`で有効化し、一般向け`nextPermutations()`と競合しない`borrowedNextPermutations()`／`BorrowedNextPermutations`へ改名。アルゴリズムと借用契約は変更せず、現行runtime-check版と同時のRelease build成功を確認 | `Sources/PermutationModule/BorrowedNextPermutations.swift` / `PermutationModule/NextPermutationsImplementationExploration.md` |
| `OPT-047` | `DONE` | Codex | [DISCOVERY] OptionalArray 0.6.0現行品質アセスメント | Debug・Release・ASan各通常35件・Death Test 26件、facade、DocC、buildを確認。View寿命とstrict memory safetyを未達、`Sendable`・`-Ounchecked`・性能・利用Validationを未検証として分離し、品質評価から新しいユーザー判断は発生しないと確認 | `OptionalArrayModule/CurrentQualityAssessment.md` / `Sources/OptionalArrayModule/Documentation/Quality-Profile.md` |
| `OPT-049` | `DONE` | Codex | [DISCOVERY] OptionalArray多次元access性能測定設計 | 2D・3Dのcold miss/storeとwarm hit、BareArrayと共通のexact-product shape・連続走査・checksum、計測境界、後続のC++ nested vector番兵版への対応を確定 | `OptionalArrayModule/CurrentQualityAssessment.md` |
| `OPT-050` | `DONE` | Codex | [EXECUTION] OptionalArray access性能のCI回帰Benchmark登録 | 2D・3Dのcold / warm memoization checksum 4件をbenchmark toolと通常CI libraryへ登録。Release build、size 1・3・16の3反復、`CI.json`の30 task・60 size・64kまでのcurrent実行が成功 | `OptionalArrayModule/CurrentQualityAssessment.md` |
| `OPT-051` | `DONE` | Codex | [EXECUTION] OptionalArrayアセスメント用C++番兵workload登録 | Swift版と同じexact-product shape・cold / warm memoization・checksumの2D・3D 4件をnested `vector<intptr_t>`と`-1`番兵で実装。Release buildとsize 1・3・16の3反復が成功し、通常CIには未登録 | `OptionalArrayModule/CurrentQualityAssessment.md` |
| `ARRAY-002` | `DONE` | Codex | [DISCOVERY] Array系object名のCodex独立候補出し | BareArray／OptionalArrayの役割から3組のbase名、次元suffix、View派生名、懸念を順位付けせず提出 | `User/ARRAY_NAMING_CANDIDATES_CODEX.md` / `ArrayObjectAndAPINamingDraft.md` |
| `ARRAY-008` | `DONE` | User | [DISCOVERY] Array系object名のユーザー独立候補出し | `BareElements`／`OptionalCache`を順位付け前の候補として提出。method名は現行familyだけを候補とする | `User/ARRAY_NAMING_CANDIDATES_USER.md` / `ArrayObjectAndAPINamingDraft.md` |
| `ARRAY-003` | `DONE` | Claude | [DISCOVERY] Array系object名のClaude独立候補出し | 他者候補を読む前に5組のbase名、次元suffix、View派生名、意図、懸念を順位付けせず提出 | `User/ARRAY_NAMING_CANDIDATES_CLAUDE.md` / `ArrayObjectAndAPINamingDraft.md` |
| `ARRAY-004` | `DONE` | Codex / Claude | [DISCOVERY] Array系object名候補の統合・順位付け | 三者の独立候補を統合し、役割、call-site、体系、互換性、過剰な意味付けを基準に順位draftを作成。2026-10-12、ユーザー指示によりレビューを受け入れた | `User/ARRAY_NAMING_RANKING_CODEX.md` / `ArrayObjectAndAPINamingDraft.md` |
| `BARE-006` | `DONE` | Codex | [DISCOVERY] BareArray多次元access性能測定設計 | 2D・3Dのsequential read / write、総要素数が等しいshape、計測内外、checksum、C++ nested `vector<intptr_t>`との対応、CI回帰とmacOS外部assessmentの境界を確定 | `BareArrayModule/CurrentQualityAssessment.md` / `Tests/TESTING.md` |
| `BARE-029` | `DONE` | Codex | [EXECUTION] BareArray access性能のCI回帰Benchmark登録 | 2D・3D sequential read / writeの4 workloadをbenchmark toolと通常CI libraryへ登録。Release build、size 1・3・16の直接実行、`CI.json`の26 task・60 size・64kまでのcurrent実行が成功 | `BareArrayModule/CurrentQualityAssessment.md` |
| `BARE-030` | `DONE` | Codex | [EXECUTION] BareArrayアセスメント用C++ nested vector workload登録 | Swift版と同じexact-product shape・連続走査・checksumの2D・3D read / write 4件をnested `vector<intptr_t>`で実装。Release buildとsize 1・3・16の3反復が成功し、通常CIには未登録 | `BareArrayModule/CurrentQualityAssessment.md` |
| `BARE-031` | `DONE` | Codex | [DISCOVERY] BareArray macOS外部性能アセスメントへのアレンジ | 3系列を含む専用library、生JSON、4枚のPNG chartに加え、commit・macOS・hardware・Swift・Clangを同一測定IDで保存するscriptを整え、正式測定へ渡せる構成を閉じた | `BareArrayModule/CurrentQualityAssessment.md` / `Sources/BareArrayModule/Documentation/Quality-Profile.md` |
| `BARE-033` | `EXCLUDED` | Codex | [EXECUTION] 新BareArray workloadの0.5.3 baseline比較経路 | harness全体の同期は0.5.3にないPermutation APIへ依存してCI失敗し、BareArrayだけの移植も初回基準のために過去harnessを特別扱いする複雑性を生むため除外。merge commitを新baselineとする | `Tests/TESTING.md` / `.github/workflows/ci.yml` / `.github/workflows/candidate.yml` |
| `BARE-034` | `DONE` | User | [DECISION] BareArrayの提供停止と保守継続 | 利用者への提供を停止する一方、実装・仕様・test・benchmark・安全性を保守対象として残す方針を決定 | `Sources/BareArrayModule/Documentation/Quality-Profile.md` |
| `PERF-001` | `DONE` | Codex | [EXECUTION] baseline harness同期の取り消し | commit `1027a154`のSources・manifest・resolved同期をPR用とcandidate用の両workflowから取り消し、従来のlibrary定義の同期だけに戻した | `Tests/TESTING.md` / `.github/workflows/ci.yml` / `.github/workflows/candidate.yml` |
| `PERF-002` | `DONE` | Codex | [EXECUTION] BareArray・OptionalArray初回性能baseline候補の完了ゲート | 両module合計8件のSwift workloadをPR #189で先にmergeし、そのmerge commitを初回baselineとした。通常CI library登録は後続PRへ分離し、0.5.3へ存在しないworkloadとの比較を要求しない境界を成立させた | `Tests/TESTING.md` / `BareArrayModule/CurrentQualityAssessment.md` / `OptionalArrayModule/CurrentQualityAssessment.md` |
| `PERF-003` | `DONE` | Codex | [EXECUTION] Array性能baseline確立後の回帰CI確認 | workload実装を含むPR #189のmerge後、CI library登録だけのPR #190と後続PR #191で、両moduleのworkloadを含むperformance jobがgreenとなり、通常のbase / current回帰比較が機能することを確認 | `Tests/TESTING.md` / `.github/workflows/ci.yml` |
| `BARE-016` | `DONE` | Codex | [DISCOVERY] BareArray現行品質アセスメント | Quality Profileの現在性監査、QR-01〜QR-06の現行評価、実行記録、既存課題と新規Validation候補への不足分離を完了 | `BareArrayModule/CurrentQualityAssessment.md` / `Sources/BareArrayModule/Documentation/Quality-Profile.md` |
| `BARE-019` | `EXCLUDED` | User / Codex | [DECISION] 同一BareArray間writebackのコンパイル時拒否採否 | 2026-10-11、拒否契約自体は従来から不変で、実行時Death Testからコンパイル時診断へVerification手段だけが移ったと確認。製品判断ではなかったため除外 | `BareArrayModule/CurrentQualityAssessment.md` |
| `BARE-023` | `DONE` | Codex | [DISCOVERY] BareArray storage境界の成立確認 | `@safe`分類とノンエスケーパブルViewにより再設計候補の前提が解消し、連続配置・O(1) access・ノンコピーViewを担う現行storage境界を維持すると確認 | `BareArrayModule/CurrentQualityAssessment.md` / `StrictMemorySafetyReadiness.md` |
| `BARE-024` | `DONE` | User / Codex | [DECISION] BareArray公開7型の`@safe`／`@unsafe`分類 | 所有型4・ノンエスケーパブルView型3を`@safe`に分類して実装し、strict warning解消とDebug・Release・compiler診断fixtureの回帰成功を確認 | `BareArrayModule/CurrentQualityAssessment.md` / `StrictMemorySafetyReadiness.md` |
| `BARE-025` | `DONE` | Codex | [DISCOVERY] BareArray strict memory safety適用の成立確認 | 公開7型の`@safe`分類後、`.strictMemorySafety()`有効状態でwarningがなく、既存検証も成功するため、採否をユーザーへ返す本質的判断は残らず、品質検証の対象として維持すると確認 | `BareArrayModule/CurrentQualityAssessment.md` / `StrictMemorySafetyReadiness.md` |
| `BARE-026` | `DONE` | User | [DECISION] BareArray品質検証の再開判断 | 2026-10-11、0.6.0品質として、完了したstorage、安全性分類、strict memory safetyの3系統を前提に品質検証を再開すると決定 | `BareArrayModule/CurrentQualityAssessment.md` |
| `BARE-027` | `DONE` | Codex | [EXECUTION] BareArrayノンエスケーパブル化の品質検証 | 0.6.0品質としてDebug・Release・ASan・compiler診断fixture・facade・DocCを検証し、View寿命とstrict memory safetyを確認済み、並行利用・`-Ounchecked`・利用Validation・外部性能を未検証として分離 | `BareArrayModule/CurrentQualityAssessment.md` / `Sources/BareArrayModule/Documentation/Quality-Profile.md` |
| `ARRAY-001` | `EXCLUDED` | Codex | [DISCOVERY] Array系storage・View寿命・strict安全性の再分解 | BareArrayのView寿命はノンエスケーパブル化へ統合し、残るstorage、公開安全性分類、strict memory safetyを独立taskへ分解したため、包括taskとしては除外。OptionalArrayは必要時に別途再分解する | `StrictMemorySafetyReadiness.md` |

## Completed precedence edges

| 後続task | 前提task | Flow | 制約 |
| --- | --- | --- | --- |
| `OPS-008` | `OPS-002` | `SEQUENCE` | V2を現行正本として採用した後にだけ、旧版の配置を判断する |
| `BARE-029` | `BARE-006` | `SEQUENCE` | workload設計後、まずSwift側を通常CIの回帰検知へ追加する |
| `OPT-049` | `BARE-006` | `SEQUENCE` | BareArrayで確定したshape・計測境界を再利用し、外部assessmentの完了を待たずOptionalArray固有のmemoization accessを設計する |
| `BARE-031` | `BARE-030` | `SEQUENCE` | Swift／C++両workloadの成立後、macOSアセスメント用にアレンジして暫定実測する |
| `BARE-032` | `BARE-031` | `SEQUENCE` | 暫定結果を確認してから、必要な性能比上限を判断する |
| `OPT-050` | `OPT-049` | `SEQUENCE` | workload設計後、まずSwift側を通常CIの回帰検知へ追加する |
| `PERF-002` | `PERF-001` | `PARALLEL_JOIN` | baseline harness移植を取り消し、意図した初回導入の赤と実装不具合を区別できる状態で合流する |
| `PERF-002` | `BARE-029` | `PARALLEL_JOIN` | BareArrayのSwift workloadとCI library登録を初回baseline候補へ合流する |
| `PERF-002` | `OPT-050` | `PARALLEL_JOIN` | OptionalArrayのSwift workloadとCI library登録を初回baseline候補へ合流する |
| `PERF-003` | `PERF-002` | `SEQUENCE` | 初回baseline候補のmerge後に、後続PRで通常のbase / current回帰比較を確認する |
| `BARE-030` | `BARE-029` | `SEQUENCE` | BareArrayのCI workload成立後、同じ条件のC++対応workloadを外部比較用に追加する |
| `OPT-051` | `OPT-050` | `SEQUENCE` | OptionalArrayのCI workload成立後、同じ条件のC++番兵workloadを外部比較用に追加する |
| `OPT-052` | `OPT-051` | `SEQUENCE` | Swift／C++両workloadの成立後、macOSアセスメント用にアレンジして暫定実測する |
| `BARE-026` | `BARE-023` | `PARALLEL_JOIN` | 現行storage境界の成立確認後に品質検証の再開を判断する |
| `BARE-026` | `BARE-024` | `PARALLEL_JOIN` | 公開7型の安全性分類を決定してから品質検証の再開を判断する |
| `BARE-026` | `BARE-025` | `PARALLEL_JOIN` | strict memory safety適用の成立確認後に品質検証の再開を判断する |
| `BARE-027` | `BARE-026` | `SEQUENCE` | ユーザーが再開を決定した場合だけ、確定した前提で品質検証を実行する |
| `BARE-018` | `BARE-027` | `SEQUENCE` | 品質検証の結果を受け入れてからノンエスケーパブル化の完了を判定する |
| `BARE-028` | `BARE-027` | `SEQUENCE` | 現行品質検証を基準に、Claudeの手直し受入後の変更影響を再検証する |
| `PERM-047` | `PERM-049` | `SEQUENCE` | 製品候補の実装境界を定めてから、その契約と実装を対象に旧Test as Specificationと実験testを棚卸しする |
| `PERM-051` | `PERM-050` | `SEQUENCE` | Span版の公開名、compiler条件、および現行版との共存を成立させてから、新しい借用契約をTest as Specificationへ固定する |
| `ARRAY-004` | `ARRAY-002` | `PARALLEL_JOIN` | Codexの独立候補を統合・順位付けの入力にする |
| `ARRAY-004` | `ARRAY-008` | `PARALLEL_JOIN` | ユーザーの独立候補を統合・順位付けの入力にする |
| `ARRAY-004` | `ARRAY-003` | `PARALLEL_JOIN` | Claudeの独立候補を統合・順位付けの入力にする。ユーザー候補も揃うまで開始しない |
