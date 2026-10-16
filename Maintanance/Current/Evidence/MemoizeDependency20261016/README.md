# メモ化依存調査の証拠

2026-10-16 / Astra。調査正本は[MEMOIZE_DEPENDENCY_INVESTIGATION](../../MEMOIZE_DEPENDENCY_INVESTIGATION.md)。

consumer-snapshot.jsonはローカルHEAD・branch・remote・未commit差分の一覧・固定先・Sources/TestsのSHA-256を記録する。remoteは設定値であり、現在のGitHub状態を取得した結果ではない。

ac.swiftとmemoization.swiftは各consumerの作業ツリーのMemoizePack.swiftとMemoizeCache.swiftを連結し、import RedBlackTreeCollectionsを付加・置換した型チェック用入力。*-compat.swiftは同じ入力で旧名RedBlackTreeModuleを参照する。原リポジトリは変更していない。legacy.swiftは旧APIの不存在確認。

実行コマンド（repository直下、Apple Swift 6.4、前ターンでbuild済みの現行Debug module）：

```sh
swiftc -typecheck -swift-version 6 -module-cache-path /tmp/astra-memoize-investigation/cache -I .build/arm64-apple-macosx/debug/Modules /tmp/astra-memoize-investigation/ac.swift
```

同様にmemoization.swift、ac-compat.swift、memoization-compat.swiftはいずれも終了0・診断なし。legacy.swiftは終了1でcannot find type '_MemoizeCacheBase'。legacyだけ-swift-versionは省略した。空の.logは診断なしを表す。package全体のbuild、macro展開、実行・性能・寿命の検証ではない。
