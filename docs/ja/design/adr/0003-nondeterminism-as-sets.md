# ADR-0003: 非決定性を Set α でモデリング

| | |
|---|---|
| **ステータス** | 承認済 |
| **日付** | 2025 |
| **決定者** | wasm-num メンテナー |

## コンテキスト

WebAssembly 仕様にはいくつかの非決定性の源があります：

1. **NaN 伝播** — 浮動小数点演算が NaN 入力を持つ場合、結果は指定された集合（`nans_N`）の任意の NaN
2. **Relaxed SIMD** — 一部の SIMD 演算は実装定義の結果を許容（例：融合 vs. 非融合の積和演算）
3. **memory.grow** — 実装は成長可能な場合でも失敗を返してよい

形式化ではこれらの仕様で許容される有効な結果の集合を、一つを早まって選択することなく表現する必要があります。

## 決定

`Set α`（Lean 4: `α → Prop`）を使用して、すべての有効な出力の集合を表現します：

```lean
def fmin [WasmFloat N] (a b : BitVec N) : Set (BitVec N) := ...

def propagateNaN₂ (op : BitVec N → BitVec N → BitVec N)
  (a b : BitVec N) : Set (BitVec N) := ...

def growSpec (mem : FlatMemory addrWidth) (delta : Nat) : Set (GrowResult addrWidth) := ...
```

決定的なインスタンス化はプロファイルを通じて提供されます：

```lean
def propagateNaN₂_det (p : DeterministicWasmProfile) ... : BitVec N := ...
-- 証明: result ∈ propagateNaN₂ ...
```

## 影響

### 肯定的
- 仕様完全な表現 — 情報損失なし
- メンバーシップ（`∈`）と集合演算による自然な証明推論
- 仕様レベル（Set）とランタイムレベル（決定的）のクリーンな分離
- `DeterministicWasmProfile` が任意の特定選択の正確性を証明

### 否定的
- Set を返す関数は直接実行不可
- 非決定的関数の合成に明示的な集合内包が必要
- 決定的振る舞いのみを必要とするユーザーにとって API がやや複雑

### 中立的
- Integration レイヤーがすべての Set を返す演算に決定的ラッパーを提供
- テストスイートは決定的ラッパーを使用（`#guard` は Set に適用不可）

## 検討した代替案

### 非決定性モナド
`NondetM α = List α` または同様のモナドと `bind`。却下：このユースケースには過剰であり、`Set α` のほうが Lean の型理論でシンプルかつ自然です。

### 一つを選択（常にカノニカル NaN）
常にカノニカル NaN を返す方式。却下：仕様情報を失い、有効な集合全体に対する性質の証明ができなくなります。

### 天使的 / 悪魔的選択
非決定性を圏論的にモデル化する方式。却下：具体的な仕様に対して不必要な理論的機構です。

---

*[English Version](../../../en/design/adr/0003-nondeterminism-as-sets.md)*
