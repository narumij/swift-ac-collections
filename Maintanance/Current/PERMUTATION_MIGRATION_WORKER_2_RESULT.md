# ワーカー2返却：性能CI・benchmark

固定ID：`PERM-074`。未返却。担当Worker Codex 2の記入領域。

## 調査結果

### 対象版・未コミット差分

- 観測対象は branch `develop/misc/66`、HEAD `cd2dd7ad3ac594b84bccc3fe62dd45779d88fb82`。
- 開始時の `git status --short --branch` は `develop/misc/66...origin/develop/misc/66 [ahead 3]` のみで、未コミット差分はなかった。
- 調査中に編集したのは本返却ファイルの「調査結果」以下だけである。source、test、manifest、workflow、Registry、依頼書には変更を加えていない。

### 確認した事実と根拠

#### 現行の登録・選択・名前対応

| 区分 | 現行値 | 根拠 | 意味 |
| --- | --- | --- | --- |
| benchmark sourceの完全title | `Permutations.SubSequenceN subscript sequential access` | `Benchmarks/Sources/Benchmarks/PermutationBenchmarks.swift:179` | unbatched。通常CIのlibraryには未登録。 |
| benchmark sourceの完全title | `Permutations.SubSequenceN subscript shuffled access` | 同 `:199` | unbatched。通常CIのlibraryには未登録。 |
| benchmark sourceの完全title | `Permutations.SubSequenceN subscript sequential access (batched)` | 同 `:231` | 通常CIで選択される1件目。 |
| benchmark sourceの完全title | `Permutations.SubSequenceN subscript shuffled access (batched)` | 同 `:258` | 通常CIで選択される2件目。 |
| 通常サイズlibrary | 上記batched 2件を完全titleで指定 | `Benchmarks/Libraries/CI.json:61-76`、特に`:71-72` | `CI.json`のgroup titleは`Permutations`、directoryは`permutations`だが、task解決のキーは2つの完全title。 |
| 小サイズlibrary | `Permutations nextPermutations end-to-end checksum` | `Benchmarks/Libraries/CI-Small.json:8-16`、source登録は`PermutationBenchmarks.swift:293` | module名を含まず、今回のmodule改名だけではtask名変更を要しない。通常CIはcurrent/base双方でこのlibraryも実行する。 |
| 品質評価library | `Permutations binary selection checksum`、`Permutations Bool binary selection checksum`ほか | `Benchmarks/Libraries/PermutationAssessment.json:12-20`、source登録は`PermutationBenchmarks.swift:323,426` | 通常Linux回帰CIとは別系列。module改名だけではtask名変更を要しない。 |
| benchmarkのmodule入口 | `import PermutationModule` | `Benchmarks/Sources/Benchmarks/PermutationBenchmarks.swift:26` | benchmark targetは旧module名を直接importしている。 |
| benchmark manifestのpackage product | `AcCollections` | `Benchmarks/Package.swift:32-41` | manifestには`PermutationModule`という個別product指定はない。root packageの`AcCollections`依存を通じて旧module importが解決される現行構成。 |

`PermutationBenchmarks.swift:14-15`は測定型を`NextPermutationsSequence.Permutation`と説明するが、現行実装は`Sources/PermutationModule/NextPermutations.swift:66,186`の`NextPermutations.Permutation`である。sourceの4 taskは実際には`nextPermutations()`の戻り値を使う（例 `PermutationBenchmarks.swift:183-184,236-237,265-266`）。したがって、旧`PERM-063`・`PERM-064`が前提にした新prefix `NextPermutationsSequence.Permutation`は、今回正式採用された型名と一致しない。

#### base / current選択と現行の正規化

- `.github/workflows/ci.yml:166-168`は、PRではbase SHA / head SHA、手動実行では`performance_base_ref`（既定`main`）/ `performance_head_ref`（空ならworkflow branchのSHA）を選ぶ。baseとHEADを別directoryへcheckoutする（`:172-186`）。
- currentはHEAD自身の`CI.json`を`current.json`へ実行し、続いて`CI-Small.json`をappendする（`:202-220`）。
- baselineはHEAD側の両libraryをbase checkoutへcopyしてから実行する（`:222-230,255-268`）。したがってHEADでtask名を変えると、base sourceがそのtitleを知らない限り変換なしでは`unknown tasks`になり得る。
- 現在の名前変換はOptionalElementBufferとElementBufferの2系列だけである（`:235-253`）。base sourceに新titleがなければ、baseline入力libraryを旧名へ置換する。
- 現在の結果正規化もその2系列だけである（`:270-282`）。base結果JSONを新名へ戻してから、base/currentを比較する（`:284-313`）。Permutation用の検出、library変換、結果正規化はまだ存在しない。
- `PERFORMANCE_CI_CHANGE_GUIDE.md:102-125`は、同一workloadのrenameに限り、互換workflowを先にmergeしてgreen確認後にtitleをrenameし、current完全title・旧baseline入力完全title・正規化後完全titleの三点を確認するよう定める。baselineへcurrent sourceを移植しない（同`:108-120`）。

### 変更候補・維持対象・工程の制約

#### module改名だけで必要になる候補

| 対象 | 分類 | 理由・境界 |
| --- | --- | --- |
| `Benchmarks/Sources/Benchmarks/PermutationBenchmarks.swift:26`のimport | 変更候補 | 新名`NextPermutationModule`をbenchmarkの主入口にするなら、新moduleをimportする必要がある。旧`PermutationModule`を互換入口として維持する方針なので、旧importを意図的に残す選択も技術的には別案だが、「主入口」の適用範囲として計画時に決める必要がある。 |
| `Benchmarks/Package.swift` | 原則維持候補 | 現行は個別module productではなく`AcCollections` productだけに依存する。新moduleの公開方法次第で個別依存追加が不要な可能性が高いが、target/product構成確定後のmanifest解決確認が必要。 |
| `.github/workflows/ci.yml:86`のDocC matrix | 他担当との変更接点 | performance jobではないが同じworkflowに旧公開target名が固定されている。新名を主入口にするなら新targetのDocC検証追加が候補。旧target互換を維持するため旧行の即時削除理由にはならない。 |
| benchmarkの7 task title（4 subscript、end-to-end、binary selection 2件）とlibrary group/directory | 維持 | いずれもSwift module名`PermutationModule`を含まない。module改名だけを理由に変更する必要はない。 |
| performance jobのbase/current選択と既存Array系正規化 | 維持 | module target renameとtask title renameは別問題。既存の一般的なrename互換は過去比較にも使うため維持方針（ガイド`:130-132`）。 |

#### benchmark名も変える場合だけ必要になる候補

- 4つのsubscript titleを現行正式型名へ合わせる場合、新prefix候補は旧計画の`NextPermutationsSequence.Permutation`ではなく`NextPermutations.Permutation`である。ただし名称決定そのものは本調査では行わない。
- 先行段階で`.github/workflows/ci.yml`へPermutation用のbase source検出、HEAD `CI.json`の新→旧完全title変換、base結果JSONの旧→新完全title正規化を追加する。通常CI登録はbatched 2件だけなので入力変換対象は2件、結果正規化はその実行結果2件で足りる。unbatched 2件はsource title変更とtask列挙の対象だが通常CI入力には追加しない。
- 先行workflowだけをmergeし、performance CIがgreenであることを次段階の条件にする。その後の独立変更でsourceの4 title、冒頭の旧名維持説明（`:14-15`）、`CI.json:71-72`のbatched 2件を同時に更新する。
- rename後もcurrent測定、旧baseline測定、結果正規化、比較までのgreenを確認する。各段階の赤を後続変更で回収しない。
- end-to-end title、品質評価title、group title/directoryまで改名するなら、subscript 4件とは別の名称判断と影響調査が必要である。現行`PERM-063`・`PERM-064`の範囲には含まれていない。

旧`PERM-063`・`PERM-064`はRegistry上ともに`FROZEN`であり、本調査は再開・実装していない。二段階の工程原則は現行ガイドと一致する一方、型名の前提と再開条件（旧facade target削除後）は今回の「旧module互換をmainに維持する」方針より古い。後続計画では凍結taskをそのまま実行せず、今回の移行計画との統合・置換・明示再開の扱いをAstraとユーザーが決める必要がある。

### 他担当との接点・未確認・計画時の判断点

- 構成・互換入口担当が決める新旧target/productと`AcCollections`再exportの形に、benchmark importとmanifest要否が依存する。ここでは方式を仮定していない。
- 文書・導入経路担当には、`PermutationBenchmarks.swift:18`の旧資料参照、旧型名説明、library表示上の`Permutations`名称を履歴／現行説明としてどう扱うかが接点になる。
- 計画時には、(1) benchmark sourceを新moduleの利用例として新importへ移すか、(2) benchmark task titleをmodule移行と同時に変えるか別taskに保つか、(3) 変えるなら正式prefixを`NextPermutations.Permutation`とするか、(4) end-to-end・assessment・group表示名も名称移行対象にするか、をそれぞれ分けて決める必要がある。
- 静的確認だけでは、新target構成後に`Benchmarks` targetが新moduleをimportできるか、旧baselineを選んだremote runnerで変換が正しく作動するか、完全task列挙が期待どおりかは未確認。最小の後続検証は、構成確定後のbenchmark release buildとtask列挙、互換workflow変更後の旧baseline対HEADのremote performance CIである。
- 過去run `38390402753`のgreenはガイドの記録（`:127-128`）として確認しただけで、今回のHEADやPermutation新旧名対応のgreenを保証しない。

### 調査範囲と完了確認

- 調査した範囲：指定された変更ガイド、`ci.yml`（base/current選択・library copy・既存変換・結果比較）、Benchmark package manifest、Permutation benchmark source、`CI.json`、`CI-Small.json`、`PermutationAssessment.json`、旧`BENCHMARK_TASK_NAME_MIGRATION.md`、現行`NextPermutations`型定義、Registry上の`PERM-063`・`PERM-064`・`PERM-074`。
- 調査していない範囲：保存済みbenchmark結果JSONの全履歴、remote Actions実物、他workflowの非Permutation処理、測定値・閾値の妥当性、他ワーカーの返却内容。
- build、benchmark、task列挙、CI実行、試作は依頼境界に従って行っていない。方式決定、実装完了、CI greenはいずれも主張しない。
