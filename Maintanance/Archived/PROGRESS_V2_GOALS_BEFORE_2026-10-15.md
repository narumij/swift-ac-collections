# Progress V2 — 目標の記録の修正前原文（2026-10-15）

- 保存日：2026-10-15
- 元の文書：`Maintanance/ProgressV2/TASK_REGISTRY_V2.md`
- 保存範囲：「目標の記録」節全体。達成記録、後続目標、遠い将来の候補、対象を復元する必要がある判断を含む。
- 参照時のGit HEAD：`a074f6fdb0aed9815c4cb4d05889483a5dee1773`
- 参照時の元文書SHA-256：`ab70b5e68ee9f332132ded3b233350e3931f8e143560cac2adba635d7406b1f7`

以下は修正前の履歴であり、現在の目標、提供方針、taskの状態、実行権限を定めない。
本文は要約せず保存した。入口への相対リンクだけ、移動後も同じ資料を指すように変更している。コード表記のパスはリポジトリ直下基準である。
現在の記録は[Task Registry V2](../ProgressV2/TASK_REGISTRY_V2.md#目標の記録)を参照する。

## 照合した根拠

- [2026-10-11までの完了記録](PROGRESS_OVERVIEW_COMPLETED_2026-10-11.md)：`RELEASE-005`・`RELEASE-006`の範囲決定とrelease検討開始。
- [2026-10-13までの完了記録](PROGRESS_OVERVIEW_COMPLETED_2026-10-13.md)：`PERM-058`・`OPT-059`・`BARE-040`の内部本文ドラフト受入。
- [現行品質要求](../QUALITY_REQUIREMENTS.md)：OptionalElementBufferの留保付き実験提供とElementBufferの1.0提供対象からの除外。現在の提供方針は常に現行正本で確認する。

## 整理結果

2026-10-15のユーザーの反映指示に基づく整理では、0.5.1・0.5.2の範囲決定と三対象の本文ドラフト受入を達成記録へ移し、OptionalElementBufferの目標を現行の実験的提供方針へ合わせる。ElementBufferの旧1.0採用目標は取り下げ、代替の目標を新設しない。方式習熟を含む残る後続目標は保持する。原文の後続目標13件は、達成済み5件、後続に残す7件、取り下げ1件に対応する。

## 保存した原文

## 目標の記録

現在選択中の目標は[入口](../ProgressV2/PROGRESS_OVERVIEW_V2.md#現在の目標)に置く。以下の記録だけでは、後続目標の選択や凍結解除は成立しない。中間ゴールはtaskではなく、独自のID・状態を付けない。

### 直近達成した目標

Array系benchmark・OptionalElementBuffer opt-in・ElementBuffer系名称移行を完了した。詳細は`Maintanance/Archived/PROGRESS_OVERVIEW_COMPLETED_2026-10-14.md`に保存されている。

### 後続の中間ゴール

- Permutation、OptionalArray、BareArrayのTest as Specification整理が完了した時点で、0.5.1の
  製品上の到達範囲を決め、release工程へ進むか判断できる状態にする。
- Permutationの利用者向け文書ドラフトを、公開契約と品質評価に接続し、ユーザーが本文をレビューできる
  状態にする。公開可能な初版の完成はこのゴールに含めない。
- OptionalArrayの利用者向け文書ドラフトを、公開契約と品質評価に接続し、ユーザーが本文をレビューできる
  状態にする。公開可能な初版の完成はこのゴールに含めない。
- BareArrayの利用者向け文書ドラフトを、監査で確定した公開契約に接続し、ユーザーが本文をレビューできる
  状態にする。公開可能な初版の完成はこのゴールに含めない。
- 三対象の文書ドラフト作業を通じて作業方式を習熟した後、RedBlackTreeに見えていない残作業を確認し、
  Codexのユーザードキュメント作業フェーズへ渡せる状態にする。
- 全公開対象のコメントドックについて、公開契約に接続したドラフトが揃った時点で、0.5.2の製品上の
  到達範囲を決め、release工程へ進むか判断できる状態にする。
- 全公開対象の利用者向けドキュメントが公開可能な初版として揃った時点で、0.6.0の製品上の到達範囲を
  決め、release工程へ進むか判断できる状態にする。
- ユーザードキュメント作業後、OptionalArrayのISO/IEC 25010観点の品質評価を再評価し、
  1.0判断前に解消する不足をtaskへ分離できる状態にする。
- 再評価後、OptionalArrayを1.0として採用できるか判断可能な状態にする。
- BareArrayのユーザードキュメント作業後、性能基準、View寿命、storage再設計、strict memory safetyを
  再評価し、BareArrayを1.0として採用できるか判断可能な状態にする。
- RedBlackTreeのユーザードキュメント作業後、汎用基盤ライブラリの1.0として採用できるか判断可能な
  状態にする。この段階でruntime-check実装を再審査し、その結論とIndex契約を1.0品質ゲートへ渡す。
- 0.9.x release後、Swift Package Indexへpackageを登録し、module別DocCの生成と互換性表示を確認する。登録後に
  SPIが提供するbadgeとmodule別API referenceへの導線をREADMEまたはPagesへ接続し、結果を1.0品質gateへ渡す。
- 保留中の運用playbookをユーザー指示で再開した後、このrepositoryで得たtask運用知見を、
  別projectでもCodexが同程度の管理品質を再現できる移植可能な形へ整理する。

### 遠い将来の目標候補

- 1.0 releaseより後の段階で、対象judgeが必要なSwift toolchainを採用した場合、Permutationを含む
  現行版の競技環境向け構成、性能、単一file経路、および実提出を検証し、judge搭載を目指す。
  現在の中間ゴールとの依存関係、着手順、および具体的な受入条件はまだ定めない。

### 対象を復元する必要がある判断の記録

基準版には、以下を「今回の作業taskへ含めない」とする記録があるが、「今回」の対象taskは明記されていない。決定済みとも、すべての新しい依頼への一律の禁止とも扱わない。関係する仕事で必要になったときに、対象範囲と既決事項を詳細正本・現在の依頼で照合し、残る判断をユーザーへ返す。

- 利用者向け文書の形（Markdown、DocC、documentation commentのみのいずれにするか）
- 性能の数値を利用者向け文書へ掲載するか
- 1.0ゲート（`QUALITY-001`）との境界
- RedBlackTreeのデバッグ用memberを`#if DEBUG`へ揃えるか

