# 開発・メンテナンス進捗一覧

最終更新: 2026-10-05 / Claude(PR #158 merge後の事実の同期のみ。構成・方針は2026-10-04 / Codex)

## 対象期間と読み方

Index / lazy tie周辺の再設計、赤黒木のテスト再編、公開文書整備が本格化した
2026-09-25頃から現在までの主要タスクを成果単位でまとめる。

細かなコミット数ではなく、現在の判断に必要な状態を記録する。

| 状態 | 意味 |
| --- | --- |
| 完了 | 実装・必要な検証・記録まで一区切りしている |
| 完了・追加検証可 | 現在の完成判断を止めないが、環境や比較対象を増やせる |
| 進行中 | 現在の主経路に含まれる |
| 判断待ち | ユーザーまたは設計判断が先に必要 |
| 保留 | 重要だが現在の完成条件には含めない |
| 中止 | 明示的に停止し、勝手に再開しない |

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

正本: `CPP_BEHAVIOR_COMPARISON_MATRIX.md`

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
- [x] ユーザーが手作業で実装した`try/index/1`のfailureless Index PoCを現行HEADとQuality Checklistへ照合する（2026-10-05: Codex・Claudeの独立検証を経てverdict `adopt after corrections`、補正後にPR #158でmerge(`a6c8a474`)。正本は`INDEX_POC_VALIDATION.md`。Comparable採否とは分離）
- [x] X1のidentity規則・停止条件と初期4 batchを整備し、同名部品を別個体として扱う診断基盤を保存（網羅inventoryは費用対効果により凍結）
- [ ] 採用表現を実装し、4コンテナとRange/Viewへ追従（success-only表現はPR #158で4コンテナ・Viewへ実装済み。nominal wrapper等を含む最終表現の判断は残る）
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
- [x] Combining系APIへ実測結果に基づく条件付きコメントを追記（`CombiningAPIPerformanceEvidence.md` §3に基づき、容量による一律推奨を避ける）
- [x] Combining系の追加NoteをClaudeが限定レビューし、測定範囲の限定とMultiMapへの未計測結果の外挿除去を反映
- [ ] PermutationのAtCoder 2025互換mode（ユーザーが明示的に再開を指示するまで、ABC328E実提出確認を含め着手・調査・Claude依頼を行わない）

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

- [x] Compatibility文書4本の広範囲な一括監査
- [x] MSVC STLとのC++挙動比較（2026-10-04ユーザー決定により実施しない）

Claudeが既存文書を広範囲に改変し始めたため、ユーザーが強制停止した。限定的に確認済みの
修正以外は残っていない。この監査は新しい明示依頼なしに再開しない。

## 次の区切り

1. 公開面監査表に従い、Index表現に拘束されない項目から変更単位を限定する。Debug-only Comparable群は分類だけ行い、Index判断まで変更しない。
2. 既存の安全性・CoW・計算量契約、Comparable採否、公開失敗状態の要否を、公開面監査と並行して確認する。
3. TestCodeへ移せるfixture・実験経路を、Index表現に依存しない範囲で小さく分離する。
4. 外部契約から内部表現を選び、実装・回帰検証する。
5. 公開範囲を縮小してから、最後にデッドコードの処遇を判断する。

非RedBlackTreeのコメントドック監査は上記と独立して並行可能であり、OptionalArray、BareArray、
再公開moduleの順で閉じる。

## 正本

- 現在のテスト状態: `Tests/TESTING.md`
- 詳細履歴: `Tests/TESTING_REFERENCE.md`
- 変更履歴: `CHANGELOG.md`
- 文書管理: `Maintanance/MAINTENANCE.md`
- RedBlackTree残タスク: `Maintanance/RED_BLACK_TREE_REMAINING_TASKS.md`
- 外部所有型extension監査: `Maintanance/EXTERNAL_TYPE_EXTENSION_AUDIT.md`
- C++比較: `Maintanance/CPP_BEHAVIOR_COMPARISON_MATRIX.md`
- SortedCollections比較: `Maintanance/SORTED_COLLECTIONS_BENCHMARK_TASK.md`
- Combining性能証拠: `Maintanance/CombiningAPIPerformanceEvidence.md`
- Permutation計画・評価: `Maintanance/PermutationModule/`
- AtCoder 2025からの再構成履歴: `Maintanance/REFACTORING_FROM_ATCODER_2025.md`
- 品質証拠・利用検討資料: `Maintanance/AdoptionReadinessAssessment.md`、同`.ja.md`
- strict memory safety: `Maintanance/StrictMemorySafetyReadiness.md`
