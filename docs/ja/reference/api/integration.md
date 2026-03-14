# Integration APIリファレンス

> **モジュール**: `WasmNum.Integration`
> **ソース**: `WasmNum/Integration/`

## DeterministicWasmProfile

> **ソース**: `WasmNum/Integration/Profile.lean`

`WasmProfile` を拡張し、すべての決定論的選択が仕様許容セットに属することの証明付き：

```lean
structure DeterministicWasmProfile [WasmFloat 32] [WasmFloat 64] extends WasmProfile where
  -- NaN 選択
  selectNaN_mem : ∀ N [WasmFloat N] inputs,
    nanProfile.selectNaN N inputs ∈ nansN N inputs

  -- Relaxed SIMD メンバーシップ証明
  relaxedMadd_mem       : ∀ a b c, relaxedProfile.relaxedMaddImpl a b c ∈ Relaxed.madd Shape.f32x4 a b c
  relaxedNmadd_mem      : ∀ a b c, ...
  relaxedMaddF64_mem    : ∀ a b c, ...
  relaxedNmaddF64_mem   : ∀ a b c, ...
  relaxedMinF32_mem     : ∀ a b, ...
  relaxedMaxF32_mem     : ∀ a b, ...
  relaxedMinF64_mem     : ∀ a b, ...
  relaxedMaxF64_mem     : ∀ a b, ...
  relaxedSwizzle_mem    : ∀ v idx, ...
  relaxedTruncF32x4S_mem : ∀ v, ...
  relaxedTruncF32x4U_mem : ∀ v, ...
  relaxedTruncF64x2SZero_mem : ∀ v, ...
  relaxedTruncF64x2UZero_mem : ∀ v, ...
  relaxedLaneselect_mem : ∀ a b mask, ...
  relaxedDot_mem        : ∀ a b, ...
  relaxedDotAdd_mem     : ∀ a b acc, ...
  relaxedQ15MulrS_mem   : ∀ a b, ...
```

各フィールドは `∈ <Set返却関数>` の証明を保持し、決定論的実装が非決定論的仕様の有効な特殊化であることを保証。

---

## ランタイムラッパー

> **ソース**: `WasmNum/Integration/Runtime.lean`

実効アドレス計算、境界検査、ロード/ストア操作を合成する決定論的な命令レベルラッパー。

### スカラーロード命令

| 関数 | シグネチャ | 説明 |
|------|----------|------|
| `i32LoadInstr` | `FlatMemory addrWidth → BitVec addrWidth → Nat → Option I32` | `i32.load`（addr+offset+bounds） |
| `i64LoadInstr` | 同パターン | `i64.load` |
| `f32LoadInstr` | 同パターン | `f32.load` |
| `f64LoadInstr` | 同パターン | `f64.load` |
| `v128LoadInstr` | 同パターン | `v128.load` |

### スカラーストア命令

| 関数 | シグネチャ | 説明 |
|------|----------|------|
| `i32StoreInstr` | `FlatMemory addrWidth → BitVec addrWidth → Nat → I32 → Option (FlatMemory addrWidth)` | `i32.store` |
| `i64StoreInstr` | 同パターン | `i64.store` |
| `f32StoreInstr` | 同パターン | `f32.store` |
| `f64StoreInstr` | 同パターン | `f64.store` |
| `v128StoreInstr` | 同パターン | `v128.store` |

### パックドロード命令

| 関数 | ロード幅 | 拡張先 | 拡張方式 |
|------|:-------:|:------:|---------|
| `i32Load8SInstr` / `i32Load8UInstr` | 8ビット | 32 | 符号付き / 符号なし |
| `i32Load16SInstr` / `i32Load16UInstr` | 16ビット | 32 | 符号付き / 符号なし |
| `i64Load8SInstr` / `i64Load8UInstr` | 8ビット | 64 | 符号付き / 符号なし |
| `i64Load16SInstr` / `i64Load16UInstr` | 16ビット | 64 | 符号付き / 符号なし |
| `i64Load32SInstr` / `i64Load32UInstr` | 32ビット | 64 | 符号付き / 符号なし |

### パックドストア命令

| 関数 | 説明 |
|------|------|
| `i32Store8Instr` / `i32Store16Instr` | 切り捨て i32 ストア |
| `i64Store8Instr` / `i64Store16Instr` / `i64Store32Instr` | 切り捨て i64 ストア |

### メモリ命令

| 関数 | シグネチャ | 説明 |
|------|----------|------|
| `memoryGrowInstr` | `[GrowthPolicy addrWidth] → FlatMemory addrWidth → Nat → (Option (FlatMemory addrWidth), Int)` | Grow：(新メモリ, 旧ページ数) または (none, -1) を返す |
| `memorySizeInstr` | `FlatMemory addrWidth → Nat` | 現在のページ数 |
| `memoryFillInstr` | `FlatMemory addrWidth → BitVec addrWidth → BitVec 8 → BitVec addrWidth → Option (FlatMemory addrWidth)` | バイト埋め |
| `memoryCopyInstr` | `FlatMemory addrWidth → BitVec addrWidth → BitVec addrWidth → BitVec addrWidth → Option (FlatMemory addrWidth)` | バイトコピー（重複安全） |
| `memoryInitInstr` | `FlatMemory addrWidth → BitVec addrWidth → DataSegment → Nat → Nat → Option (FlatMemory addrWidth)` | データセグメントから初期化 |

## 関連ドキュメント

- [Foundation API](foundation.md) — プロファイルと型
- [Memory API](memory.md) — 基盤操作
- [アーキテクチャ：データフロー](../../architecture/data-flow.md) — ランタイムフロー図
- [設計原則](../../design/principles.md)
- [English Version](../../../en/reference/api/integration.md)
