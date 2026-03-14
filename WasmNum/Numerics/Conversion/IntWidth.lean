import WasmNum.Foundation

/-!
# Integer Width Conversions

Integer narrowing (wrap) and widening (extend) conversions.

Wasm spec: Section 4.4 "Conversions"
- FR-206: wrap / extend_u / extend_s / extend_from_8/16/32
-/

namespace WasmNum.Numerics.Conversion

open WasmNum

/-- i32.wrap_i64: truncate i64 to low 32 bits.
    Wasm spec: `i32.wrap_i64` -/
def wrapI64 (v : I64) : I32 :=
  v.truncate 32

/-- i64.extend_i32_s: sign-extend i32 to i64.
    Wasm spec: `i64.extend_i32_s` -/
def extendI32S (v : I32) : I64 :=
  v.signExtend 64

/-- i64.extend_i32_u: zero-extend i32 to i64.
    Wasm spec: `i64.extend_i32_u` -/
def extendI32U (v : I32) : I64 :=
  v.zeroExtend 64

/-- i32.extend8_s: sign-extend low 8 bits of i32.
    Wasm spec: `i32.extend8_s` -/
def extendI32From8S (v : I32) : I32 :=
  (v.extractLsb' 0 8).signExtend 32

/-- i32.extend16_s: sign-extend low 16 bits of i32.
    Wasm spec: `i32.extend16_s` -/
def extendI32From16S (v : I32) : I32 :=
  (v.extractLsb' 0 16).signExtend 32

/-- i64.extend8_s: sign-extend low 8 bits of i64.
    Wasm spec: `i64.extend8_s` -/
def extendI64From8S (v : I64) : I64 :=
  (v.extractLsb' 0 8).signExtend 64

/-- i64.extend16_s: sign-extend low 16 bits of i64.
    Wasm spec: `i64.extend16_s` -/
def extendI64From16S (v : I64) : I64 :=
  (v.extractLsb' 0 16).signExtend 64

/-- i64.extend32_s: sign-extend low 32 bits of i64.
    Wasm spec: `i64.extend32_s` -/
def extendI64From32S (v : I64) : I64 :=
  (v.extractLsb' 0 32).signExtend 64

end WasmNum.Numerics.Conversion
