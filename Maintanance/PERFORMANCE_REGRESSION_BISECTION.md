# Performance Regression Bisection

> 状態(2026-10-06): 2026-10-05の回帰調査は完了。本文前半は将来の回帰時にも使う手順、
> 「今回の調査記録」以降は完了した事例記録である。

## 目的

CI の performance job が回帰を報告したとき、同一環境・同一 baseline の測定で原因コミットを
隣接する2コミットまで絞るための記録である。

ベンチマークには測定揺れがある。過去のGitHub Actionsの単発結果が緑だったコミットでも、現在の
ローカル測定では閾値を超えることがある。したがって、履歴上の緑・赤だけを二分探索の判定へ混ぜず、
探索中は同じマシン、同じツールチェーン、同じbaseline、同じbenchmark設定を使う。

## CI相当の条件

2026-10-05時点のperformance jobは、baseと対象コミットをそれぞれReleaseで測定し、結果を比較する。
調査ではCIに合わせて次の条件を使用した。

- benchmark library: CIで使用するlibrary JSON
- 最大サイズ: `64k`
- cycles: `1`
- mode: `replace-all`
- 判定: performance regressionが30%以上で失敗

SwiftPMを一時worktreeで実行する際は、環境に応じて `--disable-sandbox` が必要になる。

## 調査手順

### 1. 作業中のbranchを変更しない

調査対象ごとに一時worktreeを作る。これにより、利用中のbranchを切り替えたり、未コミット差分を
退避したりせずに、複数コミットを同じ条件でビルドできる。

```sh
git worktree add /tmp/swift-ac-bench/base <baseline-commit>
git worktree add /tmp/swift-ac-bench/candidate <candidate-commit>
```

一時worktreeのパスは実行ごとに固有にする。実際の調査では `mktemp -d` 相当の専用directoryを使った。

### 2. baselineを一度測定する

```sh
cd /tmp/swift-ac-bench/base/Benchmarks
swift run --disable-sandbox -c release benchmark library run \
  --library <library.json> \
  ../results-base.json \
  --max-size 64k \
  --cycles 1 \
  --mode replace-all
```

探索中は同じ `results-base.json` と比較する。候補ごとにbaselineを測り直すと、環境変動が境界判定へ
混ざりやすくなる。

### 3. 最初に全タスクで再現する

CIで赤になったHEADを全benchmark taskで測り、ローカルでも同じ傾向が出ることを確認する。
再現しない場合は、すぐ履歴探索へ進まず、ツールチェーン、build configuration、library JSON、
比較方向を確認する。

### 4. 回帰を代表する小さいlibraryを作る

全タスクで再現した後、強く回帰したタスクだけを含む一時library JSONを作る。今回の調査では、
次の4タスクを使用した。

- `RedBlackTreeSet<Int> remove`
- `RedBlackTreeDictionary<Int, Int> subscript, insert, unique`
- `RedBlackTreeDictionary<Int, Int> subscript, remove existing, unique`
- `RedBlackTreeDictionary<Int, Int> defaulted subscript, _modify missing`

これは探索時間を短縮するための一時的な診断用libraryであり、CIの正式なcoverageを置き換えない。

### 5. ソース変更コミットを二分探索する

候補コミットを一時worktreeへcheckoutし、絞ったタスクを同じbaselineに対して測る。

```sh
cd /tmp/swift-ac-bench/candidate/Benchmarks
swift run --disable-sandbox -c release benchmark library run \
  --library <narrow-library.json> \
  ../results-candidate.json \
  --max-size 64k \
  --cycles 1 \
  --mode replace-all

swift run --disable-sandbox -c release benchmark results compare \
  ../../base/results-base.json \
  ../results-candidate.json
```

文書だけのコミットを測る必要はない。production source、Package.swift、benchmark構成など、生成物へ
影響するコミットをfirst-parent順で並べ、その中央を測る。

緑と赤の候補が隣接するまで繰り返す。原因コミットを主張する前に、必ず「最後の緑」と「最初の赤」の
両方を同じ条件で測る。

### 6. 最小差分で因果を確認する

最初の赤コミット上で疑わしい差分だけを一時的に戻し、性能が回復するか確認する。これは一時worktree
だけで行い、主作業branchへ実験差分を入れない。

境界の特定と差分の相関だけで修正を確定せず、最小差分のA/B測定で因果を確認する。

### 7. 修正後は正式CIで確認する

局所benchmarkが緑でも、正式な全タスク、Debug、Release、sanitizer等の代わりにはならない。
修正をコミット・プッシュし、CI全体で最終確認する。

## 2026-10-05の事例

### CIで観測した回帰

`try/index/1` のperformance jobで、主に次の回帰が報告された。

| Benchmark | Difference score |
| --- | ---: |
| Dictionary remove existing, unique | 1.330 |
| Set remove | 1.318 |
| Dictionary insert, unique | 1.270 |
| Dictionary defaulted subscript, `_modify` missing | 1.161 |

Dictionary removeとSet removeが30%回帰の閾値を超えた。

### GitHub結果とローカル結果の差

調査途中のあるコミットでは、GitHub performance jobは緑だった。一方、固定したローカル条件では同コミットも
赤となった。performance jobはそれ以前から存在していたため、「当時はjobがなかった」という説明は
成立しない。

この食い違いは探索を無効にしない。GitHub上の過去の単発判定をローカル探索の緑として使わず、全候補を
同じローカルbaselineに対して測定した。

### 二分探索結果

主要な測定結果は次のとおり。

| Measurement point | Local verdict | Notes |
| --- | --- | --- |
| 初期の中間候補 | green | 最大差は約1.066 |
| 次の中間候補 | green | 最大差は約1.104 |
| 後半の中間候補 | green | 最大差は約1.081 |
| 境界付近の候補 | green | 最大差は約1.121 |
| bridge protocol縮小後 | green | 最大差は約1.070 |
| multiplicity protocol縮小後 | red | 最大差は約1.458 |

隣接境界は次のとおり。

- 最後の緑: bridge protocol縮小後
- 最初の赤: multiplicity protocol縮小後

最初の赤となった変更のproduction source差分は、`UniqueMultiplicity` と `MultiMultiplicity` の宣言を
`public protocol` から `package protocol` へ変更した2箇所だった。

### 最小差分の確認

最初の赤の一時worktreeで2プロトコルのvisibility変更だけを戻すと、局所benchmarkは緑へ戻った。
さらに、意図した外部公開範囲を維持する最小のvisibility修正でも、4タスクすべてのdifference
scoreが1.05以下へ戻った。具体的な属性方針は、この公開用の障害調査記録では扱わない。

この事例では、コンパイルと機能テストだけでは検出されないコード生成上の回帰を、同一条件での
二分探索と最小差分A/B測定によって特定した。

## 記録に残す項目

将来の調査では、少なくとも次を記録する。

- CI runと失敗したbenchmark名
- baseline commitと対象commit
- Swift/toolchain、Release configuration、library JSON、max-size、cycles、mode
- 全タスクでの再現結果
- 絞り込み用タスク一覧
- 二分探索で測ったcommitと判定
- 最後の緑と最初の赤
- 最小差分A/B測定
- 採用した修正と正式CIの結果
