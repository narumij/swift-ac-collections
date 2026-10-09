## Task Registry

| ID | 状態 | 担当 | 項目 | 再開・完了条件 | 詳細正本 |
| --- | --- | --- | --- | --- | --- |
| `T-001` | `ACTIVE` | Codex | [DISCOVERY] root | 完了まで継続 | `fixture.md` |
| `T-002` | `FROZEN` | User | [DECISION] conditional | 必要な場合だけ再開 | `fixture.md` |
| `T-003` | `ACTIVE` | Codex | [EXECUTION] leaf | T-001後 | `fixture.md` |

## Task precedence

| 後続task | 前提task | Gate | 制約 |
| --- | --- | --- | --- |
| `T-003` | `T-001` | `START` | root後に着手 |

## Registry rules
