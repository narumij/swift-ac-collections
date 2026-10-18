# Sequenceによる失効View収集のバグ課題

記録：2026-10-16、Astra。task：PERM-060。

## ユーザー判断と現在の範囲

ユーザーが「これはバグなので、課題に復活」と指示し、復帰方法を委任した。旧「Sequence表面を製品候補として検討するか」という凍結判断を、バグの再現・影響範囲・修正要求を整理するDISCOVERYとしてACTIVEへ戻した。状態の正本は[Task Registry](../ProgressV2/TASK_REGISTRY_V2.md)。

## 問題

[実験記録](../Technical/NextPermutationsSequenceExperiment.md)では、tests-onlyのRuntimeCheckedPermutationSequenceを`Array(sequence)`へ渡すと、次のnext()と終端nilの取得でViewが失効し、完成した配列の要素を読めなくなる。通常のSequence操作で利用できない結果を作ることが、この課題の対象である。

実験adapterは[テスト](../../Tests/PermutationTests/NextPermutationsSequenceExperimentTests.swift)内にある。現行の[通常公開型](../../Sources/NextPermutationModule/NextPermutations.swift)と[借用公開型](../../Sources/NextPermutationModule/BorrowedNextPermutations.swift)はSequence非準拠と明記されている。公開製品で同じ操作が可能だという確認には広げない。

## 調査の到達点

- 現行toolchain・現行実験コードで、適法な逐次利用と配列収集時の失効を区別して再現する。
- 公開API、実験adapter、利用例への影響範囲を特定する。Iteratorコピーによる共有進行と失効が関係する範囲も確認する。
- 利用者に成立させる必要のある動作と、不具合を防ぐために必要な修正範囲を根拠付きで返す。

実験の成功記録は過去の証拠として使い、今回の再実行結果にはしない。今回行ったのは課題復帰と資料・公開宣言の確認であり、再現試験や修正はまだ実施していない。

## 判断と修正の境界

Sequenceの製品導入、返す値の所有方式、copy・性能コストの許容を、この調査で決定しない。現行の一時View契約全体をバグとして変更する指示にも広げない。修正に公開契約や製品方針の新しい判断が必要なら、調査結果から判断点を分離し、ユーザーへ返す。方針が定まった修正は別の実行範囲として具体化する。

調査結果が受け入れられても、バグ修正済みとは扱わない。未解決の修正・判断の引継ぎ先を記録してから調査を閉じる。

## 経緯

[凍結時の原文](../Archived/PERM-060_BEFORE_REACTIVATION_2026-10-16.md)を保存した。旧採否待ちや凍結条件は今回の明示指示で置き換えられた。固定IDは維持し、再採番しない。

## 現行再現・受入（2026-10-18 / Astra）

根拠版 `76a96cf7123d9dfbd63a1a652160802b27843dff`。Apple Swift 6.4 (swiftlang-6.4.0.34.1)、arm64 macOS。`swift test -c debug --filter NextPermutationsSequenceExperiment` 成功。XCTest 6件とSwift Testing death test 2件、計8件失敗0。[完全ログ](../Evidence/PERM-060/2026-10-18-debug.log)。Release・ASan・互換traitは今回対象外。既存timing testの数値は性能判断に使用しない。

- `map(Array.init)` とfor内コピーの逐次消費は成功。新規iterator同士は独立、コピーしたiteratorは同じ状態を進める。
- `Array(sequence)`後の古いViewのstartIndex読取りと、iteratorコピー側のnext後の古いView読取りは、それぞれ期待したtrapで終了。
- `NextPermutations.next()`は分岐の前に世代を閉じる。終端nilも例外でない。実験adapterはこのViewをそのままElementとして返すので、収集完了時には保持したViewが有効ではない。
- 通常公開型NextPermutationsとBorrowedNextPermutationsはSequence非準拠を明記。実験adapterはテストファイル内private。したがって今回の再現から通常公開APIの修正必要性までは導けない。
- `Compatibility/AtCoder2025/PermutationsAtCoder2025.swift`には別のSequence実装がある。今回の試験は `!COMPATIBLE_ATCODER_2025` 条件内であり、互換側の安全性・不具合有無をこの結果へ含めない。

調査を受入。製品・テストコードは変更していない。修正済みではなく、実験アダプターの扱いを決める[PERM-081](PERMUTATION_SEQUENCE_ADAPTER_DECISION.md)へ引継ぐ。判断後の実装修正は別範囲で定める。

## 一時作業物:

`/tmp/astra-perm060-test.log`（実体 `/private/tmp/astra-perm060-test.log`）、2026-10-18 Astra作成、限定試験ログ。上記Evidenceへ保存済み、削除可。通常の.buildは共有build cacheとして保持。
