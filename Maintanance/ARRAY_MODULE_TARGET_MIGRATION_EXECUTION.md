# ElementBuffer系target・module名移行の実行

## Task

- ID: `ARRAY-016`
- 種別: `EXECUTION`
- 状態: `PROPOSED`
- 担当: Codex
- 現在の中間ゴールへの近さ: `DIRECT`
- 前提: `ARRAY-015`

## 確定済み方針

- 実装moduleを`ElementBufferModule`と`OptionalElementBufferModule`へ移行する。
- `BareArrayModule`と`OptionalArrayModule`は、新moduleを`@_exported import`する薄い互換targetとして残す。
- test targetとdirectoryも公開型体系へ合わせて改名する。
- `AcCollections`は新moduleへ直接依存し、直接再公開する。
- Optional側の`ENABLE_OPTIONAL_ELEMENT_BUFFER` trait条件は維持する。
- benchmarkはimportだけを変更し、task title、workload、baseline比較、結果正規化を変更しない。
- root packageのlibrary product構成と旧互換targetの終了条件は変更しない。

## 実行範囲

1. 現行実装directoryを`Sources/ElementBufferModule`と`Sources/OptionalElementBufferModule`へ移す。
2. `Sources/_BareArrayModule`と`Sources/_OptionalArrayModule`に旧名互換facadeと互換性説明用DocCを作る。
3. `Package.swift`へ新旧target、dependency、path、test target、およびtrait条件を反映する。
4. `AcCollections`、test、benchmarkのimportを新moduleへ変更する。
5. test target directoryを`Tests/ElementBufferModuleTests`と`Tests/OptionalElementBufferModuleTests`へ移す。
6. 通常CIのDocC target matrixを新module名へ更新する。
7. 現行の利用者向け正本文書にあるmodule名と現行source pathを更新する。Archived記録は履歴として改名しない。
8. 残る旧名参照を再検索し、互換target、履歴、または意図した説明以外の実行系参照がないことを確認する。

## 検証

- trait無効のpackage buildとtestが成功する。
- `ENABLE_OPTIONAL_ELEMENT_BUFFER`有効のpackage buildと対象testが成功する。
- 新moduleを直接importする両test targetが成功する。
- 旧module名だけをimportする最小compatibility testで、新moduleの公開型が利用できる。
- benchmark packageのrelease buildが成功し、既存のElementBuffer系task titleが変わっていない。
- 新module両方のDocC generationがwarnings-as-errorsで成功する。
- 変更後の検索結果とcompiler diagnosticsに、意図しない旧module依存が残らない。

## 停止条件

公開library product、trait名・提供条件、benchmark workload・task title、性能baseline、または旧互換targetの
終了条件を変更する必要が生じた場合は、このtaskで決めずに停止して別taskへ分離する。
