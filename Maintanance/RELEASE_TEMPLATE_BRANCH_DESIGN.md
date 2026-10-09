# Release template branch design

最終更新: 2026-10-09 / Codex

## 状態

設計ドラフト。`prepare/release/0`やrelease用branchの作成、workflow変更、source変換、tag、pushを
この文書だけでは許可しない。

## 目的

開発と内部管理の正本である`main`をそのまま配布せず、再現可能なrelease工程を組み込んだ
template branchから、versionごとのrelease treeを作る。

残りの`0.5.x`をrehearsal系列として工程を改善し、`0.6.0`を成熟した工程による最初の本運用候補とする。

## Branch topology

```text
prepare/release/0 ──┬─ prepare/release/1 ← main candidate
                    │       └─ transform → verify → tag
                    ├─ prepare/release/2 ← later main candidate
                    │       └─ transform → verify → tag
                    └─ ...
```

- `prepare/release/0`は製品releaseではなく、工程と検証のtemplateである。
- versionごとの`prepare/release/x`は`prepare/release/0`から作り、固定した`main`候補をmergeする。
- `/x`は`main`へmergeしない。検証済みの終端へannotated tagを作成して終了する。
- 次回の`/x`は前回tagや前回`/x`ではなく、更新済みの`prepare/release/0`から作る。
- `prepare/release/0`へ`main`を直接mergeしない。

## 責任境界

### `main`へ戻すもの

- 製品source、公開API、test、利用者向け文書の修正
- CHANGELOGなど、次の開発でも必要なrelease記録
- Package構成の製品上の修正

release工程中にこれらの修正が必要と判明した場合、`/x`だけで直さず`main`へ戻す。修正後はmain候補を
固定し直し、新しいmerge結果に対して必要なgateを再実行する。

### `prepare/release/0`へ還元するもの

- release専用workflowとtest runner
- 配布対象を検査するlint
- 通常版treeへの決定的な変換手順
- benchmarkのrelease profile
- release工程そのものの修正

製品差分やversion固有の測定結果はtemplateへ還元しない。

## Release treeの構成

### 残すもの

- `Sources`
- `Tests`
- `Benchmarks`
- `Package.swift`
- `README.md`、`README.ja.md`、`CHANGELOG.md`、`LICENSE`
- 正式な利用者向け文書
- release専用workflowと、tag treeを追試するために必要な最小script

`Benchmarks`はrelease性能gateだけでなく、利用者が性能主張を再現するための証拠として残す。

### 除外するもの

- `Maintanance`
- `AGENTS.md`
- `CLAUDE.md`
- `Utilities/Maintenance`
- 品質評価、内部設計、執筆workflow、outline、memoなどの内部文書
- 通常版から除く互換mode専用の利用者向け文書

`Utilities/Permutation`は通常版への変換検証中だけ使用し、最終的なtag treeから除外する。

## 通常版treeへの変換

`COMPATIBLE_ATCODER_2025`を未定義のまま残すのではなく、通常版として条件分岐を具体化する。

- `#if COMPATIBLE_ATCODER_2025`側は本文ごと除去する。
- `#if !COMPATIBLE_ATCODER_2025`側はguardを除き、本文を残す。
- `#if COMPATIBLE_ATCODER_2025 ... #else ... #endif`は通常版側だけを残す。
- 複合条件は通常版の真偽を代入して簡約する。
- 互換専用source、test、generator、文書はファイル単位の除外候補とする。
- `Package.swift`から互換mode固有の設定を整合する形で除く。

変換は手編集の集合ではなく、同じ入力から同じtreeを作れるscriptまたは明示的なpatchとして実装する。
変換後はtracked fileに`COMPATIBLE_ATCODER_2025`が残っていないことをlintする。

## Release専用gate

### Tree lint

- 除外対象のfile・directoryが存在しない。
- 内部文書が公開文書へ混入していない。
- `COMPATIBLE_ATCODER_2025`の条件や互換専用fileが残っていない。
- `Package.swift`が変換後のsource・test構成と一致する。
- worktreeがcleanで、gateが検証するcommitを一意に示せる。

### Tests

- `Tests`は選別せずtag treeへ残す。
- Debugでは`SKIP_DEBUG_LIFETIME_BALANCE_CHECKS`を有効にし、process-globalなallocation、node、payloadの
  寿命カウンタ等価検査だけを外す。
- Swift TestingとDeath Testを含む通常版の全testを実行する。
- Releaseでも通常版の全testを実行する。
- lifetime counterの構造検査やcounter resetまで外さない。
- Address Sanitizerの扱いは、この判断によって変更しない。

### Documentation

- 利用者向けdocumentationをwarning-as-errorで生成する。
- 公開文書から除外した内部資料へlinkしていないことを確認する。

### Performance

- 通常CIより大きな入力規模を含むrelease profileを使う。
- `16M`は候補値であり、対象、実行時間、memory上限、反復数とともに別途確定する。
- command、toolchain、runner情報、入力条件、結果をartifactとして保存する。
- tag treeに残る`Benchmarks`から利用者が同じ測定を再実行できるようにする。

## Versionごとの流れ

1. `main`で製品範囲、CHANGELOG、利用者向け文書、version固有のrelease記録を完成させる。
2. main候補commitを固定し、通常のlocal・remote gateを通す。
3. `prepare/release/0`から未使用の`prepare/release/x`を作る。
4. 固定したmain候補を`/x`へmergeする。
5. 決定的な通常版変換と配布対象の削除を実行する。
6. tree lintを通し、release tree commitを固定する。
7. release専用の全test、documentation、ASan、performance gateを同じcommitで通す。
8. Claudeが固定commit、CHANGELOG、tree、gate結果を変更せず独立確認する。
9. ユーザーへversion、tag予定commit、既知事項、次の操作一つを提示する。
10. 承認後、`/x`終端へannotated tagを作成する。
11. tagを読み戻し、別承認後にtagだけをpushする。
12. remote tagのpeeled commitを読み戻す。
13. 工程上の改善だけを別作業として`prepare/release/0`へ還元する。

## CHANGELOG gate

- `Unreleased`にrelease済みの項目を残さない。
- 当該versionの見出しには、そのversionの変更だけを置く。
- 前versionの項目を当該versionへ混在させない。
- main候補とrelease treeのCHANGELOGが、通常版への変換以外で食い違わない。
- Claude独立チェック前に、前tagから当該versionまでの見出しと実差分を照合する。

## 未確定の実装事項

- `prepare/release/0`を作る起点commitと、最初の`/x`番号
- 条件付きコンパイルを具体化するtoolの方式と検証fixture
- release benchmarkの対象、最大size、反復、時間・memory上限
- release専用workflowのtriggerと、branch protection上の必須job名
- release pageや配布artifactをこの工程へ含める時期

これらは設計ドラフトから実装taskへ移すときに、事実確認または一判断ごとのtaskへ分離する。
