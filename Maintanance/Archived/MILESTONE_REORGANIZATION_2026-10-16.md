# マイルストーン整理前の記録

2026-10-16、Astra。ユーザーがマイルストーン管理の恒久化と整理を承認。RELEASE-007・079はEXCLUDEDとして版別正本へ集約。DOC-026・027はACTIVEへ戻し、前提と依存で待つ。以下は原文の保存であり、現行の条件ではない。依存辺は整理前の関連範囲を保存した。

| `DOC-026` | `FROZEN` | User / Codex | [EXECUTION] Swift Package Indexへのpackage登録 | 0.9.x release後、`QUALITY-005`で対象版の登録可が判断され、ユーザーが明示的に再開してから、公式PackageListへ`https://github.com/narumij/swift-ac-collections.git`を追加する外部PRを準備・提出して、package page、互換性表示、module別DocC build結果を確認する | `Maintanance/Current/Frozen/DOC-026_FROZEN_TASK.md`。既存資料：`Maintanance/Current/DOCUMENTATION_CI_PLAN.md` / `Package.swift` |
| `DOC-027` | `FROZEN` | Codex | [EXECUTION] Swift Package Index公開導線のREADME・Pages反映 | `DOC-026`完了後、SPI package pageの`Do you maintain this package?`が提示するMarkdownを正として互換性badgeをREADMEへ追加し、確認できたmodule別DocC URLへの導線をREADMEまたはPagesへ接続する | `Maintanance/Current/Frozen/DOC-027_FROZEN_TASK.md`。既存資料：`Maintanance/Current/DOCUMENTATION_CI_PLAN.md` / `README.md` |
| `RELEASE-007` | `FROZEN` | User / Codex | [DECISION] 0.6.0の到達範囲とrelease検討開始 | `RELEASE-078`で、0.5.3後の公開面、現行品質区分、文書の完成状態、および旧開始条件の差を判断材料として揃えた後、ユーザーが0.6.0へ含める到達範囲とrelease工程へ進むかを一つに決定する。調査完了だけでは凍結を解除しない | `Maintanance/Current/Frozen/RELEASE-007_FROZEN_TASK.md`。既存資料：`Maintanance/Current/RELEASE_0_6_0.md` / `Maintanance/Current/QUALITY_REQUIREMENTS.md` / `Package.swift` |
| `RELEASE-079` | `FROZEN` | User / Codex | [DECISION] 0.7.0の到達範囲とrelease検討開始 | 0.6.0 releaseの完了と完了証拠の記録後、ユーザーの明示的な再開指示を受け、0.6.0後の公開面、残課題、品質・文書状態を判断材料として揃え、ユーザーが0.7.0へ含める到達範囲とrelease工程へ進むかを一つに決定する。0.6.0完了や前提整理だけでは自動再開しない | `Maintanance/Current/Frozen/RELEASE-079_FROZEN_TASK.md`。既存資料：`Maintanance/Current/RELEASE_0_7_0.md` / `Maintanance/User/RELEASE_PROCESS.md` / `Maintanance/Current/QUALITY_REQUIREMENTS.md` / `Package.swift` |
| `QUALITY-001` | `DOC-026` | `PARALLEL_JOIN` | 1.0採用品質を判定する前に、0.9.xをSwift Package Indexへ登録し、外部build・互換性表示・module別DocC生成の結果を合流する |
| `QUALITY-001` | `DOC-027` | `PARALLEL_JOIN` | 1.0採用品質を判定する前に、SPIが生成した互換性badgeと確認済みmodule別API referenceへの公開導線を合流する |
| `RELEASE-007` | `RELEASE-078` | `SEQUENCE` | 0.5.3後の公開面、現行提供区分、文書状態、および旧0.6.0開始条件の差を判断材料として揃えてから、0.6.0の範囲とrelease開始を決定する |
| `DOC-026` | `QUALITY-005` | `SEQUENCE` | 対象版についてSPI登録可の判断を得てから登録する。ゲートtaskのDONEだけでは登録可を意味せず、0.9.x release後・明示再開の条件も維持する |
| `DOC-027` | `DOC-026` | `SEQUENCE` | SPI登録と実在するpackage page・module別DocC URLを確認してから、badgeと公開導線をrepositoryへ反映する |

## RELEASE-007の旧正本

# RELEASE-007 — [DECISION] 0.6.0の到達範囲とrelease検討開始

記録者：Astra。作成日：2026-10-16。

この文書は、この凍結taskの棚卸しと今後の判断記録の正本。既存の仕様・品質判断は下記資料を参照し、ここで置き換えない。状態・担当・依存関係・再開条件の正本は[Task Registry](../ProgressV2/TASK_REGISTRY_V2.md)。今回の作成は再開を意味しない。

## 現在記録されている内容

2026-10-16のRegistryから転記：

`RELEASE-078`で、0.5.3後の公開面、現行品質区分、文書の完成状態、および旧開始条件の差を判断材料として揃えた後、ユーザーが0.6.0へ含める到達範囲とrelease工程へ進むかを一つに決定する。調査完了だけでは凍結を解除しない

## 凍結判断の補足

このtask専用の追加説明は未記入。上記にない凍結理由やユーザー判断を推測で補わない。記録の空欄は、判断が存在しなかったことを意味しない。

## 既存資料

- [Maintanance/Current/RELEASE_0_6_0.md](../Current/RELEASE_0_6_0.md)
- [Maintanance/Current/QUALITY_REQUIREMENTS.md](../Quality/QUALITY_REQUIREMENTS.md)
- [Package.swift](../../Package.swift)

## 今後の判断記録

未記入。棚卸しで確認できた判断と根拠をここへ追記する。

## RELEASE-079の旧正本

# RELEASE-079 — [DECISION] 0.7.0の到達範囲とrelease検討開始

記録者：Astra。作成日：2026-10-16。

この文書は、この凍結taskの棚卸しと今後の判断記録の正本。既存の仕様・品質判断は下記資料を参照し、ここで置き換えない。状態・担当・依存関係・再開条件の正本は[Task Registry](../ProgressV2/TASK_REGISTRY_V2.md)。今回の作成は再開を意味しない。

## 現在記録されている内容

2026-10-16のRegistryから転記：

0.6.0 releaseの完了と完了証拠の記録後、ユーザーの明示的な再開指示を受け、0.6.0後の公開面、残課題、品質・文書状態を判断材料として揃え、ユーザーが0.7.0へ含める到達範囲とrelease工程へ進むかを一つに決定する。0.6.0完了や前提整理だけでは自動再開しない

## 凍結判断の補足

このtask専用の追加説明は未記入。上記にない凍結理由やユーザー判断を推測で補わない。記録の空欄は、判断が存在しなかったことを意味しない。

## 既存資料

- [Maintanance/Current/RELEASE_0_7_0.md](../Current/RELEASE_0_7_0.md)
- [Maintanance/User/RELEASE_PROCESS.md](../User/RELEASE_PROCESS.md)
- [Maintanance/Current/QUALITY_REQUIREMENTS.md](../Quality/QUALITY_REQUIREMENTS.md)
- [Package.swift](../../Package.swift)

## 今後の判断記録

未記入。棚卸しで確認できた判断と根拠をここへ追記する。

## DOC-026の旧正本

# DOC-026 — [EXECUTION] Swift Package Indexへのpackage登録

記録者：Astra。作成日：2026-10-16。

この文書は、この凍結taskの棚卸しと今後の判断記録の正本。既存の仕様・品質判断は下記資料を参照し、ここで置き換えない。状態・担当・依存関係・再開条件の正本は[Task Registry](../ProgressV2/TASK_REGISTRY_V2.md)。今回の作成は再開を意味しない。

## 現在記録されている内容

2026-10-16のRegistryから転記：

0.9.x release後、`QUALITY-005`で対象版の登録可が判断され、ユーザーが明示的に再開してから、公式PackageListへ`https://github.com/narumij/swift-ac-collections.git`を追加する外部PRを準備・提出して、package page、互換性表示、module別DocC build結果を確認する

## 凍結判断の補足

このtask専用の追加説明は未記入。上記にない凍結理由やユーザー判断を推測で補わない。記録の空欄は、判断が存在しなかったことを意味しない。

## 既存資料

- [Maintanance/Current/DOCUMENTATION_CI_PLAN.md](../Current/DOCUMENTATION_CI_PLAN.md)
- [Package.swift](../../Package.swift)

## 今後の判断記録

未記入。棚卸しで確認できた判断と根拠をここへ追記する。

## DOC-027の旧正本

# DOC-027 — [EXECUTION] Swift Package Index公開導線のREADME・Pages反映

記録者：Astra。作成日：2026-10-16。

この文書は、この凍結taskの棚卸しと今後の判断記録の正本。既存の仕様・品質判断は下記資料を参照し、ここで置き換えない。状態・担当・依存関係・再開条件の正本は[Task Registry](../ProgressV2/TASK_REGISTRY_V2.md)。今回の作成は再開を意味しない。

## 現在記録されている内容

2026-10-16のRegistryから転記：

`DOC-026`完了後、SPI package pageの`Do you maintain this package?`が提示するMarkdownを正として互換性badgeをREADMEへ追加し、確認できたmodule別DocC URLへの導線をREADMEまたはPagesへ接続する

## 凍結判断の補足

このtask専用の追加説明は未記入。上記にない凍結理由やユーザー判断を推測で補わない。記録の空欄は、判断が存在しなかったことを意味しない。

## 既存資料

- [Maintanance/Current/DOCUMENTATION_CI_PLAN.md](../Current/DOCUMENTATION_CI_PLAN.md)
- [README.md](../../README.md)

## 今後の判断記録

未記入。棚卸しで確認できた判断と根拠をここへ追記する。
