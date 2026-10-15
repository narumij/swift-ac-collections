# Permutation benchmark task名の現行型名への移行

## 工程統合 2026-10-16

ユーザー指示によりPERM-063はEXCLUDED。必要なworkflow互換処理はPERM-064内の先行工程へ統合した。以下のPERM-063凍結・再開待ちの記述は過去の整理であり、現行条件ではない。[現行正本](PERMUTATION_BENCHMARK_TITLE_MIGRATION.md)に従う。二段階のmerge・検証境界は維持する。


## 統合前の扱い（2026-10-16の履歴）

以下は工程統合前の記録であり、凍結・再開条件として適用しない。現在の状態と工程は冒頭の現行正本を参照する。

Astra整理。これは完了済みmodule移行のmain到達確認とは別の、後段に延期したbenchmark表示名整理である。現行sourceの4 titleとCI登録2件には`Permutations.SubSequenceN`が残る。今回の照合で完了とは扱わず、PERM-063の凍結を維持する。PERM-064は同日、ユーザーの追加指示でACTIVEへ復帰した。先行依存を保ち、[現行正本](PERMUTATION_BENCHMARK_TITLE_MIGRATION.md)に従う。

以下の旧型名を新名称とする案は当時の計画である。現行の名称決定と整合する表示名は、再開時に対象とともに確定する。旧案の文字列をそのまま実装しない。workflow互換の先行mergeとgreen、その後のtitle変更という二段階は維持する。

当時の「旧facade target削除PRの完了」は、現在の再開条件として使わない。[module移行計画](PERMUTATION_MODULE_MIGRATION_PLAN.md)に従い、後段でユーザーが時期・対象を確定して明示的に再開したときに具体化する。module移行の完了だけでは再開しない。

## 当初の計画


## 目的

現行workloadが`NextPermutationsSequence.Permutation.subscript(position:)`を測定しているのに、benchmark titleと
通常CI表示が旧内部型名`Permutations.SubSequenceN`を名乗る乖離を解消する。workload、測定境界、反復回数、
performance閾値、および実装方式は変更しない。

## 当初計画時点の事実

- `PermutationBenchmarks.swift`には旧内部型名を含むtitleが4件ある。
- 通常CIの`CI.json`は、そのうちbatched sequential / shuffledの2件を登録している。
- source冒頭は、結果継続性のため旧名を維持したと説明している。
- 実際に測定する型は`NextPermutationsSequence.Permutation`であり、表示名だけが旧い。
- `Maintanance/Current/PERFORMANCE_CI_CHANGE_GUIDE.md`は、task名変更時にworkflow互換を先にmergeしてgreenを確認し、その後の
  独立変更でtitleをrenameする二段階境界を要求する。

## 当時の新名称案（現行採用名ではない）

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

## 当時の再開条件（工程統合により失効）

現在の旧facade target削除PRを完了した後、ユーザーがbenchmark表示名移行の開始を明示したときに
`PERM-063`から再開する。文書ドラフトの現在の中間ゴールより優先して割り込ませる必要はない。
