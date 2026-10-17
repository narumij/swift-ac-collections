# Registry Studio：到達点ファイルを版フォルダ間で入れ替えると更新が失敗する（OPS-078）

2026-10-18 / 登録・依頼：Fable（調整代理、OPS-044。ユーザー指示「タスク化して、姫に依頼しておいて」）。調査・修正・検証：姫。受入：Astra（Fable代理は返却の照合と Registry 反映まで）。親は恒久 task OPS-048（Studio）。状態の正本は Task Registry。

## 発端（ユーザー報告、`USER_PENDING_TASKS.md` 2026/10/18-02:17「スタジオバグ」）

**事前条件**：Studio のサーバープロセスが起動し、ブラウザで開いている。Milestones が `97e5d4ecb907cb5a2a3cd4056e9f3c8604a8c531` 時点の状態。

**再現手順**：`0.6.0/10_VALIDATION_REVIEW.md` と `0.7.0/10_SPI.md` を入れ替え、更新ボタンを押す。

**期待動作**：変更が反映され、並び順が変わった見取り図が参照できる。

**動作**：並び順は変更されず、「更新できませんでした」。ログの全文は報告の原文（`USER_PENDING_TASKS.md`）にある。要点は、sync の差分出力のあとに verify.cjs が `verify.cjs:15` で assertion に失敗し、`registry.json` と `index.html` が実行前の状態へ復元されること、および `Bundled 90 documents; missing: Maintanance/Milestones/0.6.0/10_VALIDATION_REVIEW.md, Maintanance/Milestones/0.7.0/10_SPI.md` が出ていること。

**再現率**：4/4。

## 依頼（姫へ）

**目的**：到達点ファイルを版フォルダ間で入れ替えても sync が止まらず、並び替えが見取り図に反映されること。入れ替えを戻しても通ること。到達点ファイルの移動は Milestones 仕様（`Milestones/DESIGN.md`）上の正当な操作。

**やること**：原因を特定して直す。再現手順で確認する（入れ替え → sync 成功 → 列が新しい並び → 元に戻す → sync 成功）。確認後、Milestones のファイルは必ず元の配置へ戻し、`git status` で Milestones に差分が残っていないことを確かめる（入れ替えは試験のための一時変更で、commit 対象ではない）。`missing` 2件の出どころも報告する（RegistryApp 側の不具合なら直す。文書側の古いパスなら、どの文書の何行かを返すだけでよい）。

**編集範囲**：`Maintanance/RegistryApp/` 配下（`index.template.html` の画面変更は除く）、`RegistryApp/README.md`、本書末尾の Return、証拠があれば `Maintanance/Current/Evidence/OPS-078/`。生成物（`Cache/RegistryStudio/`）は sync で更新してよい。

**対象外**：画面の変更、Registry の行、Milestones のファイル配置の恒久変更、Milestones/DESIGN の変更、製品コード、commit。

**停止条件**：直すのに画面や Registry 構造の変更が要ると分かったら、その箇所と理由を書いて止める。探索が見込みを超えたら COMMONS「探索の打ち切り」に従って確認済み範囲を添えて戻す。

**完了条件**：HEAD の配置で sync が通る。入れ替えた配置でも sync が通り、生成された列が新しい並びになっている。戻した後も通り、Milestones に差分が残っていない。verify の PASS 行数が減っていない（減るなら理由）。原因と直した箇所の説明。missing の切り分け結果。Return の記入。

**受入**：Astra が抜き取り照合する（Fable 代理は返却の照合と Registry 反映まで）。commit はユーザー指示で別途。

## Return（姫記入）

2026-10-18 / 姫・Opus 5.5。入力HEAD`1e468aa3f`。作業ツリーの未commit分（Astra・Fableの`CLAUDE_TASK.md`・Registry・Rules・本書）には触れていない。

**再現**：報告どおり`0.6.0/10_VALIDATION_REVIEW.md`と`0.7.0/10_SPI.md`を入れ替えて`sync.py`を実行し、`verify.cjs:15`のassertionで失敗、`registry.json`・`index.html`が復元されることを確認した（1/1）。

**原因**：生成器（`sync.py`）は正しく動いていた。入れ替え後の生成データでは`START-0.6.0→MS-SPI→END-0.6.0`、`START-0.7.0→MS-VALIDATION→END-0.7.0`と新しい並びになっていた。落ちたのは`verify.cjs`で、今のカード配置を決め打ちした検査が2か所あった。

1. 15行：`MS-VALIDATION→END-0.6.0`の接続がある、という検査。
2. 102行（OPS-069の検査）：`GATE-0.6.0→MS-VALIDATION`の線がSTART-0.6.0の代わりに引かれる、という検査。

1を直すと2で落ちた。どちらも、Milestones仕様で正当な「カードを版フォルダ間で動かす」操作を拒む形だった。

**直した箇所**（`verify.cjs`の2文だけ。画面・生成器・Registryは変えていない）：

1. 15行：版フォルダのカード（`gate`が`Milestones/<版>/<番号>_*.md`の到達点）をすべて取り出し、それぞれについて`START-<版>→カード`と`カード→END-<版>`の接続があることを確かめる。版はカードの置き場所から求める。カードが1枚以上あることも確かめる。
2. 102行：ゲートの後ろに隠れるSTART（`GATE→START`の関係を持つもの）から最初のカードへの接続をすべて取り出し、それぞれが「ゲート→カード、`shownFrom`=START」で描かれることを確かめる。

`README.md`の「検証範囲」に一文を足した。

**検証**：
- 入れ替えた配置：`sync.py`成功。生成された列は上の新しい並び。
- 元に戻した配置：`sync.py`成功、`missing: none`。
- `git status`でMilestonesに差分なし。
- verifyのPASS行は22行のまま（HEADの旧`verify.cjs`も同じ配置で22行。一時コピーで数え、コピーは削除済み）。
- 検査の中身は狭めていない。決め打ちの1件を、すべてのカードについての検査に広げた。
- Safariでの見え方は確かめていない（並びは生成データで確認）。

**missingの出どころ**：RegistryApp側の不具合ではなく、文書側の古いパスだった。入れ替えると、Registryの行が正本欄に持つカードのパスが古くなる。

- `TASK_REGISTRY_V2.md` 38行（DOC-036）：`Maintanance/Milestones/0.6.0/10_VALIDATION_REVIEW.md`
- 52行（DOC-026）・53行（DOC-027）：`Maintanance/Milestones/0.7.0/10_SPI.md`

内蔵文書の生成はこれを警告として出すだけで、syncは止めない。実際にカードを動かすときは、この3行のパスも直す必要がある（Registryの行は本依頼の対象外なので触っていない）。

**同じ形の残り（直していない、一行報告）**：`verify.cjs` 161行に`protectionRecords(original).length,18`という件数の決め打ちがある。配置維持の指定が増減すると、同じように同期が止まる。本依頼の範囲（カードの配置）の外なので、候補として返す。

commitはしていない。

## Astra受入（2026-10-18）

修正commit efc3868a86355991c766f02f0e04cb324f52e61eを照合。ユーザーが現在置いた入替配置を保持し、RegistryのDOC-036・026・027の正本パスを追随させてsync.pyを独立実行。22 PASS、missing: none。入替前配置の成功は姫の返却を受領し、今回はユーザーの配置を戻す再試験はしていない。Safari表示は未確認。

今回の2カード入替バグの修正として受入・DONE。返却の「すべてのカードについての検査」は現データに限定する。新しい検査は各カードにSTARTからの直接辺とENDへの直接辺を要求しており、同版内に複数カードを名前順の鎖で置く仕様には一般化できていない。数字アンダースコアのファイル名やMS接頭辞への依存も残る。配置維持18件固定とともにOPS-048の保守候補へ残し、完全な固定データ依存解消とは認定しない。

依頼中の「配置を元へ戻す」は姫の一時試験の条件。今回のユーザー配置と、それを含むcommit指示は別として扱う。
