# 設計パターン

> **対象読者**: 開発者、コントリビューター

wasm-num コードベースで繰り返し使用されるパターンと、各パターンの採用理由を解説します。

## 1. 型クラス抽象化（外部境界のみ）

**使用箇所**: `WasmFloat N`、`Profile`

```lean
class WasmFloat (N : Nat) where
  fadd : BitVec N → BitVec N → BitVec N
  fsub : BitVec N → BitVec N → BitVec N
  ...
```

**根拠**: IEEE 754 の実装は wasm-num のスコープ外です。型クラスにより実装を注入可能にしています。内部演算（整数演算、メモリ操作など）は直接定義されているため、型クラスは使用しません。

## 2. 集合を返す関数（Set α）

**使用箇所**: NaN 伝播、Relaxed SIMD、`memory.grow`

```lean
def propagateNaN₂ (op : BitVec N → BitVec N → BitVec N)
  (a b : BitVec N) : Set (BitVec N) := ...
```

**根拠**: WebAssembly 仕様は非決定的な結果をビット正確な集合として定義しています。`Set α` はこの情報を損失なく捕捉し、メンバーシップ証明を可能にします。

## 3. Profile ベースの決定的インスタンス化

**使用箇所**: Integration レイヤー

```lean
structure DeterministicWasmProfile where
  canonicalize : Bool
  relaxedMode  : RelaxedMode
  ...
```

**根拠**: `Set α` を返す関数は直接実行できません。`DeterministicWasmProfile` が特定の選択を行い、選択結果が仕様レベルの集合に属することの証明を提供します。

## 4. Option によるトラップ表現

**使用箇所**: 整数除算、変換、メモリアクセス

```lean
def idiv_s (a b : BitVec N) : Option (BitVec N) := ...
```

**根拠**: WebAssembly のトラップ（ゼロ除算、範囲外アクセスなど）を `Option.none` で表現します。シンプルで合成可能であり、`do` 記法による連鎖が可能です。

## 5. アドレス幅のパラメータ化

**使用箇所**: Memory レイヤー全体

```lean
structure FlatMemory (addrWidth : Nat) where ...
abbrev Memory32 := FlatMemory 32
abbrev Memory64 := FlatMemory 64
```

**根拠**: Memory32 と Memory64 は同一のロジックを共有しています。`addrWidth` のパラメータ化により、一度の実装で両方をサポートします。

## 6. Shape パラメータ化による SIMD

**使用箇所**: SIMD レイヤー全体

```lean
structure Shape where
  laneWidth : Nat
  laneCount : Nat
  valid     : laneWidth * laneCount = 128
  ...
```

**根拠**: 6つのレーン構成（i8x16、i16x8、i32x4、i64x2、f32x4、f64x2）すべてで同一のレーンワイズ操作を共有します。`Shape` パラメータにより一度の実装で全構成をサポートします。

## 7. レーンワイズリフティング

**使用箇所**: SIMD 演算

```lean
def zipLanes (s : Shape) (f : BitVec s.laneWidth → BitVec s.laneWidth → BitVec s.laneWidth)
  (a b : V128) : V128 := ...
```

**根拠**: ほとんどの SIMD 演算はスカラー演算を各レーンに独立に適用するものです。`mapLanes` / `zipLanes` がこの共通パターンを抽出しています。

## 8. 不変条件を持つ構造体

**使用箇所**: `FlatMemory`、`Shape`

```lean
structure FlatMemory (addrWidth : Nat) where
  data      : ByteArray
  pageCount : Nat
  inv_dataSize : data.size = pageCount * pageSize
  inv_addrFits : pageCount * pageSize ≤ 2 ^ addrWidth
```

**根拠**: 不変条件を構造体のフィールドとして保持することで、不正な状態の構築が型レベルで防止されます。証明は値とともに運ばれます。

## 9. 証明のミラーリング

**使用箇所**: `WasmNum/Proofs/` ↔ `WasmNum/`

定義ファイルのヒエラルキーをそのまま証明ファイルに反映させます。`WasmNum/Memory/Core/Bounds.lean` の証明は `WasmNum/Proofs/Memory/Bounds.lean` に配置されます。

**根拠**: 定義と証明の対応関係が自明になり、ファイルの発見が容易になります。新しい定義を追加する際に対応する証明ファイルの場所が明確です。

## 関連ドキュメント

- [設計原則](principles.md)
- [トレードオフ](trade-offs.md)
- [ADR 一覧](adr/)

---

*[English Version](../../en/design/patterns.md)*
