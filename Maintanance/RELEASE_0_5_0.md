# 0.5.0 release task

最終更新: 2026-10-09 / Codex

## 目的

`0.5.0`固有の到達範囲を決め、その再現可能な節目をtag付けする。
tag地点、release gate、tag作成を分離し、未完了taskを暗黙に完了扱いしない。

## tag地点の判断

2026-10-08、ユーザー判断により、OptionalArrayの監査・ユーザードキュメント作業への引き渡しは
`0.5.0`と関係しないことを確定した。この地点と、そのために行ったPermutation、OptionalArray、
task管理方式の整理を、tag地点の根拠や到達範囲へ自動的に含めない。

2026-10-08、ユーザー判断により、PermutationのAtCoder 2025互換modeを完成させた状態を
`0.5.0`の製品上の到達点とする。確定済みの互換mode実施列を完了するまでrelease gateへ進まない。

## release gate

tag地点の到達後、Codexが対象commitを固定して次を確認する。

- package全体のDebug test。
- package全体のRelease test。
- 通常CIで走らないが、0.5.0の変更契約に必要なDeath Test。
- 公開API・再公開面・Package設定の意図しない差分。
- tag区間の変更概要と、外部待ち・凍結・1.0へ残す既知事項。
- tracked fileがcommit済みで、対象commitを一意に示せること。

性能比較は、0.5.0の到達範囲に性能変更の判定を含めると決めた場合だけ必須にする。未計測事項を
release gate成功によって解消済みとは扱わない。

### 2026-10-09 初回実施結果と再検証

製品・Package・testの検証対象を`faad4760`（`Document permutation compatibility mode`）に固定し、
次を確認した。gate結果、Registry・handoff状態、CHANGELOGだけを加える記録commitを最終tag候補とし、
製品差分は`faad4760`から変えない。

- `swift test --disable-sandbox -c debug`: exit 0。
- `swift test --disable-sandbox -c release`: exit 0。Permutation 5件、OptionalArray 21件、
  BareArray 11件のDeath Testを含めて成功。
- 当初はPackage traitで互換構成も検証したが、0.5.0の公開構成には不要とのユーザー判断により
  traitを撤回した。互換sourceと仕様testは後続の`prepare/compatible/2`でbranch defineから使用する。
- `origin/main`との製品差分を確認。0.5.0の既定公開面は通常Permutationだけとし、Package traitを
  追加しない。
- 前回tag `0.4.4`からの区間は950 commits。製品上の追加・変更・修正・削除は
  `CHANGELOG.md`の`Unreleased`節を要約正本とし、今回の互換modeを追記した。
- worktreeは検証開始時にcleanで、検証対象commitを一意に確認した。

既知事項はrelease gateを妨げないものとして残す。

- `Container.Index`要件は外部の`swift-collections`安定待ち。
- Permutationのstrict memory safety再検討は後続へ凍結し、現行警告を解消済みとは扱わない。
- 通常版・互換版のCI job分離は、tag後に`prepare/compatible/2`へ統合してから行う。
  互換性能計測は行わない。
- ABC328Eの実提出確認はユーザー専用作業として残る。ローカルでは公式sample `33`を確認済み。
- 1.0品質判断、BareArray再開、OptionalArray品質再評価など、Registryで凍結または後続goalに
  置かれた事項は0.5.0で完了扱いにしない。

初回判定後、Package traitを追加するとDocC pluginのsymbol抽出が全traitを有効化し、通常版DocCが
互換RedBlackTreeのsymbol graphへ接続されて失敗することがCIで判明した。trait撤回後の通常Debug、
Release、documentation CIと最終差分を再確認するまで、tag可能の最終判定を保留する。

trait撤回後、cleanなscratch directoryでCIと同じ`generate-documentation --warnings-as-errors`を実行し、
exit 0を確認した。`AcCollections`から通常版Permutation APIへ到達するtestも成功した。remote CIの
再実行で通常Debug・Release・documentationを最終確認する。

remote CIでは通常Debug・Release・documentation・Address Sanitizerが成功した一方、performanceで
Permutation sequential subscriptがbaseline比`0.7247`となり30%閾値を超えた。通常sourceの製品差分は
公開入口を囲む`#if !COMPATIBLE_ATCODER_2025`だけだったため、0.5.0からこの条件も撤回し、
`origin/main`と同じ無条件compileへ戻した。再push後のperformanceを含むCI全体を最終確認する。

Claudeの独立生成コード比較では、macOS arm64・Swift 6.4の同一Release条件でbaseline、条件付き版、
撤回後版のhot path命令列が一致し、protocol / value witness table参照と特殊化失敗はなかった。
Linuxの実benchmarkではないため回帰原因の断定には使わず、少なくとも条件コンパイルがwitness経由へ
落としたという仮説を支持しない証拠として扱う。

続く実benchmarkの反復では、macOS arm64上で既知green / redを交互に各3回測定し、当該taskの
green / red中央値は`1.0053`、比較toolは三組とも差なしだった。size単位では`0.5〜2.024`まで揺れ、
回帰を再現しなかったためcommit二分探索は停止した。通常source撤回後のremote CIを先に確認し、
再び赤の場合だけ記録済みのLinux候補列で調査する。

最終的にbuffer header initializerとdebug probe initializerを`@inlinable`、buffer subscript getterを
`@inline(__always)`として最適化判断を明示した。PR #175のhead `f01c66a6`でDebug、Release、
documentation、Address Sanitizer、performanceの全jobが成功し、同じtreeを持つ`main`のmerge commit
`0dc1bd26`を最終tag対象としてrelease gateを完了した。

## tag作成

release gate成功後、Codexが対象commit、検証結果、既知事項を短く提示し、ユーザーが対象を確認する。
確認後に`0.5.0` tagを作成する。remoteへのpush、release page作成、配布はこのtaskへ自動的に含めず、
必要なら別途ユーザー承認を得る。

2026-10-09、ユーザー確認後、`0dc1bd26`へannotated tag `0.5.0`（message `Release 0.5.0`）を
作成した。tagのremote pushはこの時点では行っていない。

## 互換準備branchへの統合

`0.5.0` tag作成後、対象commitを既存branch `prepare/compatible/2`へmergeする。branchの切替、merge、
競合解消、pushは不可逆な外部影響を分離して扱い、実行直前に対象commitとbranchをユーザーへ確認する。
remoteへのpushはmergeの承認へ自動的に含めない。
