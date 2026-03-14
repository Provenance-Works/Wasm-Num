# アーキテクチャ決定記録（ADR）

> **対象読者**: 開発者、アーキテクト、コントリビューター

## ADR 一覧

| ADR | タイトル | ステータス | 日付 |
|-----|---------|-----------|------|
| [ADR-0001](0001-typeclass-mediated-754-independence.md) | WasmFloat 型クラスによる IEEE 754 独立性 | 承認済 | 2025 |
| [ADR-0002](0002-bitvec-universal-representation.md) | BitVec N を統一表現として採用 | 承認済 | 2025 |
| [ADR-0003](0003-nondeterminism-as-sets.md) | 非決定性を Set α でモデリング | 承認済 | 2025 |
| [ADR-0004](0004-v128-shape-system.md) | SIMD 用 V128 Shape システム | 承認済 | 2025 |
| [ADR-0005](0005-flatmemory-parameterized-address-width.md) | FlatMemory のアドレス幅パラメータ化 | 承認済 | 2025 |
| [ADR-0006](0006-proof-separation.md) | 定義と証明の厳格な分離 | 承認済 | 2025 |
| [ADR-0007](0007-no-c-ffi.md) | C FFI 不使用 — 純粋 Lean のみ | 承認済 | 2025 |

## ADR テンプレート

新しい ADR は [テンプレート](template.md) に従って作成してください。

## 関連ドキュメント

- [設計概要](../README.md)
- [設計原則](../principles.md)
- [トレードオフ](../trade-offs.md)

---

*[English Version](../../../en/design/adr/README.md)*
