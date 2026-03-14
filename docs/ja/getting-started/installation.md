# インストール

> **対象読者**: ユーザー、開発者

## 前提条件

### Lean 4

[elan](https://github.com/leanprover/elan)（Lean ツールチェーンマネージャー）経由で Lean 4 をインストールします：

**Linux / macOS:**
```bash
curl https://raw.githubusercontent.com/leanprover/elan/master/elan-init.sh -sSf | sh
```

**Windows:**
```powershell
# winget 経由
winget install leanprover.elan

# または https://github.com/leanprover/elan/releases からダウンロード
```

正確な Lean バージョンは `lean-toolchain` にピン留めされています（現在 `leanprover/lean4:v4.29.0-rc6`）。elan はビルド時に適切なバージョンを自動的にインストールします。

### Lake

Lake は Lean 4 のビルドシステム兼パッケージマネージャーです。すべての Lean 4 インストールにバンドルされており、別途インストールは不要です。

## 依存関係として追加

プロジェクトの `lakefile.toml` に wasm-num を追加します：

```toml
[[require]]
name = "wasm-num"
scope = "Provenance-Works"
```

必要なモジュールをインポートします：

```lean
-- すべての定義（証明なし）
import WasmNum

-- 定義 + すべての証明
import WasmNumProofs

-- 個別モジュール
import WasmNum.Numerics.Integer.Arithmetic
import WasmNum.SIMD.V128.Lanes
import WasmNum.Memory.Core.FlatMemory
```

## ソースからビルド

```bash
# クローン
git clone https://github.com/Provenance-Works/wasm-num.git
cd wasm-num

# Mathlib キャッシュを取得（Mathlib をソースからビルドすることを回避）
lake exe cache get

# 定義 + 証明をビルド
lake build
```

> **Note:** 初回の `lake exe cache get` はビルド済み Mathlib olean ファイルを約 2 GB ダウンロードします。以降のビルドはインクリメンタルで高速です。

## インストールの確認

```bash
# 定義のみビルド
lake build WasmNum

# 定義 + 証明をビルド
lake build WasmNumProofs

# テストスイートを実行
lake build TestAll
```

3つのコマンドすべてが終了コード 0 で完了し、`sorry` 警告がないことを確認してください。

## エディタ設定

**VS Code**（推奨）：
1. [lean4 拡張機能](https://marketplace.visualstudio.com/items?itemName=leanprover.lean4)をインストール
2. wasm-num フォルダを開く
3. 拡張機能が `lean-toolchain` を自動検出し、言語サーバーを設定

**Emacs**: [lean4-mode](https://github.com/leanprover/lean4-mode) を使用

**Neovim**: [lean.nvim](https://github.com/Julian/lean.nvim) を使用

## 関連ドキュメント

- [クイックスタート](quickstart.md) — 最小動作例
- [開発環境セットアップ](../development/setup.md) — コントリビューター向けフルセットアップ
- [設定](../guides/configuration.md) — ビルドオプション
- [English Version](../../en/getting-started/installation.md)
