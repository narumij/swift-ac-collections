# 0.5.0 release task

最終更新: 2026-10-08 / Codex

## 目的

`0.5.0`を、現在進行中の体系監査と利用者向け文書準備に対する再現可能な節目としてtag付けする。
tag地点、release gate、tag作成を分離し、未完了taskを暗黙に完了扱いしない。

## tag地点の判断

第一候補は、OptionalArrayをCodexのユーザードキュメント作業フェーズへ引き渡せる状態にしたcommit。
この候補では、少なくとも次を0.5.0の到達範囲として説明できる。

- Permutationの公開面、名称、仕様test、品質評価の整理。
- OptionalArrayの公開契約監査、名称・次元・不正次元契約の判断、Test as Specification整理。
- RedBlackTreeの主要な安全性・Index周辺整理。ただし外部待ちのIndex最終契約は未完了として明記する。
- Registryを中心とするtask管理と、Codex統合・Claude限定委譲の作業方式。

この第一候補でtagを振るか、別の到達点まで待つかをユーザーとCodexが一つだけ決定する。
決定前にrelease gateやtag作成へ進まない。

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
