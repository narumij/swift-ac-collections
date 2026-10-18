# 試験専用ブラウザの利用確認（OPS-120）

## TL;DR（人間向け）

試験専用のChromium・WebKitで、独立ページのクリック・入力・フォーカスを確認し、姫の返却をAstraが受け入れた記録。Astraと姫では起動に必要な権限が異なった。この結果は各時点の実行環境と基本操作に限られ、Studio実画面の検証完了を意味しない。

2026-10-18 / Astra. Parent OPS-048. The user arranged permission for Hime to launch a test-only browser and asked Astra to proceed from availability verification onward.

<a id="astra確認結果"></a>
## Astra's verification

Node v26.12.0, npm 11.20.0, Playwright 1.64.1. The module is `/opt/homebrew/lib/node_modules/playwright`; browsers are already installed in the user's Library/Caches/ms-playwright. No additional installation is needed.
Chromium failed with MachPort Permission denied in Astra's normal sandbox; WebKit also failed to launch. With authorized elevated execution, both launched headless and passed click→text change, input and focus checks on an independent setContent page. Browsers closed in finally. No connection to the user's server or browser. Do not generalize this success to Hime's environment.

<a id="姫への正式依頼"></a>
## Formal assignment to Hime

This bounded assignment follows the user's 「つづけて」; no additional start confirmation is needed. Use the normal permission mechanism for environment privileges and report denial without bypassing it.

1. Require the installed Playwright by absolute path and verify headless Chromium/WebKit launch in Hime's environment. Do not repeat the restricted-launch failure already observed by Astra.
2. Use setContent to create a test-only button and input field; verify click, input and focus. No existing server connection or launch is needed. Do not touch the user's active browser/server or Studio save data.
3. Close launched browsers in finally. On failure, return the concrete error and required permission only. No OS setting changes, installation, product repair or commit.

Editing ownership is limited to Hime's Return here. Create any required test code temporarily and remove it afterward. Work/return activity may be recorded under OPS-120; add one cache-reference line. Subsequent Studio screen verification needs separately defined scope after this return.

## 姫Return

2026-10-18 姫・Opus 5.5。結論：**姫の環境では、Chromium・WebKitとも、追加の権限なし（通常のsandboxのまま）でheadless起動でき、3項目すべてPASS**。

- 環境：`/opt/homebrew/bin/node` v26.12.0。Playwrightは`require('/opt/homebrew/lib/node_modules/playwright')`（絶対パス）。ブラウザは`~/Library/Caches/ms-playwright`の導入済みのもの（chromium-1248、chromium_headless_shell-1248、webkit-2370）。追加インストールなし。
- 試験：一時ディレクトリ（mktemp -d）の試験コードで、各ブラウザについて次を行った。
  - `launch({headless:true})`→`newPage`→`setContent`（ボタン・入力欄・段落）。
  - クリックで文字が変わる、入力欄へ日本語を入力する、フォーカスが入力欄へ移る、の3項目を確かめた。

| ブラウザ | 版 | クリック | 入力 | フォーカス |
|---|---|---|---|---|
| Chromium | 156.0.8078.4 | PASS | PASS | PASS |
| WebKit | 27.2 | PASS | PASS | PASS |

- 後始末：各ブラウザは`finally`で`close()`した。終了後、`ms-playwright`配下のプロセスは0件（`pgrep`で確認）。一時ディレクトリは削除した。
- 触れていないもの：既存のサーバー（接続も起動もしていない）、使用中のブラウザ、Studioの保存データ、OS設定、製品。commitなし。
- Astraの環境との差：Astraの通常sandboxで出たMachPort Permission deniedは、姫の環境では出なかった。理由は調べていない。この成功は、この時点の姫の実行環境についてだけのもの。
- 参照したキャッシュ：なし。

<a id="astra受入2026-10-18"></a>
## Astra acceptance (2026-10-18)

Accepted Hime's Return as availability verification. Astra's own independent launches had passed the same three checks on both engines; Hime reported the same checks without extra privileges. Retain the environment-dependent permission difference. This verifies only basic operations on an independent page, not completion of Studio screen verification. Hime deleted the test code afterward, so acceptance compares the return with independent testing rather than rerunning that same code. No additional assignment.
