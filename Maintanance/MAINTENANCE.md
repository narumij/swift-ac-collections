# 文書整備の手引き

最終更新：2026-10-16 / Astra

本書は公開ドキュメント、コメントドック、Swift-DocC、CHANGELOGを整備するための手引きである。
現在の仕事・状態・着手条件はTask Registryと各taskの詳細正本で確認する。本書には進捗や引継ぎを記録しない。

## 参照先と役割

以下のリンクは本書からの相対パス。

| 文書 | 役割 |
| --- | --- |
| [進捗の入口](ProgressV2/PROGRESS_OVERVIEW_V2.md) | 現在の依頼から関係するtaskへ進む |
| [Task Registry](ProgressV2/TASK_REGISTRY_V2.md) | 状態・担当・依存・再開条件と詳細正本 |
| [現行資料の索引](Current/README.md) | 横断的な正本・運用資料への案内 |
| [テスト整備](../Tests/TESTING.md) | テスト基盤とテスト整理 |
| [RedBlackTree設計資料](../Sources/RedBlackTreeCollections/Documentation/) | 赤黒木の設計・API・品質に関する資料。他moduleは対象taskの詳細正本から辿る |
| [圧縮・アーカイブ手順](ProgressV2/TASK_REGISTRY_ARCHIVE.md) | 原文を保存し、現行から履歴へ辿れるようにする手順 |

## 整備するとき

- 公開仕様は、対象の品質要求・決定記録、Test as Specification、実装、設計文書を照合し、推測で埋めない。食い違いは仕様変更で黙って解消せず、根拠と影響を確認する。
- RedBlackTreeの1型で不備を見つけた場合は、4型と共有Viewの対応箇所を横断確認する。他moduleでは、その変更に関係する公開面を確認する。
- 公開APIの意味、制約、計算量を、実装を読まなくても把握できる状態を目指す。
- 対象taskで維持する利用者向け文書、コメントドック、DocC、API Matrixの意味をそろえる。日英両版を維持する対象では両版を同期する。本書だけを根拠に全moduleへ翻訳や新しい文書を追加しない。
- soft-deprecated API、互換mode、構成限定APIを、通常の推奨APIと区別する。
- 作業結果・判断・検証証拠は対象taskの詳細正本へ、状態と依存はRegistryへ記録する。履歴の整理は上記の圧縮・アーカイブ手順に従う。

## Swift-DocCの確認

- Release構成かつ`--warnings-as-errors`で検証する。
- Topicsへ追加したsymbolは、実在、access level、正しいmodule所属を確認する。
- overloadは曖昧な短縮表記を避け、必要なら引数labelまで含める。
- source上のコメントだけでなく、生成結果の警告とリンク解決を確認する。

以下はRedBlackTreeCollectionsのローカル生成例。他moduleでは現行のPackage.swiftにある対象targetを指定する。

```bash
swift package -c release --allow-writing-to-directory .build/documentation \
  generate-documentation \
  --target RedBlackTreeCollections \
  --output-path .build/documentation \
  --warnings-as-errors
```

候補CIの実際の構成は[候補workflow](../.github/workflows/candidate.yml)で確認する。上の例はローカル生成用で、CIの静的ホスティング向け変換・公開パス指定は含まない。確認結果には対象target・構成・実行結果を残し、他moduleや他構成まで検証済みとしない。

## コメント・API Matrix・CHANGELOG

- コメントドックは動作説明に加え、境界、失敗条件、計算量、Index無効化を必要に応じて記す。
- Test as Specificationで固定した公開契約のうち、利用者が知る必要があるものをDocCまたは設計文書へ反映する。
- API Matrixは現行の公開面を表し、履歴や実験APIの一覧として使わない。
- source-breakingな公開面縮小、挙動変更、互換性上重要な修正はCHANGELOGへ記録する。
- CHANGELOGには検証していない性能・安全性の一般化を書かない。

## 過去の記録

- [今回の整理前全文](Archived/MAINTENANCE_BEFORE_2026-10-16.md)：旧dashboard・handoffを含む。現在の状態や着手条件には使わない。
- [2026-10-07までの履歴](Archived/MAINTENANCE_HISTORY_2026-10-07.md)。

必要な経緯を調べるときだけ参照する。過去の完了記録は、現在の仕様・実装・文書まで検証済みであることを意味しない。
