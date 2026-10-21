# Conceptual HA design: two-region Cloud Run

## Architecture

```text
Clients
  |
  v
Cloud DNS (optional managed DNS)
  |
  v
Global external Application Load Balancer
  |-- Cloud Armor security policy (WAF / rate controls)
  |-- Google-managed TLS certificate
  |
  +--> Serverless NEG: Cloud Run service in Region A
  |
  +--> Serverless NEG: Cloud Run service in Region B
           |
           +--> Regional Cloud Run revisions, min instances and independent scaling
           |
           +--> Shared/replicated dependencies (must be designed separately)
```

Use a global external Application Load Balancer with serverless network endpoint groups (NEGs) for each regional Cloud Run service, and attach Cloud Armor to the backend service. Configure Cloud Run ingress as `internal-and-cloud-load-balancing` to prevent clients from bypassing the load balancer through the default service URL. Verify the exact supported LB / Cloud Run configuration in the target project and region before implementation.

## Routing, failure detection, failover, recovery, failback

- The global load balancer routes to configured serverless NEGs. Configure health/availability signals and alerting suitable for serverless backends; do not assume a conventional VM health check behaves identically for serverless NEGs.
- Use Cloud Monitoring synthetic checks and regional request/error/latency metrics to detect application-level failure that a basic backend signal may not detect.
- If Region A is unhealthy, remove or deprioritize it through the supported backend/routing control and send traffic to Region B. Automating this requires a tested health signal and control mechanism; it is not guaranteed merely by creating two services.
- Keep both regions deployable from the same immutable image digest and compatible configuration. Validate capacity/quota in Region B for the full expected load.
- Recover Region A, verify smoke tests and dependency health, then fail back gradually (small traffic share, monitor, increase) rather than immediately restoring 100%.
- Test failover and failback with game days, including region-specific dependency failure and quota constraints.

## Stateful and external dependencies

Two stateless Cloud Run services do not make the whole system HA by themselves. Evaluate:
- Database availability, replication lag, leader election, write conflict behavior, and regional failover.
- Object storage and any regional buckets; replication and recovery point.
- Secret Manager access and IAM propagation.
- External APIs, DNS, payment/email providers, rate limits, and allowlists.
- Shared caches, queues, scheduled jobs, and idempotency.
- Artifact Registry availability and image availability in both regions.
- Quotas, VPC connectors/egress, NAT, DNS, and logging/monitoring dependencies.

Prefer regional independent dependencies where possible; otherwise document the shared dependency as a common-mode failure.

## RTO / RPO assumptions

Illustrative target only, not a guarantee:
- **RTO:** 5–15 minutes for regional service failure, assuming Region B is deployed, has quota/capacity, dependencies are healthy, and failover is automated or runbook-driven.
- **RPO:** 0 for a purely stateless service with no local state; for data, RPO depends entirely on the backing store's replication and consistency model. State a separate measured RPO for each dependency.

Validate with timed failure-injection exercises, synthetic checks, request success/latency graphs, dependency replication metrics, and an observed recovery timeline. Do not claim an RTO/RPO until it has been tested.

## Identity, secrets, observability, rollback

- Separate deployment identity from runtime identity. GitHub uses OIDC + Workload Identity Federation; runtime uses a dedicated service account with only required permissions.
- Keep secret values in Secret Manager and grant the runtime identity access only to specific secrets.
- Correlate request logs/traces with revision, commit SHA, image digest, region, and release ID. Alert on SLO burn and dependency errors.
- Roll back each region to the previous known-good immutable digest; ensure the load balancer can keep healthy-region traffic flowing while one region rolls back.
- Cloud Armor rules should be tested in preview before enforcement and monitored for false positives.

## Cost and limits

Two active regions, min instances, load balancer, Cloud Armor, logging, egress, replicated dependencies, and synthetic checks increase cost. Use budgets/alerts and load-test capacity. A lower-cost active/passive design can be considered, but failover time and cold-start capacity must be measured.

## Implemented vs. conceptual

This repository implements one reusable Cloud Run Terraform module and separate dev/prod roots. The two-region load balancer, Cloud Armor policy, serverless NEGs, regional service duplication, traffic failover automation, and game-day validation are design-only and are not claimed as deployed.
