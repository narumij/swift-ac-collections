# Performance CI変更ガイド

## 目的と正本範囲

この文書は、performance CIへbenchmark workloadを追加または変更するときの境界、導入順序、
および過去事例を管理するCodex側の正本である。

benchmark自体の試験方法やtest suiteの運用は扱わない。taskの状態は
`PROGRESS_OVERVIEW.md`のTask Registry、実際のworkflowとlibrary構成は`.github/workflows/`と
`Benchmarks/Libraries/`がそれぞれ正本である。

## 手動実行

GitHubのActionsから`CI`を選び、`Run workflow`で次を指定すると、pushやPR更新を伴わずに
performance比較を実行できる。

手動実行はperformance比較専用である。documentation、Debug・Release test、および
Address Sanitizerは起動せず、通常のPR検証で実行する。手動performance調査のたびに
通常検証の一部だけを重複実行しない。

- `Use workflow from`: workflowを実行するbranch。比較先を空欄にした場合は、このbranchのcommitを使う。
- `performance_base_ref`: 比較元のbranch、tag、またはcommit SHA。既定値は`main`。
- `performance_head_ref`: 比較先のbranch、tag、またはcommit SHA。空欄なら選択したworkflow branchを使う。

PRで起動した場合は入力値を使わず、従来どおりPRのbase SHAとhead SHAを比較する。
再現調査ではbranch名の移動を避けるため、可能なら両方をcommit SHAで固定する。

## 基本境界

base / current比較では、比較に使うworkload名と、そのworkloadを実装するbenchmark harnessが
両側に存在しなければならない。baselineに存在しないworkloadをlibraryから要求してはならない。

新しいworkloadを通常の回帰CIへ導入するときは、原則として次の境界に分ける。

1. workload実装と局所検証を独立した成果として完成させる。
2. workload実装を先にmergeし、そのmerge commitを以後のbaselineにする。
3. 後続の独立した変更でCI libraryへworkload名を登録する。
4. base / currentの双方が同じworkloadを解決し、通常の回帰比較が完走することを確認する。

この分割は赤を隠すためではない。初回導入に起因する構成不成立と、実際の性能回帰を分離し、
失敗を局所化するために行う。

## 過去事例

### 失敗例: baselineへのharness同期

commit `1027a154`では、current側のbenchmark Sources、manifest、resolved fileをbaseline側へ同期した。
その結果、baselineが本来持たないAPIやtask構成までcurrent側から持ち込まれ、比較対象のsource変更と
CI harness変更の境界が崩れた。この同期はcommit `a5662f7d`で取り消した。

また、libraryだけが先行してbaselineに存在しないtask名を要求すると、測定前に`unknown tasks`で失敗する。
これは性能の赤ではなく、比較構成が成立していない赤である。

### 成功例: workloadとCI登録の分離

BareArrayとOptionalArrayの多次元access workloadは、PR #189で実装を先にmergeした。そのmerge commitを
baselineとしてから、PR #190で通常CI libraryへの登録だけを合流し、performance jobのgreenを確認した。
PR #191でも両moduleのbase / current測定は成立したが、job全体は別件のPermutation実装方式切替を検出して
赤となった。これにより、Array workloadの初回導入と通常のbase / current回帰比較を別の受入境界にできた。

## 変更前に確認すること

- 変更するのがworkload実装、CI library、workflow、比較条件のどれかを分ける。
- baseとcurrentが同じtask名を解決できるか確認する。
- workload実装を含むcommitがbaselineへ到達済みか確認する。
- 初回baseline確立と、性能差の合否判定を同じ変更へ混ぜない。
- 赤マージが避けられない場合は、先に局所build、task列挙、current単独実行を完了し、赤の理由を
  比較構成不成立へ限定できる証拠を残す。
- performance runnerの揺れと構成不成立を混同しない。測定値の調査が必要な場合は、Archivedの
  `Canonical/PERFORMANCE_REGRESSION_BISECTION.md`を参照する。

## OptionalArray direct access workloadの適用結果

OptionalArrayのdirect access workloadはcommit `bf0259a0`で実装、専用library、暫定結果、chartまでを
独立して保存した。同commitを含むPR #189のmerge後、PR #190で通常CI libraryへの登録だけを実施し、
performance jobのgreenを確認した。外部性能アセスメントの正式化とは別の受入境界を維持する。

## Permutation実装方式の切替

2026-10-13、runtime-check付き`Permutation` Viewを導入したPR #191のperformance jobは、baseのborrowed
実装とcurrentのruntime-check実装を比較したため赤となった。これは同じ実装系列内の回帰ではなく、Swift 6.2
互換性とView失効検査を持つ標準経路へ切り替えた際の方式差である。PR #191のmerge commitを以後の
runtime-check版baselineとする。

通常のLinux CIでは、runtime-check版について次を継続監視する。

- local accumulatorと反復回数を持つbatched subscript workload 2件。
- 公開`nextPermutations()`を通るend-to-end workload。

旧unbatched subscript workload 2件は、captured accumulatorのheap boxと短すぎるsampleにより、世代確認が
vectorizationへ与える影響を過大に観測することが実装コメントとassemblyで確認された。診断用taskとして
benchmark sourceには残すが、通常CIの合否対象には含めない。

Swift 6.4のborrowed版はruntime-check版の回帰baselineにしない。lifetimeによって安全性を表現し、要素ごとの
世代確認を必要としない別の性能契約だからである。borrowed版とC++の比較はmacOS品質評価の独立系列として
保存し、Linux CIへ異なる契約を混在させない。

この分離を反映したPR #193では、PR #191のmerge commitをbaseとしてperformance jobを実行し、batched
subscript 2件とend-to-endを含む新しい比較契約でall greenを確認した。以後の赤は、borrowed版からの方式差では
なく、runtime-check版baselineに対する回帰として扱う。

## benchmark task名のrename境界

2026-10-13、BareArray／OptionalArrayの公開型rename後、HEADの`CI.json`をrename前のbaselineへ
そのまま渡したため、baseline build成功後に新しい8 task名を解決できず`unknown tasks`で停止した。
これは性能回帰ではなく、同じworkloadを指すtask名の世代差による比較構成不成立である。

PRおよびrelease candidateのperformance workflowでは、比較対象のbenchmark sourceが新しい型名を
まだ持たない場合だけ、HEADのlibrary定義を旧task名へ変換してbaselineを測定する。測定後、baselineの
結果JSONにある旧名を新名へ戻し、HEAD結果と同じworkload名で比較する。BareArrayとOptionalArrayは
個別に検出し、rename commitの途中をbaselineにした場合も一方だけを変換する。

この互換処理はbenchmark実装や測定値をbaselineへ移植しない。baselineがrenameを含むようになれば
自動的にno-opとなる。今後のtask renameでも、旧実装と新実装が同じworkloadであることを先に確認し、
library入力と結果名の両方を対応付ける。意味や測定境界が変わる場合はrename互換として扱わない。

task名を変更する場合は、renameを先にmergeしてから互換処理を足さない。旧名と新名を対応付ける
workflow変更を先にmergeし、その時点のperformance CIがgreenであることを確認してからrenameをmergeする。
rename後もcurrent測定、baseline測定、比較まで完走してgreenになることを確認する。各段階の直前のgreenを
次段階の開始条件とし、移行途中の赤を後続変更で回収する計画にしない。

また、libraryのtask名は公開型名だけで組み立てず、benchmark sourceへ登録された完全なtitleと照合する。
今回の復旧では型renameだけを追い、以前から残っていた旧い総称名を見落としたため、current側でも
`unknown tasks`になった。rename互換の検証では、currentの完全なtask名、旧baselineへ変換した完全なtask名、
結果を正規化した完全なtask名の三点を確認する。

commit `0330e7b5`のPR CI run `38390402753`では、current測定、rename前baselineの測定、結果名の正規化、
性能比較まで完走し、performanceを含む全jobのgreenを確認した。
