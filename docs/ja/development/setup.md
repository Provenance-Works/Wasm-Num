# 開発環境セットアップ

> **対象読者**: コントリビューター

wasm-num の開発環境を構築するための完全な手順。

## 前提条件

| ツール | バージョン | 必須 | 用途 |
|-------|----------|:----:|------|
| **elan** | 最新 | はい | Lean ツールチェーンマネージャ |
| **Lean 4** | v4.29.0-rc6 | はい（elan 経由で自動） | 言語・コンパイラ |
| **Git** | ≥ 2.0 | はい | バージョン管理 |
| **VS Code** | 最新 | 推奨 | エディタ |
| **lean4 拡張機能** | 最新 | 推奨 | VS Code Lean 4 サポート |

## ステップ 1: elan のインストール

elan は Lean 4 のツールチェーンバージョンを管理します（Rust の rustup に相当）。

**Linux / macOS:**

```bash
curl https://elan.lean-lang.org/elan-init.sh -sSf | sh
```

**Windows:**

[https://github.com/leanprover/elan/releases](https://github.com/leanprover/elan/releases) からインストーラをダウンロードして実行するか、以下を使用：

```powershell
choco install elan
```

確認：

```bash
elan --version
lean --version  # クローン後 v4.29.0-rc6 が表示されるはず
```

## ステップ 2: リポジトリのクローン

```bash
git clone https://github.com/Provenance-Works/wasm-num.git
cd wasm-num
```

elan が `lean-toolchain` を読み込み、正しい Lean バージョンを自動インストールします。

## ステップ 3: Mathlib キャッシュの取得

Mathlib は大規模です。ソースからのビルドを避けてください：

```bash
lake exe cache get
```

Mathlib の事前ビルド済み `.olean` ファイルをダウンロードします。キャッシュサーバーが遅い場合はリトライするか `MATHLIB_CACHE_URL` を設定してください。

## ステップ 4: ビルド

```bash
# コア定義をビルド
lake build WasmNum

# 証明をビルド（定義を含む）
lake build WasmNumProofs

# テスト実行
lake build TestAll
```

## ステップ 5: エディタ設定

### VS Code

1. **lean4** 拡張機能をインストール（`leanprover.lean4`）
2. `wasm-num` フォルダをワークスペースルートとして開く
3. 拡張機能が `lakefile.toml` と `lean-toolchain` を自動検出
4. 任意の `.lean` ファイルを開く — Lean サーバーが自動的に起動

### Emacs

`lean4-mode` を使用。`lean` が `PATH` に通っていることを確認（elan が管理）。

### Neovim

`lean.nvim` を使用。LSP を elan 管理の `lean` バイナリに設定。

## セットアップのトラブルシューティング

| 問題 | 解決方法 |
|------|---------|
| `lean` が見つからない | elan の bin ディレクトリが PATH に含まれていることを確認（`~/.elan/bin`） |
| Lean バージョンが違う | プロジェクトディレクトリで `elan override set leanprover/lean4:v4.29.0-rc6` を実行 |
| Mathlib キャッシュミス | `lake exe cache get` を実行 — 事前ビルド済み olean をダウンロード |
| Lake ビルドタイムアウト | メモリが少ないマシンでは `LAKE_WORKERS=1` を設定 |
| VS Code がロードしない | lean4 拡張機能インストール後にウィンドウをリロード（`Ctrl+Shift+P` → "Reload Window"） |

## 関連ドキュメント

- [ビルド](build.md) — ビルドターゲットとオプション
- [トラブルシューティング](../guides/troubleshooting.md) — 詳細なトラブルシューティングガイド
- [インストール](../getting-started/installation.md) — ユーザーレベルのインストール
- [English Version](../../en/development/setup.md)
