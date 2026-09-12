# AWS staging infrastructure

Terraformで東京リージョンの学習用Staging環境を管理する。`foundation` と `runtime` は別stateであり、通常の停止では課金の大きいRuntimeだけを削除する。Productionには流用しない。

## Safety boundary

- `foundation`: VPC、subnet、route table、Security Group、ECR、IAM/OIDC、ACM/DNS検証、SSM、CloudWatch Logs/SNS、AWS Budget。
- `runtime`: NAT Gateway/EIP、ALB、Route 53 Alias、ECS、使い捨てRDS、Runtime依存alarm。
- `terraform apply` と `terraform destroy` は、plan・対象account・概算費用を提示し、明示承認を得た後だけ実行する。
- RuntimeのRDSは `skip_final_snapshot = true`、backup保持0、deletion protection無効。destroyするとStagingデータは復元できない。
- `terraform destroy -target` は使用しない。通常運用でFoundationをdestroyしない。

## Prerequisites before any paid resource

次を確定するまでapplyしない。

- AWS account、root MFA有効、root access keyなし、IAM Identity Center等の作業identity
- Budget/alert通知先、所有domain、Staging subdomain、Route 53 hosted zoneまたは外部DNS手順
- RDSが提供するPostgreSQL versionとDjango/psycopg互換性
- `10.20.0.0/16` と既存VPC/VPN/社内networkの非重複
- Frontend/Backend imageのCPU architecture（初期値X86_64）
- Django admin staticのWhiteNoise/S3方針
- 継続利用前にlocal stateをS3（versioning・暗号化・最小権限・locking）へ移行する時期

また、Runtime開始前にFrontendの `GET /health`、Backendの `GET /api/health/`、Gunicorn起動、proxy/CSRF設定、非機密fixtureを確認する。

## Local validation (no AWS changes)

Terraform CLI `1.16.1` を使用する。AWS providerは `6.62.0` に固定している。

```powershell
terraform -chdir=infrastructure/environments/staging/foundation fmt -check
terraform -chdir=infrastructure/environments/staging/foundation init -backend=false
terraform -chdir=infrastructure/environments/staging/foundation validate

terraform -chdir=infrastructure/environments/staging/runtime fmt -check
terraform -chdir=infrastructure/environments/staging/runtime init -backend=false
terraform -chdir=infrastructure/environments/staging/runtime validate
```

`init` が生成する `.terraform.lock.hcl` はreviewしてcommitする。`.terraform/`、state、実tfvars、planはGitに保存しない。

## First foundation plan

```powershell
Copy-Item infrastructure/environments/staging/foundation/terraform.tfvars.example infrastructure/environments/staging/foundation/terraform.tfvars
# terraform.tfvarsのplaceholderを安全な値へ変更する
aws sso login --profile <profile>
aws sts get-caller-identity --profile <profile>
terraform -chdir=infrastructure/environments/staging/foundation init
terraform -chdir=infrastructure/environments/staging/foundation plan -out=foundation.tfplan
terraform -chdir=infrastructure/environments/staging/foundation show foundation.tfplan
```

既存のGitHub OIDC providerがaccountにある場合、`create_github_oidc_provider = false` とARNを指定する。外部DNSの場合、ACMのvalidation recordを手動登録し、証明書が `ISSUED` になるまでRuntimeへ進まない。Budget email/SNS emailはAWSからの購読確認も完了する。

## Start Runtime

1. ACMが `ISSUED`、有効期限14日以上、DNS検証recordありであることをAWS CLI/Consoleで確認する。
2. commit SHA付きFrontend/Backend imageがECRにあり、選択したCPU architectureで起動できることを確認する。
3. `runtime/terraform.tfvars.example` を `runtime/terraform.tfvars` へコピーし、RDS versionとimage tagを確定する。`desired_count = 0` のままにする。
4. identity/account/regionを表示し、`terraform plan -out=runtime.tfplan` をreviewする。NAT、ALB、public IPv4、Fargate、RDSの概算も提示し、承認後だけapplyする。
5. RDS available後、出力されたBackend task definition、app subnet、Backend Security Groupを使い、`aws ecs run-task` で `python manage.py migrate --noinput` を実行する。終了code 0を確認後、別taskで `python manage.py loaddata staging_seed` を実行する。
6. 両task成功後だけ `desired_count = 1` へ変更して再plan/applyし、HTTPS、Frontend、`/api/health/`、fixture、CloudWatch Logsを確認する。

One-off taskはBackend serviceと同じtask definitionを使い、container commandだけoverrideする。migrationとfixtureをservice起動commandへ組み込まない。

## Stop Runtime

1. 必要な変更がcode/migration/fixtureへ反映済みか確認する。
2. `desired_count = 0` をplan/applyし、service停止とconnection drainingを待つ。
3. Runtime rootで `terraform plan -destroy -out=runtime-destroy.tfplan` を作り、RDSデータ消失と削除対象を提示する。
4. 明示承認後だけRuntime root全体へ `terraform destroy` を実行する。
5. tag検索、Resource Explorer、Cost ExplorerでNAT Gateway/EIP、ALB、ECS task/service、RDS、Runtime alarm、Route 53 Aliasの残存がないことを確認する。RDS管理Secretも確認する。
6. VPC、subnet、Security Group、ECR、IAM/OIDC、ACM validation record、SSM、log group、BudgetがFoundationとして残っていることを確認する。

部分失敗時もRuntime root全体のdestroy planを作る。stateと実体がずれた場合は原因を調査し、import等をreviewしてから復旧する。

## Cost expectation

東京リージョン、低traffic、月20時間程度、Frontend/Backend各0.25 vCPU/0.5 GiB、NAT 1台、ALB 1台、Single-AZ小型RDSを前提に月5–20 USDが初期目安。これは保証額ではなく、public IPv4、LCU、NAT処理量、cross-AZ/internet転送、log、ECR/DNS、destroy遅延、税・為替で増減する。apply前にAWS Pricing Calculatorで再見積もりする。Budgetの5/10/20 USD通知は自動停止ではない。
