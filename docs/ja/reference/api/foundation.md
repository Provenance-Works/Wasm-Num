# Foundation APIリファレンス

> **モジュール**: `WasmNum.Foundation`
> **ソース**: `WasmNum/Foundation/`

## 型

> **ソース**: `WasmNum/Foundation/Types.lean`

すべての WebAssembly 数値型は `BitVec N` のエイリアスです：

```lean
abbrev I32   := BitVec 32
abbrev I64   := BitVec 64
abbrev F32   := BitVec 32
abbrev F64   := BitVec 64
abbrev V128  := BitVec 128
abbrev Byte  := BitVec 8
abbrev Addr32 := BitVec 32
abbrev Addr64 := BitVec 64
```

> **Note:** `I32` と `F32` は同じ型（`BitVec 32`）です。解釈はどの操作を適用するかによって決まります。

## 基本定義

> **ソース**: `WasmNum/Foundation/Defs.lean`

```lean
def pageSize : Nat := 65536   -- Wasm ページサイズ：64 KiB
```

## BitVecOps

> **ソース**: `WasmNum/Foundation/BitVec.lean`
> **名前空間**: `BitVecOps`

### `getByte`

```lean
def getByte (v : BitVec N) (i : Nat) : Byte
```

リトルエンディアン順で `BitVec` から i 番目のバイトを抽出（LSB = バイト 0）。

### `toLittleEndian`

```lean
def toLittleEndian (v : BitVec N) : Vector Byte (N / 8)
```

`BitVec` をリトルエンディアン順のバイトに分解。

### `fromLittleEndian`

```lean
def fromLittleEndian (bytes : Vector Byte n) : BitVec (n * 8)
```

リトルエンディアン順のバイトを `BitVec` に再構成。

### `toBytes` / `fromBytes`

`toLittleEndian` / `fromLittleEndian` のエイリアス。WebAssembly はリトルエンディアンのみを使用。

### `signExtend`

```lean
def signExtend (v : BitVec m) : BitVec N
```

幅 `m` から幅 `N` へ符号拡張。`m ≤ N` の証明が必要。

### `zeroExtend`

```lean
def zeroExtend (v : BitVec m) : BitVec N
```

幅 `m` から幅 `N` へゼロ拡張。`m ≤ N` の証明が必要。

### `extractBits`

```lean
def extractBits (v : BitVec N) (lo width : Nat) : BitVec width
```

`lo` から始まる指定 `width` のビット範囲を抽出。

### `concat`

```lean
def concat (a : BitVec m) (b : BitVec n) : BitVec (m + n)
```

`BitVec.append` の連結ラッパー。

---

## WasmFloat 型クラス

> **ソース**: `WasmNum/Foundation/WasmFloat.lean`

IEEE 754 浮動小数点操作の中心的抽象化（ADR-001）。

```lean
class WasmFloat (N : Nat) where
```

### 分類述語

| メソッド | 型 | 説明 |
|---------|-----|------|
| `isNaN` | `BitVec N → Bool` | 任意の NaN ならば true |
| `isInfinite` | `BitVec N → Bool` | ±∞ ならば true |
| `isZero` | `BitVec N → Bool` | ±0 ならば true |
| `isNegative` | `BitVec N → Bool` | 符号ビット = 1 ならば true |
| `isSubnormal` | `BitVec N → Bool` | サブノーマルならば true |
| `isCanonicalNaN` | `BitVec N → Bool` | canonical NaN ならば true |
| `isArithmeticNaN` | `BitVec N → Bool` | quiet（arithmetic）NaN ならば true |
| `canonicalNaN` | `BitVec N` | 正の canonical NaN 定数 |

### 算術操作

すべて最近接偶数丸めを使用：

| メソッド | 型 | 説明 |
|---------|-----|------|
| `add` | `BitVec N → BitVec N → BitVec N` | 加算 |
| `sub` | `BitVec N → BitVec N → BitVec N` | 減算 |
| `mul` | `BitVec N → BitVec N → BitVec N` | 乗算 |
| `div` | `BitVec N → BitVec N → BitVec N` | 除算 |
| `sqrt` | `BitVec N → BitVec N` | 平方根 |
| `fma` | `BitVec N → BitVec N → BitVec N → BitVec N` | 融合積和演算 |

### 丸めプリミティブ

| メソッド | 型 | 説明 |
|---------|-----|------|
| `nearestInt` | `BitVec N → BitVec N` | 最近接偶数丸め |
| `ceilInt` | `BitVec N → BitVec N` | +∞ 方向への丸め |
| `floorInt` | `BitVec N → BitVec N` | -∞ 方向への丸め |
| `truncInt` | `BitVec N → BitVec N` | ゼロ方向への丸め |

### 比較

| メソッド | 型 | 説明 |
|---------|-----|------|
| `lt` | `BitVec N → BitVec N → Bool` | 小なり（NaN → false） |
| `le` | `BitVec N → BitVec N → Bool` | 以下（NaN → false） |
| `eq` | `BitVec N → BitVec N → Bool` | 等値（+0 == -0 → true、NaN → false） |

### 変換

| メソッド | 型 | 説明 |
|---------|-----|------|
| `truncToInt` | `BitVec N → Option Int` | 整数へ（NaN/Inf/オーバーフローで none） |
| `truncToNat` | `BitVec N → Option Nat` | 自然数へ（NaN/Inf/負で none） |
| `convertFromInt` | `Int → BitVec N` | 整数から（偶数丸め） |
| `convertFromNat` | `Nat → BitVec N` | 自然数から（偶数丸め） |

### その他

| メソッド | 型 | 説明 |
|---------|-----|------|
| `sign_bit` | `BitVec N → Bool` | MSB（符号ビット） |
| `payloadOverlap` | `BitVec N → BitVec N → Prop` | NaN ペイロードオーバーラップ関係 |

### 構造的証明

すべての `WasmFloat` インスタンスが提供する必要があるもの：

- `isNaN_canonicalNaN : isNaN canonicalNaN = true`
- `isCanonicalNaN_isNaN : ∀ v, isCanonicalNaN v = true → isNaN v = true`
- `isArithmeticNaN_isNaN : ∀ v, isArithmeticNaN v = true → isNaN v = true`

### コンパニオン型クラス

```lean
class WasmFloatPromote where
  promote : BitVec 32 → BitVec 64    -- f32 → f64（正確）

class WasmFloatDemote where
  demote : BitVec 64 → BitVec 32     -- f64 → f32（丸めの可能性あり）
```

---

## WasmFloat デフォルトスタブ

> **ソース**: `WasmNum/Foundation/WasmFloat/Default.lean`

テスト用の `WasmFloat 32` および `WasmFloat 64` インスタンスを提供。分類は正確（binary32/binary64 レイアウト）だが、算術と丸めはプレースホルダー値（canonical NaN）を返す。

> **Warning:** 本番用途には不適。適切な IEEE 754 ブリッジを使用してください。

---

## プロファイル

> **ソース**: `WasmNum/Foundation/Profile.lean`

### `NaNProfile`

```lean
structure NaNProfile where
  selectNaN : (N : Nat) → [WasmFloat N] → List (BitVec N) → BitVec N
  selectNaN_isNaN : ∀ N [WasmFloat N] inputs,
    WasmFloat.isNaN (selectNaN N inputs) = true
```

仕様許容セットから単一の NaN を選択。結果が常に有効な NaN であることの証明を保持。

### `RelaxedProfile`

```lean
structure RelaxedProfile where
  relaxedMaddImpl        : V128 → V128 → V128 → V128
  relaxedNmaddImpl       : V128 → V128 → V128 → V128
  relaxedMaddF64Impl     : V128 → V128 → V128 → V128
  relaxedNmaddF64Impl    : V128 → V128 → V128 → V128
  relaxedMinImpl32       : BitVec 32 → BitVec 32 → BitVec 32
  relaxedMaxImpl32       : BitVec 32 → BitVec 32 → BitVec 32
  relaxedMinImpl64       : BitVec 64 → BitVec 64 → BitVec 64
  relaxedMaxImpl64       : BitVec 64 → BitVec 64 → BitVec 64
  relaxedSwizzleImpl     : V128 → V128 → V128
  relaxedTruncF32x4SImpl : V128 → V128
  relaxedTruncF32x4UImpl : V128 → V128
  relaxedTruncF64x2SZeroImpl  : V128 → V128
  relaxedTruncF64x2UZeroImpl  : V128 → V128
  relaxedLaneselectImpl  : V128 → V128 → V128 → V128
  relaxedDotI8x16I7x16SImpl    : V128 → V128 → V128
  relaxedDotI8x16I7x16AddSImpl : V128 → V128 → V128 → V128
  relaxedQ15MulrSImpl    : V128 → V128 → V128
```

すべての relaxed SIMD 操作の決定論的実装。

### `WasmProfile`

```lean
structure WasmProfile where
  nanProfile     : NaNProfile
  relaxedProfile : RelaxedProfile
```

NaN 選択と relaxed SIMD 実装をバンドル。

## 関連ドキュメント

- [Numerics API](numerics.md)
- [アーキテクチャ：データモデル](../../architecture/data-model.md)
- [ADR-001: IEEE 754 Independence](../../design/adr/0001-typeclass-mediated-754-independence.md)
- [ADR-002: BitVec Universal Representation](../../design/adr/0002-bitvec-universal-representation.md)
- [用語集](../glossary.md)
- [English Version](../../../en/reference/api/foundation.md)
