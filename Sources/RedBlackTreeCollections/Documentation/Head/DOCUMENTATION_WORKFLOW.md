# Documentation Workflow

この文書は、公開ドキュメントを作成・更新する際の作業手順を定める。

## 基本方針

ドキュメントは、いきなり本文を完成させない。

まずアウトラインを確定し、その後に本文を作成する。

人間が構成と重要事項を決定し、AIはその決定に従って本文を生成・検証する。

## 役割分担

### ChatGPT

- アウトラインの叩き台を作成する
- 確定したアウトラインをもとに本文の叩き台を作成する
- 構成整理と言語化を主に担当する

### Human

- アウトラインを編集する
- 見出し構成を決定する
- 各節で扱う事項を決定する
- 必須のコード例や注意事項を決定する
- ドキュメントとして何を伝えるかを最終判断する

### Codex

- アウトラインをリポジトリの実装・API・テスト・設計資料と照合してレビューする
- 本文をリポジトリの実態と照合してレビューする
- 技術的な誤り、欠落、古い情報、不整合を修正する
- 最終的な表現とコード例を仕上げる
- 必要な成果物間の同期を行う

## Phase 1: Outline

1. ChatGPT がアウトラインの叩き台を作成する。
2. Human がアウトラインを編集し、構成と必須事項を決定する。
3. Codex がアウトラインをリポジトリと照合してレビューする。
4. 問題がなければ、そのアウトラインを本文作成の Source of Truth とする。

Codex は、アウトラインを単なる参考資料として扱わない。

見出し、論点、必須事項、コード例の要否は、明確な理由なく追加・削除・再構成しない。

実装との不一致や重要な不足を発見した場合は、それを指摘したうえで必要な修正を行う。

## Phase 2: Draft

1. ChatGPT が確定したアウトラインをもとに本文の叩き台を作成する。
2. Codex が本文をレビューする。
3. Codex が実装・API・テスト・設計資料と照合し、本文を仕上げる。

本文はアウトラインを満たす必要がある。

アウトラインに `コード例必須` とある節には、実際に利用可能なコード例を含める。

## Technical Review

Codex は、記述内容を推測だけで確定しない。

必要に応じて以下を確認する。

- public API
- implementation
- tests
- API Matrix
- design documentation
- complexity documentation
- existing documentation

特に以下を確認する。

- API 名と signature
- index semantics
- CoW semantics
- invalidation rules
- complexity
- availability
- code examples が現在の API で成立すること

リポジトリの実態と一般的な赤黒木・Swift・C++ の知識が異なる場合は、リポジトリの実態を優先する。

## Source of Truth

各型のアウトラインに Source of Truth が指定されている場合、そのアウトラインをドキュメント構成の正本とする。

技術的事実については、実装・テスト・設計資料など、それぞれの既存 Source of Truth を確認する。

アウトラインは実装仕様そのものを置き換えるものではない。

## Outputs

型ごとのアウトラインに指定された成果物を生成・同期する。

例:

- Japanese documentation
- English translation
- Swift documentation comment

翻訳版や Swift documentation comment を独立して成長させない。

正本から派生させ、意味上の差異を作らない。

## Editing Policy

ドキュメントを改善する際に、意味を勝手に拡張しない。

特に以下を避ける。

- 実装に存在しない機能の補足
- 一般論から推測した仕様の追加
- complexity の推測
- index semantics の一般的な Collection への類推
- implementation detail を public guarantee のように記述すること

文章表現は改善してよいが、技術的意味を変更する場合は根拠を確認する。

## Completion

作業完了時には、少なくとも以下を確認する。

- アウトラインの全項目が本文に反映されている
- 必須コード例が存在する
- public API と一致している
- complexity が正しい
- 日本語版・英語版・documentation comment の意味が一致している
- 古い API 名や削除済み仕様が残っていない
