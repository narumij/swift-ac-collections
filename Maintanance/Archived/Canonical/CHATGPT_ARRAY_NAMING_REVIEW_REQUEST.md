# ChatGPTへの依頼 — Array module命名レビュー補完

## TL;DR（人間向け）
BareArrayとOptionalArrayの命名について、先行調査で残った代替語、Viewの意味、4D軸名、標準ライブラリの新しい型との関係を比較するよう依頼した記録です。名称決定やsource変更は依頼していません。これは当時の調査依頼であり、現在の指示ではありません。

## 依頼の目的

For the pre-release BareArray and OptionalArray APIs in the Swift package `swift-ac-collections`, investigate gaps relevant to selecting naming systems that can be maintained long term after publication. Do not select names or modify source; return a comparison that lets the user decide.

The prior investigation and Codex's preliminary assessment are in the attached or supplied `Maintanance/Archived/Canonical/ARRAY_NAMING_REVIEW.md`. Treat its existing surface table, exact-name checks using the local toolchain, and repository migration counts as inputs; do not repeat that work.

## 製品上の前提

- BareArray is a low-level array for competitive programming, with fixed capacity and contiguous storage.
- OptionalArray is a fixed-capacity multidimensional array whose slots can be unset.
- Both modules have owning 1D–4D types and non-owning 1D–3D Views.
- A View shares a pointer to its owner; the type system does not prevent the View from outliving that owner.
- The APIs are not yet formally published, so long-term durability, readability, searchability, and predictability take priority over source compatibility with current names. Existing usage examples and migration impact for Git users must still be recorded.
- Names, key terms, and naming conventions must not conflict with or mislead users into believing these are Swift standard-library or `swift-collections` APIs.

## 補完してほしい論点

1. Compare several meaningful alternatives to `Bare` and `Optional`. Explain how each candidate communicates ownership, fixed capacity, unset slots, and non-owning Views; describe likely misinterpretations and why candidates are rejected.
2. Compare keeping `View` with alternative suffixes. Focus on differences between this non-owning pointer type and the Collection, range, and lifetime guarantees users may expect from standard-library `Slice`, `Span`, and `View` terminology.
3. Separate renaming 4D dimensions from changing the axis contract. First compare names that preserve storage order and chained-subscript behavior. If reversing axis order is considered necessary, identify it as a separate product decision.
4. Check official `swift-collections` `main` and Swift Evolution proposal SE-0527 for `RigidArray` / `UniqueArray`; include the movement of ownership-aware array naming into the standard library as counterevidence.

Primary sources:

- https://github.com/apple/swift-collections
- https://github.com/swiftlang/swift-evolution/blob/main/proposals/0527-rigidarray-uniquearray.md

## 判断単位と出力形式

Do not combine the following three decisions. For each, provide a candidate comparison table, one recommendation, the strongest counterargument, and unverified scope.

1. The BareArray naming system, including owning types, Views, and dimension labels.
2. The OptionalArray 1D owning-type name.
3. The OptionalArray 2D–4D dimension-label system.

Do not recommend a name solely because it is not an exact match to an existing name. Evaluate how accurately it represents the contract. Do not harmonize BareArray and OptionalArray merely for visual consistency; explain the product reason if they differ.

## 禁止事項

- Do not make the final naming decision.
- Do not modify source, tests, or documentation.
- Do not implement renames, typealiases, deprecated aliases, or a migration period.
- Do not expand into performance, View lifetime remediation, storage redesign, or strict memory safety.
