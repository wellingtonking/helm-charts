# Mendicant Reference Worker

Run one serial Go worker against a direct Mendicant API origin.
This development worker replays the captured reference; it does not execute Trivy or access a registry.

Pin `image.digest` and set `serverURL`. Supply private pull access through `image.pullSecrets`.
The referenced token Secret must already exist in this namespace.
Only `token.key` is projected into the pod; it receives no other principal tokens or database credentials.
The worker has no inbound Service, Kubernetes API token, or persistent volume.

The default five-second delay makes running work visible during development.
The source repository owns wire semantics and timing/limit policy; the image includes the shared policy and original reference result.
The worker preserves original observation times. The server decides result source from its trusted binding.
Do not relabel these replayed findings as a fresh vulnerability scan.

Use Recreate deployment because one credential represents one serial agent.
Stopping a worker interrupts execution/submission. The server recovers an abandoned assignment after its fixed lease expires.
Authentication or permanent protocol errors stop the process and produce a safe structured event.

The parent environment must allow this pod to reach the Mendicant API. Do not grant database access to the worker.
The source repository's `mendicant-agent/docs/operations/REFERENCE_WORKER.md` owns runtime configuration and validation details.
