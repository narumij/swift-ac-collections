# Refactoring from `release/AtCoder/2025`

この文書は、`release/AtCoder/2025`で稼働した赤黒木実装から現在の構成へ移行した際の
手法と段階を、後から追跡できるように記録する。

## Keystone test

移行の要石は次の保存テストである。

`Tests/RedBlackTreeTests/UnsafeTreeV2/Instance/___RedBlackTreeContainerTests_unsafe.swift`

このファイルは固定したノード配置を直接構築し、木の不変条件、最小・最大ノード、回転、
挿入後の平衡化、探索位置、削除時の`begin`更新を個別に確認する。通常の公開APIテストより
下の層で、コンテナと木アルゴリズムの接続を検証していた。

現在はファイル全体を`#if false`で囲み、コンパイル対象外の保存資料としている。現行APIへ
追従させることより、移行当時の構造、命名、テスト手法を残すことを優先する。

## Confirmed stages

### 1. AtCoder 2025 implementation

`remotes/origin/release/AtCoder/2025`では、テストは次の場所にあった。

`Tests/RedBlackTreeTests/tree/___RedBlackTreeContainerTests.swift`

`RedBlackTreeModule`を`@testable import`し、`RedBlackTreeSet`へデバッグ用の操作を直接追加して、
整数ベースのノード表現を組み立てていた。

### 2. UnsafeTreeV2 extraction

2026-09-30のコミット`ecb3085d`で、テストは次の名前へ移された。

`Tests/RedBlackTreeTests/UnsafeTreeV2/Instance/___RedBlackTreeContainerTests_unsafe.swift`

この段階で、比較・ポインタ操作・デバッグ補助などが個別ファイルとFixtureへ分解され始めた。
元のコンテナ直結テストを残しながら、同じ契約をUnsafeTreeV2以下の小さな層で検証できる
構成へ移す方法が採られた。

### 3. Bootstrap naming

直後のコミット`438af006`で`UnsafeTreeV2BootstrapTests.swift`へ改名された。テスト内容の
98%はそのままで、木の開発を開始するためのブートストラップだったことが明示された。

この一般名では旧`RedBlackTreeContainer`からの移行資料であることが見えにくいため、現在は
第2段階の名前へ戻している。`Bootstrap`という役割はファイル内コメントと本書で保持する。

## Refactoring method

履歴から確認できる基本方針は次のとおり。

1. 旧コンテナを直接操作する固定Fixtureテストを基準として残す。
2. ノード表現、ポインタ操作、比較、メモリ配置、allocationを個別の内部層へ分解する。
3. 分解した各層へ専用Fixtureと単体テストを設ける。
4. 赤黒木の不変条件を、操作結果とは別の検証軸として維持する。
5. 公開4型のTest as Specificationと、原木・UnsafeTreeV2の内部契約を分離する。
6. 移行済みの旧テストは削除せず、コンパイル対象外の一次資料として温存する。

今後、移行段階を追記するときは、コミット、旧パス、新パス、移した契約、代替テストを
セットで記録する。推測による経緯は確定事項へ混ぜない。
