# Repository instructions

## Branching and Git workflow

すべての変更は [`docs/branching-strategy.md`](docs/branching-strategy.md) に定めた
ブランチ戦略に従うこと。

- `main` へ直接コミットまたはpushしない。
- 最新の `main` から、変更内容に合った短命な作業ブランチを作成する。
- ブランチ名には `feature/*`、`fix/*`、`chore/*`、`docs/*`、または
  緊急時の `hotfix/*` を使用する。
- コミットメッセージはConventional Commitsに従う。
- `main` への統合はPull RequestとSquash mergeを基本とする。
- コードの統合と機能公開を分ける必要がある場合はFeature Flagを使用する。

Git操作を伴う作業では、実行前に現在のブランチとworktreeの状態を確認し、既存の
未コミット変更を保持すること。
