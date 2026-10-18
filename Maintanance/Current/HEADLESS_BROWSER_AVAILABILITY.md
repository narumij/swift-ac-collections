# 試験専用ブラウザの利用確認（OPS-120）

2026-10-18 Astra。親OPS-048。ユーザーは姫への試験専用起動許可を用意し、Astraへ利用確認からの進行を依頼した。

## Astra確認結果

Node v26.12.0、npm 11.20.0、Playwright 1.64.1。モジュールは `/opt/homebrew/lib/node_modules/playwright`、ブラウザはユーザーLibrary/Caches/ms-playwrightに導入済み。追加インストール不要。
Astra通常sandboxではChromiumがMachPort Permission denied、WebKitも起動失敗。許可された権限付き実行では両方headlessで起動し、setContentした独立ページでクリック→文字変更、入力、フォーカスの3項目PASS。finallyでブラウザ終了。ユーザーのサーバー・ブラウザには未接続。この成功を姫の環境でも成功すると一般化しない。

## 姫への正式依頼

今回の限定依頼はユーザーの「つづけて」に基づく。追加開始確認不要。ただし実行環境の権限要求は正規の許可経路を使い、拒否されたら迂回せず返却する。

1. 上記インストール済みPlaywrightを絶対パスrequireして、姫の環境でChromiumとWebKitをheadless起動できるか確認する。Astraで制限下起動が失敗したので、同じ失敗を反復しない。
2. setContentで試験専用のボタンと入力欄を作り、クリック・入力・フォーカスを確認する。既存サーバーへの接続や起動は今回不要。使用中のブラウザ・サーバー・Studio保存データへ触れない。
3. 起動したブラウザはfinallyで終了する。失敗なら具体的エラーと必要な許可だけ返す。OS設定変更・追加インストール・製品修正・commitはしない。

編集占有は本書の姫Returnのみ。試験コードが必要なら一時領域に作り終了後削除。活動の着手・返却はOPS-120で記録可。参照キャッシュ一行を添える。成功後のStudio実画面検証は、今回の返却を受けて別途範囲を定める。

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

## Astra受入（2026-10-18）

姫のReturnを利用確認結果として受入。Astra自身の独立起動試験でも両エンジンの3項目は成功しており、姫側でも追加権限なしで同項目を確認できたと返却された。実行環境による権限差は残す。今回確認したのは独立ページの基本操作までで、Studio実画面の検証完了ではない。姫の試験コードは終了後削除済みのため同コードの再実行による受入ではなく、返却と独立試験の照合による受入。追加依頼なし。
