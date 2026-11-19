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

For the pinned Trivy upgrade, stop API and worker, drain outstanding work, and migrate with a new bootstrap Job revision.
Set `bootstrap.enableDevelopmentTrivy: true` only for this approved development profile. It explicitly activates W&K's scanner binding after migration and seeding.
Do not mutate a completed Job or switch bindings while work is in flight.

## V2 Stopped Upgrade

Version 0.4.0 accepts a credential-free `bootstrap.v2Configuration` object matching the reviewed server seed input.
When configured, bootstrap runs only migration and `seed-v2`; it neither reimports reference findings nor changes legacy bindings.
The ConfigMap mounts at `/run/configuration/v2.json`. Existing v1 organizations and principal credentials must already exist.
Keep both API and worker replicas at zero until the uniquely named Job succeeds, then start the API and verify legacy reads before worker startup.
The source repository owns schema 0005, guarded rollback, and the stopped-cutover acceptance procedure.

## Recorded Periodic Reassessment

Chart 0.5.0 exposes server scheduling for schema 0008 and its matching worker protocol.
`scheduler.enabled` defaults to false. Enable it only after stopped migration and worker/storage readiness checks.
`scheduler.reassessmentIntervalSeconds` and `scheduler.databaseRefreshIntervalSeconds` default to 86400; `scheduler.pollSeconds` defaults to 5.
Keep settings identical across API replicas. Database transactions own due times and prevent duplicate admission.
Short test intervals change schedule generations; restore both cadences to 86400 after acceptance.
Disabling scheduling stops new admission and preserves due history and active work.
The source server's `docs/operations/SCHEDULING.md` owns runtime semantics and recovery.
Use the existing uniquely named bootstrap Job for explicit migration. Never restart an old image against schema 0008 as an implicit rollback.
