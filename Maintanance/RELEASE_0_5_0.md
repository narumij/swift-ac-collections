# 0.5.0 release task

最終更新: 2026-10-08 / Codex

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

## tag作成

release gate成功後、Codexが対象commit、検証結果、既知事項を短く提示し、ユーザーが対象を確認する。
確認後に`0.5.0` tagを作成する。remoteへのpush、release page作成、配布はこのtaskへ自動的に含めず、
必要なら別途ユーザー承認を得る。

## 互換準備branchへの統合

`0.5.0` tag作成後、対象commitを既存branch `prepare/compatible/2`へmergeする。branchの切替、merge、
競合解消、pushは不可逆な外部影響を分離して扱い、実行直前に対象commitとbranchをユーザーへ確認する。
remoteへのpushはmergeの承認へ自動的に含めない。
