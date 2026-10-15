# ElementBuffer系target・module名移行の調査

## Task

- ID: `ARRAY-015`
- 種別: `DISCOVERY`
- 状態: `DONE`
- 担当: Codex
- 現在の中間ゴールへの近さ: `NEAR`

## 背景

公開所有型は`ElementBuffer`と`OptionalElementBuffer`へ改名済みだが、SwiftPM target、module、source
directory、test target、および保守資料には`BareArrayModule`と`OptionalArrayModule`が残っている。
旧名は現行moduleを指す座標としては有効だが、旧製品像と現在の公開型・提供区分を読み替える認知負荷が
実際のtask見直しで観測された。

Swift Package Indexへ登録するとmodule別DocC pageと公開導線が外部化される。登録後のmodule renameを
避けるため、0.9.x登録より前に公開型に合わせた新moduleへ移行し、旧module名を薄い互換targetとして残す
実行境界を確定する。

## 採用済み方向

2026-10-14、ユーザーはRedBlackTreeの既存方式と同様に、新moduleへ移行しながら旧module名を互換維持に
使う方向を指定した。`Sources/_RedBlackTreeModule/RedBlackTreeModule.swift`は
`@_exported import RedBlackTreeCollections`だけを持ち、manifest上の旧targetは新targetへ依存する。
ElementBuffer系でもこの薄い互換facade方式を採用方向とし、現行名の恒久維持または旧module名を残さない
非互換renameは比較候補から外す。

続く確認で、新しい実装target・module名を`ElementBufferModule`と
`OptionalElementBufferModule`にすることもユーザーが指定した。旧名の`BareArrayModule`と
`OptionalArrayModule`は、RedBlackTreeと同様に新moduleを`@_exported import`する薄い互換targetとして
残す。互換targetの削除時期は定めず、今回の移行では削除しない。

## 現在確認できる事実

- `Package.swift`は`OptionalArrayModule`、`OptionalArrayModuleTests`、`BareArrayModule`、
  `BareArrayModuleTests`をtarget名として使用している。
- `AcCollections`は`OptionalArrayModule`を`ENABLE_OPTIONAL_ELEMENT_BUFFER` trait時だけ、
  `BareArrayModule`を通常構成で依存・再公開する。
- 公開型名、target名、module名、directory名は現在一致していない。
- RedBlackTreeでは過去にdirectory、target・test import、旧名再公開targetを段階的に移行した実績がある。
  この実績は選択肢の証拠であり、同じ方式を自動採用する根拠にはしない。
- 2026-10-13の公開型renameでは、HEADのperformance CI libraryをrename前baselineへそのまま渡し、
  baselineに存在しない新task名を要求して`unknown tasks`になった。現在は旧名・新名のlibrary入力と
  結果名を対応付ける互換処理がある。
- 過去のPrime Codexは、ElementBuffer系のtarget・module renameを実行した経験がない。公開型renameの
  回復手順とRedBlackTreeの移行履歴は参考にできるが、今回の成立手順を実証した証拠ではない。
- 実行系の旧module名参照を全数検索した結果、変更対象は`Package.swift`のtarget・dependency、
  `Sources/AcCollections/AcCollections.swift`の再公開import、両test群のimport、benchmark source 2件の
  import、および`.github/workflows/ci.yml`のDocC target matrixに限られる。performance CIとcandidate
  workflowはbenchmark source fileの存在を確認するが、module名を比較契約やtask titleとして使わない。
- benchmark packageはproduct `AcCollections`だけに依存し、benchmark task titleは公開型名に基づく現行名を
  維持する。したがって今回のmodule renameは、rename前baseline向けlibrary定義や結果名正規化を変更しない。
- root packageが公開するproductは`AcCollections`だけである。旧moduleの互換targetはrepository内の直接importと
  既存source compatibilityを維持するが、独立library productを新設する判断は今回の移行に含めない。

## 調査範囲

1. `Package.swift`のtarget、dependency、trait条件、test targetを列挙する。
2. production、test、benchmark、compiler fixture、CI、DocC、maintenance文書、単一file生成物にある
   `import`とmodule名依存を、構成条件とともに確認する。
   performance CIについては`Current/PERFORMANCE_CI_CHANGE_GUIDE.md`を正本とし、target・module renameが
   benchmark sourceの完全なtask title、HEADからbaselineへ渡すlibrary定義、結果名の正規化、および
   base・currentそれぞれのharness buildへ与える影響を分ける。
3. repository外consumerで現在成立している直接importと`AcCollections`再公開経路への影響を分ける。
4. 新名称へ移行し、旧module名を薄い互換targetとして残す構成について、source compatibility、SPI・DocC表示、
   移行量、保守負担を確認する。RedBlackTreeの現行manifest、1行の再公開source、互換module用DocCを
   最小構成の基準とし、ElementBuffer系で追加条件が必要な箇所を抽出する。
5. `ElementBuffer`系と`OptionalElementBuffer`系を同時に扱う必要があるか、提供区分の違いから分離すべきかを
   確認する。
6. 判断が必要な場合は、一判断ごとの`DECISION`候補へ分離し、移行実装をこのtaskへ含めない。
7. rename実行候補を作る場合は、performance CIの互換処理をrenameより前に成立させる必要があるかを確認する。
   task titleの意味や測定境界が変わる場合はrename互換として扱わず、別workloadまたはbaseline切替として分離する。

## 調査結論

- 実装本体を`Sources/ElementBufferModule`と`Sources/OptionalElementBufferModule`へ移し、それぞれ同名の
  target・moduleを作る。
- 旧名targetは`Sources/_BareArrayModule`と`Sources/_OptionalArrayModule`の薄いfacadeとし、新moduleへ依存して
  `@_exported import`する。旧名targetの削除は別の明示的な判断がない限り行わない。
- test target名とdirectory名も公開型体系へ合わせて`ElementBufferModuleTests`と
  `OptionalElementBufferModuleTests`へ移す。
- `AcCollections`は新moduleへ直接依存・再公開する。Optional側のtrait条件と
  `ENABLE_OPTIONAL_ELEMENT_BUFFER`名は維持する。
- benchmarkのimportだけを新module名へ変更し、既存task title、workload、baseline比較、結果正規化は変更しない。
- DocC target matrixは新module名へ置換する。旧互換module用DocCは、互換性の説明だけを持つ最小構成にする。
- source、test、manifest、CI、公開文書の実変更と検証は後続の実行taskで行う。

## このtaskで変更しないこと

- `ENABLE_OPTIONAL_ELEMENT_BUFFER` trait名の変更
- ElementBufferの1.0提供対象への復帰
- benchmark workload名、task title、性能判定、baseline
- root packageのlibrary product構成

## 完了条件

- 現行名に依存するsurfaceと構成条件が再現可能な根拠つきで列挙されている。
- performance CIについて、currentの完全なtask名、rename前baselineで解決する完全なtask名、結果正規化後の
  完全なtask名、および両世代のharness build境界が確認されている。
- 薄い互換target付きrenameのmanifest、source、DocC、consumer、CIへの影響が確認されている。
- 両moduleを一括または分離して判断する根拠が示されている。
- 必要な製品判断と、判断後の実行単位が混ざらず分離されている。
- Swift Package Index登録前に閉じる必要がある範囲が明示されている。

## 後続

`ARRAY-016`で、上記のrename、旧名互換facade、import更新、DocC target更新、およびbuild・test・benchmark
検証を一つの機械的移行として実施する。コンパイラ診断で未確認のmodule依存が見つかった場合は診断に従って
同task内で追従するが、公開product、trait、workload、または互換終了条件の変更が必要になった場合は停止して
別判断へ分離する。
