# ADR-0001: WasmFloat 型クラスによる IEEE 754 独立性

| | |
|---|---|
| **ステータス** | 承認済 |
| **日付** | 2025 |
| **決定者** | wasm-num メンテナー |

## コンテキスト

WebAssembly の数値セマンティクスは IEEE 754 浮動小数点演算（add, sub, mul, div, sqrt, 比較, 丸め, 分類）に依存しています。しかし：

- Lean 4 にはビット正確なセマンティクスを持つ組み込み IEEE 754 型が存在しない
- Mathlib の `Float` はプラットフォーム依存であり、形式的推論には不適切
- ユーザーによって異なる浮動小数点実装（ソフトウェア、FFI 経由のハードウェア、検証済みライブラリ）が必要となる可能性がある
- プロジェクトは特定の浮動小数点ライブラリに*依存せず*に Wasm セマンティクスを推論できる必要がある

## 決定

幅 `N` での IEEE 754 演算のインターフェースを定義する型クラス `WasmFloat N` を定義します：

```lean
class WasmFloat (N : Nat) where
  isNaN : BitVec N → Bool
  add : BitVec N → BitVec N → BitVec N
  sub : BitVec N → BitVec N → BitVec N
  mul : BitVec N → BitVec N → BitVec N
  div : BitVec N → BitVec N → BitVec N
  sqrt : BitVec N → BitVec N
  -- ... classification, comparison, rounding, conversion methods
  -- Structural proofs (e.g., isNaN_canonicalNaN)
```

浮動小数点を必要とするすべての Wasm 数値演算は `[WasmFloat N]` をインスタンス引数として取ります。テスト用のデフォルトスタブインスタンスが提供されています（分類は正確、算術はカノニカル NaN を返却）。

## 影響

### 肯定的
- wasm-num の正確性は特定の浮動小数点ライブラリに依存しない
- ユーザーは検証済みの実装をプラグイン可能（例：Flocq、Berkeley SoftFloat バインディング）
- Wasm セマンティクスに関する証明は*任意の*準拠する浮動小数点実装に対してパラメトリック
- デフォルトスタブにより、浮動小数点に依存しないコードパスのテストが可能

### 否定的
- デフォルトスタブは実際の浮動小数点算術の正確性をテストできない
- ユーザーはプロダクション用に独自の `WasmFloat 32` および `WasmFloat 64` インスタンスを提供する必要がある
- 型クラス解決が複雑さを増す

### 中立的
- コンパニオン型クラス `WasmFloatPromote` と `WasmFloatDemote` が f32↔f64 変換を担当

## 検討した代替案

### Lean 4 による直接 IEEE 754 実装
Lean 4 で完全なソフトウェア浮動小数点ライブラリを構築する方式。却下：膨大な労力を要し、Wasm セマンティクスとは直交する問題であり、別プロジェクトとして実施すべきです。

### Lean 4 ネイティブ Float
`Float`（プラットフォーム依存）を使用する方式。却下：ビット正確ではなく、移植性がなく、形式的推論をサポートしません。

### モジュールファンクタ / パラメータ化モジュール
浮動小数点モジュールをすべての演算に明示的にスレッドする方式。却下：型クラス推論に比べて極めて冗長です。

---

*[English Version](../../../en/design/adr/0001-typeclass-mediated-754-independence.md)*
