# <VersionNumber>リリース手順書

以下は全て基本ユーザーが手作業で行う。
例外としてコードや書類の削除はAIに分担してもよい

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

- [ ] AGENTS.mdを削除
- [ ] candidate-<VersionNumber> Tagを付与
- [ ] candidate-<VersionNumber> Tagをプッシュ
- [ ] リリースCI実行確認
- [ ] リリースCIグリーン確認
- [ ] リリース判断

## 最終作業

- [ ] <VersionNumber> Tagを付与
- [ ] <VersionNumber> Tagをプッシュ
