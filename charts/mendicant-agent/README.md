# Mendicant Scanner Worker

Run one serial Go worker against a direct Mendicant API origin.
The v2 image discovers the configured Applications and executes serial image tasks using pinned Trivy and its bundled database.

Pin `image.digest` and set `serverURL`. Supply private pull access through `image.pullSecrets`.
The referenced token Secret must already exist in this namespace.
Only `token.key` is projected into the pod; it receives no other principal tokens or database credentials.
The worker has no inbound Service, Kubernetes API token, or persistent volume.

The source repository owns wire semantics and timing/limit policy; the image includes the shared v2 policy.
Real scans record actual observation times. The server decides result source from its trusted binding.
The database snapshot is bundled at image build time; there are no runtime database updates.
A bounded scratch volume is mounted at `/tmp`; the bundled database path must remain visible.

Use Recreate deployment because one credential represents one serial agent.
Stopping a worker interrupts execution/submission. The server recovers an abandoned assignment after its fixed lease expires.
Authentication or permanent protocol errors stop the process and produce a safe structured event.

The parent environment must allow this pod to reach the Mendicant API. Do not grant database access to the worker.
The source repository's `mendicant-agent/docs/operations/TRIVY_WORKER.md` owns runtime configuration and validation details.

## Optional ArgoCD Discovery Access

Discovery credential projection is disabled by default. Enable `discovery.enabled` only after the user-managed item exists.
Set `discovery.onePasswordItemPath` and `discovery.secretName`; the chart creates the OnePasswordItem and mounts only `token` and `server-url` at `/run/argocd`, read-only.
The packaged integration configuration reads those projected files directly. The configured `in-cluster` alias resolves to the Kubernetes service origin.
Set `replicaCount: 0` during migration and `replicaCount: 1` after compatible API startup. Keep discovery enabled for the v2 worker.
The ArgoCD account needs independently managed, scoped Application-read grants. No Kubernetes API role or service-account token is added.
