# Maintanance直下文書の待避判断

最終更新: 2026-10-09 / Codex

## 目的

`Maintanance/`直下のMarkdownを、現在の起動・運用・task再開に必要な正本と、完了してArchiveへ
待避できる証拠へ分ける。古いという理由だけでは移動せず、現行Registry、agent起動規則、相互参照、
継続更新の有無を根拠に判断する。

## 判断task

| ID | 種別 | 対象 | 判断 |
| --- | --- | --- | --- |
| `OPS-003` | `DISCOVERY` | 直下27文書の用途・状態・参照inventory | 完了。27文書・約618KBを4群へ分類 |
| `OPS-004` | `DECISION` | 起動・運用正本 | 直下維持。Registry、handoff、playbook、template、会話参照規則、maintenance規則を含む |
| `OPS-005` | `DECISION` | graph実験文書 | 完了済み最小schemaとインメモリfixtureの2文書だけ待避。現役・凍結taskの正本と交流logは維持 |
| `OPS-006` | `DECISION` | 評価・observation文書 | 2026-10-05の旧統合評価だけ待避。agent別interview、observation、task適性表は継続資料として維持 |
| `OPS-007` | `DECISION` | 技術調査・release文書 | すべて直下維持。凍結taskの正本、未確定の独立review、後続branch統合待ちを含む |
| `OPS-008` | `EXECUTION` | 採用した3文書の待避と参照更新 | 完了 |

## 待避

- `AI_GRAPH_SHARED_SCHEMA.md`: 共有schema最小fixtureの完了証拠。後続の追試正本から入力資料として参照する。
- `AI_GRAPH_IN_MEMORY_FIXTURE.md`: SQLiteインメモリfixtureの完了証拠。実行物は`AIGraphInMemoryFixture/`に残る。
- `USER_MANAGEMENT_ASSESSMENT.md`: 2026-10-05時点の統合評価。現在はagent別interviewとobservationが継続資料である。

## 直下維持の基準

- `PROGRESS_OVERVIEW.md`、Claude handoff、採番待ちqueueなど、sessionやagent間の入口。
- 現行Registryの`ACTIVE`、`FROZEN`、`WAITING_EXTERNAL`、`USER_ONLY`から参照される詳細正本。
- release checklist、task運用playbook、conversation ID規則などの恒久運用資料。
- agent別評価・observation・task適性表のように、明示条件で今後も追記または参照する資料。
- 原因未確定のperformance独立reviewや、後続branch統合を残すrelease記録。

## 再確認条件

graph実験群が完了・終了した時、0.5.0の後続branch統合が完了した時、RedBlackTreeの外部待ちが
解消した時に、それぞれの詳細正本を再度まとめて待避判断する。個々の文書を日付だけで移動しない。
