# RedBlackTreeCollections モジュール品質プロファイル

## 目的と適用範囲

この文書は、リポジトリ全体の上位品質要求をRedBlackTreeCollectionsへ適用し、このモジュールで重視する品質、仕様の正本、検証証拠、および未確定領域の扱いを定める。

この文書だけで品質要求を新設または変更しない。上位品質要求の正本は`Maintanance/User/QUALITY_REQUIREMENTS.md`である。公開契約、設計契約、Test as Specification、およびCIの実行結果は、それぞれが担当する事実と証拠を提供する。

## 文書の位置づけ

この文書は、RedBlackTreeCollections固有の品質プロファイルであり、次を行う。

- 上位品質要求がこのモジュールで何を意味するかを説明する。
- モジュール固有の重点領域を示す。
- 要求、仕様、および検証証拠の接続先を示す。
- 未確定の公開契約や未検証の主張を、確認済みの品質から分離する。

この文書は、Task Registry、公開API、設計文書、Test as Specification、CI設定の代わりにはならない。それらと食い違う場合は、対象事項を担当する正本を確認し、この文書の記述を訂正する。

## 上位品質要求との接続

| 上位要求 | RedBlackTreeCollectionsでの主な意味 | 主な仕様・証拠の接続先 |
| --- | --- | --- |
| QR-01 正確性 | Set、MultiSet、Dictionary、MultiMapとしての操作、比較順、赤黒木の不変条件、値セマンティクスが正しい | 公開APIのTest as Specification、`Tests/RedBlackTreeTreeTests/Foundamental/`、参照モデルを用いるテスト |
| QR-02 性能効率性 | 赤黒木とCopy on Writeを採用する目的を損なう計算量、allocation、走査特性の退行を防ぐ | `Design/*`の計算量・構造上の契約、性能テスト、CIのperformance job |
| QR-03 安全性 | raw memory、node、payload、Index、所有権、寿命、Copy on Writeの境界を壊さない | メモリ・Index関連の設計文書、通常テスト、Death Test、Sanitizer、runtime-check関連テスト |
| QR-04 理解可能性 | 公開契約、保証しない範囲、設計理由、内部契約の境界を追跡できる | API文書、`API-Matrix*.md`、`Design/*`、Test as Specificationの名称と構造 |
| QR-05 利用可能性 | 対象toolchain、platform、build configuration、互換構成で利用・検証できる | `Package.swift`、公開文書、GitHub Actions、互換構成のテスト |
| QR-06 持続可能性 | 変更時に影響範囲を特定し、契約違反と性能・安全性の退行を再検出できる | Test as Specification、内部契約テスト、設計文書、CI、release時の検証記録 |

この表は網羅的なテスト対応表ではない。個別の性質は、担当する仕様テストまたは設計文書で表現する。

## モジュール固有の重点領域

RedBlackTreeCollectionsでは、上位品質要求のうち特に次の三領域が実装リスクと利用価値へ直接影響する。

1. コレクションとして正しく動作すること。
2. raw memory、payload、Index、所有権、および寿命を壊さないこと。
3. 赤黒木とCopy on Writeを採用する目的を損なう性能退行がないこと。

これらは他の上位品質要求を対象外にするものではない。理解可能性、利用可能性、および変更可能性は、三領域の契約と証拠を利用者・保守者が確認し、変更後に再検証するために必要である。

## 仕様と証拠の境界

### Test as Specification

外部または内部から観察可能な契約について、実行可能な正本はTest as Specificationとする。テスト名と構造は、可能な限り実装手順ではなく、満たすべき性質を表す。

品質要求と個別テストの対応表は原則として別に維持しない。仕様を追加または変更するときは、その性質を担当するテストを追加または変更する。この文書からは、番号付きテスト群、内部契約テスト、Death Test、性能テストなど、変更に耐える単位で接続する。

テストの存在だけで、要求が満たされた、すべての構成で保証された、または利用目的へ適合したとは判断しない。対象構成、実行結果、反証、未検証領域を確認して評価する。

### 設計文書

テストだけでは表現しにくい所有権、計算量、採用理由、メモリレイアウト、および実装上の制約は`Design/*`を担当文書とする。観察可能な帰結がある場合はTest as Specificationで補強する。

### CIと検証記録

CI設定は、実際に検証するtoolchain、platform、build configuration、Sanitizer、およびperformance jobの正本である。CI jobの存在と、特定候補commitでの成功記録は区別する。

## 品質領域

### 1. 動作の正しさ

少なくとも次の性質を、担当するTest as Specificationで扱う。

- SetとDictionaryはキーを一意に保持する。
- MultiSetとMultiMapは重複キーを契約どおり扱う。
- 検索、挿入、削除、範囲操作、および走査の結果が公開契約と一致する。
- 走査結果が比較順と一致する。
- 変更後も赤黒木の不変条件が成立する。
- コピー後の変更で値セマンティクスが壊れない。
- 空、単一要素、最小位置、最大位置などの境界を正しく扱う。

可能な操作は、Swift標準コンテナ、ソート済み配列、または別実装の参照モデルと比較する。ランダム操作列を使用する場合は、失敗を再現できるseedまたは操作列を残す。

### 2. メモリ、所有権、およびIndex

少なくとも次の領域を、設計文書、通常テスト、Death Test、およびSanitizerで分担して扱う。

- nodeとpayloadの構築・破棄が対応すること。
- alignment、stride、および領域境界を守ること。
- 未初期化領域、解放済み領域、および無効なIndexから不正に読み書きしないこと。
- Copy on Writeによって値セマンティクスと所有権境界が保たれること。
- nodeの再利用によって古い世代のIndexが新しい要素を指さないこと。
- `endIndex`と要素を指すIndexを契約どおり区別すること。

Indexの公開表現、`Comparable`採否、異なる木の間でのIndex利用、runtime check、および構成ごとの保証範囲には未確定または再審査待ちの領域がある。担当する設計文書、Test as Specification、およびTask Registryで確定するまで、この文書から新しい公開保証を導かない。

### 3. 性能効率性

設計上の計算量と、測定による性能退行検出を区別する。

- 検索、挿入、および単一要素削除では、赤黒木に期待する探索特性を維持する。
- コレクションの値コピーと、変更時のstorage分離を区別する。
- K要素の走査を、各要素ごとの再探索へ退行させない。
- 不要なallocation、Copy on Write、または高速経路の喪失を検出可能にする。

有限回の測定だけで計算量を証明したとはみなさない。実時間を比較する場合は、toolchain、build configuration、trait、入力、および実行環境を揃え、測定条件と結果を残す。具体的な計算量契約は、現在の実装と照合された設計文書を正とする。

自己比較による相対的な性能退行の検出と、C/C++標準との外部比較も区別する。RedBlackTreeのbenchmark、`Tests/CppBehaviorReferenceTests/`、および関連する比較記録は外部比較の証拠候補であるが、それらの存在や限定された測定結果だけでQR-02への適合を証明したとはみなさない。対象実装、操作、入力、toolchain、最適化構成、および測定方法を揃えて評価する。

### 4. 理解可能性、利用可能性、および変更可能性

- 公開API、保証しない範囲、互換構成、およびunderscored declarationの扱いを利用者向け文書から確認できるようにする。
- 設計理由と内部制約を、実装だけに埋め込まず担当する設計文書へ残す。
- 変更箇所に応じて、公開仕様、内部不変条件、安全性、性能のどの証拠を再確認するか判断できるようにする。
- サポート対象は、現在の`Package.swift`、公開文書、およびCI設定から確認する。過去の記述を現在の保証として流用しない。

## 内部実装のTest as Specification

`Tests/RedBlackTreeTreeTests/Foundamental/`は、公開APIの仕様ではなく、`__tree`移植層が上位のストレージ実装から独立して満たす内部契約の実行可能な正本とする。

主な対象は、root・end・nullptr・親子リンク、挿入・削除・回転・走査後の不変条件、uniqueとmultiのキー処理、比較とkey取得の注入経路、nodeとpayloadの配置、構築と破棄、node再利用後の古いseal拒否、および不正操作の停止契約である。

Fixtureは契約を観測するための参照実装であり、製品ストレージそのものを仕様にはしない。独立した経路を照合するテストを、同じ計算を共有して結果だけ一致させるテストへ退行させない。

## 変更時の確認

変更範囲に応じて、少なくとも次を確認する。

1. 関連するTest as Specificationが成功する。
2. 挿入、削除、回転、または探索を変更した場合、赤黒木と順序の不変条件を確認する。
3. storage、Index、payload、削除、またはCopy on Writeを変更した場合、寿命、所有権、無効化、および停止契約を確認する。
4. hot path、メモリレイアウト、allocation、または走査を変更した場合、設計上の計算量と性能証拠への影響を確認する。
5. 公開契約、対象環境、または互換構成を変更した場合、利用者向け文書とCIの検証範囲を確認する。

具体的なrelease gateは、対象releaseの計画とCI設定で定める。この文書へ特定releaseの進行状態を記録しない。

## 現在評価の扱い

この文書の作成時点では、旧品質方針を現行実装と一項目ずつ再照合した完全な現在評価は行っていない。そのため、旧文書に記載されていた保証、構成、計算量、および検証状態を一括して「確認済み」とは扱わない。

現在評価を行う場合は、各品質主張について次を区別する。

- 確認済み
- 未達
- 未検証
- 対象外
- 受容済みの残余リスク

各判定では、次の情報を対応づける。

- 上位要求およびモジュール固有の要求
- 公開契約または設計契約
- Test as Specificationその他の検証証拠
- 実行した構成と結果
- 未検証領域、反証、および残余リスク
- Verificationと、利用目的に対するValidation

## 関連する正本

| 対象 | 正本 |
| --- | --- |
| リポジトリ全体の上位品質要求 | `Maintanance/User/QUALITY_REQUIREMENTS.md` |
| 現在のtask状態、所有者、依存、再開条件 | `Maintanance/PROGRESS_OVERVIEW.md`のTask Registry |
| 公開APIの存在と4型への展開 | `API-Matrix.md` |
| 外部または内部から観察可能な仕様 | Test as Specification |
| テストで使用するFixture | `Tests/RedBlackTreeFixture/Fixtures.md` |
| 設計理由、所有権、計算量、および内部構造 | `Design/*` |
| 実際に検証するtoolchain、Sanitizer、および構成 | GitHub Actions |
| 特定候補commitでの検証結果 | 対象releaseまたは検証作業の記録 |

## 関連文書

- [上位品質要求](../../../Maintanance/User/QUALITY_REQUIREMENTS.md)
- [API Matrix](API-Matrix.md)
- [設計Overview](Design/Design-Overview.md)
- [内部アーキテクチャ](Design/Design-InternalArchitecture.md)
- [ノードストレージの設計](Design/Design-NodeStorage.md)
- [メモリレイアウトの設計](Design/Design-MemoryLayout.md)
- [メモリ安全性の設計](Design/Design-MemorySafety.md)
- [Copy on Writeの設計](Design/Design-CopyOnWrite.md)
- [RangeとIndex反復の設計](Design/Design-Range.md)
- [runtime checkの設計](Design/Design-RuntimeChecks.md)
- [旧品質方針（2026-10-06時点）](Archived/Quality-Checklist_2026-10-06.md)
