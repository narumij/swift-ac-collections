# ElementBuffer系旧名互換targetの削除

## Task

- ID: `ARRAY-018`
- 種別: `EXECUTION`
- 状態: `DONE`
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
- 当初はmaintenance folder名を履歴・管理座標として改名対象外にしたが、現行module名との対応を記憶し続ける
  負担と誤認を避けるため、ユーザーの追加指示で現行正本folderも新module名へ統一する。
- benchmark task名rename互換はmodule target削除とは独立しており、削除しない。

## 実行範囲

1. `Package.swift`から旧名2 targetと、それらへの内部依存を削除する。
2. `Sources/_BareArrayModule`と`Sources/_OptionalArrayModule`のfacade source・DocCを削除する。
3. 旧名だけをimportするcompatibility smoke testを削除する。
4. PR DocC matrixから旧名2 targetを削除し、新moduleを含む5 target構成へ戻す。
5. 現行の移行正本とCI計画へ、旧名facade終了後の構成を反映する。
6. 旧名facadeのDocC入口を削除するだけで終えず、新module名のDocC入口をそれぞれのtargetへ配置する。
7. 旧名2 maintenance folderを新module名のfolderへ移し、現行・Archivedを含む管理path参照をすべて
   新座標へ統一する。本文中の歴史上の型名・target名・source pathは変更しない。

## 検証

- manifest評価と既定のpackage testが成功する。
- `ENABLE_OPTIONAL_ELEMENT_BUFFER`有効時の対象testが成功する。
- benchmark packageのrelease buildとCI libraryのtask解決が成功する。
- `ElementBufferModule`と`OptionalElementBufferModule`のDocC生成が成功する。
- 両新moduleの生成済みDocCに、新module名のmodule landing pageが含まれる。
- 旧maintenance folderと、それを指す管理path参照が残らない。
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
- commit `7377b76d`のPR #196 CI run `38465709778`で、performanceを含む10 jobsすべてのsuccessを確認した。
  DocC matrixは旧名2 targetを除いた5 targetで完走し、旧名facade終了後のremote構成を受け入れた。
- 完了記録後、旧名facadeのDocC landing pageだけを削除し、新module側へ対応するlanding pageを配置していない
  不足を確認した。`ElementBufferModule.docc/ElementBufferModule.md`と
  `OptionalElementBufferModule.docc/OptionalElementBufferModule.md`を追加し、両targetを
  `--warnings-as-errors`付きで生成して成功した。生成済みJSONでも新module名のoverviewと4公開型への
  symbol linkが採用されたことを確認した。
- Claudeの第2回独立目視検査で、Bare利用者向けドラフトに削除済みmoduleからの導入経路が残るMUST-FIXを
  検出した。両draftのmodule名、`AcCollections` DocCのOptional trait境界、ElementBuffer landing pageの案内、
  両auditの現行・履歴pathとOptionalのDocC CI記述を修正した。`AcCollections`と`ElementBufferModule`のDocCを
  `--warnings-as-errors`付きで再生成して成功し、指摘を受け入れた。公開コメント拡充、公開媒体の言語、
  release向け移行説明は後続ドキュメント作業として分離した。
- ユーザーの追加指示により、記憶上の例外だったmaintenance folder名も
  `ElementBufferModule`／`OptionalElementBufferModule`へ移した。8文書を移動し、現行・Archivedを含む管理path
  241件を新座標へ置換した。歴史上の型名、target名、および当時のsource pathは履歴事実として保持した。
- 続くユーザー指示で監査文書名も`ElementBufferAudit.md`／`OptionalElementBufferAudit.md`へ統一し、全参照を
  新しいfile名へ置換した。安定task IDと本文中の歴史上の名称は変更していない。
- Claudeの独立置換漏れ検査は`accept`。新path 8種類・246参照の実在と整合、旧管理座標のlive参照0件、
  歴史上のsource pathと安定task IDの保持を確認した。指摘されたArchived品質評価2件の現行Quality Profile
  案内を修正した。過去Return内の管理path表現も、旧座標を現行文書に残さず記憶負担を減らすというユーザー目的に
  従って検査時点の判断と分かる表現へ統一し、変更前の原文はGit履歴に保持した。
