# トップバーのコミット承認表示

## TL;DR（人間向け）

上へ戻らなくても承認状況が分かるよう、追従するトップバーにも承認信号と一括承認を置きます。下の欄と同じ依頼・状態・操作を共有します。

<a id="依頼と境界"></a>
## Assignment and boundaries

OPS-135 / 2026-10-19 / Astra. User request: 「コミット事前承認：⚪ 未処理なし[表示中の未承認0件を承認]をトップバーにも配置」. Retain the existing section. Add an output target to the same view/controller without duplicate communication or separate approval state. Preserve busy/fetch-failure/local-file limitations. Menu discussion is separate from this approval addition.

<a id="受入条件"></a>
## Acceptance criteria

Both displays, counts and enabled states must match. The upper button invokes existing ID/revision-based bulk approval once. Check new requests, busy, failure and empty lists. Do not exercise actual user approvals in tests.

<a id="astra受入2026-10-19"></a>
## Astra acceptance (2026-10-19)

Approval view now has two output targets while controller/communication remain one. Tests covered new requests, counts/signals, busy/failure/re-enable, and one action for the same ID/revision. Existing approval/activity/handoff/header tests PASS. Isolated WebKit at 1400px/390px confirmed top-bar approval fields/buttons fit (static HTML; no live API, actual approvals or user screen operations). Accepted after generation/structural checks. Menu conversion not implemented.
