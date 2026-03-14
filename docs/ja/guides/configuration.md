# 設定ガイド

> **対象読者**: ユーザー、開発者

## ビルド設定（`lakefile.toml`）

wasm-num のビルドは `lakefile.toml` で設定されます：

```toml
[package]
name = "wasm-num"
version = "0.1.0"
keywords = ["math"]
defaultTargets = ["WasmNum", "WasmNumProofs"]
```

### Lean オプション

| オプション | 値 | 効果 |
|-----------|-----|------|
| `pp.unicode.fun` | `true` | `fun a => b` の代わりに `fun a ↦ b` をプリティプリント |
| `autoImplicit` | `false` | すべての暗黙引数を明示的に宣言する必要がある |

### ビルドターゲット

| ターゲット | 説明 |
|-----------|------|
| `WasmNum` | 定義のみ（証明なし） |
| `WasmNumProofs` | 定義 + 機械検証済み証明 |
| `TestAll` | 実行可能テストスイート |

### 依存関係

| 依存関係 | スコープ | 用途 |
|---------|---------|------|
| `mathlib` | `leanprover-community` | `BitVec`、`Finset`、代数的基盤、タクティクス |

## ツールチェーン（`lean-toolchain`）

```
leanprover/lean4:v4.29.0-rc6
```

elan がこのファイルを読み取り、適切な Lean バージョンを自動的にインストール・使用します。Lean バージョンを変更するにはこのファイルを編集しますが、現在の Mathlib リビジョンとの互換性を確保してください。

## Mathlib キャッシュ

Mathlib は大規模です。ソースからのビルドを回避するためにビルド済みキャッシュを使用してください：

```bash
lake exe cache get
```

ビルド済み `.olean` ファイルを約 2 GB ダウンロードします。初回のみ（または Mathlib バージョン更新後に）必要です。

## Lake ワーカー

ビルドの並列度を制御：

```bash
# すべてのコアを使用
lake build -j 0

# 4ワーカーを使用（CIでのデフォルト）
lake build -j 4
```

## 関連ドキュメント

- [リファレンス：設定](../reference/configuration.md) — 完全なオプションリファレンス
- [ビルド](../development/build.md) — ビルドシステムのドキュメント
- [トラブルシューティング](troubleshooting.md) — よくあるビルドの問題
- [English Version](../../en/guides/configuration.md)
