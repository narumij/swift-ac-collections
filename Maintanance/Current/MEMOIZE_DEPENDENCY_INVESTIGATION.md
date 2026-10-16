# Memoize関連リポジトリの依存状況調査

2026-10-16、Astra記録。RBT-005。

## 目的と現在の扱い

ユーザー指定のローカルcheckout `swift-ac-memoize`と`Memoization`について、このリポジトリへの依存状況を調べるDISCOVERY task。ユーザー指示によりACTIVEへ変更した。担当はCodex。状態の正本は[Task Registry](../ProgressV2/TASK_REGISTRY_V2.md)。2026-10-16にAstraが下記の調査を実施・受入。結果と未確認範囲を残した。同日のユーザーcommit指示によりDONEとする。

ユーザーの説明では、もともと必要だったのはこの依存調査である。AIに調査を引き受けてもらえそうになく、進行が負担になって凍結していた。ユーザーによる方針判断待ちとして整理したのは誤りだった。

## 調査後のユーザー判断（2026-10-16）

ユーザーが「非公開化や削除検討というタスク自体を整理でいい」と判断した。Memoize群の非公開化・削除検討は整理による`EXCLUDED`として残作業から外す。実施成功やAPI削除済みを意味せず、現行APIは変更しない。外部consumerの移行や公開面縮小を後続の必須作業・ゲートとして残さない。

現行RegistryのRBT-005は既に依存状況調査へ訂正されているため、受入済みの調査成果と証拠は保持し、調査の完了として扱う（同日のユーザーcommit指示によりDONE）。非公開化・削除検討のためだけに新規採番はしない。以下の変更時の影響説明は調査知見であり、実施予定ではない。

## 調べる範囲と返すもの

- `/Users/narumij/Documents/GitHub/swift-ac-memoize/`と`/Users/narumij/Documents/GitHub/Memoization/`を調べる。remote URL、branch・commit、未commit差分を記録し、ローカル状態と公開版を混同しない。以前の`Memoize`表記は対象名の誤りとして訂正する。
- 各対象の依存宣言と実際の利用コードから、このリポジトリのどの製品・module・APIに依存しているかを確認する。
- Memoize関連部分の変更・削除がどの利用箇所に影響するか、移行が必要かを根拠付きで整理する。必要に応じて対象を絞ったコンパイル確認を行い、確認済みと未確認を分ける。
- 二つのリポジトリについて依存先・利用箇所・影響・残る不明点をまとめれば、調査の返却条件を満たす。その結果を基に必要な判断や作業を具体化する。

## 境界

旧記録の「外部consumer 2件の移行」を、調査開始の待ち条件にしない。移行の要否自体を今回調べる。移行済みとも、必ず移行が必要とも先に決めない。

「公開終了／正式API化」の二択を調査の結論として固定しない。外部リポジトリの変更、製品方針の決定、APIの削除・公開変更はこの調査に含めない。

## 資料

- [既存監査](EXTERNAL_TYPE_EXTENSION_AUDIT.md)
- [ユーザー判断扱いにする前の記録](../Archived/RBT-005_BEFORE_USER_DECISION_2026-10-16.md)
- [今回の訂正前の記録](../Archived/RBT-005_BEFORE_DEPENDENCY_DISCOVERY_2026-10-16.md)

## 調査結果（2026-10-16 / Astra）

基準：swift-ac-collections `ff209700`（develop/misc/68）。調査中に別作業のCLAUDE_PENDING_TASKS.md・Testing/JudgmentCoordinates/README.mdの変更を認めたが、本調査に関係せず編集していない。外部2リポジトリは読み取りだけで、resolve・fetch・build・編集を行っていない。公開先の最新状態ではなく、指定されたローカルcheckoutの調査である。

### 結論

- 2件ともAcCollectionsの依存宣言とRedBlackTreeModuleのimportが実在する。内部で使わないことだけを理由に、現行LRU公開APIを非公開化・削除できるとは言えない。
- ただし「外部consumer 2件の移行完了」が一括の待ち条件なのは不正確。現行LRUを使う経路と、既に消えた旧APIを参照する実験・macro経路を分ける必要がある。
- 現行の`___LRUMemoizeStorage`を維持するなら、今回確認したLRU wrapperには型の置換は不要。新module名・旧互換module名の両方で限定型チェックが成功した。package全体がそのまま動くという保証ではない。
- LRU自体を削除・非公開化する場合は、少なくとも下記wrapperの移行が必要。内部の_LinkingPair等を直接利用するconsumerは指定2件のSources/Tests検索では見つからなかった。ただしpublic typealias・protocol・@inlinableの連鎖があるため、内部公開面の縮小可否は別途compileで確認する必要がある。

### 対象版と未commit差分

| 対象 | ローカルHEAD | 宣言 / Package.resolved | 作業ツリー |
| --- | --- | --- | --- |
| swift-ac-memoize | main / e671245070bd962490bcd33a6f78621ce1331807 | compatible/AtCoder/2025 / 0fb609e336a2ed2218294490e37f5141f4b57af2 | 9ファイルに差分。Cache V2・Array系・macro・test等の変更あり |
| Memoization | main / 48dcd32d55565ac0a52f107e2dfe10a541048d05 | from 0.1.30 / 0.4.1（174e304acbdd6848604a62e70169b26ac982d775） | 8ファイルに差分。MemoizeCache・Pack追加、macro変更等 |

remote設定はそれぞれ https://github.com/narumij/swift-ac-memoize.git と https://github.com/narumij/Memoization.git 。公開済みHEADと同じかは未確認。

swift-ac-memoizeの`.build/checkouts/swift-ac-collections`は`730d3433b47219244ef69e130970cb80f68a94a2`で、Package.resolvedと一致しない。そのcheckoutのLRUはinternal・旧_KeyCustomProtocol制約であり、現行や固定先のpublic・Comparable制約と異なる。既存build結果を現在の依存解決の証拠には使えない。Memoizationには同じ場所のcheckoutがない。なおPackage.swiftのローカルpath指定はコメントであり、有効な依存指定ではない。

### 実利用と変更影響

| 対象経路 | 根拠（各consumer直下基準） | 依存と扱い |
| --- | --- | --- |
| swift-ac-memoizeの公開LRU | Sources/swift-ac-memoize/MemoizeCache.swift:121、swift_ac_memoize.swift:1 | HEADから存在。MemoizeCache.LRUが___LRUMemoizeStorageを保持し、init(maxCount:)・subscript get/set・removeAll(keepingCapacity:)・maxCount・countを使う。moduleを再exportする |
| 同、作業中のV2 | 同MemoizeCache.swift:250 | 未commitで追加された~Copyable wrapperも同じLRUに依存。StandardはSwift Dictionary。InlineMemoizeMacro.swiftはLRU/Standard wrapperを生成する |
| Memoizationの新しいLRU/Actor | Sources/Memoize/MemoizeCache.swift:75・188、Memoize.swift:4 | 新ファイルはHEADになく、staged＋unstagedの作業途中。___MemoizeCache.LRU・LRUActorが同じ現行LRU APIを使う。Standard/StandardActorはDictionary |
| Memoizationの旧実験target | Sources/MemoizeCache/MemoizeCache.swift、tarai/V1〜V6.swift、Tests/MemoizeCacheTests/MemoizeCacheTests.swift | _MemoizeCacheBase、_MemoizeCacheLRU、_KeyCustomProtocol、_ComparableMemoizationCacheProtocol、_HashableMemoizationCacheProtocol等へ依存。単なるコメントだけでなく有効な宣言や#if true経路にも残る |
| Memoizationのmacro生成 | Sources/MemoizeMacros/Common.swift:81〜157・367、StoredMemoizeMacro.swift、MemoizeMacro.swift | storedCacheから旧protocolを生成する経路が残る。新LRU wrapper追加だけでは旧macro経路の移行完了にならない |

Pack.swiftの旧Base/LRU/CoW aliasはHEADでは有効、作業ツリーではコメント化。V7は作業ツリーで#if false。これらを現在の有効利用へ一律に数えていない。MemoizationのMemoizeCache targetとそのtestはPackage.swiftに残っている。

現行Sources全体と固定先0.4.1をGit検索した範囲では、上表の旧_MemoizeCacheBase等の定義は存在しない。一方___LRUMemoizeStorageは両固定先と現行にpublicで存在する。したがって旧実験経路の不整合を、今回初めて起きる現行版の破壊的変更として扱わない。

### コンパイラによる限定確認

[証拠・再実行方法](Evidence/MemoizeDependency20261016/README.md)に入力と診断を保存した。現行moduleに対し、両consumerの作業中のPack＋Cache実装を抜き出した型チェックを実行し、新名・旧名の計4通りが成功した。旧_MemoizeCacheBaseのprobeは「型が見つからない」で失敗した。

これはwrapperの型・呼び出し面の確認。consumer全体のpackage解決、macro展開、Swift 6.2動作、LRUのclear・capacity・copy・actorでの実行安全性、性能は検証していない。外部作業ツリーを勝手に直さず、この境界で調査を閉じる。

### 後続へ渡すもの

1. 現行LRU APIを変更しない場合、この調査だけから外部移行を必須にはしない。
2. LRU公開APIを変更する場合、上記wrapperの移行範囲と互換方針を先に決める。内部公開面だけの縮小はpublic aliasとinlinableのcompile確認を切り出す。
3. Memoizationを再び動く状態へ整える場合、旧実験target・旧macro生成経路を維持するかをユーザーが決めたうえで、別の外部リポジトリ作業として扱う。今回その整理・削除を行わない。
4. Sources/RedBlackTreeCollections/Documentation/MEMO.mdの「swift-ac-memoizeはdrop」は位置づけの記録であり、ソース依存が消えた証拠にはしない。再開・提供方針はここで推定しない。

依存先・利用箇所・影響・残る不明点を返す受入条件は満たした。RBT-005は調査受入済み。同日のユーザーcommit指示によりDONEとする。移行実施や公開契約変更の完了とはしない。
