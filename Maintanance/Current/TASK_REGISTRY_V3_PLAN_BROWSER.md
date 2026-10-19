# V3既存計画編集のブラウザ往復

## TL;DR
既存カードの計画編集を、隔離WebKitで編集・保存・再開・明示適用する。関数試験とブラウザの差を埋める。本番へは接続しない。

OPS-173 / EXECUTION / Astra調整・姫 / OPS-167 K5・K6接続の限定試行 / 2026-10-19継続指示。

## 範囲と受入
OPS-172で受入済みの並べ替え・版間移動・表示名変更のみ。OPS-166の隔離serverへP4相当を接続し、明示選択とresolutionを伴うgroups適用を専用endpointから呼ぶ。保存だけではDBが変わらない契約を維持する。実際のUI操作から保存し、新しいbrowser contextで再開後、確認したplan群を適用して最新exportを検証する。

古い基準の競合、同一操作再送、骨格線の重複なし、task接続保持を確認する。実験serverは127.0.0.1の自動割当port、TemporaryDirectoryとfixtureのみ。browserは隔離origin以外の送信を事前拒否し、終了時にserver/browserを閉じる。現用server・DB・Inbox・templateは変更せず、インストールも行わない。

変更はexperiment内server/browser driver/test/README。既存の単一task往復試験は維持する。新規版/card・gate/focus変更、opaque gateのUI全般対応、production適用は対象外。新たな判断が必要なら実装で埋めず返す。

姫が実装と試験を返却、Astraが独立検証・記録・commit。

## 受入結果（2026-10-19）
返却LTR-20261019-F629FC3C8765463B80286BC3A47F3B9Eを照合。Astraが全179試験を42.501秒で独立実行し成功、ResourceWarningなし。WebKitの実編集・保存・新context再開、確認なしの保留、明示適用、再送、古い基準の競合を確認。保存だけではDBを変えず、task接続を保持する。P4を隔離serverにも接続し、骨格線が置換される。

受入は隔離WebKit範囲。適用は試験から明示HTTPで行い、画面内の適用ボタンは未実装。フォント/視覚品質の評価、新規版/card、opaque gate対応、本番接続は含めない。OPS-173完了。
