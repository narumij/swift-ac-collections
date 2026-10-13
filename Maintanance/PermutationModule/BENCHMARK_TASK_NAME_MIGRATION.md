# Permutation benchmark task名の現行型名への移行

## 目的

現行workloadが`NextPermutationsSequence.Permutation.subscript(position:)`を測定しているのに、benchmark titleと
通常CI表示が旧内部型名`Permutations.SubSequenceN`を名乗る乖離を解消する。workload、測定境界、反復回数、
performance閾値、および実装方式は変更しない。

## 現在の事実

- `PermutationBenchmarks.swift`には旧内部型名を含むtitleが4件ある。
- 通常CIの`CI.json`は、そのうちbatched sequential / shuffledの2件を登録している。
- source冒頭は、結果継続性のため旧名を維持したと説明している。
- 実際に測定する型は`NextPermutationsSequence.Permutation`であり、表示名だけが旧い。
- `PERFORMANCE_CI_CHANGE_GUIDE.md`は、task名変更時にworkflow互換を先にmergeしてgreenを確認し、その後の
  独立変更でtitleをrenameする二段階境界を要求する。

## 確定する新名称

旧prefix `Permutations.SubSequenceN`を`NextPermutationsSequence.Permutation`へ置き換える。操作名と
`(batched)` suffixは維持する。

対象titleは次の4件とする。

- sequential access
- shuffled access
- sequential access (batched)
- shuffled access (batched)

## `PERM-063`: workflow互換の先行導入

1. baselineのbenchmark sourceが新prefixを持たない場合だけ、HEADのCI library 2 taskを旧prefixへ変換する。
2. baseline測定後、結果JSONの旧prefixを新prefixへ正規化する。
3. currentのtask列挙と完全title、旧baseline入力、正規化後の完全titleを照合する。
4. workflow変更だけをmergeし、performanceを含むremote CIのgreenを次段階の開始条件とする。

## `PERM-064`: titleとCI libraryの移行

1. benchmark sourceの4 titleを新prefixへ変更する。
2. source冒頭の「旧名を維持する」説明を現行状態へ更新する。
3. `CI.json`のbatched 2 taskを新prefixへ変更する。
4. benchmark release buildとtask列挙で4 titleを確認する。
5. main baselineとHEADの測定・比較が完走し、remote performance CIがgreenになることを確認する。

## 境界

- runtime-check版とborrowed版の性能契約を変更または混在させない。
- unbatched 2 taskを通常CIへ追加しない。
- workloadの処理内容、input size、batch回数、結果検証、CI回帰閾値を変更しない。
- `Permutations.SubSequenceN`という型を復活させない。
- workflow互換の終了はこの移行の完了条件に含めない。baselineでno-opとなった後も、過去commit比較と将来renameに
  利用できる一般的な互換処理として扱う。

## 再開条件

現在の旧facade target削除PRを完了した後、ユーザーがbenchmark表示名移行の開始を明示したときに
`PERM-063`から再開する。文書ドラフトの現在の中間ゴールより優先して割り込ませる必要はない。
