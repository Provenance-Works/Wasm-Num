# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

## [0.1.0] - 2026-03-14

### Added

- **Foundation Layer** — Core type aliases (`I32`, `I64`, `F32`, `F64`, `V128`, `Byte`), `BitVec` utilities, `WasmFloat` typeclass for IEEE 754 abstraction, `NaNProfile`/`RelaxedProfile`/`WasmProfile` structures, and basic definitions (page size, limits).
- **Numerics — NaN Propagation** — `nans`, `canonicalNans`, `arithmeticNans` sets; `propagateNaN₁`/`propagateNaN₂` functions; deterministic NaN propagation via `NaNProfile`.
- **Numerics — Float Operations** — `fmin`/`fmax` (non-deterministic), `fnearest`/`fceil`/`ffloor`/`ftrunc`, `fabs`/`fneg`/`fcopysign`, comparisons (`feq`, `flt`, `fgt`, `fle`, `fge`, `fne`), pseudo min/max (`fpmin`, `fpmax`).
- **Numerics — Conversions** — Trapping (`trunc_u`, `trunc_s`), saturating (`trunc_sat`), `promote`/`demote`, `convert` (int→float), `reinterpret`, integer width (`wrap`, `extend_s`, `extend_u`).
- **Numerics — Integer Operations** — Arithmetic (`iadd`, `isub`, `imul`, `idiv`, `irem`), bitwise (`iand`, `ior`, `ixor`, `inot`, `iandnot`), shifts/rotates, comparisons, bit counting (`iclz`, `ictz`, `ipopcnt`), `iextend_s`, saturating arithmetic, min/max, abs/neg, `iavgr_u`, `iq15mulr_sat_s`, `ibitselect`.
- **SIMD — V128 Core** — `V128` type (`BitVec 128`), `Shape`/`LaneType` system, lane access (`lane`, `replaceLane`, `ofLanes`, `splat`, `mapLanes`, `zipLanes`), bitwise ops (`v128.not`, `and`, `andnot`, `or`, `xor`, `bitselect`, `anyTrue`).
- **SIMD — Integer Lanewise** — All lanewise integer operations: arithmetic, saturating, min/max, shifts, comparisons, `allTrue`, `bitmask`, narrowing/widening, `dot`, `swizzle`, `shuffle`, `splat`/`extractLane`/`replaceLane`.
- **SIMD — Float Lanewise** — Lanewise float operations: arithmetic, min/max/pmin/pmax, rounding, abs/neg, comparisons, SIMD conversions.
- **SIMD — Relaxed Operations** — `relaxed_madd`/`relaxed_nmadd`, relaxed min/max, relaxed swizzle, relaxed trunc, relaxed laneselect, relaxed dot, relaxed q15mulr.
- **Memory — Core** — `FlatMemory` structure, `Page` model, `Address` types (32/64-bit), bounds checking, `readLittleEndian`/`writeLittleEndian`.
- **Memory — Load/Store** — Scalar/packed/SIMD loads and stores, including `v128.load`, `load_splat`, `load_lane`, `load_ext`, `v128.store`, `store_lane`.
- **Memory — Operations** — `memory.size`, `memory.grow` (Set-based), `memory.fill`, `memory.copy` (with overlap handling), `memory.init`, `data.drop`, multi-memory (`MemoryStore`), Memory64 support.
- **Integration Layer** — `DeterministicWasmProfile`, deterministic wrappers for all Set-returning operations, runtime adapter.
- **Machine-Checked Proofs** — NaN propagation correctness, deterministic NaN singleton, fmin/fmax spec compliance, trunc range proofs, saturation correctness, V128 lane roundtrip and bijection, lanewise-equals-per-lane, deterministic ⊆ non-deterministic, bounds safety, load–store roundtrip, load–store disjointness, grow data preservation, copy overlap correctness, fill specification.
- **Test Suite** — 12 `#eval`-based test modules covering foundation, integer, float, conversion, SIMD core/int ops/misc, memory core/load-store/ops, and integration.
- **Documentation** — Architecture design, 7 ADRs, requirements (functional, non-functional, constraints, glossary), component specs, research summary.
- **CI/CD** — GitHub Actions formal verification pipeline (sorry detection, axiom audit, proof metrics), release pipeline, security scan workflow, Dependabot configuration.

[Unreleased]: https://github.com/Provenance-Works/wasm-num/compare/v0.1.0...HEAD
[0.1.0]: https://github.com/Provenance-Works/wasm-num/releases/tag/v0.1.0
