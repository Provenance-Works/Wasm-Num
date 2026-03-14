# リファレンス

> **対象読者**: 開発者、ユーザー、運用者

wasm-num の詳細なリファレンスドキュメント。

## ドキュメント

| ドキュメント | 対象読者 | 説明 |
|-------------|---------|------|
| [APIリファレンス](api/) | 開発者 | アーキテクチャレイヤー別の完全なAPIドキュメント |
| [設定](configuration.md) | 全員 | すべての設定オプション（lakefile、ツールチェーン等） |
| [環境変数](environment.md) | ユーザー/運用者 | 環境変数 |
| [エラー](errors.md) | 全員 | エラータイプ、トラップ条件、解決策 |
| [用語集](glossary.md) | 全員 | ドメイン用語と略語 |

## レイヤー別APIリファレンス

| レイヤー | モジュール | ドキュメント |
|---------|----------|------------|
| 0 — Foundation | Types, BitVecOps, WasmFloat, Profiles | [foundation.md](api/foundation.md) |
| 1 — Numerics | NaN, Float, Integer, Conversion | [numerics.md](api/numerics.md) |
| 2 — SIMD | V128, Ops, Relaxed | [simd.md](api/simd.md) |
| 3 — Memory | FlatMemory, Load/Store, Ops | [memory.md](api/memory.md) |
| 4 — Integration | DeterministicWasmProfile, Runtime | [integration.md](api/integration.md) |

## 関連ドキュメント

- [アーキテクチャ](../architecture/) — システム設計
- [ガイド](../guides/) — タスク指向ハウツー
- [はじめに](../getting-started/) — オンボーディング
- [English Version](../../en/reference/)
