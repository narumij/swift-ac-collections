# V3の新規版・カード・本文提案の隔離接続

## TL;DR
版の追加位置を明示し、新規カードは正本文書を用意してから正式登録する。追加案同士の接続と本文変更提案も失わず、隔離環境で保存・再開・正式化を検証する。本番は切り替えない。

OPS-176 / EXECUTION / Astra調整・姫 / OPS-167 K5残差 / 2026-10-19ユーザー承認と継続依頼。

## 方針と範囲
版順の正本と新規カード正式化条件はOPS-167「ユーザー決定：版順と新規カード」を参照。LTR-20261019-C372B1750A344FD0A3931F66B16D970AとLTR-20261019-D68757F6714845D48676A9A16206ACA1の補正内訳に基づく。

- apply_planを新規版/カードへ拡張。版追加位置は明示し既存版順を保持。フォルダ比較や名前順で推定しない。gateがない区間を勝手につながない。
- カードの正式IDは明示登録し全node/退役IDとの衝突を拒否。正式化前に準備済み文書を確認。未作成は追加案のまま保持。現行文書形式を再利用し、原型仕様へ新しい必須欄を追加しない。
- 文書の存在・IDと、提案条件の意味を満たすことは別。本文変更提案の処理済みには明示的な確認と本文digest/根拠を要求し、存在だけで条件を満たしたと扱わない。文書はDB transaction外の資源なので、確認時点の証拠と限界を明記。
- plan結果にsave/draftと正式cardの対応を保持。draft task→draft cardも、先にcard正式化、次にtask提案の適用で維持する。未適用planへの依存はpending。planのみ成功後のtask失敗を全体成功と呼ばない。保存系列・再送・claim・対応表競合は既存契約を維持。
- planConditionは本文変更提案として保持しDB本文へ自動採用しない。確認済み文書提案のack操作でsave/group/text digest/evidenceを記録。再送は同結果、同identityの内容変更は拒否。IMPORTSの一回限りの注記を群の状態管理に流用しない。

## 実装境界
experiment内writer/adapter/CLI/harness/browser tests/READMEのみ。UIは隔離template patchで版追加位置の明示選択を試す。実template/server/Inbox/DB/Milestones/DESIGN変更なし。旧保存の照合と本番接続は後続。

## 検証・返却
新規版/cardの実UI保存・再開、明示位置、文書未準備/ID不一致/衝突/古いbase、draft同士の接続、plan成功後task拒否、再送と保存系列の重複登録、本文ackの変更検出を確認。既存198試験も維持する。姫が実装と証拠を返却し、Astraが独立受入。commitはAstra。
