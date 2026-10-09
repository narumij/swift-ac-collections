# 開発・メンテナンス進捗一覧（2026-10-07アーカイブ前スナップショット）

最終更新: 2026-10-07 / Codex

## 対象期間と読み方

Index / lazy tie周辺の再設計、赤黒木のテスト再編、公開文書整備が本格化した
2026-09-25頃から現在までの主要タスクを成果単位でまとめる。

細かなコミット数ではなく、現在の判断に必要な状態を記録する。

この文書のTask Registryを、CodexとClaudeが作業を再開するときの唯一の入口とする。まずRegistry
だけを読み、選択したtask行が示す詳細正本だけを追加で読む。全管理文書やArchivedを開始時に
横断しない。

## Task registry

この表を作業状態、担当、再開条件の正本とする。後続のチェックリストと各詳細文書は、証拠と
内訳を保持するためのものであり、この表と食い違う場合は本表を優先する。

**現在の律速:** 外部（`swift-collections` ContainersPreviewの`Container.Index`要件）。
Index契約とそれに関わる残taskは、この外部条件が安定するまで最終確定できない。ユーザー判断で
解消できるtaskは現在ない。

| ID | 状態 | 担当 | 項目 | 再開・完了条件 | 詳細正本 |
| --- | --- | --- | --- | --- | --- |
| `RBT-001` | `WAITING_EXTERNAL` | User / Codex | Index完了ゲート | 公開Index表現・完了範囲と`Comparable`採否を確定し、Index契約全体を閉じる | `RED_BLACK_TREE_REMAINING_TASKS.md` |
| `RBT-010` | `WAITING_EXTERNAL` | User / Codex | Index完了ゲートのうち公開Index表現と完了範囲 | Container要件の安定後、公開Indexと内部`SealError`の分離、1.0での完了範囲を決定 | `RED_BLACK_TREE_REMAINING_TASKS.md` |
| `RBT-011` | `WAITING_EXTERNAL` | User / Codex | Indexの`Comparable`採否 | `swift-collections`の要件が安定または正式化した後、互換性を再評価して決定 | `RED_BLACK_TREE_REMAINING_TASKS.md` |
| `RBT-002` | `DONE` | User / Codex / Claude | Index-range `erase`の空guard | 2026-10-06、範囲検査を維持して空での不要なCoWを回避（`11817dfe`） | `RED_BLACK_TREE_REMAINING_TASKS.md` |
| `DOC-001` | `DONE` | Codex / Claude | P10残存記述確認 | 2026-10-06、監査と必要箇所の同期を完了（`9b0f42d5`） | `MAINTENANCE.md` |
| `GRAPH-001` | `ACTIVE` | Claude | Claude用task graph DBの独立試験 | 現行Registryとのready判定一致を確認しながら試験運用を継続 | `Graph/TASK_GRAPH_DB_EXPERIMENT.md` |
| `GRAPH-002` | `FROZEN` | Codex | Codex用task graph DBの独立試験 | Codexのcontext reset後、ユーザーが明示的に再開 | `Graph/TASK_GRAPH_DB_EXPERIMENT.md` |
| `GRAPH-003` | `FROZEN` | User / Codex / Claude | 二つのtask graph DBの統合議論 | 両試験の完了後、ユーザーが明示的に再開 | `Graph/TASK_GRAPH_DB_EXPERIMENT.md` |
| `GRAPH-004` | `ACTIVE` | Claude | AIとgraph DBによるrefactoring smellの独立試験 | 専用ノートをClaudeが自由編集し、観測・仮説・反証・再利用可能な判断基準を継続記録 | `AI_GRAPH_REFACTORING_SMELL_NOTES.md` |
| `RBT-003` | `DONE` | Codex / Claude | `Result`のpublic比較overloadとpublic `_NodePtr` | 2026-10-07、公開面縮小と検証を完了。performance job成功を確認（run 37502938888、job 112404281751） | `EXTERNAL_TYPE_EXTENSION_AUDIT.md` |
| `RBT-004` | `FROZEN` | Codex | Debug限定Comparable群・Balanced群 | Index契約またはexecutable API Matrix方針の確定後 | `EXTERNAL_TYPE_EXTENSION_AUDIT.md` |
| `RBT-005` | `FROZEN` | Codex | Memoize群の公開終了／正式API化 | 外部consumer 2件の移行後 | `EXTERNAL_TYPE_EXTENSION_AUDIT.md` |
| `RBT-006` | `FROZEN` | User / Codex | 未結線コードの個別削除 | ユーザーが対象を個別指定 | `RED_BLACK_TREE_REMAINING_TASKS.md` |
| `TEST-001` | `FROZEN` | User / Codex | 無効化・歴史的テストコードの処遇 | ユーザーが対象を個別指定 | `Tests/TESTING.md` |
| `TEST-002` | `FROZEN` | Codex | stride assertion／fixture alignmentの任意改善 | 実害または明示的な再開指示 | `Tests/TESTING.md` |
| `PERM-001` | `FROZEN` | Codex | AtCoder 2025互換mode | ユーザーが明示的に再開 | `PermutationModule/AtCoder2025CompatibilityPlan.md` |
| `PERM-002` | `USER_ONLY` | User | ABC328E実提出確認 | ユーザーが手作業で実施 | `PermutationModule/ImplementationPlan.md` |
| `PERM-003` | `FROZEN` | Claude | 現行Permutation契約の基準固定 | 本taskの明示的な再開後、互換modeから独立して現行API・通常test・旧unsafe API非露出を基準化 | `PermutationModule/AtCoder2025CompatibilityPlan.md` |
| `PERM-004` | `FROZEN` | Codex | AtCoder 2025互換ソースの隔離 | 基準版を専用fileへ配置し、通常版と排他的にcompileできる状態にする | `PermutationModule/AtCoder2025CompatibilityPlan.md` |
| `PERM-005` | `FROZEN` | Codex | Permutation互換traitのPackage設定 | 互換defineをtraitへ接続し、traitなしを通常版の既定にする | `PermutationModule/AtCoder2025CompatibilityPlan.md` |
| `PERM-006` | `FROZEN` | Codex | 互換modeのTest as Specification | 列挙順・重複・safe CoW・unsafe aliasing・境界を基準refに対して固定 | `PermutationModule/AtCoder2025CompatibilityPlan.md` |
| `PERM-007` | `FROZEN` | Codex | 両modeのAcCollections再公開検証 | 通常・互換の期待APIをAcCollections経由でcompile・test | `PermutationModule/AtCoder2025CompatibilityPlan.md` |
| `PERM-008` | `FROZEN` | Codex | Permutation互換CIの分離 | 通常版と互換版を別jobとして表示し、結果を混在させない | `PermutationModule/AtCoder2025CompatibilityPlan.md` |
| `PERM-009` | `FROZEN` | Codex | AtCoder単一file生成とローカル検証 | 互換版から自己完結fileを生成し、ABC328E相当入力で検証 | `PermutationModule/AtCoder2025CompatibilityPlan.md` |
| `PERM-010` | `FROZEN` | Codex | Permutation互換mode文書同期 | 通常APIと互換APIを混同せず、trait・制限・検証方法を文書化 | `PermutationModule/AtCoder2025CompatibilityPlan.md` |
| `OPT-001` | `FROZEN` | Codex | OptionalArrayの体系監査・名称再検討 | ユーザーが明示的に再開 | `Tests/TESTING.md` |
| `BARE-001` | `FROZEN` | Codex | BareArrayの体系監査・名称再検討 | ユーザーが明示的に再開 | `Tests/TESTING.md` |
| `ARRAY-001` | `FROZEN` | User / Codex | BareArray／OptionalArrayのstorage再設計とstrict恒久適用 | 公開unsafe境界を決定して再開 | `StrictMemorySafetyReadiness.md` |
| `RBT-007` | `FROZEN` | User / Codex | RedBlackTreeCollectionsのstrict memory safety全面適用 | ユーザーが段階3を承認 | `StrictMemorySafetyReadiness.md` |
| `BENCH-001` | `FROZEN` | Codex | SortedCollectionsとのpublishableな大規模比較 | ユーザーが明示的に再開 | `Maintanance/Archived/SORTED_COLLECTIONS_BENCHMARK_TASK.md` |
| `TEST-003` | `FROZEN` | Codex | randomized trace失敗時の自動縮小 | 実害または明示的な再開指示 | `Sources/RedBlackTreeCollections/Documentation/Cpp-Matrix.md` |
| `RBT-008` | `FROZEN` | User / Codex | `lazyDetach`等の並行初期化保証 | concurrency契約を扱う明示的な再開指示 | `RED_BLACK_TREE_REMAINING_TASKS.md` |
| `PERF-001` | `FROZEN` | Codex | Swift更新後のCoWコード生成再計測 | Swift更新または明示的な再計測指示 | `PERFORMANCE_REGRESSION_BISECTION.md` |
| `HIST-001` | `FROZEN` | Codex | unsafe移行史の追加調査 | ユーザーが明示的に再開 | `REFACTORING_FROM_ATCODER_2025.md` |
| `TEST-004` | `FROZEN` | Codex | 原木Fixtureの追加portable化 | 実害または明示的な再開指示 | `Tests/TESTING.md` |
| `RBT-009` | `FROZEN` | User / Codex | runtime-check実装の再審査 | 1.0判断直前、または`-Ounchecked`が主要構成と判明 | `Sources/RedBlackTreeCollections/Documentation/Design/Design-RuntimeChecks.md` |
| `QUALITY-001` | `FROZEN` | User / Codex | 汎用基盤ライブラリとしての1.0採用品質ゲート | Index契約確定後、ユーザーが明示的に再開 | `Sources/RedBlackTreeCollections/Documentation/Quality-Checklist.md` |
| `CPP-001` | `DONE` | Codex / Claude | C++挙動比較 | 比較契約または対象環境を変更する場合だけ更新 | `Sources/RedBlackTreeCollections/Documentation/Cpp-Matrix.md` |
| `CPP-002` | `EXCLUDED` | — | MSVC STLとのC++挙動比較 | 現行計画では実施しない | `Sources/RedBlackTreeCollections/Documentation/Cpp-Matrix.md` |

### Task precedence

Task Registryの状態は、通常の再開判断に使う計算済みの表示である。次の辺リストは、内部taskの
厳密な順序制約を保持し、状態の監査とトポロジカルソートに使う。

| 後続task | 前提task | 制約 |
| --- | --- | --- |
| `RBT-001` Index完了ゲート | `RBT-010` 公開Index表現と完了範囲 | 前提taskの完了後に後続taskを完了できる |
| `RBT-001` Index完了ゲート | `RBT-011` `Comparable`採否 | 前提taskの完了後に後続taskを完了できる |
| `QUALITY-001` 1.0採用品質ゲート | `RBT-001` Index完了ゲート | 前提taskの完了後に着手候補にできる |
| `GRAPH-003` task graph DB統合議論 | `GRAPH-001` Claude独立試験 | 前提taskの完了後に着手候補にできる |
| `GRAPH-003` task graph DB統合議論 | `GRAPH-002` Codex独立試験 | 前提taskの完了後に着手候補にできる |
| `PERM-004` AtCoder 2025互換ソースの隔離 | `PERM-003` 現行Permutation契約の基準固定 | 前提taskの完了後に着手できる |
| `PERM-005` Permutation互換traitのPackage設定 | `PERM-004` AtCoder 2025互換ソースの隔離 | 前提taskの完了後に着手できる |
| `PERM-006` 互換modeのTest as Specification | `PERM-005` Permutation互換traitのPackage設定 | 前提taskの完了後に着手できる |
| `PERM-007` 両modeのAcCollections再公開検証 | `PERM-006` 互換modeのTest as Specification | 前提taskの完了後に着手できる |
| `PERM-008` Permutation互換CIの分離 | `PERM-006` 互換modeのTest as Specification | 前提taskの完了後に着手できる |
| `PERM-009` AtCoder単一file生成とローカル検証 | `PERM-007` 両modeのAcCollections再公開検証 | 前提taskの完了後に着手できる |
| `PERM-010` Permutation互換mode文書同期 | `PERM-007` 両modeのAcCollections再公開検証 | 前提taskの完了後に着手できる |
| `PERM-010` Permutation互換mode文書同期 | `PERM-008` Permutation互換CIの分離 | 前提taskの完了後に着手できる |
| `PERM-010` Permutation互換mode文書同期 | `PERM-009` AtCoder単一file生成とローカル検証 | 前提taskの完了後に着手できる |
| `PERM-001` AtCoder 2025互換mode | `PERM-010` Permutation互換mode文書同期 | 前提taskの完了後に後続taskを完了できる |

ここには必須のAND前提だけを記録する。外部条件は各taskの状態と再開・完了条件、選択肢や
OR条件は詳細正本で扱う。必須前提が増えた場合は辺を追加し、循環が生じる場合はtask境界または
未確定の設計判断を見直す。

### Registry rules

- IDは作成後に変更・再利用しない。分類や状態が変わってもIDを維持する。
- 状態は`ACTIVE`、`WAITING_USER`、`WAITING_EXTERNAL`、`FROZEN`、`USER_ONLY`、`EXCLUDED`、
  `DONE`、`ARCHIVED`のいずれかとする。
- 状態語はAIの管理用であり、ユーザーが名称を覚えたり指定したりする必要はない。Codexが
  ユーザーの通常の言葉を対応する状態へ翻訳して記録する。
- 固定Task IDもAIの管理用とし、通常のユーザー向け報告では表示も指定要求もしない。項目名と、
  分量のある報告で必要になる一時的な会話参照IDを優先する。固定IDはユーザーが求めた場合、または
  文書・sessionをまたぐ実際の曖昧さを解消する場合だけ示す。
- `FROZEN`は明示的な再開指示なしに着手しない。
- `USER_ONLY`はユーザー専任とし、AIは着手、代行、催促を行わない。
- `EXCLUDED`は実施対象外であり、再開候補として扱わない。
- `DONE`を履歴資料へ移した場合だけ`ARCHIVED`へ変更する。
- `WAITING_EXTERNAL`は外部条件が解消するまで着手可能とみなさない。外部条件の詳細と過去の観測は
  task行の詳細正本で管理し、Task Registry表の各行へ依存列を追加しない。
- Task precedenceは内部task間の必須順序だけを保持する。Task Registryの状態を更新するときは
  辺リストとの整合を確認するが、通常の再開報告では計算済みの状態を優先して提示する。
- 前提taskが待機中で後続taskの着手または確定を止める場合、その影響を後続taskの状態にも反映する。
  通常の再開判断で、AIに毎回辺リストから着手可否を導出させない。
- 同じ条件が複数taskを止めている場合、Task Registry表の直前に`現在の律速`として明示する。
  律速が変わるか解消した時点で、記述と影響を受けるtaskの状態を同時に更新する。
- 会話参照IDの`A-1`等は一時座標であり、この固定IDとは分離する。
- 優先順位は、ユーザーの最新指示、Task Registry、task行が示す詳細正本、Archivedと過去ログの
  順とする。食い違いを見つけても、古い記述だけを根拠にtaskを再開しない。
- Task Registryの確定更新はCodexが担当する。Claudeは自分のhandoffを更新し、Registryの変更が
  必要な場合は具体的な差分案を残す。

## 状態表示

| 状態 | 意味 |
| --- | --- |
| `ACTIVE` | AIが次の作業として着手可能 |
| `WAITING_USER` | ユーザー判断または設計判断が必要 |
| `WAITING_EXTERNAL` | repository内の判断だけでは解消できない外部条件を待っている |
| `FROZEN` | 明示的な再開指示が必要 |
| `USER_ONLY` | ユーザー専任。AIは着手・代行・催促しない |
| `EXCLUDED` | 実施対象外。再開候補にも含めない |
| `DONE` | 完了。現役の正本を維持 |
| `ARCHIVED` | 完了し、履歴資料へ移動済み |

## 全体サマリー

| 領域 | 状態 | 現在地 |
| --- | --- | --- |
| RedBlackTreeの基本正当性 | 完了 | 4型の参照モデルfuzz、不変条件、原木層、C++比較まで完了 |
| RedBlackTreeの公開設計 | 進行中 | 公開面の縮小とIndex契約が最後の大きな設計課題 |
| C++挙動比較 | 完了・追加検証可 | 正本のLLVM libc++で4型・35テスト成功。libstdc++は参考比較成功。MSVCは実施対象外 |
| テスト基盤 | 完了・整理余地あり | Death Test、寿命検査、専用fixture/targetを整備済み |
| RedBlackTreeの利用者向け文書 | 大部分完了・設計同期待ち | 4型ガイド、DocC、API Matrix、Design文書を整備。公開面とIndex設計の確定後に最終同期する |
| 非RedBlackTreeのコメントドック | 部分完了 | Permutationは区切り完了・独立確認待ち。OptionalArrayは重要契約のみ更新済み、BareArrayは体系監査未完 |
| 品質証拠・利用検討資料 | 完了・更新継続 | 世界順位ではなく、利用を検討するための検証済み証拠・制限・未検証事項へ再構成 |
| SortedCollections比較 | 保留 | Phase 3 pilotまで完了。公開可能な大規模計測は延期 |
| PermutationModule | 現行modeは大部分完了・互換mode未着手 | API整理、strict memory safety、Sendable、性能検証は完了。AtCoder 2025互換modeは計画のみ |
| BareArray / OptionalArray | 段階対応完了・恒久適用保留 | 寿命・境界・Death Testを強化。strict全面適用はstorage設計待ち |

## 完了した主要タスク

### RedBlackTreeの実装・不具合修正

- [x] lazy tie、sealed pointer、tracking tag、recycle countを使うIndex安全化経路を構築
- [x] stale / recycled / detached Indexをraw pointer参照前に拒否する経路を整備
- [x] CoWで分岐した木の対応nodeへIndexを解決する経路と世代検査を整備
- [x] MultiMapの`index(inserting:)`がunique挿入を呼んでいた不具合を修正
- [x] hint挿入の`endIndex`条件で発生したMultiSet不具合を差分テストから発見・修正
- [x] 空・未発見の削除系操作で不要なCoWを起こす複数経路を横断修正
- [x] Range View、Mapped Values View、4コンテナへ関連修正を横展開
- [x] `unranged()`と専用protocol群を削除
- [x] 4コンテナのDecodableで未整列・重複入力を正しく処理するよう修正し、回帰testを追加

### RedBlackTreeのテスト再編

- [x] Set / MultiSet / Dictionary / MultiMapの連番Test as Specificationを整理
- [x] KeyOnly / KeyValue Range ViewとBoundExpressionの仕様テストを整理
- [x] 4型のfuzz testを参照モデル比較と操作ごとの木の不変条件検査へ統合
- [x] MultiSet / MultiMapの部分比較を全要素比較へ強化
- [x] Index世代、slot再利用、CoW後のIndex寿命を4型とViewへ展開
- [x] `elementsEqual(_:)` / `lexicographicallyPrecedes(_:)`を4型とViewへ展開
- [x] raw treeを専用test targetへ分離し、通常到達可能行を確認
- [x] UnsafeNode / RawBufferのメモリレイアウトと世代・recycle poolを直接検証
- [x] 原木テストから非ポータブルなbucket依存を分離
- [x] 空コレクション共有singletonの4型共通契約を検証

### C++挙動比較

- [x] Set / `std::set`
- [x] MultiSet / `std::multiset`
- [x] Dictionary / `std::map`
- [x] MultiMap / `std::multimap`
- [x] 固定seed `[1, 2, 3, 0x5EED, 0xC0FFEE]`、各300操作のtrace比較
- [x] 正本であるmacOS / LLVM libc++でDebug・Release成功
- [x] 参考情報としてLinux / GNU libstdc++でDebug成功
- [x] MultiMap `find`の同値キー内個体・rankが標準上非保証であることを比較契約へ反映
- [x] 操作、境界、seed、標準ライブラリ別結果を専用Matrixへ記録

正本: `Sources/RedBlackTreeCollections/Documentation/Cpp-Matrix.md`

### Death Test・寿命検査・CI

- [x] Darwin / Linuxでtrap signalとfatal failureを分けて検証
- [x] LinuxでDeath Testを実際に通し、移植上の問題を修正（寿命balance検査skip構成。通常CIの寿命検査とは証拠を分ける）
- [x] 通常CIは従来のtestへ戻し、Death Testを明示traitで再実行可能に保持
- [x] Debug allocation / node / payload寿命検査を4つのXCTest基盤へ統一
- [x] setup時だけresetするskip modeと、balance全体をskipする緊急modeを追加
- [x] defaultでは寿命検査が有効なままであることを維持

### 文書・品質証拠・利用検討資料

- [x] 4コンテナの利用者向け英日ガイドを整備
- [x] API MatrixとView Matrixを実装・テストへ照合
- [x] Memory Safety、Copy on Write、Range、Internal Architecture等のDesign文書を整備
- [x] DocC Topicsを利用目的別に再編
- [x] RedBlackTreeCollectionsのDocCをRelease・warnings-as-errorsでCI検証し、GitHub Pages公開経路を整備
- [x] Compatibility文書の明白に古いhint記述とMultiMap `find`の注意を限定修正
- [x] C++比較結果をCompatibility文書と分離した証拠Matrixとして記録
- [x] 「世界最高峰候補」の主張を取り下げ、採用準備と品質証拠の文書へ変更
- [x] 文書名を`AdoptionReadinessAssessment`へ変更
- [x] refactoring履歴のコミット、日付、rename判定、差分行数を再検証

### Module別コメントドック

コメント行数ではなく、残すpublic APIを一通り確認し、実装・テスト上の契約と照合したかで判定する。

| Module | 状態 | 確認済みの範囲 | 残作業 |
| --- | --- | --- | --- |
| `RedBlackTreeCollections` | 大部分完了・設計同期待ち | 4コンテナ、View、主要操作、利用者向けガイド、DocC Topics、API Matrix | 公開面縮小とIndex契約の決定後、宣言コメント・ガイド・Matrixを最終同期 |
| `PermutationModule` | 区切り完了・独立確認待ち | 残した`nextPermutations()`と公開戻り値型の主要`///`、Specification、実装・性能上の制約 | `Permutations`型とDebug-only public memberを含む全public面の独立確認、DocC相当の出力確認 |
| `OptionalArrayModule` | 部分完了 | `nil`代入時の破棄契約、非所有Viewの寿命、境界挙動 | 残るpublic宣言を列挙し、全件を実装・Death Test・寿命testと照合 |
| `BareArrayModule` | 既存コメントあり・体系監査未完 | clone所有権、境界、Death Testはテストで検証済み | public宣言のコメントドックを全件監査し、非所有View・clone・破棄責務を明文化 |
| `AcCollections` | module説明・再公開範囲確認済み | `RedBlackTreeCollections`、`PermutationModule`、`OptionalArrayModule`、`BareArrayModule`を再公開。互換modeは加えて旧名`RedBlackTreeModule`を再公開 | — |
| `RedBlackTreeModule` | module説明・互換位置づけ確認済み | 独自のpublic宣言を持たない再公開ファサード（source directoryは`_RedBlackTreeModule`） | — |

`OptionalArrayModule`と`BareArrayModule`はテスト整備の進捗を、コメントドック完了とみなさない。
再公開専用moduleはmember単位の網羅率ではなく、module-level説明の有無で完了を判断する。
`AcCollections`は現行の全collection moduleをまとめて再公開する。個別moduleの品質未達が
確定した場合は、その時点で当該moduleをファサードから外すかを判断する。

### PermutationModule

- [x] `swift-algorithms`と重複する全順列列挙APIを等価性PoC後に削除
- [x] 公開APIを`nextPermutations()`中心へ縮小
- [x] 境界チェックのDebug / Release / end-to-end性能を再計測
- [x] 不適切だった初回benchmark手法を訂正
- [x] `Int.min` / `Int.max`を含むDeath Testを追加
- [x] strict memory safetyを段階適用し、警告0で恒久適用
- [x] Bufferのfinal化、変更前detach、Iterator/SubSequenceのSendable根拠と回帰testを整備

### BareArray / OptionalArray / AcCollections

- [x] BareArray 3D cloneのcapacity不足による参照解放漏れを修正
- [x] BareArray 1D〜4D cloneの参照所有を検証
- [x] OptionalArray 2D〜4Dの破棄と3D/4D再利用を検証
- [x] OptionalArray1D / Viewの`nil`代入時に発生した二重解放を修正
- [x] 両moduleの境界Death Testを整備
- [x] strict memory safety診断を段階的に削減
- [x] AcCollectionsの通常・互換modeについて、実際の再公開範囲を検証
- [x] AcCollectionsとRedBlackTreeModuleへStrict Memory Safetyを恒久適用し、警告0を確認

## 現在進行中の主経路

### 1. 公開面の監査と縮小

- [x] 外部所有型extensionを列挙し、意図した公開APIか確認
- [x] publicな`_` / `__`、`Unsafe*`、`SealError`、typealias、protocol適合を抽出
- [x] TestCode専用、境界内部、完全な内部用途へ分類
- [x] 最初の独立バッチ（ThreeWay比較宣言群）をpackageへ縮小
- [x] Debug限定SortedSequence実験経路をproduction targetからTestCodeへ分離
- [x] View 3型の`_isIdentical(to:)`を`@inlinable internal`へ縮小
- [x] Debug限定`RedBlackTreeBoundExpression.index(_:)` / `.debug(_:)`を`package`へ縮小
- [x] 旧世代iterator `_Obverse1...3` / `_Reverse1...3`を互換mode専用へ隔離
- [x] 関連型bridge 4個と`_Tree_IsMultiTraitInterface`を`@usableFromInline package`へ縮小
- [x] `UniqueMultiplicity` / `MultiMultiplicity`を`package`へ縮小
- [x] `_BaseNode_NodeCompareProtocol`を`package`へ縮小（G3前半。SignedDistance / Index設計とは分離）
- [ ] 意図しない`public`をpackage/internal/TestSupportへ縮小（2026-10-05時点で独立縮小batchは無し。残りはIndex依存または凍結clusterのみ）
- [ ] DebugとReleaseで公開protocol適合集合が変わる箇所を解消（Balanced群はexecutable API Matrix方針により凍結、Debug比較群はIndex依存）

`EXTERNAL_TYPE_EXTENSION_AUDIT.md`を監査表とする。Gate Aの機械抽出とGate B分類・
Claudeのread-onlyレビューは完了し、blocking correctionを反映済み。B4-aの
ThreeWay比較宣言群は縮小済みで、B4-cのSortedSequence実験経路はTestCodeへ
分離済み。B3監査のG1関連型bridge群、G2 multiplicity群、G3前半のNodeCompareも縮小済み。G4はpublic witness境界により
独立縮小不可として保留した。B4-bのMemoize群は
`swift-ac-memoize`と`Memoization`の移行待ちとして
公開を維持する。残りも監査表に従って変更単位を限定する。

### 2. RedBlackTree Indexの公開契約

- [x] 既存の安全性・CoW・通常走査O(N)契約を確認
- [ ] `swift-collections/Sources/ContainersPreview`を追跡し、`Index: Comparable`の要否を判断
- [x] 2026-10-04時点のupstream main / 1.7.0が`Comparable`必須であることを確認
- [x] 比較の意味、異なる木の扱い、計算量を比較表へ記録
- [ ] Container protocol要件を踏まえ、失敗状態を格納したIndexの要否を最終判断
- [ ] nominal Index + 内部`Result<Resolved, SealError>`案を採用するか決定
- [x] ユーザーが手作業で実装した`try/index/1`のfailureless Index PoCを現行HEADとQuality Checklistへ照合する（2026-10-05: Codex・Claudeの独立検証を経てverdict `adopt after corrections`、補正後にPR #158でmerge(`a6c8a474`)。正本は`Archived/INDEX_POC_VALIDATION.md`。Comparable採否とは分離）
- [x] X1のidentity規則・停止条件と初期4 batchを整備し、同名部品を別個体として扱う診断基盤を保存（PoC統合後、検証記録とともにArchivedへ整理）
- [x] 採用したsuccess-only表現を実装し、4コンテナとRange/Viewへ追従（PR #158）
- [ ] Comparable採否により必要となる場合は、nominal wrapper等の最終境界表現を判断する
- [ ] 標準`Result`へのretroactive `Comparable`適合に依存しない設計を選択
- [ ] 内部診断用`Result<..., SealError>`と公開Indexを分離するか判断
- [x] `_O_UNCHECKED`でも消えないstale Index拒否と移動失敗診断を整備（現行実装の
  上乗せ防御。公開契約はSwift標準ライブラリと同じ事前条件モデルとし、実装を寄せるかは
  1.0前、または`-Ounchecked`が主要構成と判明した時点で再審査する）
- [ ] 必要な候補だけReleaseで試作・計測
- [ ] 4コンテナ、Range View、DocC、API Matrixへ反映
- [x] Kで（Index移行後）`index(inserting:)`をMultiSet / Dictionaryへ横展開する（4コンテナ提供と名称維持はCodex・Claudeレビューで決定済み。戻り値は全型で`(inserted: Bool, index: Index)`。Dictionaryは既存値を置換せず既存位置、Multi系は常に新規occurrenceと`true`を返す。`insert(_:)`と`erase(exactly:)`からSee Alsoで発見可能にする。2026-10-05実装・テスト済み）
- [x] Kで（Index移行後）`erase(exactly:)`をMultiSet / Dictionaryへ横展開する（4コンテナ提供は決定済み。2026-10-05実装・テスト済み。Setの空でのCoW回避漏れも同時に修正）
- [x] KeyValue Range Viewの範囲外Indexは標準Collection同様のprecondition違反とし、単一Index操作ではO(log N)の範囲内検査や停止保証を公開契約に含めない。独自のBound / range操作は処理内で入力を検査するsafe動作とする

依存順と完成条件は`RED_BLACK_TREE_REMAINING_TASKS.md`を正本とする。

### 3. 非RedBlackTreeのコメントドック監査

- [ ] `OptionalArrayModule`のpublic宣言を列挙し、既存コメントと実際の契約を照合（ユーザーが明示的に再開を希望するまで着手・Claude依頼を行わない）
- [ ] `BareArrayModule`のpublic宣言を列挙し、所有権・非所有View・破棄責務を重点監査（ユーザーが明示的に再開を希望するまで着手・Claude依頼を行わない）
- [x] `AcCollections`と`RedBlackTreeModule`のmodule-level説明と再公開範囲を確認
- [x] 適用可能なtargetでDocC生成または同等のリンク・警告確認を行う（`AcCollections` / `RedBlackTreeModule`をwarnings-as-errorsで確認）

これは赤黒木のIndex設計とは独立して進められるが、現在の最優先経路を割り込ませない。

### 4. 記録間の同期

- [x] `Tests/TESTING.md`のC++比較件数を17件から現在の35件へ同期
- [x] `AdoptionReadinessAssessment`英日版へLinux実績とlibc++正本／libstdc++参考の区別を同期
- [x] 4コンテナのDecodable修正を`CHANGELOG.md`へ記録

いずれも実装の未完ではなく、Claudeの進捗レビューで判明した記録上の不整合である。

### 5. ユーザーのマネジメント評価ヒアリング

- [x] CodexとClaudeから見たユーザーのマネジメント上の強み、負荷、改善余地を同じ質問で独立確認する
- [x] 方針決定、優先順位、品質ゲート、AI間調整、報告粒度を分けて評価する
- [x] 必要な細部共有と、AI側へ委譲できる管理作業を区別する
- [x] 「マイクロすぎるか」を印象ではなく、このrepositoryでの具体例と結果に照らして判断する
- [x] 評価結果から、ユーザーが今後直接決める事項とCodexへ委譲する事項を短い運用表にする

独立回答と統合結果は`USER_MANAGEMENT_INTERVIEW_CODEX.md`、
`USER_MANAGEMENT_INTERVIEW_CLAUDE.md`、`USER_MANAGEMENT_ASSESSMENT.md`へ記録した。
残るのはユーザーによる採用、修正、または却下だけである。

## 判断待ち

赤黒木の設計ゲート停止中、テスト責務の整理は完了した。未結線コードの個別削除は
ユーザー判断を得るまで凍結し、赤黒木側はIndex、文書、明示的な凍結事項だけとする。

- [x] `Int.__less()` / `__greater()`等、B4-aの内部由来public extensionをpackageへ縮小
- [ ] `Result`のpublic比較overloadとpublic `_NodePtr` typealiasの処遇（ユーザーが再開を決めるまで凍結）
- [x] RedBlackTreeTestSupportとDebugAdditionalsの責務整理（自動テスト基盤／人間向け診断・凍結コードで区分し、配置例外2件は移動しない）
- [x] UnsafeNode / RawBufferクロスチェックと単層テストの役割整理（独立計算によるfault independenceを維持し、共有化しない）
- [ ] 未結線コードを段階的に削除する（個々の削除はユーザーが決定し、再開指示まで凍結）
- [x] Combining系APIへ実測結果に基づく条件付きコメントを追記（`Archived/CombiningAPIPerformanceEvidence.md` §3に基づき、容量による一律推奨を避ける）
- [x] Combining系の追加NoteをClaudeが限定レビューし、測定範囲の限定とMultiMapへの未計測結果の外挿除去を反映
- [ ] PermutationのAtCoder 2025互換mode（ユーザーが明示的に再開を指示するまで着手・調査・Claude依頼を行わない）

## 保留・完成を止めない追加検証

以下は余裕ができたときに選ぶ追加メニューであり、当面は着手しない。完成条件や次作業には含めず、ユーザーの明示指示なしに調査・実装・Claude依頼を開始しない。

- [ ] `OptionalArray`の名称を再検討する
- [ ] `BareArray`の名称を再検討する
- [ ] randomized trace失敗時の自動縮小
- [ ] SortedCollectionsとのpublishableな大規模性能比較
- [ ] RedBlackTreeCollectionsのStrict Memory Safety全面適用
- [ ] BareArray / OptionalArrayのunsafe storage再設計とstrict恒久適用
- [ ] `lazyDetach`等の並行初期化保証
- [ ] Swift更新後のCoWコード生成再計測
- [ ] unsafe移行史の`unsafe!!!`前後に関する追加調査

## 中止・再開禁止

- [x] MSVC STLとのC++挙動比較（2026-10-04ユーザー決定により実施しない）
- [ ] ABC328E実提出確認（ユーザーが手作業で行う専任項目として凍結。AIは着手・代行・催促しない）

Compatibility文書4本の包括監査は凍結taskから削除した。公開ドキュメントはCodexを第一担当とし、
`Cpp-Matrix.md`または具体的な実装差を根拠に対象項目を限定して更新する。Claudeへ委譲する場合も、
範囲指定された事実確認、独立レビュー、または限定修正に留める。

## 次の区切り

1. Index完了ゲートとして、Comparable採否、公開Indexと内部`SealError`の分離、1.0での完了範囲を決める。
2. Index-range `erase`の空guardを、無効範囲の検査と不要なCoW回避のどちらを優先するか判断する。
3. P10に残るIndex統合前の記述を確認し、必要な箇所だけ現行表現へ同期する。
4. 上記の決定後、公開コメント、Design、API Matrix、DocC Topicsを最終同期する。

外部所有型extension監査、strict memory safety、OptionalArray/BareArrayの体系監査は保留中の独立作業であり、
明示的な再開判断なしに主経路へ混ぜない。

## 正本

- 現在のテスト状態: `Tests/TESTING.md`
- 詳細履歴: `Tests/Archived/TESTING_REFERENCE.md`
- 変更履歴: `CHANGELOG.md`
- 文書管理: `Maintanance/MAINTENANCE.md`
- RedBlackTree残タスク: `Maintanance/RED_BLACK_TREE_REMAINING_TASKS.md`
- 外部所有型extension監査: `Maintanance/EXTERNAL_TYPE_EXTENSION_AUDIT.md`
- C++比較: `Sources/RedBlackTreeCollections/Documentation/Cpp-Matrix.md`
- SortedCollections比較: `Maintanance/Archived/SORTED_COLLECTIONS_BENCHMARK_TASK.md`
- Combining性能証拠: `Maintanance/Archived/CombiningAPIPerformanceEvidence.md`
- Permutation計画・評価: `Maintanance/PermutationModule/`
- AtCoder 2025からの再構成履歴: `Maintanance/REFACTORING_FROM_ATCODER_2025.md`
- 品質証拠・利用検討資料: `Maintanance/Archived/AdoptionReadinessAssessment.md`、同`.ja.md`
- strict memory safety: `Maintanance/StrictMemorySafetyReadiness.md`
