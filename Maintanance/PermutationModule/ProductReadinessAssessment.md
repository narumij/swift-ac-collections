# PermutationModule 製品化判断のための所見

この文書は、`PermutationModule`を実験的ユーティリティから製品相当の公開APIへ引き上げられるかを
判断するための調査結果をまとめたもの。コード・テストへの変更はこの時点では行っていない。
意思決定はユーザーが行い、この文書はそのための材料に留める。

## 存在理由(`release/AtCoder/2025`ブランチのREADME.mdより)

現在作業中のブランチの`README.md`/`README.ja.md`には`PermutationModule`の記載が無いが、
`remotes/origin/release/AtCoder/2025`の`README.md`には由来が明記されている。

- ABC328Eという問題で、C++の解説コードが全探索的に見えたため「組み合わせを力尽くで計算できる」と
  誤解していた期間があった。実際は辞書順の変化だけを行う`next_permutation`の挙動により組み合わせ数が
  減っていたために計算可能だった、という誤解だった。
- この誤解を追いかける過程で「オーバーヘッドが少ない実装」を追求し、結果として軽量な実装が生まれた。
- `unsafePermutations`/`unsafeNextPermutations`は「おまけ」として位置付けられ、
  「コピーオンライトをキャンセルして行わない動作」であることが明記されている
  (CoWを省く設計は不備ではなく、AtCoder提出コードのような使い捨てコンテキストでの
  オーバーヘッド最小化という明確な狙いに基づく)。

つまりこのモジュールは「漫然とした実験」ではなく、特定の問題(ABC328E)から生まれた
具体的な存在理由を持つ。ただし、その経緯・位置付けが現在作業中のブランチの利用者向け文書には
反映されていない。下記の「散らかっている」状態は、目的の不明確さではなく実装・整理の債務として
見るのが妥当に見える。

## 現在の公開API

`Collection where Index == Int`への3つの拡張メソッドが公開APIの全体。

| API | 返す型 | CoW | 用途 |
| --- | --- | --- | --- |
| `nextPermutations()` | `Permutations<Self>.Nexts`(`_unsafe = false`) | あり | C++の`next_permutation`相当を辞書順で1つずつ |
| `unsafeNextPermutations()` | `Permutations<Self>.Nexts`(`_unsafe = true`) | なし | 同上、高速だが結果を即座に消費する前提 |
| `unsafePermutations()` | `Permutations<Self>.All`(`_unsafe = true`) | なし | 全順列を辞書順で列挙 |

## 発見した非対称・未結線

- `Permutations.All`には`init(safe source:)`と、それに対応する`IteratorA.ensureUnique()`が
  実装されているが、これを呼び出す公開API(`permutations()`のような「安全な全列挙」)が存在しない。
  `nextPermutations()`/`unsafeNextPermutations()`の対になる「安全な全列挙」だけが欠けている非対称な状態。
  `swift test --enable-code-coverage --filter PermutationTests`で確認したところ、
  `Permutations.All.init(safe:)`・`IteratorA.ensureUnique()`は実行回数0(カバレッジ上も未到達)。
- `Tests/PermutationTests/NextPermutation.swift`に、Sources側の`NextPermutationProtocol`と
  ほぼ同一のアルゴリズム(`nextPermutation`/`reverse(subrange:)`、コメントの参照元URLも同じ)が、
  `ManagedBuffer`ではなく`UnsafeMutableBufferPointer`を直接使う別実装として残っている。
  `Array: NextPermutation`という独自protocol適合経由で`array.nextPermutation()`という
  直接APIを提供する、Sources側とは別世代の設計の名残と見られる。現在はテストターゲット内に
  閉じていて、本体の`PermutationModule`からは参照されていない(重複・死んでいる実装)。
- ファイル先頭(`Permutations.swift:1`)に「模索の痕跡がのこっていて散らかっているので、
  要点に沿って整理しなおすか、廃止するか、いずれかを次回ジャッジ更新までに行うこと」という
  TODOが既に存在し、上記の状態を作者自身も把握している。

## カバレッジ

`Sources/PermutationModule/`全体で、行94.30%・リージョン89.09%・関数96.83%
(`swift test --enable-code-coverage --filter PermutationTests` + `llvm-cov report`)。
未到達は上記の`All.init(safe:)`経路が主要因。

## 安全性・使い勝手の注意点

- `unsafePermutations()`/`unsafeNextPermutations()`がCoWを行わないのは、上記のとおり
  オーバーヘッド最小化という明確な意図に基づく設計であり、不備ではない。ただし
  `PermutationTests.testUnsafeNextPermutations`のコメントが示すとおり、
  「単にmapしただけではコピーが行われず、原本への参照だけが返る」という直感に反する挙動があり
  (同一バッファを指す結果を複数回評価すると全て最終状態になる)、この設計意図と挙動の対応は
  現在テストのコメントにしか書かれていない。`unsafe`接頭辞だけでAPI利用者に伝わるかは別途検討の余地がある。
- `BareArray`/`OptionalArray`と異なり、`Permutations`関連の型に`Sendable`適合の宣言が無い。
- 公開メソッド3つに対して、計算量・CoW契約・事前条件(空コレクション等)を説明する
  コメントドック(`///`)が無い(`Collection`拡張部分に実装コメントのみ)。

## 既存テストで押さえられている点

- 空・単一要素相当の境界(`[0,0]`で辞書順変化なし、`[4,3,2,1]`で辞書順最後、1回で終了)は
  `testNextPermutations`/`testUnsafeNextPermutations`で確認済み。
- `unsafePermutations()`/`nextPermutations()`/`unsafeNextPermutations()`の3経路とも、
  `swift-algorithms`の`permutations()`との結果比較(`#if USING_ALGORITHMS`限定)、および
  `_copyCount == 0`によるCoW発生なしの確認がある。

## 製品化にあたって要ると思われる検討項目(所見・未着手)

1. `release/AtCoder/2025`のREADME.mdにある由来・説明を、現行ブランチの利用者向け文書へ
   どう反映するか(そのまま移植するか、現行APIに合わせて書き直すか)。
2. `Permutations.All.init(safe:)`を公開APIとして結線するか、不要なら削除するか。
3. `Tests/PermutationTests/NextPermutation.swift`の旧実装をどう扱うか(削除／参考実装として残す)。
4. `unsafe`系APIの意図(オーバーヘッド最小化のためCoWを行わない)と、その非直感的な挙動を、
   利用者向けにどう文書化するか。
5. `Sendable`適合の要否。
6. 公開APIへのコメントドック(計算量・CoW契約・事前条件)の整備。

この文書はコード変更を含まない調査結果のみ。対応方針はユーザーの判断を待つ。
