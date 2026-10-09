# ChatGPTへの依頼 — Array module命名レビュー補完

## 依頼の目的

Swift package `swift-ac-collections`で正式公開前のBareArrayとOptionalArrayについて、公開後も長く維持できる
命名体系を選ぶための不足調査をしてください。名称の決定やsource修正は行わず、ユーザーが判断できる比較を
返してください。

先行調査とCodexの予備評価は、添付または提示する`Maintanance/ARRAY_NAMING_REVIEW.md`にあります。
既存のsurface表、local toolchainでの完全一致確認、repository内の移行件数は再調査せず、その内容を入力と
してください。

## 製品上の前提

- BareArrayは、競技プログラミング向けの固定容量・連続storageを持つ低レベル配列です。
- OptionalArrayは、各slotの未設定状態を持てる固定容量の多次元配列です。
- 両moduleは所有1D〜4Dと、非所有の1D〜3D Viewを持ちます。
- Viewは所有者のpointerを共有し、所有者より長く生きることを型では禁止していません。
- 正式公開前なので、現行名とのsource compatibilityより、公開後の持続性、可読性、検索性、推測可能性を
  優先できます。
- 必須条件は、Swift標準ライブラリおよび`swift-collections`の公開型名・主要用語・命名規則と衝突せず、
  それらの型だと誤認されにくいことです。

## 補完してほしい論点

1. `Bare`と`Optional`について、実質的な代替接頭語を複数比較してください。各候補が所有、固定容量、
   未設定slot、非所有Viewの契約をどう表し、何を誤認させるか、棄却理由も示してください。
2. `View`維持案と代替suffixを比較してください。標準の`Slice`、`Span`、`View`が与えるCollection、範囲、
   寿命保証の期待と、このpackageの非所有pointer型との差を重視してください。
3. 4Dの名称変更と軸契約の変更を分離してください。storage順と連鎖subscriptの意味を維持したまま可能な
   名称案を先に比較し、軸順反転が必要なら別の製品判断だと明記してください。
4. 公式`swift-collections`の現行`main`と、Swift Evolution SE-0527の`RigidArray` / `UniqueArray`を確認し、
   ownership-aware arrayの命名領域が標準ライブラリへ移る方向を反証へ含めてください。

一次資料:

- https://github.com/apple/swift-collections
- https://github.com/swiftlang/swift-evolution/blob/main/proposals/0527-rigidarray-uniquearray.md

## 判断単位と出力形式

次の三単位を混ぜず、それぞれについて候補比較表、推奨一つ、最も強い反証、未確認範囲を示してください。

1. BareArrayの所有型、View型、次元名を含む命名体系。
2. OptionalArrayの1D所有型名。
3. OptionalArrayの2D〜4D次元名体系。

「既存名と完全一致しない」だけで推奨せず、契約を最も誤認させにくいかを評価してください。BareArrayと
OptionalArrayの見た目の統一だけを理由にせず、差を残す場合は用途上の理由を説明してください。

## 禁止事項

- 名称を最終決定しない。
- source、test、文書を変更しない。
- rename、typealias、deprecated alias、移行期間を実装しない。
- 性能、View寿命の解決、storage再設計、strict memory safetyへ範囲を広げない。
