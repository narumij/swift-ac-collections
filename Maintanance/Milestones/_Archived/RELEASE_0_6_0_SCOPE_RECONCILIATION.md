# 0.6.0提供範囲と文書入力の照合

2026-10-16 / Astra / RELEASE-078。ユーザーが先行実施を承認。基点はe76964c2の製品・manifest。既存のRBT-048時期記録差分は本照合の製品入力に影響しない。

## 結果

旧開始条件のPermutation / OptionalArray / BareArray / RedBlackTreeは、下表の現行4モジュールへ対応する。名称決定をやり直さず、DOC-035の点検範囲として渡す。リリースへ含める変更・開始許可・1.0品質達成は決定していない。

| 現行対象 | 公開入口と条件 | 文書入力・確認点 |
| --- | --- | --- |
| RedBlackTreeCollections | AcCollectionsから再公開。4コンテナと関連View | DOC-034の本文・型コメントと78例、DOC-037のユーザー受入を再利用。現行DocC・導線を確認 |
| NextPermutationModule | AcCollectionsから再公開。旧PermutationModuleは互換入口 | 現行DocC・NextPermutations/BorrowedNextPermutationsコメント。一時Viewの失効と借用、Sequenceではないこと |
| OptionalElementBufferModule | AcCollectionsからの再公開はENABLE_OPTIONAL_ELEMENT_BUFFER traitが必要。実験的、留保付き1.0対象 | 現行DocC・4次元型コメント。unset、要素寿命、非mutating更新、利用制約 |
| ElementBufferModule | AcCollectionsから再公開。Swift 6.2競技供用／6.4一般供用という方針 | 現行DocC・4次元型コメント。現パッケージはSwift 6.4必須。MutableRefアクセスはApple OS 27以降 |

根拠：Package.swift、Sources/AcCollections/AcCollections.swift、各モジュールの現行ソースとDocC、[品質要求](../../Quality/QUALITY_REQUIREMENTS.md#10に向けた開発対象)。manifestのmacOS最低宣言は15であり、個別APIの27条件や将来の1.0環境方針を混同しない。他platformの実行品質を宣言だけで確定しない。

## 条件付き依存と判断の境界

- DOC-035は本照合とDOC-037の明示受入を入力に実行可能。既存スニペットの構成・数は固定。
- 現行Pages workflowは赤黒木のみ生成。4モジュールのソース文書を確認する仕事と、0.7.0の公開方式切替は分ける。READMEでは未公開のURLを生成済みと案内しない。
- Quality/0.6.0-1は前回一周の保存資料であり、今回の対象版の合格証明ではない。対象版の差分に応じた品質確認はリリース段階に残る。
- RBT-048のnil→fatalError等のユーザー判断は0.7.0仮置き。今回決めず、現行契約で文書を点検する。
- 文書初版が揃った後の製品範囲とリリース開始は、既存のRELEASE_0_6_0 / RELEASE_PROCESSのユーザー判断へ渡す。工程整備・SPI・1.0全体評価を今回の前提へ追加しない。

## 完了

4対象・必要文書入力・条件付き依存・残るユーザー判断を整理した。新しい製品方針判断は発生していない。RELEASE-078の調査は完了し、DOC-035へ引き渡す。文書初版確認そのものは別途結果を残す。
