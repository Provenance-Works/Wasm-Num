# Errors Reference

> **Audience**: All

wasm-num models errors (traps) as `Option` types: `none` represents a trap condition. This document catalogs all trap-producing operations.

## Trap Model

WebAssembly uses traps — unrecoverable runtime errors. In wasm-num, a function that can trap returns `Option T`:

```lean
-- none = trap, some v = success
def idiv_u (a b : BitVec N) : Option (BitVec N) := ...
```

There are no error codes or exception types. All errors are structural: the function either succeeds or it doesn't.

## Integer Traps

| Operation | Condition | Spec |
|-----------|-----------|------|
| `idiv_u` | Divisor is zero | `i32.div_u`, `i64.div_u` |
| `idiv_s` | Divisor is zero | `i32.div_s`, `i64.div_s` |
| `idiv_s` | Dividend = INT_MIN, divisor = -1 (signed overflow) | `i32.div_s`, `i64.div_s` |
| `irem_u` | Divisor is zero | `i32.rem_u`, `i64.rem_u` |
| `irem_s` | Divisor is zero | `i32.rem_s`, `i64.rem_s` |

> **Note:** `irem_s` does NOT trap on INT_MIN / -1 (result is 0), unlike `idiv_s`.

## Conversion Traps

| Operation | Condition | Spec |
|-----------|-----------|------|
| `truncF32ToI32S` | NaN input | `i32.trunc_f32_s` |
| `truncF32ToI32S` | ±∞ input | `i32.trunc_f32_s` |
| `truncF32ToI32S` | Result out of i32 signed range | `i32.trunc_f32_s` |
| `truncF32ToI32U` | NaN, ±∞, or out of unsigned range | `i32.trunc_f32_u` |
| `truncF64ToI32S` | same pattern | `i32.trunc_f64_s` |
| `truncF64ToI32U` | same pattern | `i32.trunc_f64_u` |
| `truncF32ToI64S` | same pattern | `i64.trunc_f32_s` |
| `truncF32ToI64U` | same pattern | `i64.trunc_f32_u` |
| `truncF64ToI64S` | same pattern | `i64.trunc_f64_s` |
| `truncF64ToI64U` | same pattern | `i64.trunc_f64_u` |

> **Note:** Saturating trunc variants (`trunc_sat_*`) never trap — they return 0 for NaN, min/max for overflow.

## Memory Traps

### Load Traps

| Operation | Condition | Spec |
|-----------|-----------|------|
| `i32Load` | `effective_address + 4 > memory.data.size` | `i32.load` |
| `i64Load` | `effective_address + 8 > memory.data.size` | `i64.load` |
| `f32Load` | `effective_address + 4 > memory.data.size` | `f32.load` |
| `f64Load` | `effective_address + 8 > memory.data.size` | `f64.load` |
| `v128Load` | `effective_address + 16 > memory.data.size` | `v128.load` |
| `i32Load8S` etc. | `effective_address + packed_size > memory.data.size` | packed loads |
| All loads | `base + offset` overflows address width | address overflow |

### Store Traps

| Operation | Condition |
|-----------|-----------|
| `i32Store` | `effective_address + 4 > memory.data.size` |
| `i64Store` | `effective_address + 8 > memory.data.size` |
| `f32Store` / `f64Store` | Same pattern for 4/8 bytes |
| `v128Store` | `effective_address + 16 > memory.data.size` |
| Packed stores | `effective_address + packed_size > memory.data.size` |

### Memory Operation Traps

| Operation | Condition | Spec |
|-----------|-----------|------|
| `memory.fill` | `dst + len > memory.data.size` (address overflow or OOB) | `memory.fill` |
| `memory.copy` | `src + len > memory.data.size` or `dst + len > memory.data.size` | `memory.copy` |
| `memory.init` | Source offset + len > segment size, or dst + len > memory size, or segment is dropped | `memory.init` |

> **Note:** `memory.grow` does NOT trap. It returns -1 on failure.

## Non-Trap Errors

These are modeled differently from traps:

| Situation | Model | Description |
|-----------|-------|-------------|
| `memory.grow` failure | `GrowResult.failure` | Returns -1 (not a trap), memory unchanged |
| Data segment dropped | `DataSegment.dropped` | `memory.init` on dropped segment traps; `data.drop` on dropped is no-op |

## See Also

- [Numerics API](api/numerics.md) — integer and conversion operations
- [Memory API](api/memory.md) — memory operations
- [Troubleshooting](../guides/troubleshooting.md)
