# Memory APIリファレンス

> **モジュール**: `WasmNum.Memory`
> **ソース**: `WasmNum/Memory/`

## ページモデル

> **ソース**: `WasmNum/Memory/Core/Page.lean`

| 定義 | 値 | 説明 |
|-----|-----|------|
| `pageSize` | `65536` | Wasm ページサイズ：64 KiB |
| `maxPages 32` | `65536` | Memory32 の最大ページ数（4 GiB） |
| `maxPages 64` | `281474976710656` | Memory64 の最大ページ数（2^48; 16 EiB） |

**定理**: `pageSize_pos`, `maxPages_32`, `maxPages_64`

---

## FlatMemory

> **ソース**: `WasmNum/Memory/Core/FlatMemory.lean`

```lean
structure FlatMemory (addrWidth : Nat) where
  data      : ByteArray
  pageCount : Nat
  maxLimit  : Option Nat
  inv_dataSize : data.size = pageCount * pageSize
  inv_maxValid : ∀ max, maxLimit = some max → pageCount ≤ max
  inv_addrFits : pageCount * pageSize ≤ 2 ^ addrWidth
  inv_maxFits  : ∀ max, maxLimit = some max → max * pageSize ≤ 2 ^ addrWidth
```

| エイリアス | 定義 |
|----------|------|
| `Memory32` | `FlatMemory 32` |
| `Memory64` | `FlatMemory 64` |

### 構築

| 関数 | シグネチャ | 説明 |
|------|----------|------|
| `FlatMemory.empty` | `(addrWidth : Nat) → (maxLimit : Option Nat) → FlatMemory addrWidth` | 0ページメモリを作成 |
| `Memory32.empty` | `Memory32` | 空の32ビットメモリ |
| `Memory64.empty` | `Memory64` | 空の64ビットメモリ |

### 低レベルアクセス

| 関数 | シグネチャ | 説明 |
|------|----------|------|
| `readByte` | `FlatMemory addrWidth → Nat → Option (BitVec 8)` | 1バイト読み込み |
| `writeByte` | `FlatMemory addrWidth → Nat → BitVec 8 → Option (FlatMemory addrWidth)` | 1バイト書き込み |
| `readLittleEndian` | `FlatMemory addrWidth → Nat → (N : Nat) → Option (BitVec N)` | Nビット読み込み（LE） |
| `writeLittleEndian` | `FlatMemory addrWidth → Nat → (N : Nat) → BitVec N → Option (FlatMemory addrWidth)` | Nビット書き込み（LE） |

**定理**: `readByte_writeByte_same`, `readByte_writeByte_ne`

---

## Address

> **ソース**: `WasmNum/Memory/Core/Address.lean`

| 関数 | シグネチャ | 説明 |
|------|----------|------|
| `effectiveAddr` | `BitVec addrWidth → Nat → Option (BitVec addrWidth)` | `base + offset`、オーバーフロー時 none |

**定理**: `effectiveAddr_toNat`

---

## Bounds

> **ソース**: `WasmNum/Memory/Core/Bounds.lean`

| 関数 | シグネチャ | 説明 |
|------|----------|------|
| `inBounds` | `FlatMemory addrWidth → BitVec addrWidth → Nat → Prop` | アクセスが範囲内 |
| `inBoundsB` | `... → Bool` | 決定可能版 |
| `effectiveInBounds` | `FlatMemory addrWidth → BitVec addrWidth → Nat → Nat → Prop` | アドレス + 境界検査の複合 |
| `effectiveInBoundsB` | `... → Bool` | 決定可能版 |

---

## Load Scalar

> **ソース**: `WasmNum/Memory/Load/Scalar.lean`

| 関数 | シグネチャ | 説明 |
|------|----------|------|
| `loadN` | `FlatMemory addrWidth → BitVec addrWidth → (N : Nat) → Option (BitVec N)` | 汎用 Nビットロード |
| `i32Load` | `... → Option I32` | 32ビット整数ロード |
| `i64Load` | `... → Option I64` | 64ビット整数ロード |
| `f32Load` | `... → Option F32` | 32ビット浮動小数点ロード |
| `f64Load` | `... → Option F64` | 64ビット浮動小数点ロード |

---

## Load Packed

> **ソース**: `WasmNum/Memory/Load/Packed.lean`

符号/ゼロ拡張付きサブ幅ロード：

| 関数 | ロード幅 | 拡張先 | 拡張方式 |
|------|:-------:|:------:|---------|
| `i32Load8S` / `i32Load8U` | 8ビット | 32 | 符号付き / 符号なし |
| `i32Load16S` / `i32Load16U` | 16ビット | 32 | 符号付き / 符号なし |
| `i64Load8S` / `i64Load8U` | 8ビット | 64 | 符号付き / 符号なし |
| `i64Load16S` / `i64Load16U` | 16ビット | 64 | 符号付き / 符号なし |
| `i64Load32S` / `i64Load32U` | 32ビット | 64 | 符号付き / 符号なし |

---

## Load SIMD

> **ソース**: `WasmNum/Memory/Load/SIMD.lean`

| 関数 | 説明 |
|------|------|
| `v128Load` | 128ビット全体ロード |
| `v128Load8x8S` / `v128Load8x8U` | 8バイトロード、i16x8 に拡張 |
| `v128Load16x4S` / `v128Load16x4U` | 4ハーフワードロード、i32x4 に拡張 |
| `v128Load32x2S` / `v128Load32x2U` | 2ワードロード、i64x2 に拡張 |
| `v128Load8Splat` / `v128Load16Splat` / `v128Load32Splat` / `v128Load64Splat` | ロードして全レーンに複製 |
| `v128Load32Zero` / `v128Load64Zero` | 下位レーンにロード、残りゼロ |
| `v128Load8Lane` / `v128Load16Lane` / `v128Load32Lane` / `v128Load64Lane` | 特定レーンにロード |

---

## Store Scalar

> **ソース**: `WasmNum/Memory/Store/Scalar.lean`

| 関数 | シグネチャ | 説明 |
|------|----------|------|
| `storeN` | `FlatMemory addrWidth → BitVec addrWidth → BitVec N → Option (FlatMemory addrWidth)` | 汎用 Nビットストア |
| `i32Store` | `... → I32 → Option (FlatMemory addrWidth)` | 32ビットストア |
| `i64Store` | `... → I64 → ...` | 64ビットストア |
| `f32Store` / `f64Store` | `... → F32/F64 → ...` | 浮動小数点ストア |

---

## Store Packed

> **ソース**: `WasmNum/Memory/Store/Packed.lean`

| 関数 | ストア幅 | 説明 |
|------|:-------:|------|
| `i32Store8` | 下位8ビット | 切り捨て i32 ストア |
| `i32Store16` | 下位16ビット | 切り捨て i32 ストア |
| `i64Store8` | 下位8ビット | 切り捨て i64 ストア |
| `i64Store16` | 下位16ビット | 切り捨て i64 ストア |
| `i64Store32` | 下位32ビット | 切り捨て i64 ストア |

---

## Store SIMD

> **ソース**: `WasmNum/Memory/Store/SIMD.lean`

| 関数 | 説明 |
|------|------|
| `v128Store` | 128ビット全体ストア |
| `v128Store8Lane` / `v128Store16Lane` / `v128Store32Lane` / `v128Store64Lane` | 特定レーンをストア |

---

## memory.size

> **ソース**: `WasmNum/Memory/Ops/Size.lean`

| 関数 | シグネチャ | 説明 |
|------|----------|------|
| `memorySize` | `FlatMemory addrWidth → Nat` | 現在のページ数を返す |

---

## memory.grow

> **ソース**: `WasmNum/Memory/Ops/Grow.lean`

### `GrowResult`

```lean
inductive GrowResult (addrWidth : Nat) where
  | success : FlatMemory addrWidth → Nat → GrowResult addrWidth
  | failure : GrowResult addrWidth
```

### 仕様レベル（非決定論的）

| 関数 | シグネチャ | 説明 |
|------|----------|------|
| `growSpec` | `FlatMemory addrWidth → Nat → Set (GrowResult addrWidth)` | 仕様で許容される結果セット |

**定理**: `growSpec_failure_mem` — failure は常に許容セットに含まれる。

### 決定論的

```lean
class GrowthPolicy (addrWidth : Nat) where
  chooseGrow     : FlatMemory addrWidth → Nat → GrowResult addrWidth
  chooseGrow_mem : ∀ mem deltaPages, chooseGrow mem deltaPages ∈ growSpec mem deltaPages
```

| 関数 | シグネチャ | 説明 |
|------|----------|------|
| `growExec` | `[GrowthPolicy addrWidth] → FlatMemory addrWidth → Nat → GrowResult addrWidth` | 決定論的 grow |

---

## memory.fill

> **ソース**: `WasmNum/Memory/Ops/Fill.lean`

| 関数 | シグネチャ | 説明 |
|------|----------|------|
| `fill` | `FlatMemory addrWidth → BitVec addrWidth → BitVec 8 → BitVec addrWidth → Option (FlatMemory addrWidth)` | `dst` から `len` バイトを `val` で埋める。OOB で none。 |

---

## memory.copy

> **ソース**: `WasmNum/Memory/Ops/Copy.lean`

| 関数 | シグネチャ | 説明 |
|------|----------|------|
| `copy` | `FlatMemory addrWidth → BitVec addrWidth → BitVec addrWidth → BitVec addrWidth → Option (FlatMemory addrWidth)` | `src` から `dst` へ `len` バイトコピー。重複安全（方向自動選択）。OOB で none。 |

---

## memory.init

> **ソース**: `WasmNum/Memory/Ops/Init.lean`

| 関数 | シグネチャ | 説明 |
|------|----------|------|
| `init` | `FlatMemory addrWidth → BitVec addrWidth → DataSegment → Nat → Nat → Option (FlatMemory addrWidth)` | データセグメントからメモリへコピー。セグメント破棄済みまたは OOB で none。 |

---

## DataDrop

> **ソース**: `WasmNum/Memory/Ops/DataDrop.lean`

```lean
inductive DataSegment where
  | available : ByteArray → DataSegment
  | dropped   : DataSegment
```

| 関数 | シグネチャ | 説明 |
|------|----------|------|
| `dataDrop` | `DataSegment → DataSegment` | 常に `.dropped` を返す |
| `DataSegment.bytes` | `DataSegment → Option ByteArray` | 利用可能ならバイトを取得 |
| `DataSegment.isDropped` | `DataSegment → Bool` | 破棄済みか確認 |

---

## MultiMemory

> **ソース**: `WasmNum/Memory/MultiMemory.lean`

```lean
inductive MemoryInstance where
  | mem32 : FlatMemory 32 → MemoryInstance
  | mem64 : FlatMemory 64 → MemoryInstance

inductive MemoryAddress where
  | addr32 : BitVec 32 → MemoryAddress
  | addr64 : BitVec 64 → MemoryAddress

structure MemoryStore where
  memories : Array MemoryInstance
```

| 関数 | シグネチャ | 説明 |
|------|----------|------|
| `MemoryStore.get` | `MemoryStore → Nat → Option MemoryInstance` | インデックスでメモリを取得 |
| `MemoryStore.set` | `MemoryStore → Nat → MemoryInstance → Option MemoryStore` | インデックスでメモリを設定 |

---

## Memory64

> **ソース**: `WasmNum/Memory/Memory64.lean`

64ビットアドレス空間のサポート。`Memory64 = FlatMemory 64`、`maxPages 64 = 2^48`。

## 関連ドキュメント

- [Foundation API](foundation.md) — コア型
- [SIMD API](simd.md) — SIMD ロード/ストア
- [Integration API](integration.md) — 命令レベルラッパー
- [アーキテクチャ：データフロー](../../architecture/data-flow.md) — ロード/ストアフロー図
- [ADR-005: Parameterized Address Width](../../design/adr/0005-flatmemory-parameterized-address-width.md)
- [English Version](../../../en/reference/api/memory.md)
