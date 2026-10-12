# Performance CI変更ガイド

## 目的と正本範囲

この文書は、performance CIへbenchmark workloadを追加または変更するときの境界、導入順序、
および過去事例を管理するCodex側の正本である。

benchmark自体の試験方法やtest suiteの運用は扱わない。taskの状態は
`PROGRESS_OVERVIEW.md`のTask Registry、実際のworkflowとlibrary構成は`.github/workflows/`と
`Benchmarks/Libraries/`がそれぞれ正本である。

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
baselineとしてから、PR #190で通常CI libraryへの登録だけを合流し、PR #191でもperformance jobのgreenを
確認した。これにより、初回導入と通常のbase / current回帰比較を別の受入境界にできた。

## 変更前に確認すること

- 変更するのがworkload実装、CI library、workflow、比較条件のどれかを分ける。
- baseとcurrentが同じtask名を解決できるか確認する。
- workload実装を含むcommitがbaselineへ到達済みか確認する。
- 初回baseline確立と、性能差の合否判定を同じ変更へ混ぜない。
- 赤マージが避けられない場合は、先に局所build、task列挙、current単独実行を完了し、赤の理由を
  比較構成不成立へ限定できる証拠を残す。
- performance runnerの揺れと構成不成立を混同しない。測定値の調査が必要な場合は、Archivedの
  `Canonical/PERFORMANCE_REGRESSION_BISECTION.md`を参照する。

## 今回への適用

OptionalArrayのdirect access workloadはcommit `bf0259a0`で実装、専用library、暫定結果、chartまでを
独立して保存した。通常CI libraryへの登録は同commitを含むmerge commitがbaselineへ到達した後、
別taskとして実施する。外部性能アセスメントの正式化とは別の受入境界を維持する。
