# 設計原則

> **対象読者**: 開発者、アーキテクト、コントリビューター

## 1. 仕様がソースオブトゥルース

すべての定義は [WebAssembly 仕様](https://webassembly.github.io/spec/core/) から直接派生しています。仕様の動作をそのまま実装しており、最適化・簡略化・独自解釈は行いません。関数名や構造は可能な限り仕様の命名に従っています。

## 2. BitVec N を統一通貨として使用

すべての WebAssembly 数値型（`i32`、`i64`、`f32`、`f64`、`v128`）は `BitVec N` のエイリアスとして表現されます：

```lean
abbrev I32 := BitVec 32
abbrev I64 := BitVec 64
abbrev F32 := BitVec 32
abbrev F64 := BitVec 64
abbrev V128 := BitVec 128
```

これにより演算間の変換がゼロコストになり、reinterpret はアイデンティティ関数となります。

## 3. 境界でのみ抽象化

型クラスの抽象化は外部との境界（IEEE 754 浮動小数点数の `WasmFloat`、ランタイム統合の `Profile`）でのみ使用します。内部ではすべて `BitVec` 上の具象関数です。

## 4. 非決定性を集合としてモデリング

WebAssembly 仕様上の非決定的動作（NaN 伝播、Relaxed SIMD、memory.grow）は `Set α`（`α → Prop`）で表現し、有効な出力の完全な集合を捕捉します。`DeterministicWasmProfile` が特定の選択を行い、証明を通じて正当性を保証します。

## 5. 証明の分離

定義ファイル（`WasmNum/`）には `theorem` や `lemma` を含めません。証明は `WasmNum/Proofs/` と `Proofs/` に配置され、定義の階層構造をミラーリングしています。これにより `lake build WasmNum` はビルドが高速になります。

## 6. 純粋 Lean・C FFI なし

コードベース全体が純粋な Lean 4 です。C FFI は使用していません。これにより完全な検証可能性、移植性、再現性を確保しています。ハードウェア浮動小数点数が必要なユーザーは、外部で `WasmFloat` インスタンスを提供する必要があります。

## 7. レイヤードアーキテクチャ

コードベースは5つの厳密なレイヤーに構成されています：

```
Foundation → Numerics → SIMD → Memory → Integration
```

依存関係は左から右への一方向のみ許可されます。循環依存は許可されません。

## 8. Mathlib を基盤として活用

Lean のエコシステムを活用し、Mathlib4 で実証済みの数学ライブラリ（`BitVec` 演算、`Fin` 算術、集合論など）を使用します。

## 関連ドキュメント

- [設計パターン](patterns.md)
- [トレードオフ](trade-offs.md)
- [ADR 一覧](adr/)
- [アーキテクチャ概要](../architecture/)

---

*[English Version](../../en/design/principles.md)*
