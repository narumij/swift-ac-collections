# Sequenceによる失効View収集のバグ課題

記録：2026-10-16、Astra。task：PERM-060。

## ユーザー判断と現在の範囲

ユーザーが「これはバグなので、課題に復活」と指示し、復帰方法を委任した。旧「Sequence表面を製品候補として検討するか」という凍結判断を、バグの再現・影響範囲・修正要求を整理するDISCOVERYとしてACTIVEへ戻した。状態の正本は[Task Registry](../ProgressV2/TASK_REGISTRY_V2.md)。

## 問題

[実験記録](../PermutationModule/NextPermutationsSequenceExperiment.md)では、tests-onlyのRuntimeCheckedPermutationSequenceを`Array(sequence)`へ渡すと、次のnext()と終端nilの取得でViewが失効し、完成した配列の要素を読めなくなる。通常のSequence操作で利用できない結果を作ることが、この課題の対象である。

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
