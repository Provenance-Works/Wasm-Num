# ADR-0001: WasmFloat 型クラスによる IEEE 754 独立性

| | |
|---|---|
| **ステータス** | 承認済 |
| **日付** | 2025 |
| **決定者** | wasm-num メンテナー |

## コンテキスト

WebAssembly は IEEE 754 準拠の浮動小数点演算を仕様化しています。しかし：

1. **Lean 4 の `Float`** はプラットフォーム依存の倍精度であり、ビット正確ではなく、f32 と f64 の両方に対する形式的推論には不適切です
2. **ハードウェア FPU** はプラットフォーム間で異なる動作を示します（特に NaN 処理、丸めのエッジケース）
3. **純粋 Lean 実装** は wasm-num のスコープ内で完全な IEEE 754 ソフトフロート提供は現実的ではありません（かつ、wasm-num の価値提案でもありません）

プロジェクトには、浮動小数点の実装をプラグ可能にしつつ、すべての非浮動小数点セマンティクスを具体的に定義する方法が必要です。

## 決定

浮動小数点演算を抽象化する型クラス `WasmFloat N` を定義します：

```lean
class WasmFloat (N : Nat) where
  fadd : BitVec N → BitVec N → BitVec N
  fsub : BitVec N → BitVec N → BitVec N
  fmul : BitVec N → BitVec N → BitVec N
  fdiv : BitVec N → BitVec N → BitVec N
  fsqrt : BitVec N → BitVec N
  fnearest : BitVec N → BitVec N
  ffloor : BitVec N → BitVec N
  fceil : BitVec N → BitVec N
  ftrunc : BitVec N → BitVec N
  isNaN : BitVec N → Bool
  isInf : BitVec N → Bool
  ...
```

テスト用のデフォルトスタブインスタンスが `WasmFloat/Default.lean` で提供されています。

## 影響

### 肯定的
- 浮動小数点の実装なしで整数・メモリ・SIMD 構造の定義と検証が可能
- ユーザーが独自の `WasmFloat` インスタンスを提供可能（SoftFloat ラッパー、ハードウェア FPU バインディングなど）
- `N` のパラメータ化により f32（`WasmFloat 32`）と f64（`WasmFloat 64`）を統一的に処理
- コア型クラスに IEEE 754 の型レベル分類（NaN、Inf、ゼロ、サブノーマル、ノーマル）を含む

### 否定的
- デフォルトスタブは実際の IEEE 754 演算を実行しない（プレースホルダ値を返却）
- すべての浮動小数点依存の関数で `[WasmFloat N]` 制約が必要
- 具体的な浮動小数点ライブラリへの橋渡しを構築する負担はユーザーが負う

### 中立的
- ビット分解（符号・指数・仮数）、NaN の分類や操作などの非演算的浮動小数点操作は `BitVec` 上に具体的に定義（`WasmFloat` 不要）
- テストスイートはスタブの分類を用いて浮動小数点パスを検証（演算の正確性ではなく構造的正確性を確認）

## 検討した代替案

### Lean 4 ネイティブ Float
`Float`（倍精度）を使用し f32 にキャストする方式。却下：ビット正確ではなく、プラットフォーム依存であり、`Float` に対して形式的性質を証明できません。

### 組み込み SoftFloat
wasm-num 内に完全な IEEE 754 ソフトフロートライブラリを実装する方式。却下：プロジェクトスコープ外であり、膨大なコードと検証労力が必要です。

### C FFI → SoftFloat
C FFI で Berkeley SoftFloat をリンクする方式。却下：検証ギャップ、ネイティブ依存関係を導入（[ADR-0007](0007-no-c-ffi.md) 参照）。

---

*[English Version](../../../en/design/adr/0001-ieee754-independence-via-wasmfloat.md)*
