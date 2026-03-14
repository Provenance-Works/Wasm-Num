-- Root import for completed wasm-num proofs.
-- Import `WasmNumProofs` to get current proof modules together with definitions.

import WasmNum
import WasmNum.Proofs.Numerics.NaN.Propagation
import WasmNum.Proofs.Numerics.NaN.Deterministic

-- Phase 4: Float proofs
import WasmNum.Proofs.Numerics.Float.MinMax

-- Phase 5: Conversion proofs
import WasmNum.Proofs.Numerics.Conversion.TruncPartial
import WasmNum.Proofs.Numerics.Conversion.TruncSat

-- Phase 6: SIMD proofs
import WasmNum.Proofs.SIMD.V128.LanesRoundtrip
import WasmNum.Proofs.SIMD.V128.LanesBijection

-- Phase 7: SIMD Integer Ops proofs
import WasmNum.Proofs.SIMD.Ops.Lanewise

-- Phase 9: Relaxed SIMD proofs
import WasmNum.Proofs.SIMD.Relaxed.DetIsSpecialCase

-- Phase 11: Memory Bounds and Load/Store proofs
import WasmNum.Proofs.Memory.Bounds
import WasmNum.Proofs.Memory.LoadStore

-- Phase 12: Memory Ops proofs
import WasmNum.Proofs.Memory.Grow
import WasmNum.Proofs.Memory.Fill
import WasmNum.Proofs.Memory.Copy
