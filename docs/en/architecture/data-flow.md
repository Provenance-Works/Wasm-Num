# Data Flow

> **Audience**: Developers, Contributors

This document describes how data flows through the wasm-num system for key operations.

## Scalar Integer Operation (e.g. `iadd`)

Scalar integer operations are direct functions on `BitVec N`:

```mermaid
sequenceDiagram
    participant Caller
    participant Integer as Integer.Arithmetic
    participant BitVec as Mathlib BitVec

    Caller->>Integer: iadd(a : BitVec N, b : BitVec N)
    Integer->>BitVec: a + b (modular addition)
    BitVec-->>Integer: result : BitVec N
    Integer-->>Caller: result : BitVec N
```

No NaN propagation, no non-determinism. `Option` return for trapping operations (`idiv_u`, `idiv_s`, `irem_u`, `irem_s` — returns `none` on division by zero or signed overflow).

## Float Operation with NaN Propagation (e.g. `fmin`)

Non-deterministic float operations return `Set (BitVec N)`:

```mermaid
sequenceDiagram
    participant Caller
    participant Float as Float.MinMax
    participant NaN as NaN.Propagation
    participant WF as WasmFloat typeclass

    Caller->>Float: fmin(a, b)
    Float->>WF: isNaN(a), isNaN(b)
    alt Either is NaN
        Float->>NaN: nansN N [a, b]
        NaN->>WF: canonicalNaN, isArithmeticNaN
        NaN-->>Float: Set (BitVec N)
        Float-->>Caller: result ∈ nansN
    else Both zero, different signs
        Float-->>Caller: {negative zero}
    else Normal comparison
        Float->>WF: lt(a, b)
        Float-->>Caller: {min value}
    end
```

## Deterministic NaN Resolution

The integration layer narrows `Set` to a single value:

```mermaid
sequenceDiagram
    participant Runtime
    participant Det as Deterministic
    participant Profile as DeterministicWasmProfile
    participant NaN as NaN.Propagation
    participant Float as Float.MinMax

    Runtime->>Det: fmin_det(profile, a, b)
    Det->>Float: fmin(a, b) : Set
    Det->>Profile: profile.nanProfile.selectNaN(inputs)
    Profile-->>Det: selected NaN (with proof ∈ nansN)
    Det-->>Runtime: single BitVec N value
```

## Memory Load (Scalar)

```mermaid
sequenceDiagram
    participant Runtime as Integration.Runtime
    participant Addr as Core.Address
    participant Bounds as Core.Bounds
    participant Load as Load.Scalar
    participant FM as FlatMemory

    Runtime->>Addr: effectiveAddr(base, offset)
    alt Overflow
        Addr-->>Runtime: none (trap)
    else Valid
        Addr-->>Runtime: some(addr)
        Runtime->>Bounds: inBoundsB(mem, addr, N/8)
        alt Out of bounds
            Bounds-->>Runtime: false (trap)
        else In bounds
            Bounds-->>Runtime: true
            Runtime->>Load: loadN(mem, addr, N)
            Load->>FM: readLittleEndian(data, addr.toNat, N)
            FM-->>Load: some(BitVec N)
            Load-->>Runtime: value
        end
    end
```

## Memory Store (Scalar)

```mermaid
sequenceDiagram
    participant Runtime as Integration.Runtime
    participant Addr as Core.Address
    participant Bounds as Core.Bounds
    participant Store as Store.Scalar
    participant FM as FlatMemory

    Runtime->>Addr: effectiveAddr(base, offset)
    alt Overflow
        Addr-->>Runtime: none (trap)
    else Valid
        Runtime->>Bounds: inBoundsB(mem, addr, N/8)
        alt Out of bounds
            Bounds-->>Runtime: false (trap)
        else In bounds
            Runtime->>Store: storeN(mem, addr, val)
            Store->>FM: writeLittleEndian(data, addr.toNat, N, val)
            FM-->>Store: some(FlatMemory')
            Store-->>Runtime: updated memory
        end
    end
```

## Memory Grow

```mermaid
sequenceDiagram
    participant Caller
    participant Grow as Ops.Grow
    participant Policy as GrowthPolicy
    participant FM as FlatMemory

    Caller->>Grow: growExec(mem, deltaPages)
    Grow->>Policy: chooseGrow(mem, deltaPages)
    
    alt Policy accepts growth
        Note over Policy: Checks: pageCount + delta ≤ maxLimit<br/>pageCount + delta ≤ maxPages(addrWidth)
        Policy->>FM: create new FlatMemory
        Note over FM: data extended with zero bytes<br/>pageCount incremented<br/>invariants maintained
        FM-->>Policy: FlatMemory'
        Policy-->>Grow: success(FlatMemory', oldPageCount)
    else Policy rejects (or constraints violated)
        Policy-->>Grow: failure
    end
    
    Grow-->>Caller: GrowResult
```

## SIMD Lanewise Operation

```mermaid
sequenceDiagram
    participant Caller
    participant IL as SIMD.Ops.IntLanewise
    participant Lanes as V128.Lanes
    participant Scalar as Integer.Arithmetic

    Caller->>IL: add(shape, a, b)
    IL->>Lanes: zipLanes(shape, iadd, a, b)
    
    loop For each lane i in 0..shape.laneCount
        Lanes->>Lanes: lane(shape, a, i) → laneA
        Lanes->>Lanes: lane(shape, b, i) → laneB
        Lanes->>Scalar: iadd(laneA, laneB)
        Scalar-->>Lanes: result lane
    end
    
    Lanes->>Lanes: ofLanes(shape, results)
    Lanes-->>IL: V128
    IL-->>Caller: V128
```

## Relaxed SIMD Resolution

```mermaid
sequenceDiagram
    participant Caller
    participant Relaxed as SIMD.Relaxed.Madd
    participant DWP as DeterministicWasmProfile
    participant RP as RelaxedProfile

    Caller->>Relaxed: madd(shape, a, b, c) : Set V128
    Note over Relaxed: Spec allows multiple valid results<br/>(fused vs unfused multiply-add)
    Relaxed-->>Caller: Set V128

    Note over Caller: For deterministic execution:
    Caller->>DWP: relaxedProfile.relaxedMaddImpl(a, b, c)
    DWP->>RP: relaxedMaddImpl(a, b, c)
    RP-->>DWP: V128
    Note over DWP: Carries proof: result ∈ madd(shape, a, b, c)
    DWP-->>Caller: V128 (deterministic)
```

## Memory Copy (Overlap Handling)

```mermaid
flowchart TD
    Start["copy(mem, dst, src, len)"] --> CheckBounds{"dst + len ≤ size<br/>AND src + len ≤ size?"}
    CheckBounds -->|No| Trap["none (trap)"]
    CheckBounds -->|Yes| CheckDir{"dst ≤ src?"}
    CheckDir -->|"Yes (or non-overlapping)"| Forward["Forward copy<br/>(low → high)"]
    CheckDir -->|"No (dst > src, overlapping)"| Backward["Backward copy<br/>(high → low)"]
    Forward --> Done["some(FlatMemory')"]
    Backward --> Done
```

## Related Documents

- [Architecture Overview](README.md)
- [Components](components.md)
- [Data Model](data-model.md)
- [Memory API](../reference/api/memory.md)
- [Numerics API](../reference/api/numerics.md)
