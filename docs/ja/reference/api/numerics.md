# Numerics APIリファレンス

> **モジュール**: `WasmNum.Numerics`
> **ソース**: `WasmNum/Numerics/`

## NaN Propagation

> **ソース**: `WasmNum/Numerics/NaN/Propagation.lean`

### セット

| 関数 | シグネチャ | 説明 |
|------|----------|------|
| `nans` | `(N : Nat) → [WasmFloat N] → Set (BitVec N)` | 幅 N のすべての NaN 値 |
| `canonicalNans` | `(N : Nat) → [WasmFloat N] → Set (BitVec N)` | Canonical NaN セット（±） |
| `arithmeticNans` | `(N : Nat) → [WasmFloat N] → Set (BitVec N)` | すべての quiet（arithmetic）NaN 値 |

### NaN 結果セット

| 関数 | シグネチャ | 説明 |
|------|----------|------|
| `payloadOverlapsAny` | `BitVec N → List (BitVec N) → Prop` | ペイロードが少なくとも1つの入力とオーバーラップ |
| `overlappingArithmeticNans` | `(N : Nat) → List (BitVec N) → Set (BitVec N)` | オーバーラップするペイロードの arithmetic NaN |
| `nansN` | `(N : Nat) → [WasmFloat N] → List (BitVec N) → Set (BitVec N)` | 仕様 `nans_N{z*}`：canonical ∪ オーバーラップする arithmetic NaN |

### 伝播関数

| 関数 | シグネチャ | 戻り値 | 説明 |
|------|----------|-------|------|
| `propagateNaN₁` | `(op : BitVec N → BitVec N) → BitVec N → Set (BitVec N)` | `Set` | 単項 NaN 伝播 |
| `propagateNaN₂` | `(op : BitVec N → BitVec N → BitVec N) → BitVec N → BitVec N → Set (BitVec N)` | `Set` | 二項 NaN 伝播 |

---

## NaN Deterministic

> **ソース**: `WasmNum/Numerics/NaN/Deterministic.lean`

### `DeterministicWasmProfile`

`WasmProfile` を拡張し、`selectNaN` が常に `nansN` 内の値を生成することの証明付き：

```lean
structure DeterministicWasmProfile extends WasmProfile where
  selectNaN_mem : ∀ N [WasmFloat N] inputs,
    nanProfile.selectNaN N inputs ∈ nansN N inputs
```

### 決定論的伝播

| 関数 | シグネチャ | 説明 |
|------|----------|------|
| `propagateNaN₁_det` | `DeterministicWasmProfile → (BitVec N → BitVec N) → BitVec N → BitVec N` | 決定論的単項 |
| `propagateNaN₂_det` | `DeterministicWasmProfile → (BitVec N → BitVec N → BitVec N) → BitVec N → BitVec N → BitVec N` | 決定論的二項 |

---

## Float MinMax

> **ソース**: `WasmNum/Numerics/Float/MinMax.lean`

| 関数 | シグネチャ | 戻り値 | 説明 |
|------|----------|-------|------|
| `fmin` | `[WasmFloat N] → BitVec N → BitVec N → Set (BitVec N)` | `Set` | 符号付きゼロ処理付き Wasm `fmin` |
| `fmax` | `[WasmFloat N] → BitVec N → BitVec N → Set (BitVec N)` | `Set` | 符号付きゼロ処理付き Wasm `fmax` |

**動作**：
- いずれかのオペランドが NaN：結果 ∈ `nansN`
- 両方ゼロで異なる符号：`fmin` は -0 を返し、`fmax` は +0 を返す
- それ以外：小さい/大きい方の値を返す

---

## Float Rounding

> **ソース**: `WasmNum/Numerics/Float/Rounding.lean`

| 関数 | シグネチャ | 戻り値 | 説明 |
|------|----------|-------|------|
| `fnearest` | `[WasmFloat N] → BitVec N → Set (BitVec N)` | `Set` | 最近接偶数丸め |
| `fceil` | `[WasmFloat N] → BitVec N → Set (BitVec N)` | `Set` | +∞ 方向丸め |
| `ffloor` | `[WasmFloat N] → BitVec N → Set (BitVec N)` | `Set` | -∞ 方向丸め |
| `ftrunc` | `[WasmFloat N] → BitVec N → Set (BitVec N)` | `Set` | ゼロ方向丸め |

NaN 伝播のためすべて `Set` を返す。

---

## Float Sign

> **ソース**: `WasmNum/Numerics/Float/Sign.lean`

| 関数 | シグネチャ | 戻り値 | 説明 |
|------|----------|-------|------|
| `fabs` | `BitVec N → BitVec N` | 決定論的 | 符号ビットをクリア |
| `fneg` | `BitVec N → BitVec N` | 決定論的 | 符号ビットをトグル |
| `fcopysign` | `BitVec N → BitVec N → BitVec N` | 決定論的 | 第2オペランドの符号を第1の絶対値にコピー |

純粋なビットワイズ操作 — IEEE 754 解釈不要。

---

## Float Compare

> **ソース**: `WasmNum/Numerics/Float/Compare.lean`

| 関数 | シグネチャ | 戻り値 | 説明 |
|------|----------|-------|------|
| `feq` | `[WasmFloat N] → BitVec N → BitVec N → I32` | `I32` | 等値（+0 == -0 → 1、NaN → 0） |
| `fne` | `[WasmFloat N] → BitVec N → BitVec N → I32` | `I32` | 非等値（NaN → 1） |
| `flt` | `[WasmFloat N] → BitVec N → BitVec N → I32` | `I32` | 小なり（NaN → 0） |
| `fgt` | `[WasmFloat N] → BitVec N → BitVec N → I32` | `I32` | 大なり（NaN → 0） |
| `fle` | `[WasmFloat N] → BitVec N → BitVec N → I32` | `I32` | 以下（NaN → 0） |
| `fge` | `[WasmFloat N] → BitVec N → BitVec N → I32` | `I32` | 以上（NaN → 0） |

すべて `I32`（0 または 1）を返す。NaN オペランドは非順序として比較。

---

## Float PseudoMinMax

> **ソース**: `WasmNum/Numerics/Float/PseudoMinMax.lean`

| 関数 | シグネチャ | 戻り値 | 説明 |
|------|----------|-------|------|
| `fpmin` | `[WasmFloat N] → BitVec N → BitVec N → BitVec N` | 決定論的 | `if b < a then b else a` |
| `fpmax` | `[WasmFloat N] → BitVec N → BitVec N → BitVec N` | 決定論的 | `if a < b then b else a` |

NaN 伝播なし — NaN は第1オペランドを返す（非順序比較）。SIMD で使用。

---

## Integer Arithmetic

> **ソース**: `WasmNum/Numerics/Integer/Arithmetic.lean`

| 関数 | シグネチャ | 戻り値 | 説明 |
|------|----------|-------|------|
| `iadd` | `BitVec N → BitVec N → BitVec N` | 決定論的 | 剰余加算 |
| `isub` | `BitVec N → BitVec N → BitVec N` | 決定論的 | 剰余減算 |
| `imul` | `BitVec N → BitVec N → BitVec N` | 決定論的 | 剰余乗算 |
| `idiv_u` | `BitVec N → BitVec N → Option (BitVec N)` | `Option` | 符号なし除算（0除算で none） |
| `idiv_s` | `BitVec N → BitVec N → Option (BitVec N)` | `Option` | 符号付き除算（0除算または INT_MIN/-1 で none） |
| `irem_u` | `BitVec N → BitVec N → Option (BitVec N)` | `Option` | 符号なし剰余（0除算で none） |
| `irem_s` | `BitVec N → BitVec N → Option (BitVec N)` | `Option` | 符号付き剰余、被除数の符号（0除算で none） |

---

## Integer Bitwise

> **ソース**: `WasmNum/Numerics/Integer/Bitwise.lean`

| 関数 | シグネチャ | 説明 |
|------|----------|------|
| `iand` | `BitVec N → BitVec N → BitVec N` | ビットワイズ AND |
| `ior` | `BitVec N → BitVec N → BitVec N` | ビットワイズ OR |
| `ixor` | `BitVec N → BitVec N → BitVec N` | ビットワイズ XOR |
| `inot` | `BitVec N → BitVec N` | ビットワイズ補数 |
| `iandnot` | `BitVec N → BitVec N → BitVec N` | `a AND (NOT b)` |

---

## Integer Shift

> **ソース**: `WasmNum/Numerics/Integer/Shift.lean`

| 関数 | シグネチャ | 説明 |
|------|----------|------|
| `ishl` | `BitVec N → BitVec N → BitVec N` | `(k mod N)` ビット左シフト |
| `ishr_u` | `BitVec N → BitVec N → BitVec N` | `(k mod N)` 論理右シフト |
| `ishr_s` | `BitVec N → BitVec N → BitVec N` | `(k mod N)` 算術右シフト |
| `irotl` | `BitVec N → BitVec N → BitVec N` | 左ローテート |
| `irotr` | `BitVec N → BitVec N → BitVec N` | 右ローテート |

シフト量は常にビット幅 N で剰余を取る。

---

## Integer Compare

> **ソース**: `WasmNum/Numerics/Integer/Compare.lean`

| 関数 | シグネチャ | 説明 |
|------|----------|------|
| `ieqz` | `BitVec N → I32` | ゼロ判定 |
| `ieq` | `BitVec N → BitVec N → I32` | 等値 |
| `ine` | `BitVec N → BitVec N → I32` | 非等値 |
| `ilt_u` / `ilt_s` | `BitVec N → BitVec N → I32` | 小なり（符号なし / 符号付き） |
| `igt_u` / `igt_s` | `BitVec N → BitVec N → I32` | 大なり |
| `ile_u` / `ile_s` | `BitVec N → BitVec N → I32` | 以下 |
| `ige_u` / `ige_s` | `BitVec N → BitVec N → I32` | 以上 |

すべて `I32`（0 または 1）を返す。

---

## Integer Bits

> **ソース**: `WasmNum/Numerics/Integer/Bits.lean`

| 関数 | シグネチャ | 説明 |
|------|----------|------|
| `iclz` | `BitVec N → BitVec N` | 先頭ゼロビットカウント |
| `ictz` | `BitVec N → BitVec N` | 末尾ゼロビットカウント |
| `ipopcnt` | `BitVec N → BitVec N` | ポピュレーションカウント（セットビット数） |

---

## Integer Ext

> **ソース**: `WasmNum/Numerics/Integer/Ext.lean`

| 関数 | シグネチャ | 説明 |
|------|----------|------|
| `iextend_s` | `(fromWidth : Nat) → BitVec N → BitVec N` | 下位 `fromWidth` ビットを N ビット幅に符号拡張 |

---

## Integer Saturating

> **ソース**: `WasmNum/Numerics/Integer/Saturating.lean`

| 関数 | シグネチャ | 説明 |
|------|----------|------|
| `sat_s` | `(N : Nat) → Int → BitVec N` | 整数を N ビット符号付き範囲にクランプ |
| `sat_u` | `(N : Nat) → Int → BitVec N` | 整数を N ビット符号なし範囲にクランプ |
| `iadd_sat_s` | `BitVec N → BitVec N → BitVec N` | 符号付き飽和加算 |
| `iadd_sat_u` | `BitVec N → BitVec N → BitVec N` | 符号なし飽和加算 |
| `isub_sat_s` | `BitVec N → BitVec N → BitVec N` | 符号付き飽和減算 |
| `isub_sat_u` | `BitVec N → BitVec N → BitVec N` | 符号なし飽和減算 |

---

## Integer MinMax

> **ソース**: `WasmNum/Numerics/Integer/MinMax.lean`

| 関数 | シグネチャ | 説明 |
|------|----------|------|
| `imin_u` / `imin_s` | `BitVec N → BitVec N → BitVec N` | 最小値（符号なし / 符号付き） |
| `imax_u` / `imax_s` | `BitVec N → BitVec N → BitVec N` | 最大値（符号なし / 符号付き） |

---

## Integer Misc

> **ソース**: `WasmNum/Numerics/Integer/Misc.lean`

| 関数 | シグネチャ | 説明 |
|------|----------|------|
| `iabs` | `BitVec N → BitVec N` | 絶対値（符号付き解釈） |
| `ineg` | `BitVec N → BitVec N` | 2の補数否定 |
| `iavgr_u` | `BitVec N → BitVec N → BitVec N` | 符号なし丸め平均：`(a + b + 1) / 2` |
| `iq15mulr_sat_s` | `BitVec 16 → BitVec 16 → BitVec 16` | Q15 飽和丸め乗算（16ビットのみ） |

---

## Integer Bitselect

> **ソース**: `WasmNum/Numerics/Integer/Bitselect.lean`

| 関数 | シグネチャ | 説明 |
|------|----------|------|
| `ibitselect` | `BitVec N → BitVec N → BitVec N → BitVec N` | `(a AND mask) OR (b AND NOT mask)` |

---

## Conversion TruncPartial

> **ソース**: `WasmNum/Numerics/Conversion/TruncPartial.lean`

トラップ変換 — NaN、無限大、範囲外で `none` を返す：

| 関数 | 変換 | 説明 |
|------|------|------|
| `truncToIntS` | `float N → Option (BitVec M)` | 汎用符号付き trunc |
| `truncToIntU` | `float N → Option (BitVec M)` | 汎用符号なし trunc |
| `truncF32ToI32S` | `F32 → Option I32` | f32 → i32（符号付き） |
| `truncF32ToI32U` | `F32 → Option I32` | f32 → i32（符号なし） |
| `truncF64ToI32S` | `F64 → Option I32` | f64 → i32（符号付き） |
| `truncF64ToI32U` | `F64 → Option I32` | f64 → i32（符号なし） |
| `truncF32ToI64S` | `F32 → Option I64` | f32 → i64（符号付き） |
| `truncF32ToI64U` | `F32 → Option I64` | f32 → i64（符号なし） |
| `truncF64ToI64S` | `F64 → Option I64` | f64 → i64（符号付き） |
| `truncF64ToI64U` | `F64 → Option I64` | f64 → i64（符号なし） |

---

## Conversion TruncSat

> **ソース**: `WasmNum/Numerics/Conversion/TruncSat.lean`

飽和変換 — NaN→0、-Inf→min、+Inf→max、範囲外→クランプ：

| 関数 | 変換 | 説明 |
|------|------|------|
| `truncSatToIntS` | `float N → BitVec M` | 汎用符号付き飽和 trunc |
| `truncSatToIntU` | `float N → BitVec M` | 汎用符号なし飽和 trunc |
| `truncSatF32ToI32S` | `F32 → I32` | f32 → i32（符号付き、飽和） |
| `truncSatF32ToI32U` | `F32 → I32` | f32 → i32（符号なし、飽和） |
| `truncSatF64ToI32S` | `F64 → I32` | 8つの組み合わせすべて同様のパターン |
| ... | ... | ... |

---

## Conversion PromoteDemote

> **ソース**: `WasmNum/Numerics/Conversion/PromoteDemote.lean`

| 関数 | シグネチャ | 戻り値 | 説明 |
|------|----------|-------|------|
| `promoteF32` | `F32 → Set F64` | `Set` | f32 → f64（正確、NaN canonical/arithmetic） |
| `demoteF64` | `F64 → Set F32` | `Set` | f64 → f32（非可逆、丸めの可能性、NaN 処理） |

---

## Conversion ConvertIntFloat

> **ソース**: `WasmNum/Numerics/Conversion/ConvertIntFloat.lean`

| 関数 | 変換 | 説明 |
|------|------|------|
| `convertI32SToF32` | `I32 → F32` | 符号付き i32 → f32（偶数丸め） |
| `convertI32UToF32` | `I32 → F32` | 符号なし i32 → f32 |
| `convertI32SToF64` | `I32 → F64` | 符号付き i32 → f64（正確） |
| `convertI32UToF64` | `I32 → F64` | 符号なし i32 → f64（正確） |
| `convertI64SToF32` | `I64 → F32` | 符号付き i64 → f32 |
| `convertI64UToF32` | `I64 → F32` | 符号なし i64 → f32 |
| `convertI64SToF64` | `I64 → F64` | 符号付き i64 → f64 |
| `convertI64UToF64` | `I64 → F64` | 符号なし i64 → f64 |

---

## Conversion Reinterpret

> **ソース**: `WasmNum/Numerics/Conversion/Reinterpret.lean`

| 関数 | シグネチャ | 説明 |
|------|----------|------|
| `reinterpretF32AsI32` | `F32 → I32` | 恒等（同じ BitVec 32） |
| `reinterpretI32AsF32` | `I32 → F32` | 恒等 |
| `reinterpretF64AsI64` | `F64 → I64` | 恒等（同じ BitVec 64） |
| `reinterpretI64AsF64` | `I64 → F64` | 恒等 |

整数と浮動小数点は同じ `BitVec N` 表現を共有するため、これらは no-op。

---

## Conversion IntWidth

> **ソース**: `WasmNum/Numerics/Conversion/IntWidth.lean`

| 関数 | シグネチャ | 説明 |
|------|----------|------|
| `wrapI64` | `I64 → I32` | 下位32ビットに切り捨て |
| `extendI32S` | `I32 → I64` | i32 を i64 に符号拡張 |
| `extendI32U` | `I32 → I64` | i32 を i64 にゼロ拡張 |
| `extendI32From8S` | `I32 → I32` | 下位8ビットを符号拡張 |
| `extendI32From16S` | `I32 → I32` | 下位16ビットを符号拡張 |
| `extendI64From8S` | `I64 → I64` | 下位8ビットを符号拡張 |
| `extendI64From16S` | `I64 → I64` | 下位16ビットを符号拡張 |
| `extendI64From32S` | `I64 → I64` | 下位32ビットを符号拡張 |

## 関連ドキュメント

- [Foundation API](foundation.md)
- [SIMD API](simd.md) — スカラー操作をレーン単位で使用
- [Integration API](integration.md) — 決定論的ラッパー
- [ADR-003: Non-determinism as Sets](../../design/adr/0003-nondeterminism-as-sets.md)
- [English Version](../../../en/reference/api/numerics.md)
