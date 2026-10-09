# Oracle E-Business Suite GitOps Modernization

| Field   | Value                                              |
| ------- | -------------------------------------------------- |
| Version | 1.5                                                |
| Date    | 2026-10-06                                         |
| Status  | Proposed                                           |
| Nature  | Living reference, updated as evidence is validated |

## 1. Purpose and Scope

Modernize release control for Oracle E-Business Suite customizations using GitHub and GitOps practices.

- The target solution does not depend on legacy release tooling.
- The allowlist of schemas remains unchanged for now.
- Privilege review, Security alignment and cultural change are deferred.

## 2. Core Requirements

Every change must be identifiable, traceable and reversible.

| Requirement           | Description                                                                                           |
| --------------------- | ----------------------------------------------------------------------------------------------------- |
| Object identification | Each object is identified by edition, owner, type and name, with status, capture metadata and hash.   |
| Pre/post comparison   | Objects are captured before and after deployment and compared against the approved manifest.          |
| Tracking              | Every change links request, approval, commit, branch, pull request, manifest, artifact and execution. |
| Logging               | Every step and validation produces a log referenced by change and execution identifiers.              |
| Versioning            | Every artifact is versioned and tied to a commit and a manifest.                                      |
| Rollback              | Every change has a defined, authorized and validated reversal path.                                   |

Related objects (for example a package specification and its body) are tracked as related artifacts with independent hashes and states.

## 3. Environment

### Confirmed

- Oracle E-Business Suite `12.2.12`.
- Oracle Database `19c Enterprise Edition Extreme Performance`.
- Environment: `DEV`.
- Session edition and `DEFAULT_EDITION`: `V_20261001_1432` (parent `V_20260925_0826`, usable).
- Run edition: `V_20261001_1432`.
- ADOP version: `C.Delta.17`. Latest session: 426, all phases completed on both nodes (cutover 2026-10-01, cleanup 2026-10-01). No active patching cycle as of the 2026-10-08 status check.
- Two application nodes (primary and secondary). File system synchronization type: `Full`.
- ADOP logs location: `<NE_BASE>/EBSapps/log/adop/<session_id>/<timestamp>/`.

### Preliminary

- Custom objects (`XX%`) exist in `APPS` and in dedicated custom schemas.
- Broad `CREATE ANY` / `ALTER ANY` privileges exist in `DEVELOPER_ROLE` and `DNVGL_DEVELOPER_ROLE`.
- Unified Auditing is reported as enabled; coverage is not established.
- A DDL trigger is active: `XXISV.XXISV_MSFTR_CTL_DDLH`.
- Object DDL timestamps after the 2026-10-01 cleanup indicate changes applied directly in the run edition outside a patching cycle. Attribution is pending.

### Pending

- Confirm with Basis that the missing finish time and elapsed value for the APPLY phase on the primary node are expected.
- Re-run the ADOP status check in every deployment preflight.

## 4. Evidence Log (addition)

| ID    | Evidence                                                                                   | Status    |
| ----- | ------------------------------------------------------------------------------------------ | --------- |
| E-002 | ADOP status output, session 426, retrieved 2026-10-08. All phases completed on both nodes. | Confirmed |

## Change History (addition)

| 1.6 | 2026-10-08 | Added E-002 (ADOP status), confirmed run edition and no active cycle, noted post-cleanup DDL activity. |

## 4. Evidence Log

| ID    | Evidence                                                                                                                                                                     | Status      |
| ----- | ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | ----------- |
| E-001 | Inventory capture, edition `V_20261001_1432`, captured at `2026-10-06T12:18:58 +02:00`. Columns: owner, object_type, object_name, status, last_ddl_time, line_count, sha256. | Preliminary |

### E-001 Notes

- Owners observed: `APPS`, `XXABNK`, `XXBLACKLINE`, `XXCONV`, `XXDNVGL`, `XXFINBI`, `XXISV`.
- Types observed: function, package, package body, procedure, trigger, type, type body.
- The capture shared in chat was truncated; findings must be confirmed against the full output.
- Invalid objects reported in the sample:
  - `APPS.XXDNVGL_GCC_SC_INT_PKG` (package and package body)
  - `APPS.XXDNV_ESS_RESP_PKG` (package body)
- One `last_ddl_time` value appears malformed (`XXDNVGL_OKS_BILLING_WRAPPER`). It must be corrected or flagged before any manifest is generated.
- `line_count` is metadata only and is not evidence of change.
- The capture does not identify who made a change. Attribution requires correlation with audit, session, user, host, program and connection context.

## 5. Pending Validation

1. Two consecutive captures produce identical hashes.
2. Recompilation without a change does not alter hashes.
3. A controlled change to a single test object changes only that object's hash.
4. Inventory and baseline counts reconcile.
5. The view and synonym extraction is stable.
6. Large objects hash correctly (aggregation of long source is considered fragile).
7. Compilation errors for invalid objects are retrieved from `DBA_ERRORS`.
8. Full capture reviewed for truncation and malformed values.

Scripts have been executed in `DEV`. Execution is confirmed; hash stability and correct change detection are not yet validated.

## 6. Prerequisites

- Confirmed run edition and default edition.
- Confirmed ADOP state.
- Validated baseline capture.
- Defined change identifier convention.
- Defined repository structure and branch strategy.
- Private runner and service identity for deployment (MVP1-C).
- Defined log storage, retention and access rules.

## 7. MVP1 Scope

### MVP1-A: Discovery and Baseline

Inventory, owner classification, editioned and non-editioned classification, run edition, source hashes, changed candidates, session attribution and dependencies. No automatic deployment.

### MVP1-B: Selection and Publication

Candidate selection, extraction, manifest, branch and pull request in GitHub. Artifact published after approval.

### MVP1-C: Controlled Deployment

Private runner, controlled ADOP execution, preflight, `DEV` deployment, validation, history and rollback.

## 8. Traceability Model (Proposed)

| Identifier       | Purpose                                                                                                      |
| ---------------- | ------------------------------------------------------------------------------------------------------------ |
| Change ID        | Links request, scope and approval.                                                                           |
| Capture ID       | Identifies each inventory capture (pre and post).                                                            |
| Manifest ID      | Identifies the approved list of objects and expected hashes.                                                 |
| Artifact version | Identifies the published artifact, tied to a commit.                                                         |
| Execution ID     | Identifies a deployment run, including ADOP session, edition, times, steps and operator or service identity. |
| Rollback ID      | Identifies a reversal, linked to the original Change ID and Execution ID.                                    |

Object identity key: `edition + owner + object_type + object_name`.

## 9. Pre/Post Deployment Verification

After deployment, compare the post-capture to the manifest and report:

- Missing objects.
- Unexpected objects.
- Invalid objects.
- Hash differences.
- Status differences in related objects.

## 10. Rollback Requirements

- Target version and artifacts identified before deployment.
- Objects involved listed in the manifest.
- Procedure defined per change type.
- Authorization recorded.
- Execution logged under a Rollback ID.
- Post-rollback capture compared with the pre-deployment baseline.

Rollback mechanism, retention and permissions are to be defined and validated.

## 11. Future Deliverables

- Architecture Definition: MVP1
- Validated baseline report
- Manifest specification
- Deployment and rollback runbook
- Logging and retention standard

## 12. Open Items

- Privilege review and Security alignment.
- Audit coverage.
- Attribution of changes to individuals.
- Extension beyond `DEV`.

## Change History

| Version | Date       | Summary                                                                                                                   |
| ------- | ---------- | ------------------------------------------------------------------------------------------------------------------------- |
| 1.5     | 2026-10-06 | Added core requirements (identification, tracking, logging, versioning, rollback), E-001 evidence and traceability model. |
