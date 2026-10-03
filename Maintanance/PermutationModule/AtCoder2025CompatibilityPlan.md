# PermutationModule AtCoder 2025互換モード計画

## 目的

通常ビルドでは、整理済みの現行`PermutationModule`だけを提供する。一方、既存の
AtCoder 2025向けコードを移行するときに限り、`release/AtCoder/2025`時点の公開APIと
観測可能な挙動へコンパイル時に切り替えられるようにする。

互換APIを通常ビルドへ再追加する計画ではない。`swift-algorithms`と重複するAPIや
unsafeな結果共有を、現行APIとして再推奨もしない。

## 確認した基準点

- 基準ref: `remotes/origin/release/AtCoder/2025`
- 基準ソース: `Sources/PermutationModule/Permutations.swift`
- 現行と共有可能: `NextPermutationProtocol.swift`。基準refとの差分はない。
- 既存の切替名: `COMPATIBLE_ATCODER_2025`。現在の`Package.swift`とテスト運用で既に
  使用実績があるが、Permutationの実装自体はまだ切り替わらない。

基準版にだけ存在する公開表面は次のとおり。

- `unsafeNextPermutations()`
- `unsafePermutations()`
- `Permutations.All`
- `Permutations.IteratorA`
- `Permutations.SubSequenceA`
- `Permutations.Nexts.init(safe:)` / `init(unsafe:)`
- safe/unsafeを切り替える各iteratorの内部経路

`nextPermutations()`自体は両版に存在する。現行版は常にCoWを行い、取得済み結果を
保持しても値が変化しない。基準版にはsafe/unsafeの選択肢があり、unsafe経路では
結果が内部bufferを共有する。この差は互換テストで固定し、通常版の仕様へ混ぜない。

## 採用する構成

同じ`PermutationModule`ターゲット内で、`COMPATIBLE_ATCODER_2025`により実装を
排他的に選択する。

```text
Sources/PermutationModule/
├── NextPermutationProtocol.swift              # 両モードで共有
├── Permutations.swift                          # 現行版のみ
└── Compatibility/AtCoder2025/Permutations.swift # 互換版のみ
```

- 現行ファイル全体を`#if !COMPATIBLE_ATCODER_2025`で囲む。
- 互換ファイル全体を`#if COMPATIBLE_ATCODER_2025`で囲む。
- 同じ宣言へ細かな`#if`を散らさない。2版の公開表面と所有権モデルが大きく異なるため、
  ファイル単位で分けた方が差分を監査しやすい。
- 別ターゲット名にはしない。既存コードの`import PermutationModule`を変更せずに
  コンパイルできることが互換モードの目的だからである。
- 通常版から削除したunsafe APIをdeprecated aliasとして再公開しない。

## Package設定

`COMPATIBLE_ATCODER_2025`をPackage traitとして宣言し、既存の手編集コメント切替を
trait条件のdefineへ置き換える。traitを指定しない既定ビルドは必ず現行版とする。

互換defineは、互換性を検証する必要がある既存ターゲットへだけ渡す。新しい通常APIが
誤って互換defineへ依存しないよう、可能なら全ターゲット共通の`_settings`から分離する。

AtCoderへ貼り付ける単一ファイルの生成はSwiftPM traitとは別問題である。生成元を
互換ファイルへ固定し、生成物自体はリポジトリへ常設しない。

## 実装段階

### 1. 基準版の隔離コピー

1. 基準refの`Permutations.swift`を互換ファイルの出発点にする。
2. 公開宣言、列挙順、重複値、safe/unsafeのaliasing挙動を変えない。
3. 現行toolchainでのコンパイルに必要な構文修正は、公開挙動と分けて記録する。
4. strict-memory-safety注釈や`Sendable`を、診断を消す目的だけでunsafe経路へ追加しない。

### 2. モード別Test as Specification

- 通常モードでは現在の`PermutationTests`をそのまま実行し、削除済みAPIが復活して
  いないこと、取得済み`SubSequenceN`が安定することを維持する。
- 互換モードでは基準refのテストを復元し、次を明示的に固定する。
  - `unsafePermutations()`の全順列列挙順と重複の見え方
  - `nextPermutations()`が現在位置以降だけを列挙すること
  - safe結果のCoWと、unsafe結果を保持した場合のaliasing
  - 空、単一、降順、同値要素の境界
- 通常版の`Sendable`コンパイル時テストは互換モードへ自動適用しない。互換版のunsafe
  iteratorを`@unchecked Sendable`にして通すことは禁止する。

### 3. 再公開と貼り付け検証

1. 通常・互換の両モードで`AcCollections`から期待するAPIが再公開されることを確認する。
2. 自己完結したAtCoder用単一ファイルを互換版から生成し、ローカルでABC328E相当の
   入力を検証する。
3. 実提出は外部操作なのでユーザーが行い、提出日時、Swift版、結果だけを記録する。

## 完了条件

- traitなしの通常ビルドで、削除済みunsafe/All APIが公開されない。
- traitありの互換ビルドで、基準版の公開テストがソース変更なしでコンパイル・成功する。
- 両モードで`AcCollections`経由の利用を検証する。
- 通常版と互換版のテストを同一実行結果として混ぜず、CI上で別ジョブとして表示する。
- 互換版の存在を理由に、現行仕様書へunsafe APIを現役APIとして掲載しない。

## 今回実施しないこと

- 互換ソースのコピーと条件コンパイル
- Package traitの追加
- CIジョブの追加
- AtCoder用単一ファイル生成器の実装
- ABC328Eへの外部提出

この文書は、上記を小さなレビュー単位で実装するための方針確定までを扱う。
