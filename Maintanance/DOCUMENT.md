# 文書整備の手引き

最終更新：2026-10-16 / Astra

本書は公開ドキュメント、コメントドック、Swift-DocC、CHANGELOGを整備するための手引きである。
現在の仕事・状態・着手条件はTask Registryと各taskの詳細正本で確認する。本書には進捗や引継ぎを記録しない。

本書は文書整備の恒久task `DOC-030` の維持文書とする。個別の文書作業が完了しても本書は残す。
配置は `Maintanance/DOCUMENT.md` に固定し、ユーザーの明示指示なしに移動・改名・アーカイブしない。
旧名は `MAINTENANCE.md`。過去の記録中の旧名は当時の文書を指す。

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

## 外部ファイル（Maintananceの外）

ここでいう外部ファイルは、リポジトリ内の `Maintanance/` 外に置かれた文書・作業資料を指す。外部サービスのファイルという意味ではない。関連する資料はフォルダ単位でまとめ、下記から必要なものを辿る。

この一覧への掲載は、恒久保存・配置固定・内容の正しさ・編集権限を一括で認めるものではない。維持文書と途中の作業資料、取得済みの証拠を区別する。移動・アーカイブの際は用途と依存する仕事を確かめる。

| ファイル・入口 | 役割・扱い | 恒久taskとの関係 |
| --- | --- | --- |
| [AGENTS.md](../AGENTS.md)、[CLAUDE.md](../CLAUDE.md) | 協働の規則。各文書の変更権限に従う | `DOC-030`では参照関係を把握する。本文の変更権限は得ない |
| [Tests/TESTING.md](../Tests/TESTING.md) | テストの継続整備と現在地の入口。状態記述はRegistry・対象の詳細正本と照合する | テスト整備の恒久系の中心文書。専用の恒久taskは未登録。`DOC-030`では文書の参照関係を扱う |
| [Tests/CLAUDE.md](../Tests/CLAUDE.md)、[Fixtures.md](../Tests/RedBlackTreeFixture/Fixtures.md) | テスト作業の規則とfixtureの説明 | テスト整備に関連。文書の導線は`DOC-030`、内容更新は対象のテスト作業 |
| [README.ja.md](../README.ja.md)、[README.md](../README.md) | 利用者向け入口。日本語版が正本、英語版は翻訳という現行の指定を維持する | `DOC-030`。製品方針の決定は代行しない |
| [CHANGELOG.md](../CHANGELOG.md) | 利用者に関係する変更の記録 | `DOC-030`。対象の変更・リリース作業と照合する |
| [Documentation/](../Documentation/) | 利用者向け本文・互換APIの説明 | `DOC-030`。各文書の正本・翻訳・対象版を確認する |
| [設計資料](../Sources/RedBlackTreeCollections/Documentation/Design/Design-Overview.md)、[API Matrix](../Sources/RedBlackTreeCollections/Documentation/API-Matrix.md)、[View Matrix](../Sources/RedBlackTreeCollections/Documentation/API-Matrix-View.md) | 赤黒木の設計・公開面の維持文書 | `DOC-030`。仕様判断は対象task・決定正本に従う |
| [文書workflow・本文・outline](../Sources/RedBlackTreeCollections/Documentation/Head/) | 文書作成手順と作業資料が混在。本文・outlineの完成や公開可否は個別に確認する | `DOC-030`。具体的な作業状態はRegistryと対象taskで管理する |
| [赤黒木のその他資料](../Sources/RedBlackTreeCollections/Documentation/)、[Indexメモ](../Sources/RedBlackTreeCollections/Implements/Index/index_stale_check.md) | 比較証拠、互換説明、設計メモなど。フォルダ全体を現行仕様の正本とは扱わない | `DOC-030`では用途・参照先を整理し、個別の判断や証拠は関係taskへ紐付ける |
| [赤黒木](../Sources/RedBlackTreeCollections/Documentation/Quality-Profile.md)、[Permutation](../Sources/NextPermutationModule/Documentation/Quality-Profile.md)、[OptionalElementBuffer](../Sources/OptionalElementBufferModule/Documentation/Quality-Profile.md)、[ElementBuffer](../Sources/ElementBufferModule/Documentation/Quality-Profile.md)の品質プロファイル | module別の品質主張・境界 | `DOC-030`では文書整合を扱う。品質の判断・検証は品質要求と各評価taskによる |
| [AcCollections DocC](../Sources/AcCollections/AcCollections.docc/)、[赤黒木 DocC](../Sources/RedBlackTreeCollections/RedBlackTreeCollections.docc/)、[Permutation DocC](../Sources/NextPermutationModule/NextPermutationModule.docc/)、[OptionalElementBuffer DocC](../Sources/OptionalElementBufferModule/OptionalElementBufferModule.docc/)、[ElementBuffer DocC](../Sources/ElementBufferModule/ElementBufferModule.docc/) | 公開ドキュメントの生成入力。各moduleのSwiftソース内の公開コメントも関連する | `DOC-030`。生成入力と生成物を区別し、変更対象の生成・リンク解決を確認する |
| [旧RedBlackTree DocC](../Sources/_RedBlackTreeModule/RedBlackTreeModule.docc/)、[旧Permutation DocC](../Sources/_PermutationModule/PermutationModule.docc/) | 旧名互換入口の案内 | `DOC-030`。旧名という理由で履歴・削除対象にしない |
| [Benchmark結果一覧](../Benchmarks/Results.md)、[macOS品質評価資料](../Benchmarks/QualityAssessment/macOS/) | 計測結果の入口、評価説明、生成結果・証拠が混在 | `DOC-030`では導線を維持する。結果の有効範囲・保存・再測定は関係する品質・性能taskで扱う |

一覧は文書・作業資料への入口であり、ソースコード・全生成物のファイル台帳ではない。資料を追加したときは、その用途に応じてこの入口または関係taskの詳細正本から辿れるようにする。現時点で個別の紐付けが未確認の資料は、掲載だけで確認済みとしない。

## 整備するとき

- 公開仕様は、対象の品質要求・決定記録、Test as Specification、実装、設計文書を照合し、推測で埋めない。食い違いは仕様変更で黙って解消せず、根拠と影響を確認する。
- RedBlackTreeの1型で不備を見つけた場合は、4型と共有Viewの対応箇所を横断確認する。他moduleでは、その変更に関係する公開面を確認する。
- 公開APIの意味、制約、計算量を、実装を読まなくても把握できる状態を目指す。
- 対象taskで維持する利用者向け文書、コメントドック、DocC、API Matrixの意味をそろえる。日英両版を維持する対象では両版を同期する。本書だけを根拠に全moduleへ翻訳や新しい文書を追加しない。
- soft-deprecated API、互換mode、構成限定APIを、通常の推奨APIと区別する。
- 作業結果・判断・検証証拠は対象taskの詳細正本へ、状態と依存はRegistryへ記録する。履歴の整理は上記の圧縮・アーカイブ手順に従う。

## リンクと参照先の保守

リンク保守は文書整備の恒久task `DOC-030` に含める。文書を追加・変更・移動・改名・アーカイブするときは、その変更に関係する参照を確認する。全体点検は依頼された範囲で行い、毎回の全件確認を開始条件にしない。

- 対象はMarkdownの本文・参照形式のリンク、画像、見出しへのリンク、DocCのsymbol link・Topics、参照先として使うコード表記のファイルパス、外部URLとする。
- 移動・改名の前に、旧パス・ファイル名・対象見出しを検索して参照元を洗い出す。移動後は、参照元から新しい場所へ辿れることに加え、移動した文書自身の相対リンクも確認する。
- ローカル参照は、文書が指定する基準位置からファイル・ディレクトリの実在を確認する。見出しリンクは対象の見出しと表示先のアンカーを確認する。ファイルが存在するだけで節まで確認済みとしない。
- DocCの参照は、下記の生成確認で警告・リンク解決を確認する。Markdownファイルの存在確認で代用しない。
- 外部URLは実際の到達先と内容を確認する。認証要求・通信制限・一時的な障害で確かめられない場合は、リンク切れと断定せず未確認として残す。
- 履歴や原回答にある当時のパスは一括置換しない。現在も使う案内リンクを更新し、原文を保持する必要がある箇所には、履歴の案内から移動先や当時の版へ辿れる経路を用意する。
- 修正先が不明なリンクを、存在するだけの別文書へ付け替えない。意図した参照先を確かめて直す。

確認した範囲・方法・結果と、未確認や残るリンク切れを作業の詳細正本または返却記録へ残す。部分確認を全件確認と報告しない。本節は保守手順であり、自動検査や定期実行が導入済みであることを意味しない。

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
