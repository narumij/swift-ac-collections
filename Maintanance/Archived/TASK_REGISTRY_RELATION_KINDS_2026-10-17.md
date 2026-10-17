# マイルストーン接続（4列）とゲート経路の関係種類の原文（2026-10-17、線の種類廃止前）

2026-10-17 / Fable（調整代理、OPS-044）。元：`Maintanance/ProgressV2/TASK_REGISTRY_V2.md`の2節。移動時点の履歴であり現行指示ではない。ユーザー決定（Astra助言）により線の種類（stage / required / material / after / resume）を廃止し、種類が担っていた条件は「マイルストーン接続」の制約文へ移した（OPS-062、[正本](../Current/REGISTRY_STUDIO_SINGLE_LINE_KIND.md)）。「ゲート経路の関係種類」は列の線が配置だけから作られるようになったため節ごと廃止。本文は逐語。

## マイルストーン接続

タスクとEND・途中ゲートの接続の正本。Studioはこの表から生成し、JSONから引き継いだり接続先・方向を暗黙に変更したりしない。版を挟んでも到達先が同じなら行の変更は不要。ゲート同士の経路はMilestonesの配置から生成する。

接続は現行Studioから移管したもの。`required`は必須、`material`は判断材料、`resume`・`after`は再開判断・着手条件を表し、矢印だけで自動開始や必須完了を意味しない。状態・ユーザー判断・委任は各タスクの条件に従う。

| 接続元 | 接続先 | 関係 | 制約 |
| --- | --- | --- | --- |
| `RELEASE-084` | `END-0.5.4` | `required` | 2026-10-17ユーザー指定。候補CIの限定修正・検証結果をEND-0.5.4へ合流する。未決方針やCI実走の未確認を完了扱いにしない。 |
| `PERM-079` | `END-0.6.0` | `resume` | 0.6.0のリリース完了を確認した後、`PERM-079`で`prepare/compatible/2`の統合手順再構築調査を再開するかユーザーが判断する。 |
| `RELEASE-072` | `END-0.6.0` | `required` | \| RELEASE-072 \| 人間向け工程表が実際の現在位置・次の操作・証拠・停止点を追えるか確認する \| |
| `RELEASE-075` | `END-0.6.0` | `required` | \| RELEASE-075 \| 判定基準、証拠取得、停止・復旧などの不足仕様を充当する \| |
| `RELEASE-076` | `END-0.6.0` | `required` | \| RELEASE-076 \| 充当後の工程をValidation & Verificationする。RELEASE-075への依存を維持する \| |
| `QUALITY-005` | `END-0.7.0` | `after` | 0.7.0 release完了後、対象版のSPI登録可否をQUALITY-005で判定する。 |
| `DOC-027` | `MS-SPI` | `required` | 続いてDOC-027でSPI提示のbadgeと確認済みURLをREADME・Pagesへ接続する。 |
| `DOC-036` | `MS-VALIDATION` | `required` | DOC-036 → Validation計画レビュー（MS-VALIDATION）→ 0.7.0。 |
| `DOC-038` | `END-0.7.0` | `required` | DOC-038とDOC-039の成果を0.8.0の文書整備条件へ接続する。 |
| `DOC-039` | `END-0.7.0` | `required` | DOC-038とDOC-039の成果を0.8.0の文書整備条件へ接続する。 |
| `RBT-001` | `MS-QUALITY` | `material` | 品質調査は並行できるが、1.0品質判定を確定する前にIndex契約完了と合流する |
| `RBT-009` | `MS-QUALITY` | `material` | 他の1.0品質作業は並行できるが、最終判定前にruntime-check実装の採否と合流する |
| `RBT-034` | `MS-QUALITY` | `material` | 1.0採用品質を判定する前に、再現可能な証拠を備えた品質アセスメントの完成と合流する |
| `QUALITY-002` | `MS-QUALITY` | `material` | 1.0採用品質を判定する前に、Linux代表環境の品質保証CIと再現可能な実行証拠を合流する |
| `QUALITY-003` | `MS-QUALITY` | `material` | 1.0採用品質を判定する前に、Apple platforms 27のmanifest境界とplatform別build証拠を合流する |

## ゲート経路の関係種類

対象ノードへ入る経路の線の種類を指定する。接続元・接続先の組はここに持たず、Milestonesの配置から生成する。ゲートを移動しても指定は対象IDに追従する。未指定の新規ノードは `stage`（段階の接続）。この表はタスクからの接続には適用しない。

| 対象ノード | 関係 |
| --- | --- |
| `END-0.5.3` | `stage` |
| `GATE-0.5.4` | `stage` |
| `END-0.5.4` | `stage` |
| `GATE-0.6.0` | `stage` |
| `MS-VALIDATION` | `stage` |
| `END-0.6.0` | `required` |
| `GATE-0.7.0` | `stage` |
| `MS-SPI` | `stage` |
| `END-0.7.0` | `stage` |
| `GATE-0.8.0` | `stage` |
| `MS-HUMAN` | `after` |
| `END-0.8.0` | `stage` |
| `GATE-0.9.0` | `stage` |
| `MS-QUALITY` | `stage` |
| `END-0.9.0` | `stage` |
| `GATE-1.0.0` | `stage` |
| `END-1.0.0` | `stage` |
