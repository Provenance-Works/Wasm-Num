import WasmNum.Memory.Core.FlatMemory

/-!
# Address Types

Address types and effective address calculation for WebAssembly memory operations.
Supports both 32-bit and 64-bit addressing (ADR-005).

Wasm spec: Section 4.4.7 "Memory Instructions"
- FR-503: Address Types
-/

set_option autoImplicit false

namespace WasmNum.Memory

open WasmNum

/-- Effective address calculation: base + offset with overflow checking.
    Returns `none` if `base.toNat + offset ≥ 2^addrWidth` (address space overflow).
    Wasm spec: effective address = i + memarg.offset; trap on overflow. -/
def effectiveAddr {addrWidth : Nat} (base : BitVec addrWidth) (offset : Nat)
    : Option (BitVec addrWidth) :=
  let ea := base.toNat + offset
  if ea < 2 ^ addrWidth then some (BitVec.ofNat addrWidth ea)
  else none

/-- If effectiveAddr succeeds, the result's toNat equals base.toNat + offset. -/
theorem effectiveAddr_toNat {addrWidth : Nat} (base : BitVec addrWidth) (offset : Nat)
    (addr : BitVec addrWidth) (h : effectiveAddr base offset = some addr) :
    addr.toNat = base.toNat + offset := by
  simp only [effectiveAddr] at h
  split at h
  · simp only [Option.some.injEq] at h
    subst h
    simp [BitVec.toNat_ofNat, Nat.mod_eq_of_lt (by assumption)]
  · simp at h

end WasmNum.Memory
