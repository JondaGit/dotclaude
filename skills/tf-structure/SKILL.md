---
name: tf-structure
description: Use when creating, splitting, or reorganizing Terraform (.tf) files, adding a new resource and choosing which file it belongs in, adding an `output` block, reviewing TF file layout, or whenever the user asks to follow the project's TF file structure convention. Also use when you notice TF files that violate the naming or output-location conventions.
---

## Organizing Principle

Terraform files are split by **problem domain** (what part of the system this is), not by Terraform concept (resources vs. outputs vs. data) and not by AWS primitive. A reader scanning the directory should learn the system's shape from filenames alone.

Two rules carry the whole convention:

1. Each `.tf` file is named `<category>_<component>[_<subcomponent>].tf` and contains everything for that component — including its outputs.
2. The directory has no central `outputs.tf`. Outputs are the public interface of the component that produces them; they live next to the resource they expose.

The exceptions are project-wide files that don't belong to any single component: `config.tf`, `locals.tf`, `variables.tf`, `terraform.tfvars`, `terraform.tfvars.example`.

## Naming Pattern

```
<category>_<component>[_<subcomponent>].tf
```

- **category** — the problem domain (see list below)
- **component** — the thing within the domain (`rds`, `ecs_backend`, `dns`, `s3_access_logs`)
- **subcomponent** — optional narrower slice when one component splits into focused files (`database_rds_bootstrap.tf`, `database_rds_cloudwatch.tf`, `network_dns_dnssec.tf`)

All segments are `snake_case`. Plural vs. singular follows the AWS/Terraform name of the thing (`network_security_groups.tf`, `compute_ecs_cluster.tf`).

## Categories

These seven cover almost everything. Prefer them strongly. Only introduce a new prefix when none of these is a defensible fit, and surface that choice to the user.

- **compute_** — anything that runs code: ECR, ECS clusters/services/tasks, Lambda, EC2 workloads
- **database_** — persistent stateful stores: RDS, ElastiCache, OpenSearch, DynamoDB
- **ingress_** — public traffic entry: ALB/NLB, WAF, API Gateway, CloudFront
- **network_** — VPC plumbing: subnets, DNS, NAT, security groups, endpoints, flow logs, peering
- **security_** — audit and secret material that isn't tied to one component: CloudTrail, Secrets Manager, KMS keys, IAM baselines
- **storage_** — buckets and object stores: S3 (usually `storage_s3_<purpose>.tf`), EFS
- **tools_** — operator-facing utilities: jump/bastion servers, debugging endpoints, one-off automation

When a resource could plausibly live in two categories, pick the one that describes **what the resource exists for in this system**, not what AWS calls it. An S3 bucket holding VPC flow logs is `storage_s3_vpc_flow_logs.tf` (it's storage, and it stores flow logs) — not `network_vpc_flow_logs.tf`.

## Outputs

Outputs go in the file that declares the resource or module they expose. There is no `outputs.tf`.

The reason: an output is part of a component's contract — what it offers to the rest of the project. Splitting outputs into a separate file hides that contract behind a wall and forces a context switch on every change. Co-locating means the answer to "what does this component expose?" lives one screen-scroll from the resource itself.

When a component spans multiple files (e.g., `database_rds.tf`, `database_rds_bootstrap.tf`, `database_rds_cloudwatch.tf`), put each output in the file that declares the underlying resource — not in the "primary" file of the group.

## Variables

Variables stay centralized in `variables.tf`. They are the project's inputs from the outside (CI, user, env), not owned by any one component, so they belong in one scannable place. This is the deliberate asymmetry with outputs.

## Behavior

**When writing new Terraform:**
- Pick the file by category + component. If the right file exists, add to it. If it doesn't, create it following the pattern.
- New `output` blocks go in the same file as the resource they reference. Never create or extend `outputs.tf`.
- New input variables go in `variables.tf`.

**When you spot a violation** (an `outputs.tf` with content, a file that doesn't match the pattern, an output declared away from its resource):
- Point it out and explain the convention briefly.
- Propose the concrete fix (which file the output should move to, what the file should be renamed to).
- **Do not move or rename files unless the user agrees or asked for cleanup.** Style migrations churn diffs and create review noise — they deserve their own deliberate change.

**When the user explicitly asks to clean up / follow the convention / split `outputs.tf`:**
- Move each output to the file declaring the resource its `value` references.
- For outputs whose underlying resource has been removed or commented out, ask before deleting — they may be intentional documentation.
- Preserve comments, `description`, and `depends_on` exactly.

## Edge Cases

- **Cross-component outputs** (an output whose value combines resources from two files) — put it in the file of the resource that conceptually "owns" the exposed value. If genuinely ambiguous, ask.
- **Heredoc / computed outputs** (e.g., a `run-task` command line) — these live with whichever resource is the primary subject of the command, not in a separate "commands" file.
- **Module-only outputs** (re-exporting a module's output) — put the re-export in whichever file declares the `module` block.
- **`terraform.tfvars`** is a value file, not a structural file. Don't restructure it to match the source layout; keep variables grouped by logical concern for human readability.
