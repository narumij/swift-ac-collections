# BareArray documentation handoff audit

最終更新: 2026-10-09 / Codex

## 目的

BareArrayの公開契約をsource、test、git履歴、OptionalArrayとの対応に照らして整理し、Codexの
ユーザードキュメント作業フェーズへ渡せるかを判定する。利用者向け本文とコメントドック全件整備は
この監査に含めない。

## 現在の対象

- source: `Sources/BareArrayModule/BareArray.swift` 1ファイル、450行
- 公開型: 所有型1D〜4DとView 1D〜3Dの7型
- 公開宣言: 型7、所有型initializer 8、subscript 7、`indices` 7の計29件
- 公開適合: 所有型4型の`@unchecked Sendable`
- test: `Tests/BareArrayModuleTests`の3ファイル、38件
- 比較資料: `Maintanance/OptionalArrayModule/OptionalArrayAudit.md`
- safety資料: `Maintanance/StrictMemorySafetyReadiness.md`

2026-10-09の再開時点で、strict memory safetyの段階対応、境界Death Test、参照型寿命、clone所有権の
証拠は存在する。一方、BareArray固有の公開宣言ledgerはまだ作成されていない。`BARE-002`の「途中成果」は
完成済みledgerではなく、これらの周辺証拠を指すものとして扱う。

## `BARE-002` — 公開7型の契約棚卸し

### 調査する契約

- 各initializerの寸法・個数、空・負値・積のoverflowに関する前提
- subscriptの境界、軸順、offset計算、返すViewの範囲
- 所有型の初期化、変更、破棄、cloneの所有責任
- Viewの非所有性、元の所有型との変更共有、寿命上の制約
- `indices`が表す軸と範囲
- `@unchecked Sendable`の既存根拠と制約
- 2D・3Dの`width` / `height` / `depth`と4Dの`size0...size3`、1D所有型とViewの名称差
- 多次元subscript setterのNOPが成立した経緯と現在の契約

### 成果物

この文書へ次を追記する。

1. 公開29宣言と公開適合4件を一度ずつ収録したledger
2. 宣言ごとの境界、寿命、所有、破棄、変更、軸・offset契約
3. 対応する既存test、git履歴、OptionalArrayの比較箇所
4. `事実`、`過去の決定`、`現在の推論`、`未確認`の区別
5. 新しい判断が必要な場合の、一判断ごとの`DECISION`候補

### 停止条件

- 公開継続、命名、性能、安全性などの製品判断が必要になった場合は結論を補わず停止する。
- OptionalArrayとの類似だけでは同一契約と認定しない。
- source、test、コメントドック、Registryを変更しない。
- Test as Specificationのファイル再編は`BARE-005`へ残す。
- 性能基準、Viewが所有者より長く生きる問題、strict memory safetyの恒久適用は後続の1.0判断側へ残す。

### Codex受入条件

- 公開29宣言と4適合に欠落・重複がない。
- testが証明する範囲と、文書または呼び出し側前提だけの契約が分離されている。
- OptionalArrayとの差異が、同一視せず比較根拠付きで示されている。
- 新しい判断点が実装へ混入せず、一判断ごとの候補として止まっている。
- 親監査、条件付き判断、Test as Specification整理の次状態をCodexが判定できる。

## 後続境界

- `BARE-003`: 公開継続が未決定と判明した場合だけ再開する。
- `BARE-004`: 公開継続時に命名体系が未決定と判明した場合だけ再開する。
- `BARE-005`: `BARE-002`受入後、既存testを番号付き仕様へ整理する。
- `BARE-006` / `BARE-007` / `ARRAY-001`: 文書作業後の1.0判断側として凍結を維持する。
