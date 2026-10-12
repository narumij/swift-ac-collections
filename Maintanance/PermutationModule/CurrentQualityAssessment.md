# PermutationModule Current Quality Assessment

## 文書の役割

この文書は、PermutationModuleの現行品質評価taskの詳細正本である。
上位品質要求は`Maintanance/User/QUALITY_REQUIREMENTS.md`、モジュールへの適用と
証拠境界は`Sources/PermutationModule/Documentation/Quality-Profile.md`を正本とする。
本書はそれらを変更せず、現在評価の作業範囲、完了条件、結果を管理する。

## 一時View契約への変更後の現在性

通常版は旧`NextPermutationsSequence`のCOW・値セマンティクス契約から、単一bufferを破壊的に進める
`NextPermutations`とruntime-check付き`Permutation` Viewの契約へ変更された。旧通常版testは`#if false`で
退避され、新契約のTest as Specificationは再構築前である。Swift 6.4のLifetimesと`Span`を使う版は、
View省略と性能を調べた特殊経路として無効化し、通常提供から分離した。

この変更より前に記録した本書の「現行評価」、実行記録、およびPERM-040〜PERM-044の旧通常版に対する
結論は、移行前実装の評価・調査記録として保持する。借用版の現在評価として流用せず、再評価が完了する
まではQR-01、QR-03〜QR-06の旧判定を現在の適合主張に用いない。性能記録も、測定対象の実装と契約を
区別して扱う。

## Task

- ID: `PERM-039`
- 種別: `DISCOVERY`
- 担当: Codex
- 現在の中間ゴールへの近さ: `DIRECT`

現在の状態、担当、および再開条件はTask Registryを正本とする。

### 実行内訳

| 内訳 | 内容 | 状態 |
| --- | --- | --- |
| A | 公開契約・実装・Test as Specificationの照合 | 完了 |
| B | 通常版test・buildによる現在証拠の取得 | 完了 |
| C | 性能証拠・CI構成・利用経路の照合 | 完了 |
| D | QR-01〜QR-06の評価と後続task候補の分離 | 完了 |

## 目的

PermutationModuleを最初の適用対象として、上位品質要求QR-01〜QR-06に対する
現行実装の品質を、現在の仕様と独立した証拠に基づいて評価可能な状態にする。

旧評価の判定を引き継がず、各品質主張を次のいずれかへ分類する。

- 確認済み
- 未達
- 未検証
- 対象外
- 受容済みの残余リスク

## 対象

- 通常版の公開API、実装、Test as Specification、documentation comment
- 通常版とAtCoder 2025互換modeの境界
- benchmark対象、継続測定構成、および現在利用できる性能証拠
- SwiftPM、`AcCollections`再公開、他moduleとの共存経路
- CIが実際に扱うtoolchain、platform、build configuration、trait、test
- 現在確認できる安全性、値セマンティクス、寿命、範囲検査の証拠

## 対象外

- 公開契約、性能目標、比較水準、残余リスク許容条件の新規決定
- 未確定事項をagent判断で製品契約へ取り込むこと
- `PERM-002`の実提出確認またはその代行
- 発見した不足の実装修正
- Permutation以外のモジュールの品質評価

## 確認済みの開始時点

- 通常版の`PermutationModule` targetには`.strictMemorySafety()`が恒久適用されている。
- 2026-10-11、testingを含むproject buildが警告・errorなしで成功した。
- 通常版実装のポインタ操作は明示的なscoped `unsafe`に置かれている。
- `PermutationTests` target自体には`.strictMemorySafety()`が設定されていない。
- `Iterator`と`Permutation`の`@unchecked Sendable`、scoped `unsafe`の個別の妥当性は、
  strict memory safety適用の完了だけから推定せず、品質主張ごとの証拠で評価する。

## 作業

1. QR-01〜QR-06ごとに、評価対象となる品質主張を品質プロファイルから抽出する。
2. 各主張を担当する公開契約、設計契約、Test as Specification、測定、CI構成へ接続する。
3. 証拠の現在性、対象構成、実行結果、反証、証明できる範囲を確認する。
4. 各主張を評価区分へ分類し、VerificationとValidationを分離する。
5. 不足を次の単位へ分ける。
   - 事実確認を続ける`DISCOVERY`
   - ユーザー判断を一つだけ扱う`DECISION`
   - 方針確定後の`EXECUTION`
   - 既存taskへ属する事項
6. 後続候補について必要性と`DIRECT`、`NEAR`、`FAR`、`LATER`、
   `OUTSIDE`の関係を示し、必要なものだけRegistry候補として提示する。

## 成果物

現在評価は本書へ記録する。長い調査ログや再実行用データが必要になった場合は、
本書から参照する別紙へ分離し、同じ判定を重複して正本化しない。

最低限、次を残す。

- 品質主張
- 対応する上位要求
- 仕様の正本
- 証拠と対象構成
- 評価区分
- 根拠
- 反証または未確認範囲
- 残余リスク
- 必要な後続task候補

## 完了条件

- QR-01〜QR-06の各領域について、少なくとも一つの現行評価が記録されている。
- 通常版とAtCoder 2025互換modeの証拠が混同されていない。
- Verificationの結果から競技提出、C/C++級性能、一般Swift採用のValidationを推定していない。
- `PERM-002`を開始または代行していない。
- 未達・未検証・判断待ち・実行不足が区別され、一判断一taskの規則で後続候補へ分離されている。
- ユーザーが評価結果と後続候補をレビューできる。

## 現行評価

評価日は2026-10-11。旧品質評価の判定は継承せず、現行source、Test as Specification、
Package設定、benchmark、workflow、および今回の実行結果から評価した。

### 0.5.xの対象環境

0.5.xの品質アセスメントでVerificationとValidationの証拠を要求する対象環境はmacOSに限定する。
benchmarkの実行環境、toolchain、最適化構成、およびmachine条件は、macOS上の再現条件として記録する。

この限定は品質アセスメントの対象境界であり、`Package.swift`に宣言された他platformの対応削除、
非対応宣言、または1.0以降の対象環境を決定するものではない。他platformの結果を利用する場合は
補足証拠とし、0.5.xの適合判定に必須の証拠とは扱わない。

| 上位要求 | 品質主張 | 評価 | 現在の証拠 | 未確認範囲・残余リスク |
| --- | --- | --- | --- | --- |
| QR-01 正確性 | 現在順からの辞書順列挙、境界、重複、非Int Index、入力不変、結果Collectionが契約どおり動く | 確認済み | 通常版Test as Specification 38件中、列挙・公開面・Collection・値セマンティクス・内部・Death Testを含む全38件成功 | 有限な例と構成に対する確認であり、任意入力の数学的証明ではない |
| QR-02 性能効率性 | APIと1 stepの計算量契約、および自己回帰を検出する測定経路が存在する | 確認済み | sourceのO(1)生成、O(n) iterator生成・step、O(1) subscript契約。Swift側のsubscript 4件とend-to-end 1件、CI/CI-Small構成、PR・candidate performance workflow | C++ workloadは通常CIへ含めず、外部比較アセスメント専用とする |
| QR-02 性能効率性 | C/C++標準に匹敵する性能を持つ | 未検証 | 同一Benchmark基盤に`std::next_permutation`対応workloadを追加済み | macOS上の比較条件、統計、machine記録、測定結果、比較水準が未確定であり、上位コンセプトの中心主張へ直接残る証拠不足 |
| QR-03 安全性 | 値セマンティクス、要素寿命、範囲拒否、通常版strict memory safetyが成立する | 確認済み | 値セマンティクス6件、内部寿命・CoW 4件、Death Test 5件が成功。`.strictMemorySafety()`適用下のtesting build成功。危険操作はscoped `unsafe` | `@unchecked Sendable`と個々のunsafe操作はテストと設計根拠による確認であり、あらゆる並行実行の証明ではない |
| QR-04 理解可能性 | 後続順列と全順列、開始位置、重複、値保持、Index、失敗条件、計算量、類似APIとの差を確認できる | 確認済み | 公開documentation commentとコード例が各項目を説明し、対応するTest as Specificationが成功 | 一般Swift利用者による理解のValidationは未実施。独立した利用者向けPermutation文書は存在しない |
| QR-05 利用可能性 | 通常版をSwiftPMと`AcCollections` facadeから利用し、swift-algorithmsと共存できる | 確認済み | project build成功、facade再公開test 1件成功、共存test 2件成功 | 今回のローカルRelease再実行は環境sandboxに阻まれ未取得。CI設定の存在とremote成功記録は区別する |
| QR-05 利用可能性 | 競技プログラミングで実用できる | 未検証 | 通常版・互換modeの仕様testと単一file経路は候補証拠だが、実提出は未実施 | `PERM-002`はユーザー専任。今回の通常構成では互換mode 5件は条件外で未実行 |
| QR-06 持続可能性 | 公開面、列挙、値セマンティクス、Collection、共存、安全性、性能を変更後に再確認できる | 確認済み | 番号付きTest as Specification、benchmark library、Debug・Release・ASan・performanceを含むworkflow分担 | workflowの存在だけで特定commitのremote成功を推定しない |

## 実行記録

- Xcodeのtesting build: 成功、警告・errorなし。
- 通常版Permutation test: 38件成功、失敗0件。
- AtCoder 2025互換mode test: 通常構成では5件とも条件外で未実行。
- `AcCollections`からの通常版Permutation再公開test: 1件成功。
- Release絞り込みtest: SwiftPM起動時に環境の` sandbox-exec: sandbox_apply: Operation not permitted`
  で実行不能。製品test失敗とは分類しない。

## 後続task候補

| ID | 種別 | 近さ | 内容 | 必要性 |
| --- | --- | --- | --- | --- |
| `PERM-040` | `EXECUTION` | `DIRECT` | アセスメント用C++対応workloadのBenchmark登録 | Swift側の既存CI回帰benchmarkは変更せず、`CppBenchmarks`へC++ `std::next_permutation`の対応workloadを追加し、後続の外部比較アセスメントから利用可能にする。0.5.xの評価対象環境はmacOSとし、独自runnerや品質判定基準は作らない |
| `PERM-041` | `DISCOVERY` | `NEAR` | 一般Swift利用Validation scenarioの設計 | QR-04・QR-05について、文書とtestのVerificationから実利用適合を推定しないために必要。代表利用者、導入経路、利用課題、観測方法を整理する |
| `PERM-042` | `DISCOVERY` | `DIRECT` | CI benchmarkのアセスメント用外部比較へのアレンジ | `PERM-040`で継続観測可能になった同一workloadを入力に、macOS上の比較対象、入力範囲、toolchain、最適化、統計、machine条件、再現証拠、測定JSONとchart画像を整理し、比較水準など必要なユーザー判断を分離する |
| `PERM-002` | 既存`USER_ONLY` | `DIRECT` | ABC328E実提出確認 | 競技利用Validationに必要。agentは開始、代行、催促を行わない |

`PERM-041`と`PERM-042`は判断を確定せず、後続の一判断ごとの`DECISION`を発見する。
`PERM-042`は`PERM-040`を必須前提とし、既存CI回帰benchmarkと追加するC++対応workloadを
アセスメント結果そのものとは扱わない。独立した利用者向け文書の形は上位の未確定事項なので、この評価から
Markdown、DocC、documentation commentのいずれかへ固定しない。

## PERM-040 実施結果

2026-10-11、既存のSwift end-to-end workloadと同じ昇順整数入力、全順列列挙、
位置加重checksumを使う`std::next_permutation` workloadを`CppBenchmarks`へ追加し、
後続の外部比較アセスメントから利用可能にした。入力の準備は測定外とし、測定内では双方とも入力copy、
全順列の生成、checksum計算を行う。C++標準ライブラリはこのrepositoryの変更対象ではないため、
通常の`CI-Small`には登録せず、Swift実装の自己回帰監視と外部比較アセスメントを分離する。

release buildと一時的な比較libraryによるsize 1...10・1 cycle実行が成功し、
Swift／C++両workloadの件数とchecksum検査も成功した。既存のPR・candidate workflowと
`CI-Small.json`には変更を加えていない。

この結果はC++対応workloadを同じBenchmark基盤から実行可能にしたことだけを示す。
macOS上の評価条件、統計、machine記録、比較水準、測定JSONとchart画像は`PERM-042`で扱い、
現時点では「C/C++標準に匹敵する」という品質主張を未検証のまま維持する。

## PERM-042 実施結果

2026-10-11、28要素中7要素を選ぶ最大条件から、PermutationModuleの主評価scenarioを次のように確定した。

- 長さ28の昇順二値列を使い、`0`を21個、`1`を7個とする。
- 重複しない`C(28, 7) = 1,184,040`候補を最後まで列挙する。
- 列挙件数と位置加重checksumを閉形式で検査する。
- Union-Findによる全域木判定と問題固有計算は別libraryの責務として対象外にする。
- Swiftと`std::next_permutation`で入力準備を測定外、入力copy・列挙・checksumを測定内に置く。

28要素の条件を主評価としつつ、PNG chartで性能の伸びと余裕を確認できるよう、7個の`1`を固定して
長さ8、12、16、20、24、28、32を測定点とする。32要素の`C(32, 7) = 3,365,856`候補は
主評価を置き換えない補助点とする。専用library
`Benchmarks/Libraries/PermutationAssessment.json`と実行script
`Benchmarks/run-permutation-assessment.sh`を追加した。scriptはrelease buildで5 cycles測定し、
commit、macOS、hardware、Swift、Clangの情報、生JSON、および総処理時間のPNG chartを
`Benchmarks/QualityAssessment/macOS/Permutations`配下へ測定IDで対応づけて保存する。
通常のPR・candidate性能CIには接続しない。

release build、全6入力でのSwift/C++件数・checksum検査、5 cyclesのJSON生成、PNG生成に成功した。
保存用scriptと同じ測定条件による一時試走では、最大ケースの5標本平均がSwift約28.2ms、
C++約20.2msで、Swift/C++比は約1.40だった。この試走は実行経路の検証値であり、比較水準を
適用した品質判定ではない。

「C/C++標準に匹敵する」と判定する性能比上限は既存契約から決まらないため、`PERM-043`へ分離した。
確定後、`PERM-044`でmacOS環境情報と測定成果物を保存し、性能主張を判定する。

### PERM-043 判断候補

判断対象は、28要素中7要素を選ぶ最大ケースにおけるSwift/C++総処理時間比の上限だけとする。

1. `1.5倍以内`: C++より遅いことは許容しつつ、同じ実用帯にあることを要求する。今回の試走は通過する。
2. `2.0倍以内`: Swift実装上の抽象化コストを広く許容する。今回の試走は余裕をもって通過する。
3. `1.0倍以内`: C++と同等以上だけを「匹敵」とする。今回の試走は通過しない。

現行のコンセプトが要求する「匹敵」と、競技用途で約118万候補を処理する実用性の双方を反映する候補として、
`1.5倍以内`を推奨する。これは未決定の製品判断であり、試走結果だけから確定しない。

2026-10-11、ユーザー指示により、比較水準の判断と、その基準を使う正式な実測・判定をともに保留した。
測定基盤と試走証拠は維持するが、明示的な再開指示までは`PERM-043`と`PERM-044`を開始しない。

保留中の暫定比較には、現行公開実装とC++に加え、標準`Array`をiterator内で直接更新して
`[Element]`を返す単純なSwift実装を性能peerとして追加した。これは公開実装の変更ではなく、
独自buffer・公開Permutation viewと、標準Array COW最適化の差を観測するための比較対象である。

同一release build・5 cyclesの試走平均では、28要素で現行版約26.7ms、Array版約28.0ms、
C++版約19.7ms、32要素で現行版約80.8ms、Array版約85.9ms、C++版約62.4msだった。
この単体比較ではArray版が現行版より約5〜6%遅く、提出全体で観測された実行時間差を
Permutation実装だけへ帰属できない。統合コード、DSU、データ表現、module境界、toolchainの差を
含む結果として分離する。

実提出で使われた`[Bool]`と`false < true`のretroactive `Comparable`実装による影響を分離するため、
同じ現行公開Permutationsを使うBool版peerも暫定比較へ追加した。Bool版のchecksumは選択位置だけを
加算し、実利用と同じ真偽分岐を測定内に含める。

5 cyclesの試走平均では、28要素でInt版約27.0msに対してBool版約27.9ms、32要素で
Int版約81.5msに対してBool版約83.8msだった。Bool版は約3%遅いが、統合提出で観測された差を
単独で説明する規模ではない。

## PERM-049 実施結果

2026-10-12、実提出で最速80msへ到達した実験を、Permutation製品候補と提出固有最適化へ分離した。
大幅な短縮へ寄与したDSU storage再利用、閉路判定と結合を一度のleader探索で行う`unite`、および反復leaderは、
提出コード側の処理構造をC++版へ揃える変更であり、PermutationModuleの製品変更には含めない。

ViewからGateKeeper所有を除く変更と、選択状態をpointerから直接取得する変更は、一時Viewの失効検査または
安全なCollection accessを迂回する。前者は実提出で効果がなく、後者は88msから80msへ短縮したが、いずれも
現行の安全性契約を維持する製品候補から除外した。

実験sourceをruntime-check付きView、公開subscript、および製品版と同じGateKeeperのinline境界へ戻し、
Swift 6.4 Release、36辺の固定入力で各7回測定した。unsafe枝、安全なView、`next()`の強制inlineなし、
製品版GateKeeper境界の各構成はいずれも中央値0.46秒で、出力も一致した。DSUの宣言順をac-libraryに近い順へ
戻した前後でも同じ範囲だった。

この証拠から、今回の探索を理由とするPermutation製品sourceの追加変更は行わない。現行runtime-check View実装を
維持し、80ms枝は安全性を外した性能上限の反証として作業報告と履歴へ残す。

ユーザー判断により、旧test群の詳細棚卸しは今回行わない。現行の有効testだけをDebug・Releaseで実行し、
手動列挙2件と、次の`next()`および所有者破棄による失効Death Test 2件が両構成で成功した。これは正式な
Test as Specification再構築や品質再評価の代替ではなく、現行実装を継続するための暫定的な回帰確認とする。

## Swift 6.4基準化後のSwift 6.2提供方針

Swift 6.4のLifetimes、`Span`、`~Copyable`を用いる借用型Permutationを通常版の次期実装候補として
組み込み、packageの最低toolchainもSwift 6.4へ変更した。これにより、通常版をまず一般Swift開発へ
提供し、その後に対応toolchainを採用した競技judgeへの搭載を目指す段階構成が具体化した。

SwiftPMはversion-specific manifestを選択できるため、同一releaseにSwift 6.4向けmanifestと
Swift 6.2向けmanifestを置き、6.2側だけPermutationModuleを製品・target・依存関係から外す構成も
候補になる。これにより、6.2利用者へ他moduleを提供しながら、Lifetimesを必要とする通常版Permutationを
6.4以降だけへ公開できる。ただし、6.2でPermutationを提供しないのか、旧tag・互換branch、単一file、
別の保守線などから提供するのかは、既存の品質要求から一意に決まらない。

`PERM-045`で、無印`Package.swift`をSwift 6.4の完全版とし、`Package@swift-6.2.swift`では
PermutationModuleを提供しない縮小構成を採用すると決定した。Swift 6.2向けの他module提供は維持し、
Lifetimesを必要とする通常版PermutationだけをSwift 6.4以降へ限定する。

version-specific manifest、`AcCollections` facade、test、CIの実装と両toolchainでの検証は`PERM-046`へ
分離し、ユーザー指示により凍結する。明示的な再開指示までは現在の単一manifest構成を変更しない。

### Swift 6.2互換runtime-check View通常経路

通常版は外側を手動の`while let`で進め、各`next()`が現在順列の`Permutation` Viewを返す。iteratorは
単一bufferと一つの`GateKeeper`を所有し、全Viewがその門番を共有する。次の`next()`またはiterator破棄時に
門番の世代番号を進め、発行時の世代と一致しないViewへのcollection操作をpreconditionで拒否する。

Swift 6.2 toolchainで、strict memory safetyを有効にした通常sourceのtypecheck、重複要素を含む順列列挙、
次の順列へ進んだ後の旧View参照が`Permutation view is no longer valid`で停止することを確認した。
所有者破棄後の旧Viewも同じpreconditionで停止する。Swift 6.4の`EtcTests`でも通常列挙と両失効trapが
成功し、Debug／Release buildも成立した。

binary-selection workloadを5 cycles測定した平均は、28要素で通常View 21.61ms、C++ 19.24ms、特殊Span
16.01ms、32要素で通常View 66.39ms、C++ 61.24ms、特殊Span 51.37msだった。通常ViewはC++比で
約1.12倍・約1.08倍となり、実行時寿命検査を維持した通常経路として採用した。

この成立により、既決だった「Swift 6.2 manifestからPermutationModuleを除く」実装案の前提は失われた。
version-specific manifestの必要性とpackage全体の6.2提供方針は、凍結中の`PERM-046`を再開するときに
必要性から再評価する。現時点ではmanifestを変更しない。

各候補の成立条件、反証、暫定性能値、および不採用理由は
`NextPermutationsImplementationExploration.md`へ探索証拠として分離した。
