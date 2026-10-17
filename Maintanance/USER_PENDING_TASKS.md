# User採番待ちqueue

正式なRegistry IDへの照合・登録前に、ユーザーが発見・整理・明示実行した作業を
一時的に受け渡す。このfileはTask Registryではなく、ユーザーが自律的に次作業を選ぶbacklogでもない。

現在の入口は[進捗 V2](ProgressV2/PROGRESS_OVERVIEW_V2.md)、正式なtaskの状態・担当・依存・再開条件は
[Task Registry V2](ProgressV2/TASK_REGISTRY_V2.md)、制度・採番・文書権限は
[Task制度 V2](ProgressV2/TASK_RULES_V2.md)を参照する。

## 規則

- ユーザー裁量

## entry template

- 自由

## 採番待ち

### スタジオバグ

#### 事前条件

- スタジオのサーバープロセスが起動していること
- スタジオをブラウザでしていること
- マイルストーンが97e5d4ecb907cb5a2a3cd4056e9f3c8604a8c531時点の状態となっていること

#### 再現手順

- `0.6.0/10_VALIDATION_REVIEW.md`と`0.7.0/10_SPI.md`を入れ替える
- 更新ボタンを押下

#### 期待動作

- 変更が反映され、並び順が変わった見取り図が参照できること

#### 動作

- 並び順は変更されない
- 以下のログが表示される

```
更新できませんでした：Pending entries: Claude（姫） 0, Fable 0 · open requests: none
Bundled 90 documents; missing: Maintanance/Milestones/0.6.0/10_VALIDATION_REVIEW.md, Maintanance/Milestones/0.7.0/10_SPI.md
PASS: JS syntax; 61 tasks / 10 edges (= Registry rows); edit deltas; unchanged baseline; JSON roundtrip; duplicate/self/dangling/invalid-flow/cycle checks; duplicate/deleted task rejection; version rejection; unknown state and extra-field retention.
Not tested: DOM rendering, actual file download, Safari UI.
PASS: independent nodes excluded from graph; all connected nodes retained; all edges left-to-right; no overlap; empty-edge graph.
tasks 61, edges 9, milestones 25 (from gate files)
~ milestone MS-SPI: gate
~ milestone MS-VALIDATION: detail, gate
+ relation MS-SPI -> END-0.6.0
+ relation MS-VALIDATION -> END-0.7.0
+ relation START-0.6.0 -> MS-SPI
+ relation START-0.7.0 -> MS-VALIDATION
- relation MS-SPI -> END-0.7.0
- relation MS-VALIDATION -> END-0.6.0
- relation START-0.6.0 -> MS-VALIDATION
- relation START-0.7.0 -> MS-SPI
node: /Users/narumij/.cache/codex-runtimes/codex-primary-runtime/dependencies/node/bin/node (saved record, v24.19.0)
marked: /Users/narumij/.cache/codex-runtimes/codex-primary-runtime/dependencies/node/node_modules/marked/lib/marked.esm.js (saved record)
FAILED (Command '['/Users/narumij/.cache/codex-runtimes/codex-primary-runtime/dependencies/node/bin/node', '/Users/narumij/Documents/GitHub/swift-ac-collections/Maintanance/RegistryApp/verify.cjs']' returned non-zero exit status 1.); restored registry.json and index.html to their state before this run
node:internal/assert/utils:77
    throw err;
    ^

AssertionError [ERR_ASSERTION]: The expression evaluated to a falsy value:

  assert(original.milestoneRelations.some(e=>e.prerequisite==='MS-VALIDATION'&&e.successor==='END-0.6.0'&&!('relation' in e)))

    at Object.<anonymous> (/Users/narumij/Documents/GitHub/swift-ac-collections/Maintanance/RegistryApp/verify.cjs:15:807)
    at Module._compile (node:internal/modules/cjs/loader:1872:14)
    at Object..js (node:internal/modules/cjs/loader:2003:10)
    at Module.load (node:internal/modules/cjs/loader:1594:32)
    at Module._load (node:internal/modules/cjs/loader:1396:12)
    at wrapModuleLoad (node:internal/modules/cjs/loader:255:19)
    at Module.executeUserEntryPoint [as runMain] (node:internal/modules/run_main:154:5)
    at node:internal/main/run_main_module:33:47 {
  generatedMessage: true,
  code: 'ERR_ASSERTION',
  actual: false,
  expected: true,
  operator: '==',
  diff: 'simple'
}

Node.js v24.19.0
```

#### 再現率

- 4/4

