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

### 2026-10-09 実施結果

製品・Package・testの検証対象を`faad4760`（`Document permutation compatibility mode`）に固定し、
次を確認した。gate結果、Registry・handoff状態、CHANGELOGだけを加える記録commitを最終tag候補とし、
製品差分は`faad4760`から変えない。

- `swift test --disable-sandbox -c debug`: exit 0。
- `swift test --disable-sandbox -c release`: exit 0。Permutation 5件、OptionalArray 21件、
  BareArray 11件のDeath Testを含めて成功。
- `swift test --disable-sandbox -c debug --traits COMPATIBLE_ATCODER_2025`: exit 0。
  互換source、互換仕様test、`AcCollections`からの再公開を含む全package testが成功。
- `origin/main`との製品差分を確認。Package変更は`COMPATIBLE_ATCODER_2025` traitと対応define、
  公開面は通常版と排他的なAtCoder 2025互換API、再公開面は`AcCollections`のmode別testであり、
  互換計画に記録された意図と一致した。
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

以上から、製品差分とgate記録だけを含むcleanなcommitを対象として`0.5.0`をtag付け可能と判定する。

## tag作成

release gate成功後、Codexが対象commit、検証結果、既知事項を短く提示し、ユーザーが対象を確認する。
確認後に`0.5.0` tagを作成する。remoteへのpush、release page作成、配布はこのtaskへ自動的に含めず、
必要なら別途ユーザー承認を得る。

## 互換準備branchへの統合

`0.5.0` tag作成後、対象commitを既存branch `prepare/compatible/2`へmergeする。branchの切替、merge、
競合解消、pushは不可逆な外部影響を分離して扱い、実行直前に対象commitとbranchをユーザーへ確認する。
remoteへのpushはmergeの承認へ自動的に含めない。
