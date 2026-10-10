# 製品品質要求 参照資料

## 位置づけ

本書は、製品品質要求の正本である
[`QUALITY_REQUIREMENTS.md`](QUALITY_REQUIREMENTS.md)を
具体化・評価するときに参照する非規範的な資料である。

既存の品質資産との接続、VerificationとValidationの例、不足仕様の候補を整理する。
ここに記載された既存資産、検証手段、候補は、品質要求、達成水準、受入条件を追加または確定しない。

本書は[`QUALITY_REQUIREMENTS_CLAUDE_V2.md`](QUALITY_REQUIREMENTS_CLAUDE_V2.md)から、正本を洗練する
手がかりとして利用できる内容を抽出・再編した。元文書は独立ドラフトとして保存する。

各節の「洗練の手がかり」は、正本を具体化するときに検討する論点であり、作業義務や受入条件ではない。
「観察」は元ドラフト作成時（2026-10-10）に見えていた事実で、現在も成り立つかは確認していない（`UNVERIFIED`）。

## 品質要求ごとの参照情報

### QR-01 正確性

既存資産:

- 各moduleの番号付きTest as Specification
- C++挙動比較test
- 公開surfaceと互換性に関するtest・記録

洗練の手がかり:

- 公開APIと仕様testの対応範囲をmodule横断で確認できるようにする。
- C++との挙動比較が必要な対象と、Swift固有の契約だけで評価する対象を区別する。

観察: 仕様testはmodule別に整理されている。C++挙動比較testは赤黒木系に偏り、Permutationの
`next_permutation`相当の比較はtest内コメントにとどまる。

Verificationの例は、仕様testによる公開契約の確認やC++比較testによる結果の一致である。
Validationの例は、実際の競技利用で意図した問題を正しく解けることである。

### QR-02 性能効率性

既存資産:

- 公開コメントの計算量記述
- `Benchmarks/`のC++標準ライブラリとの比較
- release間のperformance comparison
- 性能回帰と測定noiseの分析記録

洗練の手がかり:

- 自己比較による回帰検知と、C/C++標準との外部比較を別の証拠経路として扱う。
- 比較対象、操作、入力分布、入力規模、toolchainを明示する。
- 計算量の宣言、実装、実測の対応を確認できるようにする。

観察: C/C++との外部比較の結果は、一部の型（赤黒木系）と一時点のものにとどまる。CIの性能比較は
base／headの自己比較である。

Verificationの例は、宣言した計算量と実装の整合やrelease間での回帰確認である。
Validationの例は、同じworkloadのC/C++標準と比較して製品コンセプト上の「匹敵」を評価することである。

### QR-03 安全性

既存資産:

- 値semantics、copy-on-write、iterator copyの仕様test
- 要素寿命、View、Index validityの仕様test
- Death Test、Sanitizer、strict memory safety評価
- runtime checkと`-Ounchecked`に関する設計・検討記録

洗練の手がかり:

- memory safety、値semantics、利用者の事前条件、ISO/IEC 25010のSafetyを区別する。
- Debug、Release、`-Ounchecked`などの構成ごとに保証範囲を明確にする。
- compiler最適化によって壊れ得る性質を、通常の機能testとは別のリスクとして扱う。

観察: Swift 6.4のRelease最適化でiterator copyの独立性が壊れる事象（`PERM-029`）は、CI（Linux）ではなく
macOSのローカルRelease testで見つかった。

Verificationの例は、値semantics、寿命、契約違反時の挙動を対応する検査で確認することである。
Validationの例は、一般のSwift利用者が明示された保証範囲内で安全に利用できることである。

### QR-04 理解可能性

既存資産:

- DocC、公開コメント、README、利用者向け文書
- コードスニペット候補の調査
- API matrixとTest as Specification

洗練の手がかり:

- Test as Specification、公開コメント、利用者向け文書の間で同じ契約を追跡可能にする。
- DocCが生成できることと、説明やコード例が正しいことを分けて評価する。
- C++経験者とSwift開発者の双方が誤読しやすい用語や制約を確認する。

観察: DocCの`--warnings-as-errors`が通る状態で、赤黒木の型コメントのコード例が現行APIでコンパイルできなかった
（`CP-20261010-002`で修正）。CIでDocCを生成している対象はRedBlackTreeCollectionsだけである。

Verificationの例は、公開文書と現行API・仕様testの整合確認である。
Validationの例は、対象利用者が文書からAPIの意味と制約を理解して正しく利用できることである。

### QR-05 利用可能性

既存資産:

- SwiftPM manifest、umbrella product、package trait
- 対応branchと互換コードの分離
- CIのbuild構成、README、CHANGELOG

洗練の手がかり:

- buildできた環境と、製品が対応を約束する環境を区別する。
- 競技用途の互換構成、実験的構成、一般用途の既定構成を分離する。
- 公開APIの安定性と、0.xで許容する変更範囲を明確にする。

Verificationの例は、宣言した構成でbuildとtestが成功することである。
Validationの例は、競技環境と一般のSwift projectの双方で、想定した方法により導入・利用できることである。

### QR-06 持続可能性

既存資産:

- Test as Specification、performance履歴、品質評価、設計文書
- CI、release記録、Git履歴
- task Registryと事故後の停止・復旧原則

洗練の手がかり:

- 要求から公開契約、test、証拠、判断まで追跡できることを重視する。
- 古い証拠を保存しながら、現行の正本を明確にする。
- 失敗と未確認事項を、次の設計・実装・検証へ戻せるようにする。

Verificationの例は、変更時に関連する品質要求の検証を再実行できることである。
Validationの例は、releaseを重ねても製品コンセプトの四要素が同時に成立していることである。

## 横断的な不足仕様候補

以下は判断候補であり、本書では確定しない。

- C、C++標準、同等実装のどれを、各データ構造・操作の比較対象とするか。
- 「匹敵」を評価するworkload、入力規模、時間・memory上の観点をどう定めるか。
- 計算量の宣言と実装の一致を何の証拠で受け入れるか。
- Debug、Release、`-Ounchecked`ごとの安全性の保証範囲をどう定めるか。
- 公開文書と仕様testをどの単位で対応させるか。
- 競技用途と一般用途で保証するSwift環境、platform、構成をどう定めるか。
- 公開APIの安定性と、0.xで許容する変更範囲をどう定めるか。
- module別の品質評価を製品全体の適合判断へどう集約するか。
- 代表的なValidation scenarioと、その適合を誰が何によって判断するか。

## 証拠を読むときの注意

- 既存資産があることは、その品質要求を満たすことの証明ではない。
- CIの成功は、CIが扱った構成と検査範囲の証拠に限られる。
- 自己比較による性能回帰の不在は、C/C++標準に匹敵することの証明ではない。
- Verificationの成功からValidationの成功を推定しない。
- AI間の見解の一致を、独立した製品証拠として扱わない。
- 元ドラフトが挙げた個別資産の内容と適合範囲には、未確認のものが含まれる。

## ISO/IEC 25010との境界に関する参考

元ドラフトでは、セキュリティを独立要求とせず、低レベル実装に伴うメモリ安全性をQR-03で扱っている。
互換性と柔軟性はQR-05へ、利用時の効果性などはValidationの観点へ接続している。
これは要求体系を洗練するときの参考整理であり、規格への完全適合や特性の除外決定を意味しない。
