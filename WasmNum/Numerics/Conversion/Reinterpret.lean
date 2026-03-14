import WasmNum.Foundation

/-!
# Reinterpret Conversions

Bit-pattern reinterpretation between integer and float types.
These are identity functions since I32/F32 and I64/F64 share
the same `BitVec N` representation (ADR-002).

Wasm spec: Section 4.4 "Conversions"
- FR-205: reinterpret
-/

namespace WasmNum.Numerics.Conversion

open WasmNum

/-- i32.reinterpret_f32: reinterpret f32 bits as i32.
    Identity function — same BitVec 32 representation.
    Wasm spec: `i32.reinterpret_f32` -/
def reinterpretF32AsI32 (v : F32) : I32 := v

/-- f32.reinterpret_i32: reinterpret i32 bits as f32.
    Identity function — same BitVec 32 representation.
    Wasm spec: `f32.reinterpret_i32` -/
def reinterpretI32AsF32 (v : I32) : F32 := v

/-- i64.reinterpret_f64: reinterpret f64 bits as i64.
    Identity function — same BitVec 64 representation.
    Wasm spec: `i64.reinterpret_f64` -/
def reinterpretF64AsI64 (v : F64) : I64 := v

/-- f64.reinterpret_i64: reinterpret i64 bits as f64.
    Identity function — same BitVec 64 representation.
    Wasm spec: `f64.reinterpret_i64` -/
def reinterpretI64AsF64 (v : I64) : F64 := v

end WasmNum.Numerics.Conversion
