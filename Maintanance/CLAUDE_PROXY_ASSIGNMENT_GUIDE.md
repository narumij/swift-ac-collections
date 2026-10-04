# Claude代理発注手順書

Codexが不在または利用上限に達している間に、ユーザーがChatGPT（以下「代理発注者」）へ
Claude向け作業の整理と発注文作成を依頼するための手順書である。

代理発注者はClaudeの代わりに実装する担当ではない。リポジトリの現在状態と既存方針を
確認し、安全で検証可能な一作業へ切り分け、`Maintanance/CLAUDE_TASK.md`へ記録する。
Claudeチャットの開始・再開はユーザーが行う。

## ユーザーから代理発注者への最短依頼

次の一文でよい。

> `Maintanance/CLAUDE_PROXY_ASSIGNMENT_GUIDE.md`に従って、Claudeへ次の作業を代理発注して。
> 対象は「ここへ目的を書く」。

障害対応なら、エラー全文または「いま失敗しているコマンド」も添える。添付がなくても、
代理発注者はリポジトリ内で安全に確認できる範囲から調査を始める。

## 代理発注者が最初に確認するもの

1. `git status --short --branch`でbranch、dirty tree、merge/rebase/cherry-pick状態を確認する。
2. `CLAUDE.md`、`Tests/CLAUDE.md`、`Tests/TESTING.md`を読む。
3. `Maintanance/CLAUDE_TASK.md`のStatusを確認する。`Assigned`または未完の作業があれば、
   上書きせずユーザーへ知らせる。
4. 対象領域の正本を確認する。
   - 赤黒木の残件と依存順: `RED_BLACK_TREE_REMAINING_TASKS.md`
   - 全体進捗: `PROGRESS_OVERVIEW.md`
   - 公開面: `EXTERNAL_TYPE_EXTENSION_AUDIT.md`
   - C++比較: `CPP_BEHAVIOR_COMPARISON_MATRIX.md`
   - テスト運用: `Tests/TESTING.md`
5. ユーザー変更、未コミット差分、進行中のGit操作を依頼対象と区別する。

確認はread-onlyを基本とする。発注準備のためにbuildや全testを先に走らせない。エラー再現が
依頼範囲の確定に不可欠な場合だけ、最小のread-only検証を行う。

## 発注可能かの判定

次の条件をすべて満たす作業だけを発注する。

- 目的と完了条件を一文で説明できる。
- 編集可能なファイルまたは領域を限定できる。
- 禁止事項と守る既存契約を列挙できる。
- 最小検証と、必要なら広い検証を区別できる。
- 公開APIや設計判断をClaudeが独断で確定しなくてよい。
- commit、push、merge、branch操作が不要、またはユーザーが明示的に許可している。

次の場合は発注せず、ユーザーの判断を求める。

- 既存のactive assignmentと競合する。
- 公開API、互換性、データ削除、履歴改変、branch統合方針を選ぶ必要がある。
- dirty treeの所有者や意図を判別できない。
- 複数の有力案で成果物が大きく変わる。
- repository外へのアクセスや外部サービス上の変更が必要である。

## 作業単位

一回の依頼は原則として次のいずれか一つにする。

- read-only監査と結論
- 一つの不具合の再現、局所修正、回帰test
- 一つの公開面縮小batch
- 一つの文書と実装・testの同期
- 一つのbuild/CI障害の診断と修正

「残りを全部」「ついでに整理」「関連箇所を全面改修」のような依頼にしない。横展開が
必要なAPIでは対象型を明記する。大きな作業は、調査、判断、実装、検証へ分割する。

## `CLAUDE_TASK.md`へ書く必須項目

代理発注者は`Status: Assigned`へ変更し、`## Active assignment`を次の内容で置き換える。
過去のCompleted assignmentは削除しない。

1. **Objective**: 達成する結果。
2. **Context**: 現在のbranch、関連する既知の判断、正本。
3. **Allowed scope**: 読み取り・編集してよいファイルまたは領域。
4. **Required work**: 調査・実装・test・記録の順序。
5. **Must preserve**: 既存契約、ユーザー差分、設計上の意図。
6. **Do not**: 無関係なcleanup、設計決定、Git操作などの禁止事項。
7. **Validation**: 実行対象と成功判定。testが実際に発見・実行されたことも確認する。
8. **Handoff**: 詳細を記録する場所、block時に必要な証拠。

Claudeへの標準終了指示は次のとおり。

> Set this task to `Completed`, append the result and validation evidence below the
> assignment, and report only `完了` to the user. Put technical details in this Markdown
> file. Explain directly only when blocked, when a safety issue is found, or when a
> product-owner decision is required.

## 標準的な権限境界

ユーザーの明示許可がなければ、次を依頼に含めない。

- commit、push、pull、merge、rebase、branch作成・削除
- workflow、release、package versionの変更
- 大量ファイルのrename・削除・format
- 公開APIの破壊的変更
- repository外のファイルやサービスへのアクセス

通常の局所的なsource/test/doc編集と、その検証は依頼できる。Git操作中の場合は、
`continue`や`abort`をClaudeへ任せず、修正をworking treeへ残すところまでを既定とする。

## Claude完了後の代理引き取り

ユーザーが「完了」と伝えたら、代理発注者は次を行う。

1. `CLAUDE_TASK.md`のStatusとResultを読む。
2. `git status`とdiffを確認し、依頼外変更がないか照合する。
3. Claudeの申告だけで成功扱いせず、重要な検証結果と実際の差分を確認する。
4. 未解決の判断があれば、選択肢と影響だけをユーザーへ短く示す。
5. 問題がなければ、次の安全な作業を管理文書へ反映する。

代理発注者は、ユーザーにClaudeの長い報告を転送しない。「完了」「要判断」「検証失敗」の
いずれかを先に示し、必要な場合だけ要点を説明する。

## Codex復帰時

Codexは`CLAUDE_TASK.md`、Result、diff、検証結果を読み、Claudeの作業を独立確認する。
代理発注者が作った依頼文自体も絶対視せず、範囲不足や危険な前提があれば修正する。
Claudeの完了はcommit許可を意味しない。commitの要否はユーザーまたは復帰したCodexが
判断する。

