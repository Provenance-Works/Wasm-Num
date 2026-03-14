# ADR-0005: FlatMemory Parameterized by Address Width

| | |
|---|---|
| **Status** | Accepted |
| **Date** | 2025 |
| **Deciders** | wasm-num maintainers |

## Context

WebAssembly has two memory proposals:
- **Memory32**: 32-bit addresses, max 4 GiB (65536 pages)
- **Memory64**: 64-bit addresses, max ~16 EiB

All memory operations (load, store, grow, copy, fill, init) work identically regardless of address width — only the address size and maximum page count differ.

## Decision

Parameterize `FlatMemory` and all operations by `addrWidth : Nat`:

```lean
structure FlatMemory (addrWidth : Nat) where
  data      : ByteArray
  pageCount : Nat
  maxLimit  : Option Nat
  inv_dataSize : data.size = pageCount * pageSize
  inv_addrFits : pageCount * pageSize ≤ 2 ^ addrWidth
  ...

abbrev Memory32 := FlatMemory 32
abbrev Memory64 := FlatMemory 64
```

Addresses are `BitVec addrWidth`. Operations like `i32Load`, `fill`, `copy` are all generic over `addrWidth`.

## Consequences

### Positive
- One implementation for both Memory32 and Memory64
- Address overflow checks use `addrWidth` naturally
- Max page count derived from `2 ^ addrWidth / pageSize`
- Proofs work uniformly across both address widths
- Multi-memory support is straightforward (mix Memory32 and Memory64 instances)

### Negative
- Some operations need `addrWidth` constraints (e.g., `addrWidth ≤ 64`)
- Slightly more complex type signatures than fixed 32-bit

### Neutral
- `Addr32 = BitVec 32`, `Addr64 = BitVec 64` are convenience aliases
- The `MultiMemory` module wraps different address widths in a sum type

## Alternatives Considered

### Separate Memory32 / Memory64 Implementations
Two completely independent modules. Rejected: massive code duplication for load, store, grow, copy, fill, init, bounds checking, etc.

### GADTs / Indexed Family
Use an inductive type indexed by address width. Rejected: parameterization is simpler and sufficient in Lean 4.

### Always 64-bit, Mask for 32-bit
Use 64-bit internally, mask addresses for Memory32. Rejected: loses type-level tracking of address width.
