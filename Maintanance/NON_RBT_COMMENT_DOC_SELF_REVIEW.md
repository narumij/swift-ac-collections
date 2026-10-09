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
2. `OptionalArrayModule`の多次元subscriptとView subscriptは、連鎖書き込みのための
   setterが任意の`newValue`を黙って無視する。公開コメントはView共有と寿命を説明するが、
   setterがwriteback専用であることや別View代入の扱いは説明していない。testは連鎖書き込みと
   取得したViewからの変更共有を確認するが、別Viewの直接代入契約は定めていない。
   BareArray同様に代入を契約違反として検査するか、現在のno-opを公開契約として記載するかは
   製品判断が必要であり、本レビューでは修正しない。
