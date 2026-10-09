# Array module naming review

最終更新: 2026-10-09 / Codex

## 目的

BareArrayとOptionalArrayの正式公開前に、公開型名と次元名体系がSwift標準ライブラリおよび
`swift-collections`と衝突せず、公開後も長く維持できるかをAI間で検討し、ユーザー判断へ渡す。

AIは名称を決定しない。Claudeが候補と反証を調査し、Codexが同じ証拠を独立評価して統合する。最終的な
公開名は、整理済みの選択肢からユーザーが一件ずつ判断する。

## 判断へ渡す単位

1. BareArrayの所有型、View型、次元名を含む一つの命名体系。
2. OptionalArrayの1D所有型名。
3. OptionalArrayの2D〜4D次元名体系。

上の三判断を一度に要求しない。共有できる衝突調査と対応表は一つにまとめ、推奨と影響は判断単位ごとに
分ける。

## 必須条件

- Swift標準ライブラリの公開型名、主要用語、命名規則と衝突しない。
- `swift-collections`の公開型名、主要用語、命名規則と衝突しない。
- 標準または`swift-collections`由来の型だと利用者が誤認しにくい。
- BareArrayとOptionalArrayの対応関係を説明でき、差異には用途上の理由がある。
- 正式公開前なので、既存名とのsource compatibilityより、公開後の持続性、可読性、検索性、推測可能性を
  優先する。ただし既存利用例とGit利用者への移行影響は記録する。

## Claude調査

次を事実、評価、推奨、反証に分けて提出する。

1. 両moduleの現行公開型、initializer label、subscript軸、`indices`軸の対応表。
2. 使用中のSwift toolchainとpackageが解決している`swift-collections`版を特定した衝突確認。
3. 必要なら、公式のSwift標準ライブラリinterfaceと`swift-collections`一次資料を使った現行公開名の確認。
   調査日、versionまたはcommit、確認範囲を記録する。
4. 現行維持、部分整合、正式公開前の破壊的整合を含む候補。各候補について、利点、欠点、誤認可能性、
   影響する宣言、test・文書・利用例の移行範囲を示す。
5. 三つの判断単位ごとに推奨を一つ示し、その最も強い反証も併記する。

名称候補を考案しただけで衝突なしとみなさない。文字列の完全一致だけでなく、既存collection概念との
意味上の近さ、Swift API Design Guidelinesとの整合も確認する。

## 境界と停止条件

- source、test、利用例、コメントドック、Registryを変更しない。
- rename、typealias、deprecated alias、移行期間を実装しない。
- 公開名を決定しない。
- 性能、View寿命、storage設計、strict memory safetyへ議論を広げない。
- 衝突確認に必要な一次資料へ到達できない場合は、推測で安全とせず未確認範囲として返す。

Claudeはこの文書へ`Claude調査結果`を追記し、`Maintanance/CLAUDE_TASK.md`の状態を返却待ちへ更新して
git addまで行う。Codexはその後に独立評価を追記し、三つのユーザー判断を順次起動できるか判定する。
