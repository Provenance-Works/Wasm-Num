# 設定リファレンス

> **対象読者**: 全員

wasm-num のすべての設定オプションの完全なリファレンス。

## lakefile.toml

プライマリビルド設定ファイル。

| キー | 型 | デフォルト | 説明 |
|-----|-----|---------|------|
| `name` | `String` | `"wasm-num"` | パッケージ名 |
| `version` | `String` | `"0.1.0"` | パッケージバージョン |
| `leanOptions` | `Array` | 下記参照 | コンパイラ/チェッカーオプション |
| `[[require]]` | `Table` | 下記参照 | 依存関係 |
| `[[lean_lib]]` | `Table` | 下記参照 | ビルドターゲット |

### 依存関係

| 名前 | ソース | 説明 |
|-----|--------|------|
| `mathlib` | `leanprover-community/mathlib4` | コミュニティ数学ライブラリ。`lake-manifest.json` にピン留め。 |

### ビルドターゲット

| ターゲット | ルートファイル | 説明 |
|-----------|-------------|------|
| `WasmNum` | `WasmNum.lean` | コア定義のみ |
| `WasmNumProofs` | `WasmNumProofs.lean` | 定義 + すべての証明 |
| `TestAll` | `TestAll.lean` | フルテストスイート（414テスト） |

### Lean オプション

| オプション | 型 | 値 | 説明 |
|-----------|-----|-----|------|
| `autoImplicit` | `Bool` | `false` | auto-implicit 引数を無効化。すべての変数を明示的に宣言する必要がある。 |
| `relaxedAutoImplicit` | `Bool` | `false` | relaxed auto-implicit を無効化（`autoImplicit` のコンパニオン）。 |

## lean-toolchain

正確な Lean 4 バージョンをピン留め。

| フォーマット | 現在の値 |
|------------|---------|
| `leanprover/lean4:v{version}` | `leanprover/lean4:v4.29.0-rc6` |

## lake-manifest.json

自動生成される依存関係ロックファイル。すべての推移的依存関係の正確なリビジョンを含む。

| 依存関係 | 型 | リビジョン（ピン留め） |
|---------|-----|---------------------|
| `mathlib` | `git` | `09c7a883755f6005ca7f950a3935bfa9928cb5cb` |

> **Warning:** `lake-manifest.json` を手動で編集しないでください。`lake update` を使用して更新。

## 設定ファイルのまとめ

| ファイル | 目的 | 編集可能 |
|---------|------|---------|
| `lakefile.toml` | ビルドターゲット、依存関係、オプション | はい |
| `lean-toolchain` | Lean バージョンピン | はい（慎重に） |
| `lake-manifest.json` | 依存関係ロック | いいえ（自動生成） |

## 関連ドキュメント

- [インストール](../getting-started/installation.md)
- [ビルド](../development/build.md)
- [設定ガイド](../guides/configuration.md) — 一般的な設定タスクのハウツーガイド
- [English Version](../../en/reference/configuration.md)
