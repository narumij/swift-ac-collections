## Task Registry

| ID | 状態 | 担当 | 項目 | 再開・完了条件 | 詳細正本 |
| --- | --- | --- | --- | --- | --- |
| `T-001` | `ACTIVE` | Codex | [DISCOVERY] first | 完了まで継続 | `fixture.md` |
| `T-002` | `ACTIVE` | Codex | [EXECUTION] second | T-001後 | `fixture.md` |

## Task precedence

| 後続task | 前提task | Gate | 制約 |
| --- | --- | --- | --- |
| `T-001` | `T-002` | `START` | cycle half |
| `T-002` | `T-001` | `COMPLETE` | cycle half |
| `T-001` | `T-001` | `START` | self dependency |
| `T-002` | `MISSING` | `INVALID` | dangling and invalid gate |

## Registry rules
