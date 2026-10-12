# Release Task Registry rehearsal overlay

この文書は独立したrelease工程の複製ではない。
`RELEASE_TASK_REGISTRY_TEMPLATE.md`を唯一のtask骨格として使用し、別の観点を検証するrehearsalごとに
以下の情報と境界を加えて`_ReleaseTask/ACTIVE.md`を生成する。

## Rehearsal setup

- Registry identity: `<rehearsal identity>`
- Life cycle: `ACTIVE`
- Mode: `REHEARSAL / STEP EXECUTION`
- Rehearsal objective: `<今回発見したい問題>`
- Target gates: `<実際に判断まで通すgate>`
- Simulated inputs: `<REHEARSAL ONLYと明記した入力>`
- Forbidden external operations: branch作成、commit、merge、tag、push、公開
- End condition: `<確認後にCANCELLEDへ移す条件>`

## Generation rules

1. `RELEASE_TASK_REGISTRY_TEMPLATE.md`から、その時点の全taskとprecedenceを複製する。
2. 検証対象のgateへ至る前提taskを残し、不要な後続taskだけを`EXCLUDED`にする。
3. 実行しないbuild、remote CI、merge、tag、push、公開は成功扱いにせず、訓練境界または未実施として記録する。
4. 対象のユーザー判断は実際に一問ずつ提示し、回答によるready状態の変化まで確認する。
5. 模擬証拠と判断には`REHEARSAL ONLY`を付け、実releaseへ再利用しない。
6. 発見した欠落、順序誤り、権限境界、証拠不足は本番templateまたは設計へ還元する。
7. 予定したgate確認後はRegistryを`CANCELLED`へ移し、通常Registryへ結果を還元して`ACTIVE.md`を削除する。

## Drift check

- [ ] 本番templateのtask IDとprecedenceを手書きで複製していない。
- [ ] rehearsal開始時点の本番template commitを記録した。
- [ ] rehearsal固有の変更は目的、入力、除外、境界だけである。
- [ ] 本番templateへ還元すべき発見を記録した。
