# PermutationModule 製品化判断のための所見(削減実施後版)

この文書は、`PermutationModule`の公開APIを調査した所見の記録である。2026-10-03、
`Maintanance/CLAUDE_TASK.md`のユーザー最終決定に基づき、本書で削除候補として
扱っていた`All`系・`unsafe`系の公開APIは実際に削除済み(実施記録は
`ImplementationPlan.md`、現行APIは`Sources/PermutationModule/Documentation/Specification.md`
を参照)。本書は調査結果・判断根拠の記録として残す。

## 存在理由(`release/AtCoder/2025`ブランチのREADME.mdより)

現在作業中のブランチの`README.md`/`README.ja.md`には`PermutationModule`の記載が無いが、
`remotes/origin/release/AtCoder/2025`の`README.md`には由来が明記されている。

- ABC328Eという問題(制約`N <= 8`, `M <= 28`)で、C++の解説コードが全探索的に見えたため
  「組み合わせを力尽くで計算できる」と誤解していた期間があった。実際は辞書順の変化だけを
  行う`next_permutation`の挙動により組み合わせ数が減っていたために計算可能だった、
  という誤解だった。
- この誤解を追いかける過程で「オーバーヘッドが少ない実装」を追求し、結果として軽量な実装が
  生まれた。
- `unsafePermutations`/`unsafeNextPermutations`は「おまけ」として位置付けられ、
  「コピーオンライトをキャンセルして行わない動作」であることが明記されていた
  (CoWを省く設計は不備ではなく、AtCoder提出コードのような使い捨てコンテキストでの
  オーバーヘッド最小化という明確な狙いに基づく)。

つまりこのモジュールは「漫然とした実験」ではなく、特定の問題(ABC328E)から生まれた
具体的な存在理由を持つ。この存在理由の中心は「辞書順で次を1つ求める」操作
(`next_permutation`相当、`nextPermutations()`)であり、「全順列を列挙する」操作
(旧`All`系)は、その過程で派生的に実装されたものであって、モジュールの中心的な
価値ではなかった。この判断に基づき`All`系は削除した。

## 削除根拠となった所見

- `Permutations.All`にはpublicな`init(safe:)`と、それに対応する`IteratorA.ensureUnique()`が
  実装されていたが、これを呼び出すCollection拡張(「安全な全列挙」の便利メソッド)は
  存在しなかった。`swift test --enable-code-coverage --filter PermutationTests`で
  確認したところ、`Permutations.All.init(safe:)`・`IteratorA.ensureUnique()`は実行回数0
  (カバレッジ上も未到達)であり、本リポジトリ内にこれらを使う既存コードが無いことも
  削除の障害が少ないことを示していた。
- `All`系統は`swift-algorithms`の`permutations()`と機能的に重複していた。この重複は
  `ImplementationPlan.md`のPhase 1A PoC(空/単一要素/昇順/非昇順/降順/重複値/
  `Array`以外のCollectionの7ケース)で、即時`Array`化した結果が完全一致することを
  確認し、削除根拠として確定させた。
- ファイル先頭(`Permutations.swift:1`、削除前)に「模索の痕跡がのこっていて散らかって
  いるので、要点に沿って整理しなおすか、廃止するか、いずれかを次回ジャッジ更新までに
  行うこと」というTODOが存在し、作者自身も状態を把握していた。

## 現在も残る論点(所見・未着手)

- `Sendable`適合の要否。`BareArray`/`OptionalArray`と異なり、`Permutations`関連の型に
  `Sendable`適合の宣言が無い。
- 公開メソッドに対して、計算量・CoW契約・事前条件(空コレクション等)を説明する
  コメントドック(`///`)が無い。
- ABC328Eの実提出による性能検証(ベースライン記録・削除後の再提出比較)は、外部サービス
  (AtCoder)への投稿を伴うためユーザー自身が行う前提。

この文書はコード変更を含まない調査結果の記録。残る論点への対応方針はユーザーの判断を待つ。
