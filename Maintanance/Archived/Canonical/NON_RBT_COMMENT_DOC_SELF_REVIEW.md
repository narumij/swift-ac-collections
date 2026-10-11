# RedBlackTree以外のコメントドック・セルフレビュー

2026-10-10、`AcCollections`、`PermutationModule`通常版、
`OptionalArrayModule`、`BareArrayModule`の公開宣言を実装と対応testへ照合した。
互換mode、RedBlackTree系、test・fixture・C helperは対象外。

## 結果

- `AcCollections`: facadeの再公開は専用testで到達確認されており、独自の公開宣言はない。
- `BareArrayModule`: ownership、View寿命、軸順、writeback専用setter、境界、計算量は
  実装と通常test・death testに一致した。
- 判断不要で直せるコメント不一致は見つからなかった。

## 製品判断または追加検証が必要な候補

1. `PermutationModule`はiterator copyの独立性を公開契約として記載し、対応testもある。
   一方、source内TODOにはSwift 6.4 Release構成で元iteratorの進行がcopy側へ波及した
   未解決事象が記録されている。実装由来かcompiler由来か確定していないため、コメントを
   修正すべきとは推定しない。1.0前の再現確認までは未確認事項として残す。
2. `OptionalArrayModule`の多次元subscriptとView subscriptのsetterは任意の`newValue`を
   黙って無視するが、`OptionalArrayAudit.md`を再確認すると、2026-10-08に「連鎖subscriptの
   writeback用の実装手段で、View全体代入を提供する公開契約ではない」とユーザー確認済みだった。
   したがって新しい製品判断候補ではなく、公開コメントへsetterの実装詳細を追加しない現状を維持する。

## Claude独立照合の受入

2026-10-10、Claudeのread-only照合は完成判定ではなく証拠packageとしてCodexが検収した。
先行観測2件に加え、次の判断不要な修正候補を受け入れた。

- `NextPermutationsSequence.makeIterator()`はsource collectionをbufferへcopyするためO(n)だが、
  公開コメントに計算量がない。
- `OptionalArray1D`と`OptionalArray1DView`の要素subscriptは、設定済みslotへ非`nil`を
  上書きしたとき以前の要素を破棄することがtestで固定されているが、コメントに明記されていない。
- `OptionalArray4D`の軸説明が`array[size3][size2][size1][size0]`となっており、寸法名を
  添字値のように見せるため、添字記号へ直す余地がある。
- 1D `BareArray`の本文に「多次元配列」が残っている。

一方、公開仕様testがないことだけを理由にした`next()`終端とOptionalArray境界条件の
`UNVERIFIED`分類は採用しない。実装と既存testからコメントとの一致を確認できる。
`removeAll()`を`let`所有値から呼べる点も、利用者が必要とするコメント制約とは判定しない。
3 moduleを公開初版へ進める完成判定はClaudeの結論から切り離し、Codexに残す。

## 後続対応

2026-10-10、ユーザー指示によりA系統を実行した。

- Permutationは`makeIterator()`だけでなく、公開入口、index、等値比較、hash、descriptionまで
  計算量を横断確認し、実装に基づく記載を補った。OptionalArrayとBareArrayは、計算量を記載すべき
  公開operationに既に記載があり、実装との新たな不一致は見つからなかった。
- OptionalArrayの上書き破棄は、所有1Dと1DViewの別々の`_modify`実装、および両経路の参照寿命testで
  契約が固定されていた。記載不能な契約ではなく、ドラフト時にnil代入だけを説明して非nil上書きを
  落とした重要なcoverage不足と判定し、両subscriptへ以前の要素を破棄して置き換える旨を追記した。
- OptionalArray4Dの軸表現とBareArray 1Dの「多次元配列」を最小補正した。
- Xcode build成功。OptionalArrayとBareArrayのfile診断は0件。Permutationのfile診断2件は既存の
  unsafe／未使用結果warningで、今回のコメント差分とは無関係。3 targetのdocumentation buildを
  `--warnings-as-errors`付きで実行し、すべて成功した。
## DOC-018: 公開コメントのparameter欄補完

BareArray、OptionalArray、Permutationの公開APIコメントについて、引数を持つ宣言にDocCの
`Parameter`／`Parameters`欄を補う。既存の公開契約は変更せず、各引数の意味は実装とtestで確認する。
完了条件は対象宣言のparameter coverage確認と、3 targetのdocumentation build成功。

2026-10-10完了。parameterを持つ公開宣言29件（BareArray 15件、OptionalArray 11件、
Permutation 3件）を照合し、`Parameter`／`Parameters`欄を補完した。軸・位置・closureの意味は
既存実装とtestで確定している表現に限定した。3 targetとも`--warnings-as-errors`付きの
documentation buildに成功した。
