<!-- CodexとClaudeによるCodexとClaudeのためのメモ -->

# Documentation maintenance notes

この文書は、公開ドキュメント、コメントドック、Swift-DocC、およびCHANGELOGを継続的に整備するための作業連絡と判断基準をまとめる。

ドキュメントに関する作業を行ったCodexおよびClaudeは、作業結果、残件、検証内容をこの文書へ都度反映すること。長期的に有効な知見は作業ログだけに残さず、該当する規則へ反映する。

## User requests for the next session

次回のドキュメント作業で優先してほしい内容をユーザーが書く欄。この欄に記載がある場合、CodexおよびClaudeは`Current handoff`より先に読み、最新のユーザー要望として優先する。完了した項目を勝手に削除せず、完了済みの要望へ移すか、ユーザー確認後に整理する。

<!-- ユーザー記入欄: この下へ追記 -->

### ビジョン

- 公開APIの意味、制約、計算量を、実装を読まなくても正しく把握できる状態を維持する
- 日英の案内文書、コメントドック、DocC、API一覧の内容を同期する
- DocCの警告と生成結果を、公開前にCIで継続的に検証する

### 優先事項

- 追加したイニシャライザ、共通操作ガイド、View TopicsのCI検証結果を確認する

### 相談事項

- DocCの手動Topicsは`API-Matrix.md`と`API-Matrix-View.md`を基準に、検索・挿入・削除・範囲操作などへ広げる。4型の具象型ページだけでなく、共通protocolのDefault ImplementationsやViewへの導線をどこへ置くかは引き続き検討する

### 連絡事項

- この文書のユーザー記入欄を更新する場合は、日付に加えて時刻も記載する
- 最後に作業したモデル名とバージョンを記録する
- 完了済みログを無制限に蓄積しない。恒久的な知見は規則へ移し、`Current handoff`は直近の状況を中心に保つ

### 停止条件

- 公開APIの意味を実装やテストから確定できない場合は、推測で文書化せずユーザーへ確認する
- 日英どちらを正とするか判断できない差異を見つけた場合は、一方へ機械的に合わせず保留事項として記録する

### 保留中の判断・懸念

- API Matrix上の多くの共通APIが、各型のDocCでは`Default Implementations`配下に入る。今回追加した共通操作ガイドから各操作の個別シンボルへ、さらに細かいリンクを追加する必要があるかは公開結果を見て判断する

### 完了済みの要望

(ユーザーが確認したら各項目を整理します)

- 2026-10-01 12:43 JST Codex (GPT-5): `API-Matrix.md`と`API-Matrix-View.md`を基準にDocCの導線を整備。4型に共通する検索、挿入・更新、削除、Range/Boundの意味を説明する`CommonOperations.md`を追加し、モジュールページと4型ページからリンクした。KeyOnly Range View、KeyValue Range View、MappedValues Viewには、基本状態、Index検証、参照・更新、削除、走査・比較をMatrixの区分に沿って手動Topics化した。
- 2026-10-01 12:36 JST Codex (GPT-5): `main`のCIによるGitHub Pages初回公開が成功し、常設URLから閲覧できることをユーザーが確認した。
- 2026-10-01 12:27 JST Codex (GPT-5): ドキュメントメンテナンス専用の作業連絡文書として、この`Documentation/MAINTENANCE.md`を作成した。

## 文書の役割と正本

| 対象 | 役割 |
| --- | --- |
| `README.md` / `README.ja.md` | パッケージ全体の入口、導入方法、主要な利用案内 |
| `Documentation/*.md` / `*.ja.md` | 各コレクションの利用者向けガイド。日英ペアで管理する |
| `Sources/RedBlackTreeCollections/RedBlackTreeCollections.docc/` | Swift-DocCのモジュールページ、手動Topics、補足記事 |
| Swiftソース内の`///` | 公開宣言に直接対応するAPIリファレンス |
| `Sources/RedBlackTreeCollections/Documentation/API-Matrix.md` | 4つのコレクション型における公開APIの実装状況 |
| `Sources/RedBlackTreeCollections/Documentation/API-Matrix-View.md` | View系公開APIの実装状況 |
| `Sources/RedBlackTreeCollections/Documentation/Quality-Checklist.md` | 品質要件と検証観点 |
| `Sources/RedBlackTreeCollections/Documentation/Design/` | 内部設計と実装上の判断 |
| `CHANGELOG.md` | リリース利用者に影響する変更の記録 |

APIの有無は実装とAPI Matrix、挙動は実装とテストを照合して判断する。説明文書だけを根拠に別の説明文書を更新しない。

## メンテナンス規則

### 日英文書

- `Documentation`直下に日英ペアがある文書は、片方を変更したら他方も同じ作業で確認する
- 見出し、コード例、注意事項、公開API名を対応させる
- 逐語訳より、Swift APIとして同じ意味と制約を伝えることを優先する

### コメントドック

- DocCへ公開する説明だけを`///`で記述する
- 日本語の実装メモ、設計途中の覚え書き、保留事項は`//`を使用する
- 宣言の実際の引数名と`- Parameter`の名前を一致させる
- 戻り値、重複要素の扱い、Indexの無効化条件、計算量を実装と照合する
- コレクションの順序性は`sorted`と表現する
- MultiSetとMultiMapについて、要素またはキーが一意であると誤解させる説明を避ける
- 1型で誤りを見つけた場合は、Set、MultiSet、Dictionary、MultiMapおよび共有Viewへ横展開して確認する

### API MatrixとCHANGELOG

- API Matrixの状態は、現行ソースとテストを確認してから変更する
- CHANGELOG更新時は、対象とする開始コミットまたはリリースタグを明確にする
- 内部整理だけの変更と、利用者から見えるAPI・挙動変更を区別する
- 既存リリース欄を遡って書き換える場合は、ユーザーの明示的な意図を確認する

## Swift-DocC運用

公開用のシンボルはRelease構成から抽出する。

生成と警告検証:

```console
swift package -c release generate-documentation \
  --target RedBlackTreeCollections \
  --warnings-as-errors
```

ローカルプレビュー:

```console
swift package -c release --disable-sandbox preview-documentation \
  --target RedBlackTreeCollections
```

- CIでも`-c release`を指定する
- DocC警告は`--warnings-as-errors`で失敗として扱う
- GitHub Pages用には`--transform-for-static-hosting`と正しい`--hosting-base-path`を指定する
- DocC生成物にはWindows非互換の文字を含むファイル名があり得るため、通常artifactはディレクトリを直接渡さず`tar.gz`へ格納する
- GitHub Pages artifactはPages専用Actionへ生成ディレクトリを渡す
- 生成物はリポジトリへコミットしない
- 手動Topicsを変更した場合は、リンク解決だけでなく生成後のTopics表示件数と分類も確認する

## 検証チェックリスト

ドキュメント変更の内容に応じて、必要な項目を確認する。

- 日英ペアの差分確認
- 4型およびKeyOnly/KeyValue Viewへの横展開確認
- コメントドックの引数名、戻り値、計算量の照合
- API Matrixとの整合
- DocCのRelease生成と`--warnings-as-errors`
- 生成済みDocCページのTopicsとリンク
- workflow YAMLの構文
- `git diff --check`

文書だけの変更では通常、全体テストを必須としない。ただし、コード例をテストで検証している文書や、コンパイル対象のコメントドックに影響する変更では、対応するビルドまたはテストを実行する。

## Current handoff

- 2026-10-01 12:43 JST Codex (GPT-5): 公開済みRelease版DocC JSON、`API-Matrix.md`、`API-Matrix-View.md`を照合し、3型のイニシャライザTopicsに加えて共通操作ガイドと3種類のView Topicsを追加した。照合中にDictionaryの`insert(key:value:hint:)`と`update(_:hint:)`のMatrix同期漏れを修正。Viewのリンク識別子は具象ページおよびDefault Implementationsの公開JSONで確認した。ローカルのSwiftPM実行は環境のsandboxエラーで開始できないため、最終的な`--warnings-as-errors`検証はCI結果を確認する。
