# 環境変数

> **対象読者**: ユーザー、運用者

wasm-num のビルドと開発に影響する環境変数。

## Lake / Lean 変数

| 変数 | デフォルト | 説明 |
|------|---------|------|
| `LAKE_HOME` | `~/.elan/lake` | Lake キャッシュ / パッケージディレクトリ |
| `LEAN_PATH` | （自動） | Lean モジュール検索パス。Lake が管理；手動設定は稀。 |
| `ELAN_HOME` | `~/.elan` | elan ツールチェーンマネージャーのインストールディレクトリ |
| `ELAN_TOOLCHAIN` | （`lean-toolchain` から） | ツールチェーンのオーバーライド。非推奨。 |
| `MATHLIB_CACHE_URL` | （デフォルト Mathlib CDN） | ビルド済み Mathlib olean のカスタム URL |

## ビルド変数

| 変数 | デフォルト | 説明 |
|------|---------|------|
| `LAKE_WORKERS` | CPU数 | 並列 Lake ビルドワーカー数 |

## CI 変数

CI 環境で設定される変数（ユーザーが設定するものではありません）：

| 変数 | コンテキスト | 説明 |
|------|-----------|------|
| `CI` | GitHub Actions / GitLab CI | CI 環境を示す |
| `GITHUB_TOKEN` | GitHub Actions | GitHub API での認証 |
| `GITLAB_CI` | GitLab CI | GitLab CI 環境を示す |

## 関連ドキュメント

- [設定リファレンス](configuration.md) — ファイルベースの設定
- [インストール](../getting-started/installation.md) — セットアップ手順
- [トラブルシューティング](../guides/troubleshooting.md) — よくある環境の問題
- [English Version](../../en/reference/environment.md)
