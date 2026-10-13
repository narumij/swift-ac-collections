# Benchmark利用ガイド

## 目的と正本範囲

この文書は、CodexとClaudeがこのrepositoryのbenchmarkを測定、比較、chart化するときの共通入口である。
benchmarkのtask定義と登録は`Benchmarks/Sources/`、chartとtaskの構成は`Benchmarks/Libraries/`、
実行可能なCLIはbenchmark executableと依存packageが正本である。この文書はそれらを再定義しない。

個別の品質判定、性能目標、受入水準は各moduleの品質文書が持つ。performance CIの変更境界は
`PERFORMANCE_CI_CHANGE_GUIDE.md`、回帰の履歴探索は
`Archived/Canonical/PERFORMANCE_REGRESSION_BISECTION.md`を参照する。

## 最初に区別すること

同じbenchmark toolを使っても、次の仕事は別である。

- **探索測定:** 仮説を絞るための局所測定。正式な品質証拠とは限らない。
- **回帰比較:** 同じworkloadをbaseとheadで測り、変更前後の差を調べる。
- **品質アセスメント:** 比較対象、入力、環境、統計、保証境界を固定して製品品質を評価する。
- **chart再生成:** 既存の生JSONを描画する。再測定ではない。

依頼に`chartを作る`とだけ書かれている場合、まず既存library JSONと`benchmark library render`が
何を測り、どう描画するかを確認する。その上で、目的に合わせてtask、軸、統計、比較系列、注記、または
独自の作図をアレンジしてよい。アレンジ後は、生JSON、task、集約方法、chartの線とbandが対応しているかを
確認する。CIのbase/head診断chartと、C++・Swift標準型・本製品を同じworkloadで比較する品質chartは
目的が異なる。

## 基本操作

コマンドは原則として`Benchmarks/`から実行する。

### 登録済みtaskを直接測る

対象taskをfilterで限定する探索向けの入口である。

```sh
swift run -c release benchmark run \
  --filter '<task-name-or-regular-expression>' \
  --sizes 16 256 4096 \
  --cycles 5 \
  --mode replace-all \
  <result.json>
```

実際のoptionは現在のCLI helpを確認する。過去文書のcommandを、現在も有効だと推定して使わない。

### libraryに定義された一組を測る

library JSONは、測定taskの選択だけでなく、group、chart、表示名、出力構成も定める。

```sh
swift run -c release benchmark library run \
  --library ./Libraries/<Library>.json \
  <result.json> \
  --max-size 64k \
  --cycles 5 \
  --mode replace-all
```

- `replace-all`は出力JSONを今回の測定で置き換える。
- `append`は、CIの大小別libraryのように、同じ結果へ別のtask群を追記する場合にだけ使う。
- task名がbenchmark binaryに登録されていなければ`unknown tasks`で失敗する。これは性能回帰ではなく、
  libraryとbenchmark sourceの比較構成が成立していない状態である。

### 既存結果から標準chartを生成する

```sh
swift run -c release benchmark library render \
  --library ./Libraries/<Library>.json \
  <result.json> \
  --format png \
  --multifile \
  --output <chart-directory>
```

必要に応じて`--amortized false`、`--percentile`、時間軸の上下限を指定する。ただし、既存の正式scriptや
評価計画が値を固定している場合はそれに従う。標準出力が目的を十分に表さない場合は別のchartへ
アレンジしてよいが、標準chartの意味を理解せず見た目だけを再現しない。`render`は既存JSONを描画する
だけで、測定条件やsample数を改善しない。

標準chartのbandと中心線を説明するときは、使用したcyclesとpercentileを確認する。既存の5-cycle、
`--percentile 50`の事例では、最速側3 sampleを残し、bottomがmin、centerがその平均、topが平均+2σである。
これを「5 sampleのmedian」と呼ばない。

### 二つの結果を比較する

```sh
swift run -c release benchmark results compare \
  <base.json> \
  <head.json>
```

標準toolでbase/headの重ね描きchartも生成できる。

```sh
swift run -c release benchmark results compare \
  <base.json> \
  <head.json> \
  --chart-labels base head \
  --chart-cutoff 0 \
  --format png \
  --multifile \
  --output <chart-directory>
```

`--chart-labels`は空白区切りで2値を渡す。`--chart-cutoff`の既定値は1.10で、差が小さいtaskのchartは
生成されない。全対象を観察する場合は0を明示する。

compareのsizeごとの係数は`min(base) / min(head)`で、1より大きければheadが速い。表示される`Sum`は
全sizeの係数の算術平均であり、幾何平均ではない。`Score`は、`Sum`が1以上ならそのまま、1未満なら
`1 / Sum`として方向を畳んだ値である。`Improvements`と`Regressions`は各方向の係数だけを合計し、
反対側のsizeを1として数えた平均で、括弧内の`#`はその方向に分類されたsize数を示す。

引数順を固定し、比較方向を結果と一緒に記録する。task名が同じでもworkload、入力生成、timed region、
build構成が違えば、同じ性能を比較したことにはならない。

## Repository内の既存入口

まず、目的に合う既存scriptとlibraryを探す。

- `Benchmarks/run-bare-array-assessment.sh`
- `Benchmarks/run-permutation-assessment.sh`
- `Benchmarks/Libraries/CI.json`と`CI-Small.json`
- `Benchmarks/QualityAssessment/macOS/*/README.md`

品質アセスメント用scriptは、commit、OS、hardware、Swift、Clang、生JSON、chartを同じ測定IDへ結びつける。
同種の測定で、この証拠採取を手作業で弱くしない。

## Performance CIの手動比較

GitHub Actionsの`CI` workflowは、PR更新なしでもperformance比較を実行できる。

1. `Actions`から`CI`を開き、`Run workflow`を選ぶ。
2. `Use workflow from`で、手動入力対応を持つbranchを選ぶ。
3. `performance_base_ref`へ比較元のbranch、tag、またはcommit SHAを入れる。
4. `performance_head_ref`へ比較先を入れる。空欄なら選択したworkflow branchのcommitを使う。

再現調査では、移動するbranch名よりcommit SHAを優先する。artifact内の
`comparison-refs.txt`には、要求されたrefと実際にcheckoutされたSHAが記録される。後から付けるartifactの
directory名は、この解決済みSHAを確認して`<head-short-sha>-vs-<base-short-sha>`とする。

## 証拠として残すもの

正式測定または再利用する調査では、少なくとも次を対応付ける。

- base/headまたは対象commitの完全なSHA;
- OS、architecture、CPU/hardware、Swift、必要ならClang;
- Release等のbuild configurationと実行command;
- 使用したlibrary JSON、task名、sizes、cycles、mode、percentile;
- 生の結果JSON;
- compareのtext出力;
- chartと、そのchartが表す統計;
- 失敗、skip、not run、測定揺らぎ、対象外の範囲。

CI artifactに実測binary、symbol table、assemblyが含まれる場合、hot pathの議論ではそれを優先する。
別machineや別buildのassemblyを、CIで実際に測定されたbinaryの代用にしない。

既存のbenchmark executableで`render`または`compare`だけを行う場合は、再測定とは分けてよい。ただし、
executableのbuild元が対象sourceと一致するかを確認し、確認できなければ由来不明として記録する。
`swift run`は必要に応じて再buildするため、既存結果を読むだけの操作でも実行経路を記録する。

## 解釈上の境界

- chartの見た目だけで合否や原因を決めない。
- 一回のcycleではsample分散を評価できない。chartにmin、mean、mean+2σのband表記があっても、1 sampleなら
  三者は一致して帯が一本の線になる。
- Debug、Release、`-Ounchecked`を互いの適合証拠として読み替えない。
- toolchain、OS、architecture、CPUが異なる測定から、source変更の因果を直接断定しない。
- benchmark harnessの変更とproduction sourceの変更を分離する。
- 名前変更をまたぐ場合、名前を正規化しただけでworkloadが同一になったとはみなさない。
- `let`、`var`、escaping capture、借用、timed regionの違いは、生成コードと結果へ影響し得る。
- C++との比較では、FFI overheadをSwift operationの性能へ混ぜない。

AI同士の解釈が一致しても性能事実にはならない。生JSON、実SHA、実測binary、再現commandなど、答えを
持つartifactへ戻って確認する。

## 変更するとき

既存libraryへtaskを追加する前に、そのtaskが比較対象のbaseとheadの両方で解決できるか確認する。
新しいworkloadは、原則として実装を先にmergeし、そのcommitをbaselineにしてから後続変更でCI libraryへ
登録する。詳しい導入順序と過去の失敗事例は`PERFORMANCE_CI_CHANGE_GUIDE.md`を使う。

このガイドに不足が見つかっても、個別の調査記録をそのまま一般規則へ昇格しない。再利用できる操作、
繰り返し起きる誤り、証拠境界だけをここへ戻す。
