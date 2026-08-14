# ブランチ戦略

## 方針

このリポジトリでは、`main` を中心とした trunk-based development を採用する。
`develop` のような長期ブランチは設けず、短命な作業ブランチから Pull Request
（PR）を通して `main` に統合する。

```text
feature/* ─┐
fix/*     ─┼─> Pull Request ─> main ─> release
chore/*   ─┘
```

`main` は常にテストを通過し、リリース可能な状態に保つ。

## ブランチの種類

| ブランチ | 用途 | 例 |
| --- | --- | --- |
| `main` | 統合済みのリリース可能なコード | `main` |
| `feature/*` | 新機能 | `feature/practice-session` |
| `fix/*` | 通常の不具合修正 | `fix/session-duration-validation` |
| `chore/*` | CI、依存関係、開発環境など | `chore/add-github-actions` |
| `docs/*` | 文書だけの変更 | `docs/api-usage` |
| `hotfix/*` | 本番障害の緊急修正 | `hotfix/login-failure` |

ブランチ名には、小文字の英数字とハイフンを使用する。フロントエンドと
バックエンドをまたぐ変更も、レイヤー別ではなく機能単位で1つのブランチにまとめる。

## 通常の開発フロー

1. 最新の `main` から作業ブランチを作成する。
2. レビュー可能な小ささで変更し、テストを追加または更新する。
3. PRを作成し、CIとレビューを通す。
4. Squash mergeで `main` に統合する。
5. マージ後、作業ブランチを削除する。

```powershell
git switch main
git pull --ff-only
git switch -c feature/practice-session
```

作業ブランチは数日以内の短命なものを基本とする。変更が大きい場合は、利用者から
見えない形で段階的に統合できる単位へ分割する。

## コミット

コミットメッセージは Conventional Commits に合わせる。

```text
feat: add practice session API
fix: reject negative practice durations
chore: add frontend lint workflow
docs: document local development
test: add session endpoint tests
```

1つのコミットには、後から意図を説明できる1つの論理的な変更を含める。

## Pull Requestとマージ

- `main` への直接pushは行わない。
- PRには変更理由、変更内容、確認方法を記載する。
- CIの成功と未解決コメントの解消をマージ条件とする。
- 複数人で開発する場合は、1人以上の承認を必須とする。
- 原則としてSquash mergeを使用し、`main` の履歴をPR単位に保つ。
- force pushと履歴の書き換えを `main` では禁止する。

## 未完成機能とFeature Flag

コードの統合と利用者への公開を分離する必要がある場合はFeature Flagを使用する。
フラグがOFFの間は、新機能を `main` に統合しても利用者に表示または提供しない。

初期段階では環境変数などの単純な仕組みを使用する。利用者別の公開や即時切り替えが
必要になった場合は、バックエンドや専用サービスでの管理を検討する。

公開が安定したらフラグと旧実装を削除し、不要な条件分岐を残さない。

## リリース

リリース専用ブランチは作成せず、`main` の対象コミットにSemantic Versioningのタグを
付ける。

```text
v0.1.0
v0.2.0
v1.0.0
```

緊急修正は最新の `main` から `hotfix/*` を作成し、通常と同様にPRとCIを通して
`main` へ戻す。

## `develop` を設けない理由

現在は `main` を常にリリース可能に保てる開発規模であり、`develop` を追加すると
マージが二段階になり、ブランチ間の同期やhotfixの二重反映が必要になるためである。

次のような要件が生じた場合は、この方針を見直す。

- 複数機能をまとめて決まった日程でリリースする。
- 長期間の結合テストや承認期間が必要になる。
- 複数のリリースバージョンを並行して保守する。

見直し時には、長期ブランチを追加する前に、Feature Flagや一時的な `release/*`
ブランチで要件を満たせないか検討する。
