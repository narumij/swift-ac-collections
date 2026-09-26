
|  | (A) CROSS=OFF / LAZY=OFF / 同じ木 | (B) CROSS=OFF / LAZY=OFF / 別の木 | (C) CROSS=OFF / LAZY=ON / 同じ木 | (D) CROSS=OFF / LAZY=ON / 別の木 | (E) CROSS=ON / LAZY=OFF / 同じ木 | (F) CROSS=ON / LAZY=OFF / 別の木 | (G) CROSS=ON / LAZY=ON / 同じ木 | (H) CROSS=ON / LAZY=ON / 別の木 |
|---|---|---|---|---|---|---|---|---|
| **(1) 健全** | o | x | o | x | o | o | o | o |
| **(2) 世代違い** | x | x | x | x | x | x | x | x |
| **(3) デタッチ済み** | - | x | - | x | - | o | - | o |
| **(4) デタッチ済み + 世代違い** | - | x | - | x | - | x | - | x |

表は現状を反映している

CoWは別の木という判定になる

LAZY=ONはdeprecated

TODO: CROSSのONとOFFのどちらを標準動作とするかを検討する

- COW時の保証とStringのインデックス挙動を考えると、CROSS=ONが良さそう。
- 異なる木に用いた場合は未定義とする。
