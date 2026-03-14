-- Root import for Wasm numerics definitions (definitions only, no proofs).
-- Import `WasmNum` to get all definitions.
-- For proofs, import specific `WasmNum.Proofs.*` modules.

-- Layer 0: Foundation
import WasmNum.Foundation

-- Layer 1: Numerics — NaN
import WasmNum.Numerics.NaN.Propagation
import WasmNum.Numerics.NaN.Deterministic

-- Layer 1: Numerics — Float (Phase 4)
import WasmNum.Numerics.Float.MinMax
import WasmNum.Numerics.Float.Rounding
import WasmNum.Numerics.Float.Sign
import WasmNum.Numerics.Float.Compare
import WasmNum.Numerics.Float.PseudoMinMax

-- Layer 1: Numerics — Conversion (Phase 5)
import WasmNum.Numerics.Conversion.TruncPartial
import WasmNum.Numerics.Conversion.TruncSat
import WasmNum.Numerics.Conversion.PromoteDemote
import WasmNum.Numerics.Conversion.ConvertIntFloat
import WasmNum.Numerics.Conversion.Reinterpret
import WasmNum.Numerics.Conversion.IntWidth

-- Layer 1: Numerics — Integer (Phase 5.5)
import WasmNum.Numerics.Integer.Arithmetic
import WasmNum.Numerics.Integer.Bitwise
import WasmNum.Numerics.Integer.Shift
import WasmNum.Numerics.Integer.Compare
import WasmNum.Numerics.Integer.Bits
import WasmNum.Numerics.Integer.Ext
import WasmNum.Numerics.Integer.Saturating
import WasmNum.Numerics.Integer.MinMax
import WasmNum.Numerics.Integer.Misc
import WasmNum.Numerics.Integer.Bitselect

-- Layer 2: SIMD — Core (Phase 6)
import WasmNum.SIMD.V128.Shape
import WasmNum.SIMD.V128.Type
import WasmNum.SIMD.V128.Lanes
import WasmNum.SIMD.Ops.Bitwise

-- Layer 2: SIMD — Integer Ops (Phase 7)
import WasmNum.SIMD.Ops.IntLanewise
import WasmNum.SIMD.Ops.Bitmask
import WasmNum.SIMD.Ops.Narrow
import WasmNum.SIMD.Ops.Extend
import WasmNum.SIMD.Ops.Dot
import WasmNum.SIMD.Ops.Swizzle
import WasmNum.SIMD.Ops.Shuffle
import WasmNum.SIMD.Ops.SplatExtractReplace

-- Layer 2: SIMD — Float Ops (Phase 8)
import WasmNum.SIMD.Ops.FloatLanewise
import WasmNum.SIMD.Ops.Convert

-- Layer 2: SIMD — Relaxed Ops (Phase 9)
import WasmNum.SIMD.Relaxed.Madd
import WasmNum.SIMD.Relaxed.MinMax
import WasmNum.SIMD.Relaxed.Swizzle
import WasmNum.SIMD.Relaxed.Trunc
import WasmNum.SIMD.Relaxed.Laneselect
import WasmNum.SIMD.Relaxed.Dot
import WasmNum.SIMD.Relaxed.Q15

-- Integration (Phase 9)
import WasmNum.Integration.Profile

-- Layer 3: Memory — Core (Phase 10)
import WasmNum.Memory.Core.Page
import WasmNum.Memory.Core.FlatMemory
import WasmNum.Memory.Core.Address
import WasmNum.Memory.Core.Bounds
import WasmNum.Memory.MultiMemory
import WasmNum.Memory.Ops.DataDrop

-- Layer 3: Memory — Load/Store (Phase 11)
import WasmNum.Memory.Load.Scalar
import WasmNum.Memory.Load.Packed
import WasmNum.Memory.Load.SIMD
import WasmNum.Memory.Store.Scalar
import WasmNum.Memory.Store.Packed
import WasmNum.Memory.Store.SIMD

-- Layer 3: Memory — Operations (Phase 12)
import WasmNum.Memory.Ops.Size
import WasmNum.Memory.Ops.Grow
import WasmNum.Memory.Ops.Fill
import WasmNum.Memory.Ops.Copy
import WasmNum.Memory.Ops.Init
import WasmNum.Memory.Memory64

-- Layer 4: Integration — Runtime (Phase 13)
import WasmNum.Integration.Runtime
