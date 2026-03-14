import WasmNum.Memory.Load.Scalar

/-!
# Packed Loads (Sub-Width with Extension)

Load sub-width integers from memory with sign or zero extension.
These operations read fewer bytes than the target type and extend.

Wasm spec: Section 4.4.7 "Memory Instructions"
- `i32.load8_s`, `i32.load8_u`, `i32.load16_s`, `i32.load16_u`
- `i64.load8_s`, `i64.load8_u`, `i64.load16_s`, `i64.load16_u`
- `i64.load32_s`, `i64.load32_u`
- FR-507: Packed Loads
-/

set_option autoImplicit false

namespace WasmNum.Memory.Load

open WasmNum
open WasmNum.Memory

-- === i32 packed loads ===

/-- `i32.load8_s`: load 8 bits, sign-extend to 32 bits -/
def i32Load8S {addrWidth : Nat} (mem : FlatMemory addrWidth) (addr : BitVec addrWidth)
    : Option I32 :=
  (loadN mem addr 8 (by omega)).map (fun v => v.signExtend 32)

/-- `i32.load8_u`: load 8 bits, zero-extend to 32 bits -/
def i32Load8U {addrWidth : Nat} (mem : FlatMemory addrWidth) (addr : BitVec addrWidth)
    : Option I32 :=
  (loadN mem addr 8 (by omega)).map (fun v => v.zeroExtend 32)

/-- `i32.load16_s`: load 16 bits, sign-extend to 32 bits -/
def i32Load16S {addrWidth : Nat} (mem : FlatMemory addrWidth) (addr : BitVec addrWidth)
    : Option I32 :=
  (loadN mem addr 16 (by omega)).map (fun v => v.signExtend 32)

/-- `i32.load16_u`: load 16 bits, zero-extend to 32 bits -/
def i32Load16U {addrWidth : Nat} (mem : FlatMemory addrWidth) (addr : BitVec addrWidth)
    : Option I32 :=
  (loadN mem addr 16 (by omega)).map (fun v => v.zeroExtend 32)

-- === i64 packed loads ===

/-- `i64.load8_s`: load 8 bits, sign-extend to 64 bits -/
def i64Load8S {addrWidth : Nat} (mem : FlatMemory addrWidth) (addr : BitVec addrWidth)
    : Option I64 :=
  (loadN mem addr 8 (by omega)).map (fun v => v.signExtend 64)

/-- `i64.load8_u`: load 8 bits, zero-extend to 64 bits -/
def i64Load8U {addrWidth : Nat} (mem : FlatMemory addrWidth) (addr : BitVec addrWidth)
    : Option I64 :=
  (loadN mem addr 8 (by omega)).map (fun v => v.zeroExtend 64)

/-- `i64.load16_s`: load 16 bits, sign-extend to 64 bits -/
def i64Load16S {addrWidth : Nat} (mem : FlatMemory addrWidth) (addr : BitVec addrWidth)
    : Option I64 :=
  (loadN mem addr 16 (by omega)).map (fun v => v.signExtend 64)

/-- `i64.load16_u`: load 16 bits, zero-extend to 64 bits -/
def i64Load16U {addrWidth : Nat} (mem : FlatMemory addrWidth) (addr : BitVec addrWidth)
    : Option I64 :=
  (loadN mem addr 16 (by omega)).map (fun v => v.zeroExtend 64)

/-- `i64.load32_s`: load 32 bits, sign-extend to 64 bits -/
def i64Load32S {addrWidth : Nat} (mem : FlatMemory addrWidth) (addr : BitVec addrWidth)
    : Option I64 :=
  (loadN mem addr 32 (by omega)).map (fun v => v.signExtend 64)

/-- `i64.load32_u`: load 32 bits, zero-extend to 64 bits -/
def i64Load32U {addrWidth : Nat} (mem : FlatMemory addrWidth) (addr : BitVec addrWidth)
    : Option I64 :=
  (loadN mem addr 32 (by omega)).map (fun v => v.zeroExtend 64)

end WasmNum.Memory.Load
