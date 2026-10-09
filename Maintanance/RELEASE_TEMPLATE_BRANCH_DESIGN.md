# Release template branch design

最終更新: 2026-10-09 / Codex

## 状態

2026-10-09、release rehearsalを設計していた前任conversationの意図と途中経過が失われ、そのままでは
安全な再開が困難なため、関連taskとともに凍結した設計ドラフト。
ユーザーの明示的な再開指示があるまで、`prepare/release/template`やrelease用branchの作成、workflow変更、
source変換、test、benchmark、tag、pushを進めない。この文書だけでは再開や各操作を許可しない。

### 前任conversationの残存資料

以下は前任conversationが残した設計内容である。現在のCodexには、その選択へ至った意図、検討途中の状態、
各項目間の優先関係を十分に復元できない。したがって既決事項や再開指示として扱わず、当面削除せずに保存する
参考資料とする。再開時は、ユーザーの明示指示を受けて目的と境界を確定し直し、採用できる部分だけを選ぶ。

- `prepare/release/template`からversion別`release/<version>`を作り、固定したmain候補をmergeする。
- version別branchはmainへ戻さず、検証済み終端への同version tagで完成とする。
- 内部管理資産と内部文書をrelease treeから除き、Testsと再実行可能なBenchmarksは残す。
- 通常版変換では`COMPATIBLE_ATCODER_2025`を具体化し、`Utilities/Permutation`は最終treeから除く。
- release専用workflowはmain用workflowと別fileにし、version別branchのremote pushはユーザー操作とする。
- benchmark結果はCI artifactへ保存し、直前release tagを同一runner・同一定義で測るbaselineとする。

残存記録上は、実際の変換、allowlist、workflow、lint、test、benchmarkで成立させる試行と、0.5.1実績を
汎用checklistへ反映する作業が未完に見える。ただし、これが完全な残作業一覧であることや、同じ順序で再開
できることは確認できない。凍結時点のworktreeにある未追跡`Utilities/Release/`はPython bytecode cacheだけで、
設計成果または再開可能な実装として扱わない。

## 目的

開発と内部管理の正本である`main`をそのまま配布せず、再現可能なrelease工程を組み込んだ
template branchから、versionごとのrelease treeを作る。

残りの`0.5.x`をrehearsal系列として工程を改善し、`0.6.0`を成熟した工程による最初の本運用候補とする。

## Branch topology

```text
prepare/release/template ──┬─ release/0.5.2 ← main candidate
                           │       └─ transform → verify → tag 0.5.2
                           ├─ release/0.5.3 ← later main candidate
                           │       └─ transform → verify → tag 0.5.3
                           └─ ...
```

- `prepare/release/template`は製品releaseではなく、工程と検証のtemplateである。
- versionごとの`release/<version>`はtemplateから作り、固定した`main`候補をmergeする。
- `release/<version>`は`main`へmergeしない。検証済みの終端へ同じversionのannotated tagを作成した時点で
  完成とし、以後commitを追加しない。
- 次回のrelease branchは前回tagや前回release branchではなく、更新済みのtemplateから作る。
- `prepare/release/template`へ`main`を直接mergeしない。

## 責任境界

### `main`へ戻すもの

- 製品source、公開API、test、利用者向け文書の修正
- CHANGELOGなど、次の開発でも必要なrelease記録
- Package構成の製品上の修正

release工程中にこれらの修正が必要と判明した場合、release branchだけで直さず`main`へ戻す。修正後はmain候補を
固定し直し、新しいmerge結果に対して必要なgateを再実行する。

### `prepare/release/template`へ還元するもの

- release専用workflowとtest runner
- 配布対象を検査するlint
- 通常版treeへの決定的な変換手順
- benchmarkのrelease profile
- release工程そのものの修正

製品差分やversion固有の測定結果はtemplateへ還元しない。

release専用workflowはmain用`.github/workflows/swift.yml`と別file名でtemplateへ置き、version別branchの
変換時にmain用workflowを除外する。同じfileを両branchで変更して毎回競合する構造を作らない。

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

### File allowlist

release treeは「削除対象らしい名前」を推測する方式ではなく、次の配布目的ごとのallowlistと、その補集合を
検査するmanifestで構成する。新規fileは自動的に配布せず、どの目的で必要かを確認してallowlistへ加える。

| 目的 | 残すpath | 除外する代表例 |
| --- | --- | --- |
| Package | `Package.swift` | 変換後に存在しないpathを指す`exclude`設定 |
| 製品source | `Sources/**`のbuild入力、`Sources/**/*.docc/**` | module内の品質評価、内部設計、草稿、memo、互換専用source |
| Test | `Tests/**`のtest・fixture sourceと実行時resource | `Tests/CLAUDE.md`、`Tests/TESTING.md`、`Tests/Archived/**`、fixture作業文書 |
| 利用者文書 | root README、CHANGELOG、LICENSE、通常版のtop-level `Documentation` | `Documentation/Compatibility/**`、内部評価・設計・執筆資料 |
| Benchmark | `Benchmarks/Package.swift`、`Benchmarks/Sources/**`、release profileと再実行script | ad-hoc profile、絶対path依存script、過去の結果・chart・作業出力 |
| Release工程 | release専用workflow、tree変換・lint・検証に必要な最小script | main用workflow、AI運用・task管理資産 |

`Benchmarks/Results/**`はtag treeへ含めない。release測定のresult、比較、CPU・toolchain情報、実行binary、
symbol、assemblyは、tag対象と同じcommitを入力にしたCI artifactとして保存する。tag treeには利用者が
同じ測定を追試できるbenchmark source、profile、commandを残す。

内部文書を削除した結果、`Package.swift`の`exclude`が存在しないpathを指す場合は、変換時にその設定も
除去する。最終的なPackage manifestは変換後treeだけを参照し、SwiftPMの未処理file警告を出さないことを
gateで確認する。

2026-10-09、Swift 6.2の最小fixtureで、存在しないtarget `exclude`はbuildを失敗させない一方、
`Invalid Exclude ... File not found`警告を`swift package describe`と`swift build`の両方で出すことを確認した。
したがって、release変換では削除済みpathの`exclude`を残さない。

## 通常版treeへの変換

`COMPATIBLE_ATCODER_2025`を未定義のまま残すのではなく、通常版として条件分岐を具体化する。

- `#if COMPATIBLE_ATCODER_2025`側は本文ごと除去する。
- `#if !COMPATIBLE_ATCODER_2025`側はguardを除き、本文を残す。
- `#if COMPATIBLE_ATCODER_2025 ... #else ... #endif`は通常版側だけを残す。
- 複合条件は通常版の真偽を代入して簡約する。
- 互換専用source、test、generator、文書はファイル単位の除外候補とする。
- `Package.swift`から互換mode固有の設定を整合する形で除く。

変換は手編集の集合ではなく、同じ入力から同じtreeを作れるscriptまたは明示的なpatchとして実装する。
変換後は、Swiftの`#if`・`#elseif`条件式と`Package.swift`のdefineに
`COMPATIBLE_ATCODER_2025`が残っていないことをlintする。CHANGELOG、コメント、過去の説明など、
コンパイルへ影響しない地の文はこのlintの対象にしない。

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
- Linuxでは`ENABLE_DEATH_TESTS`も有効にし、Swift TestingとDeath Testを含む通常版の全testを実行する。
- Releaseでも通常版の全testを実行する。
- lifetime counterの構造検査やcounter resetまで外さない。
- 変換後treeでは寿命カウンタの釣り合いをrelease gateの証拠にしない。釣り合い検査は変換前のmain候補で
  完了させ、変換後treeではSwift Testingを含む全testの実行を優先する。
- Address Sanitizerの扱いは、この判断によって変更しない。

### Documentation

- 利用者向けdocumentationをwarning-as-errorで生成する。
- 公開文書から除外した内部資料へlinkしていないことを確認する。

### Performance

- 通常CIより大きな入力規模を含むrelease profileを使う。
- `16M`は候補値であり、対象、実行時間、memory上限、反復数とともに別途確定する。
- baselineは直前のrelease tagとし、candidate側で固定したrelease profile・benchmark定義をbaselineと
  candidateの双方へ適用する。0.5.2では`0.5.1`を比較対象とする。
- command、toolchain、runner情報、入力条件、結果をartifactとして保存する。
- baselineとcandidateは同じrunner job内で測定し、両方のcommit、tree、実行順、個別結果を保存する。
- tag treeに残る`Benchmarks`から利用者が同じ測定を再実行できるようにする。
- `Benchmarks/Results/**`の過去の実験結果はbaselineとして暗黙採用せず、releaseごとの比較基準を明示する。

## Versionごとの流れ

1. `main`で製品範囲、CHANGELOG、利用者向け文書、version固有のrelease記録を完成させる。
2. main候補commitを固定し、通常のlocal・remote gateを通す。
3. `prepare/release/template`から`release/<version>`を作る。
4. 固定したmain候補をrelease branchへmergeする。
5. 決定的な通常版変換と配布対象の削除を実行する。
6. tree lintを通し、release tree commitを固定する。
7. localで実行するrelease専用gateを同じcommitで通す。
8. 対象branchとcommitを提示し、ユーザー操作で`release/<version>`をremoteへpushする。
9. release専用のremote CIで全test、documentation、ASan、performance、tree lintを同じcommitに通す。
10. Claudeが固定commit、CHANGELOG、tree、gate結果を変更せず独立確認する。
11. ユーザーへversion、tag予定commit、既知事項、次の操作一つを提示する。
12. 承認後、release branch終端へ同じversionのannotated tagを作成し、branchを完成扱いとする。
13. tagを読み戻し、別承認後にtagだけをpushする。
14. remote tagのpeeled commitを読み戻す。
15. 工程上の改善だけを別作業として`prepare/release/template`へ還元する。

## CHANGELOG gate

- `Unreleased`にrelease済みの項目を残さない。
- 当該versionの見出しには、そのversionの変更だけを置く。
- 前versionの項目を当該versionへ混在させない。
- main候補とrelease treeのCHANGELOGが、通常版への変換以外で食い違わない。
- Claude独立チェック前に、前tagから当該versionまでの見出しと実差分を照合する。

## 未確定の実装事項

- `prepare/release/template`を作る起点commit
- 条件付きコンパイルを具体化するtoolの方式と検証fixture
- release benchmarkの対象、最大size、反復、時間・memory上限、失敗閾値
- release専用workflowのtriggerと、branch protection上の必須job名
- release pageや配布artifactをこの工程へ含める時期

これらは設計ドラフトから実装taskへ移すときに、事実確認または一判断ごとのtaskへ分離する。
