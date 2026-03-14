# SIMD APIリファレンス

> **モジュール**: `WasmNum.SIMD`
> **ソース**: `WasmNum/SIMD/`

## V128 Shape

> **ソース**: `WasmNum/SIMD/V128/Shape.lean`

### `LaneType`

```lean
inductive LaneType where
  | int
  | float
```

### `Shape`

```lean
structure Shape where
  laneWidth : Nat
  laneCount : Nat
  laneType  : LaneType
  valid     : laneWidth * laneCount = 128
  widthPow2 : ∃ k, laneWidth = 2 ^ k ∧ 3 ≤ k ∧ k ≤ 6
```

### 具象シェイプ

| 定数 | レーン幅 | レーン数 | 型 |
|------|:-------:|:-------:|-----|
| `Shape.i8x16` | 8 | 16 | int |
| `Shape.i16x8` | 16 | 8 | int |
| `Shape.i32x4` | 32 | 4 | int |
| `Shape.i64x2` | 64 | 2 | int |
| `Shape.f32x4` | 32 | 4 | float |
| `Shape.f64x2` | 64 | 2 | float |

| ユーティリティ | 説明 |
|-------------|------|
| `Shape.all : List Shape` | 全6シェイプのリスト |

---

## V128 Type

> **ソース**: `WasmNum/SIMD/V128/Type.lean`

```lean
abbrev V128 := BitVec 128
```

---

## V128 Lanes

> **ソース**: `WasmNum/SIMD/V128/Lanes.lean`

### コアレーン操作

| 関数 | シグネチャ | 説明 |
|------|----------|------|
| `lane` | `(s : Shape) → V128 → Fin s.laneCount → BitVec s.laneWidth` | レーン i を抽出 |
| `replaceLane` | `(s : Shape) → V128 → Fin s.laneCount → BitVec s.laneWidth → V128` | レーン i を置換 |
| `ofLanes` | `(s : Shape) → (Fin s.laneCount → BitVec s.laneWidth) → V128` | レーン関数から作成 |
| `splat` | `(s : Shape) → BitVec s.laneWidth → V128` | 全レーンに値を複製 |

### 高階レーン操作

| 関数 | シグネチャ | 説明 |
|------|----------|------|
| `mapLanes` | `(s : Shape) → (BitVec s.laneWidth → BitVec s.laneWidth) → V128 → V128` | 単項操作をレーン毎に適用 |
| `zipLanes` | `(s : Shape) → (BitVec s.laneWidth → BitVec s.laneWidth → BitVec s.laneWidth) → V128 → V128 → V128` | 二項操作をレーン毎に適用 |

### 定数

| 定数 | 値 |
|------|-----|
| `V128.zero` | 全ビットゼロ |
| `V128.allOnes` | 全ビット1 |

---

## Ops Bitwise

> **ソース**: `WasmNum/SIMD/Ops/Bitwise.lean`

シェイプ非依存（128ビットベクター全体に対して操作）：

| 関数 | シグネチャ | 説明 |
|------|----------|------|
| `v128_not` | `V128 → V128` | ビットワイズ NOT |
| `v128_and` | `V128 → V128 → V128` | AND |
| `v128_andnot` | `V128 → V128 → V128` | `a AND (NOT b)` |
| `v128_or` | `V128 → V128 → V128` | OR |
| `v128_xor` | `V128 → V128 → V128` | XOR |
| `v128_bitselect` | `V128 → V128 → V128 → V128` | ビットワイズ選択 |
| `v128_any_true` | `V128 → I32` | いずれかのビットがセットなら 1、それ以外 0 |
| `boolToMask` | `(n : Nat) → Bool → BitVec n` | Bool を全1 / 全0マスクに変換 |

---

## Ops IntLanewise

> **ソース**: `WasmNum/SIMD/Ops/IntLanewise.lean`

すべて `Shape` パラメータを取り、レーン毎に操作：

### 算術

| 関数 | シグネチャ |
|------|----------|
| `add` | `Shape → V128 → V128 → V128` |
| `sub` | `Shape → V128 → V128 → V128` |
| `neg` | `Shape → V128 → V128` |
| `mul` | `Shape → V128 → V128 → V128` |

### 飽和算術

| 関数 | シグネチャ |
|------|----------|
| `addSatS` / `addSatU` | `Shape → V128 → V128 → V128` |
| `subSatS` / `subSatU` | `Shape → V128 → V128 → V128` |

### 最小値/最大値

| 関数 | シグネチャ |
|------|----------|
| `minS` / `minU` | `Shape → V128 → V128 → V128` |
| `maxS` / `maxU` | `Shape → V128 → V128 → V128` |

### シフト

シフト量は `I32` で、レーン幅で剰余を取る：

| 関数 | シグネチャ | 説明 |
|------|----------|------|
| `shl` | `Shape → V128 → I32 → V128` | 左シフト |
| `shrS` | `Shape → V128 → I32 → V128` | 算術右シフト |
| `shrU` | `Shape → V128 → I32 → V128` | 論理右シフト |

### 比較

結果：真ならレーン毎に全1、偽なら全0：

| 関数 | シグネチャ |
|------|----------|
| `eqLane` / `neLane` | `Shape → V128 → V128 → V128` |
| `ltSLane` / `ltULane` | `Shape → V128 → V128 → V128` |
| `leSLane` / `leULane` | `Shape → V128 → V128 → V128` |
| `gtSLane` / `gtULane` | `Shape → V128 → V128 → V128` |
| `geSLane` / `geULane` | `Shape → V128 → V128 → V128` |

### その他

| 関数 | シグネチャ | 説明 |
|------|----------|------|
| `abs` | `Shape → V128 → V128` | 絶対値 |
| `avgRU` | `Shape → V128 → V128 → V128` | 符号なし丸め平均 |
| `popcnt_i8x16` | `V128 → V128` | ポピュレーションカウント（i8x16 のみ） |
| `q15mulrSatS` | `V128 → V128 → V128` | Q15 飽和乗算（i16x8） |

---

## Ops FloatLanewise

> **ソース**: `WasmNum/SIMD/Ops/FloatLanewise.lean`

### 算術（Set 返却 — NaN 非決定性）

| 関数 | シグネチャ |
|------|----------|
| `fadd` | `(s : Shape) → [WasmFloat s.laneWidth] → V128 → V128 → Set V128` |
| `fsub` | `(s : Shape) → [WasmFloat s.laneWidth] → V128 → V128 → Set V128` |
| `fmul` | 同上 |
| `fdiv` | 同上 |
| `fsqrt` | `(s : Shape) → [WasmFloat s.laneWidth] → V128 → Set V128` |

### 最小値/最大値

| 関数 | 戻り値 | 説明 |
|------|-------|------|
| `fminLane` | `Set V128` | NaN 伝播付きレーン毎 fmin |
| `fmaxLane` | `Set V128` | NaN 伝播付きレーン毎 fmax |
| `fpminLane` | `V128` | レーン毎 pseudo-min（決定論的） |
| `fpmaxLane` | `V128` | レーン毎 pseudo-max（決定論的） |

### 丸め（Set 返却）

| 関数 | 戻り値 |
|------|-------|
| `fceilLane` / `ffloorLane` / `ftruncLane` / `fnearestLane` | `Set V128` |

### ビットワイズ（決定論的）

| 関数 | 戻り値 | 説明 |
|------|-------|------|
| `fabsLane` | `V128` | レーン毎に符号ビットクリア |
| `fnegLane` | `V128` | レーン毎に符号ビットトグル |

### 比較（決定論的）

結果：真ならレーン毎に全1、偽なら全0：

| 関数 | 戻り値 |
|------|-------|
| `feqLane` / `fneLane` / `fltLane` / `fleLane` / `fgtLane` / `fgeLane` | `V128` |

---

## Ops Bitmask

> **ソース**: `WasmNum/SIMD/Ops/Bitmask.lean`

| 関数 | シグネチャ | 説明 |
|------|----------|------|
| `allTrue` | `Shape → V128 → Bool` | すべてのレーンが非ゼロなら true |
| `bitmask` | `Shape → V128 → I32` | 各レーンの MSB をビットマスクに抽出 |

---

## Ops Narrow

> **ソース**: `WasmNum/SIMD/Ops/Narrow.lean`

| 関数 | シグネチャ | 説明 |
|------|----------|------|
| `narrowS` | `Shape → V128 → V128 → V128` | 符号付き飽和でナロー |
| `narrowU` | `Shape → V128 → V128 → V128` | 符号なし飽和でナロー |

---

## Ops Extend

> **ソース**: `WasmNum/SIMD/Ops/Extend.lean`

| 関数 | シグネチャ | 説明 |
|------|----------|------|
| `extendLowS` / `extendLowU` | `Shape → V128 → V128` | 下位半分のレーンを拡張 |
| `extendHighS` / `extendHighU` | `Shape → V128 → V128` | 上位半分のレーンを拡張 |
| `extAddPairwiseS` / `extAddPairwiseU` | `Shape → V128 → V128` | 拡張付きペアワイズ加算 |
| `extMulS` / `extMulU` | `Shape → V128 → V128 → V128` | 拡張乗算 |

---

## Ops Dot

> **ソース**: `WasmNum/SIMD/Ops/Dot.lean`

| 関数 | シグネチャ | 説明 |
|------|----------|------|
| `dot_i16x8_i32x4` | `V128 → V128 → V128` | i16x8 内積 → i32x4 |

---

## Ops Swizzle

> **ソース**: `WasmNum/SIMD/Ops/Swizzle.lean`

| 関数 | シグネチャ | 説明 |
|------|----------|------|
| `swizzle` | `V128 → V128 → V128` | レーンスウィズル：インデックス値でレーンを選択 |

---

## Ops Shuffle

> **ソース**: `WasmNum/SIMD/Ops/Shuffle.lean`

| 関数 | シグネチャ | 説明 |
|------|----------|------|
| `shuffle` | `Shape → V128 → V128 → Vector (Fin (2 * s.laneCount)) s.laneCount → V128` | 2つのベクターからレーンを選択 |

---

## Ops SplatExtractReplace

> **ソース**: `WasmNum/SIMD/Ops/SplatExtractReplace.lean`

シェイプ毎の splat、extract、replace 操作：

| シェイプ | Splat | Extract | Replace |
|---------|-------|---------|---------|
| i8x16 | `splat_i8x16` | `extractLane_i8x16` | `replaceLane_i8x16` |
| i16x8 | `splat_i16x8` | `extractLane_i16x8` | `replaceLane_i16x8` |
| i32x4 | `splat_i32x4` | `extractLane_i32x4` | `replaceLane_i32x4` |
| i64x2 | `splat_i64x2` | `extractLane_i64x2` | `replaceLane_i64x2` |

---

## Ops Convert

> **ソース**: `WasmNum/SIMD/Ops/Convert.lean`

| 関数 | シグネチャ | 戻り値 | 説明 |
|------|----------|-------|------|
| `convertI32x4` | `V128 → V128` | 決定論的 | i32x4 → f32x4 |
| `truncSatF32x4S` | `V128 → V128` | 決定論的 | f32x4 → i32x4（符号付き飽和） |
| `truncSatF32x4U` | `V128 → V128` | 決定論的 | f32x4 → i32x4（符号なし飽和） |
| `truncSatF64x2S` | `V128 → V128` | 決定論的 | f64x2 → i64x2（符号付き飽和） |
| `truncSatF64x2U` | `V128 → V128` | 決定論的 | f64x2 → i64x2（符号なし飽和） |
| `promoteF32x4` | `V128 → Set V128` | `Set` | f32x4 → f64x2（下位半分、NaN 処理） |
| `demoteF64x2` | `V128 → Set V128` | `Set` | f64x2 → f32x4（ゼロ充填、NaN 処理） |

---

## Relaxed Madd

> **ソース**: `WasmNum/SIMD/Relaxed/Madd.lean`

| 関数 | シグネチャ | 戻り値 | 説明 |
|------|----------|-------|------|
| `madd` | `Shape → [WasmFloat s.laneWidth] → V128 → V128 → V128 → Set V128` | `Set` | Relaxed 融合積和演算 |
| `nmadd` | 同上 | `Set` | Relaxed 否定融合積和演算 |

---

## Relaxed MinMax

> **ソース**: `WasmNum/SIMD/Relaxed/MinMax.lean`

| 関数 | シグネチャ | 戻り値 |
|------|----------|-------|
| `min` | `Shape → [WasmFloat s.laneWidth] → V128 → V128 → Set V128` | `Set` |
| `max` | 同上 | `Set` |

---

## Relaxed Swizzle

> **ソース**: `WasmNum/SIMD/Relaxed/Swizzle.lean`

| 関数 | シグネチャ | 戻り値 | 説明 |
|------|----------|-------|------|
| `swizzle` | `V128 → V128 → Set V128` | `Set` | 範囲外はゼロまたは飽和の可能性 |

---

## Relaxed Trunc

> **ソース**: `WasmNum/SIMD/Relaxed/Trunc.lean`

| 関数 | 戻り値 | 説明 |
|------|-------|------|
| `truncF32x4S` | `Set V128` | f32x4 → i32x4（relaxed 符号付き） |
| `truncF32x4U` | `Set V128` | f32x4 → i32x4（relaxed 符号なし） |
| `truncF64x2SZero` | `Set V128` | f64x2 → i32x4（relaxed 符号付き、ゼロ充填） |
| `truncF64x2UZero` | `Set V128` | f64x2 → i32x4（relaxed 符号なし、ゼロ充填） |

---

## Relaxed Laneselect

> **ソース**: `WasmNum/SIMD/Relaxed/Laneselect.lean`

| 関数 | シグネチャ | 戻り値 | 説明 |
|------|----------|-------|------|
| `laneselect` | `Shape → V128 → V128 → V128 → Set V128` | `Set` | MSBベースまたはビットワイズ選択 |

---

## Relaxed Dot

> **ソース**: `WasmNum/SIMD/Relaxed/Dot.lean`

| 関数 | 戻り値 | 説明 |
|------|-------|------|
| `dot_i8x16_i7x16_s` | `Set V128` | Relaxed i8×i7 符号付き内積 |
| `dot_i8x16_i7x16_add_s` | `Set V128` | Relaxed 内積 + アキュムレート |

---

## Relaxed Q15

> **ソース**: `WasmNum/SIMD/Relaxed/Q15.lean`

| 関数 | 戻り値 | 説明 |
|------|-------|------|
| `q15mulrS` | `Set V128` | Relaxed Q15 飽和丸め乗算 |

## 関連ドキュメント

- [Foundation API](foundation.md) — 型と WasmFloat
- [Numerics API](numerics.md) — レーン毎に使用されるスカラー操作
- [Memory API](memory.md) — SIMD ロード/ストア
- [ADR-004: V128 Shape System](../../design/adr/0004-v128-shape-system.md)
- [English Version](../../../en/reference/api/simd.md)
