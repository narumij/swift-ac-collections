# ElementBuffer系旧名互換targetの削除

## Task

- ID: `ARRAY-018`
- 種別: `EXECUTION`
- 状態: `ACTIVE`
- 担当: Codex
- 現在の中間ゴールへの近さ: `DIRECT`
- 前提: `ARRAY-016`

## ゴール

ElementBuffer系module名移行の最終状態として、`BareArrayModule`と`OptionalArrayModule`の旧名facade targetを
削除し、`ElementBufferModule`と`OptionalElementBufferModule`だけをpackageと継続CIへ残す。

## 確認した境界

- root packageが公開するlibrary productは`AcCollections`だけで、旧名facadeを直接含むlibrary productはない。
- `AcCollections`は新moduleを直接再公開しており、旧名facadeの公開宣言には依存していない。
- production sourceとbenchmarkは新moduleを直接importする。
- 旧名facadeへの実行系依存は、manifest内の`AcCollections`・test target依存、互換smoke test、およびDocC CI entryに限定される。
- maintenance folder名とArchived記録は履歴・管理座標であり、このtaskでは改名しない。
- benchmark task名rename互換はmodule target削除とは独立しており、削除しない。

## 実行範囲

1. `Package.swift`から旧名2 targetと、それらへの内部依存を削除する。
2. `Sources/_BareArrayModule`と`Sources/_OptionalArrayModule`のfacade source・DocCを削除する。
3. 旧名だけをimportするcompatibility smoke testを削除する。
4. PR DocC matrixから旧名2 targetを削除し、新moduleを含む5 target構成へ戻す。
5. 現行の移行正本とCI計画へ、旧名facade終了後の構成を反映する。

## 検証

- manifest評価と既定のpackage testが成功する。
- `ENABLE_OPTIONAL_ELEMENT_BUFFER`有効時の対象testが成功する。
- benchmark packageのrelease buildとCI libraryのtask解決が成功する。
- `ElementBufferModule`と`OptionalElementBufferModule`のDocC生成が成功する。
- 実行系に旧名targetへの依存またはimportが残らない。
- remote PR CIでperformanceを含む全jobが完走する。

## 停止条件

旧名targetを直接提供するlibrary productまたはrepository外consumerが確認され、互換終了時期について新しい
製品判断が必要になった場合は、削除を進めず判断taskへ分離する。

## ローカル検証（2026-10-14）

- YAML parseと`swift package --disable-sandbox dump-package`が成功した。
- `swift test --disable-sandbox`が成功した。
- `ENABLE_OPTIONAL_ELEMENT_BUFFER`有効のOptional系通常test 35件とDeath Test 21件が成功した。
- benchmark packageのrelease buildが成功した。
- `ElementBufferModule`と`OptionalElementBufferModule`のDocC generationが`--warnings-as-errors`付きで成功した。
- 実行系の旧名target定義、依存、import、およびDocC matrix entryが残っていないことを検索で確認した。
- Claudeの独立目視検査で、`Utilities`配下のcompiler fixture 2件に旧名importが残ることと、`Tests/TESTING.md`の
  compatibility test記述が古いことを検出した。両方を修正し、fixtureのcompile-pass 1件と期待する
  escape diagnostic 4件をscriptで再確認した。目視検査はCodexが受け入れた。
