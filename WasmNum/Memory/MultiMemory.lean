import WasmNum.Memory.Core.FlatMemory

/-!
# Multi-Memory

Multi-memory support: heterogeneous memory instances (32-bit and 64-bit)
and an indexed memory store.

Wasm spec: multi-memory proposal
- FR-505: Multi-Memory Store
-/

set_option autoImplicit false

namespace WasmNum.Memory

/-- A memory instance: either 32-bit or 64-bit addressed.
    Used by multi-memory stores that can contain a mix of widths. -/
inductive MemoryInstance where
  | mem32 : FlatMemory 32 → MemoryInstance
  | mem64 : FlatMemory 64 → MemoryInstance

/-- A memory address: either 32-bit or 64-bit.
    Width is determined by the memory type being accessed. -/
inductive MemoryAddress where
  | addr32 : BitVec 32 → MemoryAddress
  | addr64 : BitVec 64 → MemoryAddress

/-- Get the address width of a MemoryAddress -/
def MemoryAddress.width : MemoryAddress → Nat
  | .addr32 _ => 32
  | .addr64 _ => 64

/-- Get the address width of a MemoryInstance -/
def MemoryInstance.addrWidth : MemoryInstance → Nat
  | .mem32 _ => 32
  | .mem64 _ => 64

/-- Multi-memory store: an indexed collection of memory instances.
    Wasm spec: multi-memory proposal -/
structure MemoryStore where
  /-- The collection of memory instances -/
  memories : Array MemoryInstance

/-- Get a memory instance by index -/
def MemoryStore.get (store : MemoryStore) (idx : Nat) : Option MemoryInstance :=
  if h : idx < store.memories.size then
    some (store.memories[idx])
  else
    none

/-- Update a memory instance at the given index -/
def MemoryStore.set (store : MemoryStore) (idx : Nat) (mem : MemoryInstance)
    : Option MemoryStore :=
  if h : idx < store.memories.size then
    some { store with memories := store.memories.set idx mem }
  else
    none

/-- Number of memories in the store -/
def MemoryStore.count (store : MemoryStore) : Nat := store.memories.size

/-- Empty memory store -/
def MemoryStore.empty : MemoryStore := { memories := #[] }

end WasmNum.Memory
