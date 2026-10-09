# Release専用Task Registry設計

最終更新: 2026-10-09 / Codex

## Task

- 種別: `DISCOVERY`
- 担当: User / Codex
- 状態: `PROPOSED`
- 再開条件: 0.5.2 release完了後、今回の実績を入力としてユーザーとCodexが設計を開始する。

## 目的

release候補commitを固定した後も、候補treeを変更せずにgate、判断、権限、実績、次の操作を更新できる
release専用Task Registryを設計する。

## 発見の根拠

0.5.2ではremote CI green後、通常のTask Registryとrelease正本へrelease可否を記録した結果、候補commitが
変わり、再pushと同一commitへのCI再実行が必要になった。task分解や依存の組み替えでは解消できない、
記録の保存場所と候補treeの結合が原因だった。

## 設計対象

- 固定候補のbranch、commit SHA、tree。
- local gate、remote CI、documentation、性能、独立確認の状態と証拠。
- ユーザー判断と、merge、tag、push、公開に関する操作権限。
- 次に許可される操作とhard stop。
- release完了後に通常Task Registryとversion固有正本へ還元する内容と時点。
- branch切り替え、別worktree、事故復旧、削除操作に対する保存性。
- 生成された実行用正本だけを読んでもrelease中のtask運用を再開できる、task運用summary。

## 実行用正本に内包するtask運用summary

version別のrelease実行taskには、チェック項目だけでなく、少なくとも次の運用規則を短く載せる。

- 現在の中間ゴール、固定候補、完了条件を先に確認する。
- `DISCOVERY`、一判断だけを閉じる`DECISION`、判断済み事項だけを扱う`EXECUTION`を混在させない。
- 一つのユーザー判断taskでは一問だけを尋ね、複数の判断が必要なら先にtaskを分解する。
- 依存が完了していても現在のゴールに必要とは限らないため、`DIRECT`、`NEAR`、`FAR`、`LATER`、
  `OUTSIDE`で距離を確認してから次を選ぶ。
- 判断材料が不足している場合は、直ちにユーザー判断へ送らず、既決事項、実装、test、CIを先に調べる。
- `USER_ONLY`の操作はagentが実行、代行、承認依頼、催促をしない。
- merge、tag作成、tag push、release pageなど、権限が分かれた操作を一つの承認へ束ねない。
- 候補固定後は通常Task Registry、version固有release正本、CHANGELOGを含む候補treeを更新せず、release中の
  状態と証拠はgitignoreされた実行用正本だけへ記録する。
- 候補が変わった場合は、影響するgateを同じcommitへ取り直す。greenだった旧commitの証拠を流用しない。
- release完了後、新しい作業branchで実績と再利用可能な教訓を通常Registryと正本文書へ還元する。

このsummaryは`TASK_ORIENTATION.md`全体の複製ではなく、release中に停止・再開・権限判断を誤らないための
最小版とする。

## 現在の案

repository直下のgitignore対象`_ReleaseTask/`にversion別の実行中正本を置き、候補branchを切り替えても同じ
workspaceから参照する案がある。候補treeを動かさない利点がある一方、別worktree、clone、別端末へ自動では
引き継がれず、`git clean -fdx`で失われる。この案はまだ採用決定ではない。

## Discoveryの出力

1. 正本の配置と永続化方式の候補、利点、失敗条件を比較する。
2. Registryの最小schemaとlife cycleを定める。
3. checklistとtask運用summaryを含むversion別実行taskのtemplateを定める。
4. 通常Task Registry、version固有release正本、CI、PRとの責任境界を定める。
5. ユーザー判断が必要な論点を、一判断ごとの`DECISION` taskへ分離する。
6. 判断不要の作成、検証、移行を`EXECUTION` taskへ分離する。

## 完了条件

- 候補commitを動かさずにrelease進捗を更新できる構造が説明されている。
- branch切り替えと事故復旧を含む保存性が評価されている。
- 生成された実行用正本だけで、release taskの再開と次の操作の判定ができる。
- 一つのtaskへ複数のユーザー判断を束ねていない。
- 採用判断と実装taskがTask Registryへ登録され、依存関係が明示されている。

このDISCOVERY自体は配置方式を採用せず、`_ReleaseTask/`の作成や`.gitignore`変更も行わない。
