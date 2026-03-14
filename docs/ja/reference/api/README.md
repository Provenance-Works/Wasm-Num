# APIリファレンス

> **対象読者**: 開発者

wasm-num の完全な API ドキュメント。アーキテクチャレイヤー別に整理。

## レイヤー別モジュール

### レイヤー 0: Foundation

| モジュール | インポートパス | ドキュメント |
|-----------|-------------|------------|
| Types | `WasmNum.Foundation.Types` | [foundation.md](foundation.md) |
| BitVecOps | `WasmNum.Foundation.BitVec` | [foundation.md](foundation.md#bitvecops) |
| WasmFloat | `WasmNum.Foundation.WasmFloat` | [foundation.md](foundation.md#wasmfloat-型クラス) |
| WasmFloat Default | `WasmNum.Foundation.WasmFloat.Default` | [foundation.md](foundation.md#wasmfloat-デフォルトスタブ) |
| Profiles | `WasmNum.Foundation.Profile` | [foundation.md](foundation.md#プロファイル) |
| Defs | `WasmNum.Foundation.Defs` | [foundation.md](foundation.md#基本定義) |

### レイヤー 1: Numerics

| モジュール | インポートパス | ドキュメント |
|-----------|-------------|------------|
| NaN Propagation | `WasmNum.Numerics.NaN.Propagation` | [numerics.md](numerics.md#nan-propagation) |
| NaN Deterministic | `WasmNum.Numerics.NaN.Deterministic` | [numerics.md](numerics.md#nan-deterministic) |
| Float MinMax | `WasmNum.Numerics.Float.MinMax` | [numerics.md](numerics.md#float-minmax) |
| Float Rounding | `WasmNum.Numerics.Float.Rounding` | [numerics.md](numerics.md#float-rounding) |
| Float Sign | `WasmNum.Numerics.Float.Sign` | [numerics.md](numerics.md#float-sign) |
| Float Compare | `WasmNum.Numerics.Float.Compare` | [numerics.md](numerics.md#float-compare) |
| Float PseudoMinMax | `WasmNum.Numerics.Float.PseudoMinMax` | [numerics.md](numerics.md#float-pseudominmax) |
| Integer Arithmetic | `WasmNum.Numerics.Integer.Arithmetic` | [numerics.md](numerics.md#integer-arithmetic) |
| Integer Bitwise | `WasmNum.Numerics.Integer.Bitwise` | [numerics.md](numerics.md#integer-bitwise) |
| Integer Shift | `WasmNum.Numerics.Integer.Shift` | [numerics.md](numerics.md#integer-shift) |
| Integer Compare | `WasmNum.Numerics.Integer.Compare` | [numerics.md](numerics.md#integer-compare) |
| Integer Bits | `WasmNum.Numerics.Integer.Bits` | [numerics.md](numerics.md#integer-bits) |
| Integer Ext | `WasmNum.Numerics.Integer.Ext` | [numerics.md](numerics.md#integer-ext) |
| Integer Saturating | `WasmNum.Numerics.Integer.Saturating` | [numerics.md](numerics.md#integer-saturating) |
| Integer MinMax | `WasmNum.Numerics.Integer.MinMax` | [numerics.md](numerics.md#integer-minmax) |
| Integer Misc | `WasmNum.Numerics.Integer.Misc` | [numerics.md](numerics.md#integer-misc) |
| Integer Bitselect | `WasmNum.Numerics.Integer.Bitselect` | [numerics.md](numerics.md#integer-bitselect) |
| TruncPartial | `WasmNum.Numerics.Conversion.TruncPartial` | [numerics.md](numerics.md#conversion-truncpartial) |
| TruncSat | `WasmNum.Numerics.Conversion.TruncSat` | [numerics.md](numerics.md#conversion-truncsat) |
| PromoteDemote | `WasmNum.Numerics.Conversion.PromoteDemote` | [numerics.md](numerics.md#conversion-promotedemote) |
| ConvertIntFloat | `WasmNum.Numerics.Conversion.ConvertIntFloat` | [numerics.md](numerics.md#conversion-convertintfloat) |
| Reinterpret | `WasmNum.Numerics.Conversion.Reinterpret` | [numerics.md](numerics.md#conversion-reinterpret) |
| IntWidth | `WasmNum.Numerics.Conversion.IntWidth` | [numerics.md](numerics.md#conversion-intwidth) |

### レイヤー 2: SIMD

| モジュール | インポートパス | ドキュメント |
|-----------|-------------|------------|
| V128 Shape | `WasmNum.SIMD.V128.Shape` | [simd.md](simd.md#v128-shape) |
| V128 Type | `WasmNum.SIMD.V128.Type` | [simd.md](simd.md#v128-type) |
| V128 Lanes | `WasmNum.SIMD.V128.Lanes` | [simd.md](simd.md#v128-lanes) |
| Ops Bitwise | `WasmNum.SIMD.Ops.Bitwise` | [simd.md](simd.md#ops-bitwise) |
| Ops IntLanewise | `WasmNum.SIMD.Ops.IntLanewise` | [simd.md](simd.md#ops-intlanewise) |
| Ops FloatLanewise | `WasmNum.SIMD.Ops.FloatLanewise` | [simd.md](simd.md#ops-floatlanewise) |
| Ops Bitmask | `WasmNum.SIMD.Ops.Bitmask` | [simd.md](simd.md#ops-bitmask) |
| Ops Narrow | `WasmNum.SIMD.Ops.Narrow` | [simd.md](simd.md#ops-narrow) |
| Ops Extend | `WasmNum.SIMD.Ops.Extend` | [simd.md](simd.md#ops-extend) |
| Ops Dot | `WasmNum.SIMD.Ops.Dot` | [simd.md](simd.md#ops-dot) |
| Ops Swizzle | `WasmNum.SIMD.Ops.Swizzle` | [simd.md](simd.md#ops-swizzle) |
| Ops Shuffle | `WasmNum.SIMD.Ops.Shuffle` | [simd.md](simd.md#ops-shuffle) |
| Ops SplatExtractReplace | `WasmNum.SIMD.Ops.SplatExtractReplace` | [simd.md](simd.md#ops-splatextractreplace) |
| Ops Convert | `WasmNum.SIMD.Ops.Convert` | [simd.md](simd.md#ops-convert) |
| Relaxed Madd | `WasmNum.SIMD.Relaxed.Madd` | [simd.md](simd.md#relaxed-madd) |
| Relaxed MinMax | `WasmNum.SIMD.Relaxed.MinMax` | [simd.md](simd.md#relaxed-minmax) |
| Relaxed Swizzle | `WasmNum.SIMD.Relaxed.Swizzle` | [simd.md](simd.md#relaxed-swizzle) |
| Relaxed Trunc | `WasmNum.SIMD.Relaxed.Trunc` | [simd.md](simd.md#relaxed-trunc) |
| Relaxed Laneselect | `WasmNum.SIMD.Relaxed.Laneselect` | [simd.md](simd.md#relaxed-laneselect) |
| Relaxed Dot | `WasmNum.SIMD.Relaxed.Dot` | [simd.md](simd.md#relaxed-dot) |
| Relaxed Q15 | `WasmNum.SIMD.Relaxed.Q15` | [simd.md](simd.md#relaxed-q15) |

### レイヤー 3: Memory

| モジュール | インポートパス | ドキュメント |
|-----------|-------------|------------|
| Page | `WasmNum.Memory.Core.Page` | [memory.md](memory.md#page-model) |
| FlatMemory | `WasmNum.Memory.Core.FlatMemory` | [memory.md](memory.md#flatmemory) |
| Address | `WasmNum.Memory.Core.Address` | [memory.md](memory.md#address) |
| Bounds | `WasmNum.Memory.Core.Bounds` | [memory.md](memory.md#bounds) |
| Load Scalar | `WasmNum.Memory.Load.Scalar` | [memory.md](memory.md#load-scalar) |
| Load Packed | `WasmNum.Memory.Load.Packed` | [memory.md](memory.md#load-packed) |
| Load SIMD | `WasmNum.Memory.Load.SIMD` | [memory.md](memory.md#load-simd) |
| Store Scalar | `WasmNum.Memory.Store.Scalar` | [memory.md](memory.md#store-scalar) |
| Store Packed | `WasmNum.Memory.Store.Packed` | [memory.md](memory.md#store-packed) |
| Store SIMD | `WasmNum.Memory.Store.SIMD` | [memory.md](memory.md#store-simd) |
| Size | `WasmNum.Memory.Ops.Size` | [memory.md](memory.md#memorysize) |
| Grow | `WasmNum.Memory.Ops.Grow` | [memory.md](memory.md#memorygrow) |
| Fill | `WasmNum.Memory.Ops.Fill` | [memory.md](memory.md#memoryfill) |
| Copy | `WasmNum.Memory.Ops.Copy` | [memory.md](memory.md#memorycopy) |
| Init | `WasmNum.Memory.Ops.Init` | [memory.md](memory.md#memoryinit) |
| DataDrop | `WasmNum.Memory.Ops.DataDrop` | [memory.md](memory.md#datadrop) |
| MultiMemory | `WasmNum.Memory.MultiMemory` | [memory.md](memory.md#multimemory) |
| Memory64 | `WasmNum.Memory.Memory64` | [memory.md](memory.md#memory64) |

### レイヤー 4: Integration

| モジュール | インポートパス | ドキュメント |
|-----------|-------------|------------|
| Profile | `WasmNum.Integration.Profile` | [integration.md](integration.md#deterministicwasmprofile) |
| Runtime | `WasmNum.Integration.Runtime` | [integration.md](integration.md#runtime-wrappers) |

## 関連ドキュメント

- [アーキテクチャ](../../architecture/) — システム設計
- [用語集](../glossary.md) — 用語の定義
- [English Version](../../../en/reference/api/)
