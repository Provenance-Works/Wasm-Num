# Module Dependency Graph

> **Audience**: Developers, Contributors

This document shows the import relationships between all modules in wasm-num.

## High-Level Layer Dependencies

```mermaid
graph LR
    L4["Layer 4<br/>Integration"] --> L3["Layer 3<br/>Memory"]
    L4 --> L2["Layer 2<br/>SIMD"]
    L4 --> L1["Layer 1<br/>Numerics"]
    L3 --> L0["Layer 0<br/>Foundation"]
    L2 --> L1
    L2 --> L0
    L1 --> L0

    style L0 fill:#1565C0,color:white
    style L1 fill:#2E7D32,color:white
    style L2 fill:#E65100,color:white
    style L3 fill:#6A1B9A,color:white
    style L4 fill:#C62828,color:white
```

## Foundation Module Graph

```mermaid
graph LR
    Types["Foundation.Types"] --> BitVec["Foundation.BitVec"]
    Defs["Foundation.Defs"]
    WF["Foundation.WasmFloat"] --> Types
    WFD["Foundation.WasmFloat.Default"] --> WF
    Profile["Foundation.Profile"] --> Types
    Profile --> WF

    style Types fill:#1565C0,color:white
    style BitVec fill:#1565C0,color:white
    style Defs fill:#1565C0,color:white
    style WF fill:#1565C0,color:white
    style WFD fill:#1565C0,color:white
    style Profile fill:#1565C0,color:white
```

## Numerics Module Graph

```mermaid
graph TD
    NP["NaN.Propagation"] --> WF["Foundation.WasmFloat"]
    ND["NaN.Deterministic"] --> NP
    ND --> Profile["Foundation.Profile"]

    FMM["Float.MinMax"] --> NP
    FR["Float.Rounding"] --> NP
    FS["Float.Sign"] --> Types["Foundation.Types"]
    FC["Float.Compare"] --> WF
    FP["Float.PseudoMinMax"] --> WF

    IA["Integer.Arithmetic"] --> Types
    IB["Integer.Bitwise"] --> Types
    IS["Integer.Shift"] --> Types
    IC["Integer.Compare"] --> Types
    IBi["Integer.Bits"] --> Types
    IE["Integer.Ext"] --> Types
    ISat["Integer.Saturating"] --> Types
    IMM["Integer.MinMax"] --> Types
    IMisc["Integer.Misc"] --> Types
    IBs["Integer.Bitselect"] --> Types

    TP["Conversion.TruncPartial"] --> WF
    TS["Conversion.TruncSat"] --> WF
    PD["Conversion.PromoteDemote"] --> NP
    CIF["Conversion.ConvertIntFloat"] --> WF
    RI["Conversion.Reinterpret"] --> Types
    IW["Conversion.IntWidth"] --> Types

    style NP fill:#2E7D32,color:white
    style ND fill:#2E7D32,color:white
    style FMM fill:#2E7D32,color:white
    style FR fill:#2E7D32,color:white
    style FS fill:#2E7D32,color:white
    style FC fill:#2E7D32,color:white
    style FP fill:#2E7D32,color:white
    style IA fill:#2E7D32,color:white
    style IB fill:#2E7D32,color:white
    style IS fill:#2E7D32,color:white
    style IC fill:#2E7D32,color:white
    style IBi fill:#2E7D32,color:white
    style IE fill:#2E7D32,color:white
    style ISat fill:#2E7D32,color:white
    style IMM fill:#2E7D32,color:white
    style IMisc fill:#2E7D32,color:white
    style IBs fill:#2E7D32,color:white
    style TP fill:#2E7D32,color:white
    style TS fill:#2E7D32,color:white
    style PD fill:#2E7D32,color:white
    style CIF fill:#2E7D32,color:white
    style RI fill:#2E7D32,color:white
    style IW fill:#2E7D32,color:white
```

## SIMD Module Graph

```mermaid
graph TD
    Shape["V128.Shape"] --> Types["Foundation.Types"]
    V128T["V128.Type"] --> Types
    Lanes["V128.Lanes"] --> Shape
    Lanes --> V128T
    Lanes --> BitVec["Foundation.BitVec"]

    BW["Ops.Bitwise"] --> V128T
    IL["Ops.IntLanewise"] --> Lanes
    IL --> Integer["Integer.*"]
    FL["Ops.FloatLanewise"] --> Lanes
    FL --> Float["Float.*"]
    FL --> NaN["NaN.Propagation"]
    BM["Ops.Bitmask"] --> Lanes
    NR["Ops.Narrow"] --> Lanes
    NR --> ISat["Integer.Saturating"]
    EX["Ops.Extend"] --> Lanes
    Dot["Ops.Dot"] --> Lanes
    Sw["Ops.Swizzle"] --> Lanes
    Sh["Ops.Shuffle"] --> Lanes
    SE["Ops.SplatExtractReplace"] --> Lanes
    CV["Ops.Convert"] --> Lanes
    CV --> Conversion["Conversion.*"]

    RM["Relaxed.Madd"] --> FL
    RMM["Relaxed.MinMax"] --> FL
    RSw["Relaxed.Swizzle"] --> Sw
    RT["Relaxed.Trunc"] --> CV
    RLS["Relaxed.Laneselect"] --> BW
    RD["Relaxed.Dot"] --> Dot
    RQ["Relaxed.Q15"] --> IL

    style Shape fill:#E65100,color:white
    style V128T fill:#E65100,color:white
    style Lanes fill:#E65100,color:white
    style BW fill:#E65100,color:white
    style IL fill:#E65100,color:white
    style FL fill:#E65100,color:white
    style BM fill:#E65100,color:white
    style NR fill:#E65100,color:white
    style EX fill:#E65100,color:white
    style Dot fill:#E65100,color:white
    style Sw fill:#E65100,color:white
    style Sh fill:#E65100,color:white
    style SE fill:#E65100,color:white
    style CV fill:#E65100,color:white
    style RM fill:#E65100,color:white
    style RMM fill:#E65100,color:white
    style RSw fill:#E65100,color:white
    style RT fill:#E65100,color:white
    style RLS fill:#E65100,color:white
    style RD fill:#E65100,color:white
    style RQ fill:#E65100,color:white
```

## Memory Module Graph

```mermaid
graph TD
    Page["Core.Page"] --> Defs["Foundation.Defs"]
    FM["Core.FlatMemory"] --> Page
    FM --> BitVec["Foundation.BitVec"]
    Addr["Core.Address"] --> Types["Foundation.Types"]
    Bnd["Core.Bounds"] --> FM
    Bnd --> Addr

    LSc["Load.Scalar"] --> FM
    LSc --> Bnd
    LPk["Load.Packed"] --> LSc
    LPk --> BitVec
    LSi["Load.SIMD"] --> LSc
    LSi --> V128["V128.Lanes"]

    SSc["Store.Scalar"] --> FM
    SSc --> Bnd
    SPk["Store.Packed"] --> SSc
    SSi["Store.SIMD"] --> SSc
    SSi --> V128

    Sz["Ops.Size"] --> FM
    Gw["Ops.Grow"] --> FM
    Gw --> Page
    Fl["Ops.Fill"] --> FM
    Cp["Ops.Copy"] --> FM
    In["Ops.Init"] --> FM
    In --> DD["Ops.DataDrop"]

    MM["MultiMemory"] --> FM
    M64["Memory64"] --> FM
    M64 --> Page

    style Page fill:#6A1B9A,color:white
    style FM fill:#6A1B9A,color:white
    style Addr fill:#6A1B9A,color:white
    style Bnd fill:#6A1B9A,color:white
    style LSc fill:#6A1B9A,color:white
    style LPk fill:#6A1B9A,color:white
    style LSi fill:#6A1B9A,color:white
    style SSc fill:#6A1B9A,color:white
    style SPk fill:#6A1B9A,color:white
    style SSi fill:#6A1B9A,color:white
    style Sz fill:#6A1B9A,color:white
    style Gw fill:#6A1B9A,color:white
    style Fl fill:#6A1B9A,color:white
    style Cp fill:#6A1B9A,color:white
    style In fill:#6A1B9A,color:white
    style DD fill:#6A1B9A,color:white
    style MM fill:#6A1B9A,color:white
    style M64 fill:#6A1B9A,color:white
```

## Integration Module Graph

```mermaid
graph TD
    IP["Integration.Profile"] --> NP["NaN.Propagation"]
    IP --> ND["NaN.Deterministic"]
    IP --> RM["Relaxed.*"]
    IP --> Profile["Foundation.Profile"]

    RT["Integration.Runtime"] --> IP
    RT --> LSc["Load.Scalar"]
    RT --> LPk["Load.Packed"]
    RT --> LSi["Load.SIMD"]
    RT --> SSc["Store.Scalar"]
    RT --> SPk["Store.Packed"]
    RT --> SSi["Store.SIMD"]
    RT --> Addr["Core.Address"]
    RT --> Bnd["Core.Bounds"]
    RT --> Gw["Ops.Grow"]
    RT --> Sz["Ops.Size"]
    RT --> Fl["Ops.Fill"]
    RT --> Cp["Ops.Copy"]
    RT --> In["Ops.Init"]

    style IP fill:#C62828,color:white
    style RT fill:#C62828,color:white
```

## Proof Module Dependencies

Proof modules mirror the definition hierarchy and import both the definition module being proved and Mathlib tactics:

```mermaid
graph LR
    subgraph "Proofs"
        PNaN["Proofs.NaN.*"]
        PFloat["Proofs.Float.*"]
        PConv["Proofs.Conversion.*"]
        PV128["Proofs.V128.*"]
        PSOps["Proofs.SIMD.Ops.*"]
        PRel["Proofs.Relaxed.*"]
        PMem["Proofs.Memory.*"]
    end

    PNaN --> NaN["NaN.Propagation/Deterministic"]
    PFloat --> Float["Float.MinMax"]
    PConv --> Conv["Conversion.TruncPartial/TruncSat"]
    PV128 --> Lanes["V128.Lanes"]
    PSOps --> IL["Ops.IntLanewise"]
    PRel --> Rel["Relaxed.*"]
    PMem --> FM["Core.FlatMemory"]
    PMem --> Load["Load/Store.*"]
```

## Related Documents

- [Architecture Overview](README.md)
- [Components](components.md)
- [Data Model](data-model.md)
- [Project Structure](../development/project-structure.md)
