# PermutationModule AtCoder 2025互換モード計画

最終更新: 2026-10-07 / Codex

## 実装タスク境界

最初の「現行契約の基準固定」は互換modeから独立した先頭taskとし、その成果を後続するすべての
互換mode taskの入力にする。Task Registryで明示的に再開されるまでは、各taskの凍結を維持する。

| 順序 | 成果単位 | 完了条件 |
| --- | --- | --- |
| 1 | 現行契約の基準固定 | 現行API、通常test、取得済み結果の安定性、旧unsafe APIの非露出を基準として固定 |
| 2 | 互換ソースの隔離 | 基準refの実装を専用fileへ置き、通常版と排他的にcompileできる |
| 3 | Package trait設定 | traitありだけが互換版、traitなしは必ず通常版になる |
| 4 | 互換仕様test | 列挙順、重複、safe CoW、unsafe aliasing、境界が基準refどおりに成功する |
| 5 | `AcCollections`再公開検証 | 通常・互換の両modeで期待する公開APIを利用できる |
| 6 | CI分離 | 通常版と互換版を別jobで検証し、結果を混在させない |
| 7 | 単一file生成・ローカル検証 | 自己完結fileを生成し、ABC328E相当入力で検証する |
| 8 | 文書同期 | 通常APIと互換APIを混同せず、trait、制限、検証方法を記録する |

1は互換modeの実装判断から独立して実施できる。2以降の互換mode taskはすべて1の成果に依存し、
1から4は実行順として直列になる。4の完了後、5と6は独立して進められる。7は5を前提とし、8は
5、6、7の完了後に行う。実提出確認はこの実装列に含めず、引き続きユーザー専任とする。

## 1. 現行契約の基準固定（2026-10-07完了 / Claude Opus 5.5）

通常版の基準は次のtestで固定した。互換modeの検証はユーザー判断で省略した。

- `PermutationRemovedAPITests`: 基準版にだけある`unsafePermutations()`と
  `unsafeNextPermutations()`が復活するとcompileが失敗する。一時的に再追加し、個別に
  compile errorになることを確認済み。`COMPATIBLE_ATCODER_2025`では対象外。
  - 2026-10-07の改名で`Permutations`名前空間を廃止したため、その下にあった旧型
    （`All`・`IteratorA`・`SubSequenceA`・`Nexts`等）の検査は外した。トップレベルの型名は
    テスト側の同名宣言が優先されて黙って通るので、この方式では守れない。互換版が通常ビルドへ
    漏れた場合は上の2メソッドも漏れるので、それを漏れの警報とする。
- `PermutationTests`: 列挙順・境界・取得済み結果の安定性・`Sendable`に加え、重複要素と
  非Array入力（`Range`、起点が0でないslice）を追加した。sliceについては、yieldされる結果の
  添字の起点を契約として固定していない（未決）。

## 目的

通常ビルドでは、整理済みの現行`PermutationModule`だけを提供する。一方、既存の
AtCoder 2025向けコードを移行するときに限り、`release/AtCoder/2025`時点の公開APIと
観測可能な挙動へコンパイル時に切り替えられるようにする。

互換APIを通常ビルドへ再追加する計画ではない。`swift-algorithms`と重複するAPIや
unsafeな結果共有を、現行APIとして再推奨もしない。

## 確認した基準点

- 基準ref: `remotes/origin/release/AtCoder/2025`
- 基準ソース: `Sources/PermutationModule/Permutations.swift`
- 共有しない（2026-10-07変更）: 基準refの`NextPermutationProtocol.swift`。通常版はこのprotocolを
  廃止し、アルゴリズムを`NextPermutation.swift`の`Buffer`拡張へまとめた。互換版は基準refの
  protocolファイルを互換ディレクトリへ自分で持つ。
- 型名の差（2026-10-07）: 通常版は`Permutations<C>.Nexts`/`IteratorN`/`SubSequenceN`を
  `NextPermutationsSequence<Base>`/`.Iterator`/`.Permutation`へ改名し、`Permutations`名前空間を
  廃止した。互換版は基準refの旧名をそのまま持つ。
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
├── NextPermutation.swift                         # 現行版のみ
├── Permutations.swift                            # 現行版のみ
└── Compatibility/AtCoder2025/
    ├── NextPermutationProtocol.swift             # 互換版のみ
    └── Permutations.swift                        # 互換版のみ
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
  いないこと、取得済み`NextPermutationsSequence.Permutation`が安定することを維持する。
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
