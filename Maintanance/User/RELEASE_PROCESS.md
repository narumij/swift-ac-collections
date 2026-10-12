# <VersionNumber>リリース手順書

以下は全て基本ユーザーが手作業で行う。
例外としてコードや書類の削除はAIに分担してもよい

## AI分担境界

- リリース作業に伴うソースコード整理は、司令塔を担うCodex conversationへ実装させず、別のCodexへ分担する
- 司令塔Codexは、その成果の目的・差分・検証証拠を確認し、リリース工程、正本、Task Registryへの接続を担当する

## 事前準備

- [ ] .gitignore対象の`_ReleaseTask`フォルダにこの書類をコピー
- [ ] コピーしたファイルの<VersionNumber>を予定したバージョンナンバーに全て書き換え

## 事前状態チェック

- [ ] 必要な品質評価・品質試験をパス
- [ ] CHANGELOGが<VersionNumber>まで反映
- [ ] 直前のCIが全てグリーン

## 候補採用

- [ ] リリース候補採用判断

## 準備作業

- [ ] AGENTS.mdを残す
- [ ] 互換コードの削除
- [ ] ユーザードキュメント以外の書類の削除
- [ ] Benchmarkリザルトの削除
- [ ] プッシュ
- [ ] CIを実行
- [ ] CIが全てグリーン

## 候補確定作業

- [ ] candidate-<VersionNumber> Tagを付与
- [ ] candidate-<VersionNumber> Tagをプッシュ
- [ ] リリースCI実行確認
- [ ] リリースCIグリーン確認
- [ ] リリース判断

## 最終作業

- [ ] AGENTS.mdを削除
- [ ] AGENTS.md削除後はAI作業へ戻らず、残る最終作業だけをユーザーが行う
- [ ] <VersionNumber> Tagを付与
- [ ] <VersionNumber> Tagをプッシュ
