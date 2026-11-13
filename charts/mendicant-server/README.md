# Mendicant Server Development Chart

Deploy the assessment API and a dedicated MariaDB managed by the existing MariaDB Operator.
This chart requires the MariaDB and 1Password Operators, their CRDs, and a network-policy-capable CNI.
Database contents are disposable; the persistent volume supports restarts, not backup or high availability.

## Configuration

Pin `image.digest` to the published `ghcr.io/wellingtonking/app-mendicant/server` image.
Configure private image pull access through `image.pullSecrets`.
Set `onePassword.databaseItemPath` and `onePassword.tokensItemPath` to user-managed items.
The chart never contains secret values.

The database item provides `root-password`, `migrator-password`, `runtime-password`, `migrator-url`, and `runtime-url`.
The migrator URL uses `mendicant_migrator`; the runtime URL uses `mendicant_runtime`.
Both use database `mendicant` on `mendicant-mariadb.<namespace>.svc.cluster.local:3306`.
URLs may retain `<migrator-password>` or `<runtime-password>` in their password position.
Each process receives only its corresponding URL and raw password fields.
The work runtime has SELECT, INSERT, and UPDATE permissions only; DDL remains with migration credentials.

The token item provides independent `wk-proxy`, `wk-agent`, `isolation-test-proxy`, and `isolation-test-agent` tokens.
Each token must contain exactly 43 URL-safe characters from a cryptographically random generator.
Bootstrap reads the tokens without generating, replacing, or printing them.

## First Deployment

1. Set `replicaCount: 0` and `bootstrap.enabled: false`; sync database and credential resources.
2. Verify MariaDB, its runtime User/Grant, and both generated Secrets are ready. Inspect Secret key names only.
3. Enable `bootstrap.enabled` and sync. The Job applies migrations, seeds organizations, and imports the reference explicitly.
4. Verify the Job completed, then set `replicaCount: 1` and sync.
5. Verify readiness and proxy access before changing the ArgoCD UI.

The bootstrap Job does not retry failed migrations automatically. Investigate partial DDL before changing `bootstrap.revision` to run it again.
The image includes the pinned reference files; bootstrap does not contact Trivy or a container registry for a scan.
`bootstrap.revision` identifies a Job, not the schema version.

## Access And Recovery

The Service is cluster-internal. NetworkPolicies admit ArgoCD server pods to the API and application/bootstrap pods to MariaDB.
The configured MariaDB Operator namespace can also reach MariaDB for reconciliation.
Swagger remains disabled in the cluster.
The API receives neither root/migrator credentials nor integration bearer tokens.
The optional worker can reach the API from the same release/namespace but receives no database access.
For the work-loop upgrade, stop API replicas, use a new bootstrap revision for migration 0002 and agent bindings, then start the new API before enabling the worker.

Keep the completed bootstrap Job until an explicit later cleanup. Do not rerun it merely because the server restarts.
Roll back the server image by restoring a previous digest; schema rollback requires separate review.
A retained local persistent volume is not a backup. Rebuilding this environment requires the user-managed items and explicit bootstrap.
