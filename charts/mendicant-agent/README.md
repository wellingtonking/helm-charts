# Mendicant Scanner Worker

Run one serial Go worker against a direct Mendicant API origin.
The v2 image discovers the configured Applications and executes serial image tasks using pinned Trivy and its bundled database.

Pin `image.digest` and set `serverURL`. Supply private pull access through `image.pullSecrets`.
The referenced token Secret must already exist in this namespace.
Only `token.key` is projected into the pod; it receives no other principal tokens or database credentials.
The worker has no inbound Service or Kubernetes API token. A dedicated cache volume defaults to PVC storage.

The source repository owns wire semantics and timing/limit policy; the image includes the shared v2 policy.
Real scans record actual observation times. The server decides result source from its trusted binding.
The database snapshot is bundled at image build time. Compatible workers also retain immutable runtime refresh snapshots.
Chart 0.5.0 requires a worker supporting `MENDICANT_DATABASE_STORE_MAX_BYTES` and server-directed refresh.
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

## Database Cache Storage

`cache.mode` defaults to `pvc`. The chart creates `mendicant-agent-cache`, with ReadWriteOnce access and an 8-GiB request.
Set `cache.existingClaim` to reuse an operator-managed claim; the chart then creates no PVC.
That claim must provide at least `cache.size`; Helm cannot verify its actual capacity or permissions.
`cache.storageClass` selects a class. Empty uses the cluster default; `-` explicitly requests no storage class.
Removing a chart-created claim follows Helm and storage-class reclaim policy. Back up retained cache data when required.

Set `cache.mode: emptyDir` for clusters without persistent storage. This uses disk-backed emptyDir, not memory-backed tmpfs.
Container restart within the same Pod preserves it; Pod replacement loses it. The bundled database remains available in either mode.

`cache.maxBytes` is a quoted decimal byte limit, default `"4294967296"` (4 GiB). It bounds retained/staging data inside the worker.
`cache.size` defaults to `8Gi`; use a positive Mi/Gi/Ti quantity. Render validation requires at least 64 MiB above the logical budget.
This headroom is a minimum validation guard, not guaranteed free space. Keep staging, filesystem overhead, and other node consumers in mind.
The physical volume does not enforce the worker's byte accounting; existing claims and shared node disks can still run out of space.

The cache mounts at `/var/lib/mendicant/database`; writable scratch remains separately mounted at `/tmp` with a 2-GiB limit.
Do not mount cache storage over `/app/cache`, which contains the immutable fallback database.
The Pod retains UID/GID/fsGroup 10001, a read-only root filesystem, and Recreate deployment strategy.
`fsGroupChangePolicy: OnRootMismatch` applies only to supporting persistent-volume drivers, not emptyDir.
A real cluster smoke test must verify writable access and cache survival/loss for the selected mode before rollout.
Docker-volume acceptance in the source repository does not establish CSI ownership behaviour.

## Optional Live Application Notices

Chart 0.6.0 adds `publication.enabled`, disabled by default. Use a compatible agent image and server notice-feed endpoint.
Keep discovery and publication credentials separate. ArgoCD PATCH requires Application get/update permissions; discovery remains read-only.
ArgoCD RBAC cannot restrict annotation keys. The publisher code constrains its patches to the five adopted notice keys.
Obtain explicit operator approval for that permission boundary before provisioning the publication account.
Set `discovery.integrationKey` and explicit `discovery.destinations` aliases for the installation.
Set `publication.onePasswordItemPath`, `publication.secretName`, and the non-secret `publication.publicURL` before enabling.
The item contains only `token`; the chart projects that key read-only at `/run/argocd-publication/token`.
The chart generates integration configuration and rolls the worker when discovery/publication settings change.
It does not create ArgoCD accounts or configure GitOps ownership ignores. Provision both before enabling publication.
The source repository's `docs/operations/COVERAGE_AND_NOTICES.md` owns guard semantics and combined rollout acceptance.

## Private registry access

Set `registryAccess.credentials.<name>.onePasswordItemPath` to an item with
`username` and `token` fields. Each rule selects a credential for a registry
host. Add a `repository` path to make the rule an exact override. Set
`tokenURL` to the trusted HTTPS token endpoint for Bearer authentication.
Keep the values in the environment repository. The chart projects the two
credential fields into the agent as read-only files.
