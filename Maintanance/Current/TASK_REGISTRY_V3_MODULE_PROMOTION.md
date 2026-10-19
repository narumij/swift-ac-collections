# V3モジュールの正式配置

## TL;DR
受入済みのV3実装を実験フォルダからRegistryApp/v3へ移す。複製せず参照先を直し、同じ226試験を通す。本番機能の有効化はしない。

OPS-178 / EXECUTION / Astra調整・姫 / OPS-167 S3-0 / 2026-10-19継続指示。

## 範囲
LTR-20261019-7CA4DD1A19B3406CBEF66A62C6EE79A6のS3-0を採用。Maintanance/RegistryApp/v3/を配置先とする。Experiments/registry_v3_read/の受入済み実装・fixture・試験を移動し、二重実装を残さない。README・証拠への入口は旧場所に残せる。テスト専用server/harnessは本番公開経路にしない。

移動に必要なimport/sys.path・fixture/テンプレート/リポジトリrootの相対参照・現行の実行案内を更新する。過去の証跡中の実行pathを改竄しない。ロジック変更はしない。参照先探索は対象pathに限定する。

## 検証と返却
移動後に同じ226試験、diff --check、旧場所への実行依存が残っていないことを確認。fixtureや生成物は一時領域に限定し、現用serverの起動/再起動、実DB/Inboxへの操作をしない。現用inbox/template/serveの機能変更は後続。姫が実施・返却、Astraが独立受入・commit。

## 受入（2026-10-19）
LTR-20261019-342DC0F9BF05433F9B28CD033D9D3591を受入。実装・fixture・試験をv3へ移動し、旧場所は証拠と入口READMEを保持。相対参照と実行案内のみ変更、ロジック追加なし。

Astra独立実行：`python3 -B -W always::ResourceWarning -m unittest discover -s Maintanance/RegistryApp/v3 -p 'test_*.py'`で226件成功（69.726秒）。cached diff --check成功。OPS-178 DONE。本番のV3有効化やデータ移行は未実施。
