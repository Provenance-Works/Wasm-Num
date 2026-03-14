import WasmNum.Foundation

/-!
# Integer to Float Conversions

Convert integer values to float (round-to-nearest, ties-to-even).
These are total functions (always succeed). All 8 Wasm variants.

Wasm spec: Section 4.4 "Conversions"
- FR-204: convert_u / convert_s
-/

namespace WasmNum.Numerics.Conversion

open WasmNum

/-- f32.convert_i32_s: signed i32 → f32.
    Wasm spec: `f32.convert_i32_s` -/
def convertI32SToF32 [WasmFloat 32] (v : I32) : F32 :=
  WasmFloat.convertFromInt v.toInt

/-- f32.convert_i32_u: unsigned i32 → f32.
    Wasm spec: `f32.convert_i32_u` -/
def convertI32UToF32 [WasmFloat 32] (v : I32) : F32 :=
  WasmFloat.convertFromNat v.toNat

/-- f32.convert_i64_s: signed i64 → f32.
    Wasm spec: `f32.convert_i64_s` -/
def convertI64SToF32 [WasmFloat 32] (v : I64) : F32 :=
  WasmFloat.convertFromInt v.toInt

/-- f32.convert_i64_u: unsigned i64 → f32.
    Wasm spec: `f32.convert_i64_u` -/
def convertI64UToF32 [WasmFloat 32] (v : I64) : F32 :=
  WasmFloat.convertFromNat v.toNat

/-- f64.convert_i32_s: signed i32 → f64.
    Wasm spec: `f64.convert_i32_s` -/
def convertI32SToF64 [WasmFloat 64] (v : I32) : F64 :=
  WasmFloat.convertFromInt v.toInt

/-- f64.convert_i32_u: unsigned i32 → f64.
    Wasm spec: `f64.convert_i32_u` -/
def convertI32UToF64 [WasmFloat 64] (v : I32) : F64 :=
  WasmFloat.convertFromNat v.toNat

/-- f64.convert_i64_s: signed i64 → f64.
    Wasm spec: `f64.convert_i64_s` -/
def convertI64SToF64 [WasmFloat 64] (v : I64) : F64 :=
  WasmFloat.convertFromInt v.toInt

/-- f64.convert_i64_u: unsigned i64 → f64.
    Wasm spec: `f64.convert_i64_u` -/
def convertI64UToF64 [WasmFloat 64] (v : I64) : F64 :=
  WasmFloat.convertFromNat v.toNat

end WasmNum.Numerics.Conversion
