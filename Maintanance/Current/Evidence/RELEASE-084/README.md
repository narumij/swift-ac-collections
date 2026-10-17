# RELEASE-084 再依頼の証拠（2026-10-17 / Claude 姫）

- `baseline-0.5.4-CI.log` / `baseline-0.5.4-CI-Small.log`：比較元 0.5.4（`b03d0bf2`）を一時worktreeにチェックアウトし、候補（`0789479b`）の`Benchmarks/Libraries/CI.json`・`CI-Small.json`をcandidate.ymlと同じ手順で写して`benchmark library run`を`--max-size 2 --cycles 1`で実行した記録。両方exit 0、`unknown tasks`なし、記録された測定29件。
- 名前変換（BareArray / OptionalArray の旧名）は0.5.4で不要（新名がソースにある）と確認。
- 実行環境：macOS（ローカル）。CIのUbuntu runnerでの実行ではない。性能値は比較に使っていない（測定の受付だけを確かめた）。
