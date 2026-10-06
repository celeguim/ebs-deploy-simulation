# Oracle E-Business Suite GitOps Modernization

## Architecture Definition — MVP1

| Field                              | Value                           |
| ---------------------------------- | ------------------------------- |
| **Document version**               | 1.2                             |
| **Date**                           | 2026-10-06                      |
| **Status**                         | Proposed                        |
| **Communication language**         | Brazilian Portuguese            |
| **Project documentation language** | English                         |
| **Target EBS environment**         | Oracle E-Business Suite 12.2.12 |
| **Target database**                | Oracle Database 19c             |

---

## 1. Executive Summary

The project establishes a controlled, auditable, and progressively automated release process for Oracle E-Business Suite customizations.

The current environment has a large custom object footprint distributed across `APPS` and multiple custom schemas. Developers may connect directly as `APPS`, individual developer accounts exist, broad `CREATE ANY` and `ALTER ANY` privileges have been identified, and current auditing does not appear to provide sufficient coverage of custom-object DDL.

The proposed solution will:

1. Inventory custom objects in the EBS database.
2. Detect object changes by comparing normalized content hashes against an approved baseline.
3. Allow users to review and select candidate objects for a change.
4. Extract selected objects and their relevant metadata.
5. Generate a versioned release manifest containing checksums, object ownership, dependencies, and execution characteristics.
6. Commit the resulting source and manifest to GitHub through a reviewed pull request.
7. Deploy releases to DEV using a controlled, ADOP-aware runner with preflight checks, execution ordering, post-deployment validation, and rollback capability.

**MVP1 is divided into three sub-phases: MVP1-A (inventory and detection), MVP1-B (capture and manifest), and MVP1-C (controlled DEV deployment).** Each sub-phase has its own exit criteria and must be validated before the next begins.

---

## 2. Project Context

### 2.1 Current environment

The environment information confirmed so far is:

| Property                | Confirmed value                                                                          |
| ----------------------- | ---------------------------------------------------------------------------------------- |
| Oracle E-Business Suite | 12.2.12                                                                                  |
| Oracle Database         | 19c Enterprise Edition Extreme Performance                                               |
| EBS database container  | `DEV`                                                                                    |
| Current session edition | `V_20261001_1432`                                                                        |
| Application tier nodes  | `ocifra2041`, `ocifra2042`                                                               |
| Online patching         | `adop` is used                                                                           |
| Unified Auditing        | Enabled                                                                                  |
| Custom object owners    | `APPS` and multiple custom schemas                                                       |
| Developer access        | Individual `DEV_*` accounts exist; direct development sessions as `APPS` were observed   |
| Developer privileges    | Broad `CREATE ANY` and `ALTER ANY` system privileges are granted through developer roles |
| DDL audit coverage      | Existing evidence is incomplete for custom objects                                       |

The current session edition is **not sufficient by itself** to establish which edition is the run edition. The run edition and ADOP state must be verified before implementing capture or deployment operations.

### 2.2 Project principles

- **GitHub is the version-control system of record.**
- **The EBS database is the source for initial discovery and extraction**, not the long-term source of truth for released code.
- **No automatic deployment occurs before MVP1-C.**
- **Selected changes require review and approval in GitHub.**
- **Artifacts and manifests are immutable once a release is approved.**
- **Production credentials and direct database access are not exposed to GitHub-hosted runners.**
- **Deployment must follow Oracle EBS 12.2 online-patching requirements and be validated against the environment's AD/TXK level and Oracle guidance.**

---

## 3. MVP1 Structure

MVP1 is organized into three sequential sub-phases. Each sub-phase must be completed and validated before the next begins.

### 3.1 MVP1-A — Inventory and Detection

**Goal:** establish a reliable, repeatable inventory of custom objects and a hash-based change detection mechanism.

**Deliverables:**

- Inventory of custom objects within the approved schema and object-type scope.
- Classification by owner, object type, and edition-related characteristics (editioned vs. noneditioned).
- Identification of the run edition.
- Baseline snapshot with normalized content hashes.
- Hash-based change detection for PL/SQL objects.
- Candidate list reporting `NEW`, `MODIFIED`, `MISSING`, and `UNCHANGED` objects.
- Session identification for future change attribution (audit policy or trigger design).
- Dependency report using `DBA_DEPENDENCIES` and documented AOL rules.

**Exit criteria:**

- Repeated snapshots of unchanged objects produce stable hashes.
- A controlled test change is correctly detected and classified.
- The run edition is confirmed and the ADOP pre-check procedure is documented.
- Dependency reporting identifies both resolved and unresolved dependencies.
- No deployment or DDL execution occurs.

### 3.2 MVP1-B — Capture and Manifest

**Goal:** enable user-driven selection of candidate objects, extraction of source code, and generation of a validated release manifest committed to GitHub.

**Deliverables:**

- User interface or CLI change-set format for selecting candidate objects.
- Source code extraction for the agreed object types.
- Release manifest generation with SHA-256 checksums, ownership, dependencies, and selection origin.
- Manifest validation (schema, file existence, checksum consistency, dependency references).
- GitHub branch creation with extracted source and manifest.
- Pull request submission for review and approval.
- Artifact publication only after pull request approval.

**Exit criteria:**

- A user can select objects associated with a change request.
- Selected objects are extracted into the agreed repository structure.
- The generated manifest passes all automated validations.
- A GitHub pull request is created and reviewed.
- The process is repeatable with traceable results.
- No deployment or DDL execution occurs.

### 3.3 MVP1-C — Controlled DEV Deployment

**Goal:** execute approved releases in DEV using a private runner with ADOP awareness, preflight checks, ordered execution, post-deployment validation, and rollback capability.

**Deliverables:**

- Private GitHub Actions runner within the DEV environment.
- ADOP-aware deployment executor (online patching for editioned objects, direct execution for noneditioned objects).
- Preflight checks: ADOP status, previous release verification, invalid object baseline, disk space, backup.
- Ordered step execution respecting schema connections, object dependencies, and execution layers.
- Post-deployment validation: recompilation, `USER_ERRORS` check, smoke tests.
- Deployment history recording in `XX_DEPLOY_HISTORY` and `XX_DEPLOY_STEP_HISTORY`.
- Rollback via redeployment of the previous release.

**Exit criteria:**

- A release can be deployed to DEV with full preflight and postflight checks.
- Deployment history is recorded and queryable.
- A failed deployment stops at the failing step and records the error.
- Rollback to the previous release is tested and confirmed.
- The same immutable artifact is used for deployment and rollback.

---

## 4. Scope

### 4.1 Initial in-scope object types

The initial inventory and extraction scope should prioritize database objects with reliable source representations:

- Package specifications and package bodies
- Procedures and functions
- Views
- Triggers
- Types and type bodies
- Synonyms
- Sequences
- Tables and indexes, subject to a reviewed extraction and normalization policy
- Grants, if they are explicitly included in the approved scope

AOL objects, including concurrent programs, value sets, menus, and related definitions, may be added after the database-object workflow is proven. AOL extraction should use the appropriate `FNDLOAD DOWNLOAD` control files and object definitions; it is not covered by database source extraction alone.

### 4.2 Initial schema scope

The first implementation must use an explicit allowlist rather than scanning every schema or every `XX%` object in the database.

A proposed initial scope is:

```yaml
scope:
  schemas:
    - APPS
    - XXDNVGL

  object_name_prefixes:
    - XX

  excluded_schemas:
    - SYS
    - SYSTEM

  excluded_object_name_patterns:
    - APEX_%
    - WWV_%
    - FND_%
    - AD_%
```

The final allowlist must be approved by the EBS application owner and DBA before implementation.

### 4.3 Out of scope for the initial object scope

- Oracle-delivered objects
- APEX internal objects, unless explicitly approved
- Forms, Reports, OAF, BI Publisher, and Workflow artifacts
- Objects in schemas not yet approved for capture
- Objects that cannot be extracted or normalized reliably

---

## 5. Target Architecture

```text
                    Oracle EBS DEV
        ┌───────────────────────────────────────┐
        │ Approved schemas and custom objects   │
        │                                       │
        │  Inventory ── Snapshot ── Hash diff   │
        │                    │                  │
        └────────────────────┼──────────────────┘
                             │
                             ▼
                  Private capture component
            ┌────────────────────────────────┐
            │ ebsops                         │
            │                                │
            │ inventory / snapshot / detect  │
            │ select / extract / manifest    │
            │ validate / deploy / verify     │
            └────────────────┬───────────────┘
                             │
                             ▼
                    GitHub repository
            ┌────────────────────────────────┐
            │ Extracted source + manifest    │
            │ Branch + pull request          │
            │ Review and approval            │
            └────────────────────────────────┘
```

### 5.1 Components

| Component             | Responsibility                                                                                                                           |
| --------------------- | ---------------------------------------------------------------------------------------------------------------------------------------- |
| **EBS database**      | Provides the current definitions and metadata for in-scope objects.                                                                      |
| **Capture runner**    | Runs in a controlled network location with read access to DEV and write access to the GitHub repository or its API.                      |
| **`ebsops` CLI**      | Performs inventory, snapshot comparison, candidate selection, extraction, manifest generation, validation, deployment, and verification. |
| **Snapshot store**    | Stores approved baselines and snapshot metadata. Its implementation is a design decision for MVP1-A.                                     |
| **GitHub repository** | Stores extracted source, manifests, review history, and approved changes.                                                                |
| **GitHub Actions**    | Validates pull requests and artifacts. In MVP1-C, triggers controlled deployment to DEV.                                                 |
| **Deployment runner** | Private runner within the DEV environment, introduced in MVP1-C, with access to the EBS database and application tier.                   |

### 5.2 Repository structure

```text
ebs-custom/
├── db/
│   ├── apps/
│   └── schemas/
│       └── xxdnvgl/
├── aol/
├── manifests/
│   └── releases/
├── rules/
│   ├── scope.yaml
│   ├── object_types.yaml
│   └── dependencies.yaml
├── tests/
├── .github/
│   └── workflows/
│       ├── validate.yml
│       └── deploy-dev.yml
└── README.md

ebsops/
├── src/
│   └── ebsops/
│       ├── inventory.py
│       ├── snapshot.py
│       ├── detect.py
│       ├── select.py
│       ├── extract.py
│       ├── manifest.py
│       ├── validate.py
│       ├── deploy.py
│       └── verify.py
├── tests/
├── pyproject.toml
└── README.md
```

---

## 6. MVP1 Workflow

### 6.1 MVP1-A Workflow

```text
1. Establish the approved schema and object-type allowlist.
2. Verify the EBS run edition and ensure no conflicting ADOP activity.
3. Capture the initial baseline with normalized content hashes.
4. Capture a later snapshot and compare it with the baseline.
5. Report candidates: NEW, MODIFIED, MISSING, UNCHANGED.
6. Generate dependency report for detected changes.
7. Document session identification requirements for future attribution.
```

### 6.2 MVP1-B Workflow

```text
1. User selects candidate objects associated with a change request.
2. System extracts source code for selected objects.
3. System resolves dependencies and adds them to the change set.
4. System generates the release manifest with checksums and metadata.
5. System validates the manifest.
6. System creates a GitHub branch with extracted source and manifest.
7. System opens a pull request for review.
8. After approval, the artifact is published.
```

### 6.3 MVP1-C Workflow

```text
1. GitHub Actions triggers deployment on push to the release branch.
2. Private runner downloads the immutable artifact and verifies checksum.
3. Runner executes preflight checks (ADOP status, previous release, invalids, space).
4. Runner backs up current object definitions.
5. Runner executes steps in manifest order, respecting schema connections and dependencies.
6. Runner performs post-deployment validation (recompilation, errors, smoke tests).
7. Runner records deployment status in XX_DEPLOY_HISTORY.
8. On failure, runner stops and records the error; rollback is available via previous release redeployment.
```

---

## 7. Change Detection and Snapshot Design

### 7.1 Detection method

Object change detection will use normalized content hashes rather than relying solely on `LAST_DDL_TIME`.

- `LAST_DDL_TIME` and AOL `LAST_UPDATE_DATE` may be used to narrow candidate searches.
- Hash comparison is used to determine whether the normalized definition actually changed.
- New, changed, and missing objects are reported distinctly.
- Missing objects are informational candidates only; no deletion scripts are generated automatically.

### 7.2 Source extraction

Proposed extraction sources:

| Object category                   | Extraction approach                                                   |
| --------------------------------- | --------------------------------------------------------------------- |
| PL/SQL source                     | `DBA_SOURCE` or an approved metadata extraction method                |
| Tables, views, indexes, sequences | `DBMS_METADATA` with a reviewed transform policy                      |
| Synonyms and grants               | Metadata extraction or explicit scripts, subject to validation        |
| AOL objects                       | `FNDLOAD DOWNLOAD`, added after the database-object flow is validated |

### 7.3 Normalization

Normalization rules must be documented and tested for each object category. The purpose is to avoid reporting changes caused only by non-functional metadata.

Examples of possible normalization include:

- Line-ending normalization
- Consistent character encoding
- Exclusion of known generated headers
- Stable ordering of metadata elements where appropriate
- Removal of environment-specific physical storage clauses where approved

Normalization must **not** remove semantically significant information. Every normalization rule must have a test demonstrating which differences are ignored and which remain detectable.

### 7.4 EBS 12.2 editions and ADOP

The current session edition is not proof that the session is connected to the run edition.

Before capture:

1. Determine the database default/run edition using an approved query.
2. Verify ADOP status using the supported application-tier command, such as `adop -status`.
3. Block capture if an active or inconsistent patching cycle makes the source ambiguous.
4. Record the edition name and capture timestamp in the snapshot metadata.

Edition-aware metadata must be considered during inventory and extraction. Object type alone is not a sufficient basis for deciding how an object is handled by the deployment process.

---

## 8. Release Manifest

The manifest evolves across MVP1 sub-phases:

- **MVP1-A:** no manifest generation; detection output is a candidate report.
- **MVP1-B:** the manifest is generated as a descriptive document with checksums, ownership, dependencies, and selection origin.
- **MVP1-C:** the manifest is extended with execution metadata (apply mode, preflight/postflight scripts, rollback strategy).

Example (MVP1-B):

```yaml
apiVersion: ebsops/v1
kind: ReleaseManifest

metadata:
  release: "0.1.0"
  change_id: "CHG-20431"
  generated_at: "2026-10-06T10:00:00Z"
  source_environment: "DEV"
  ebs_release: "12.2.12"
  database_version: "19c"
  source_edition: "V_20261001_1432"

spec:
  objects:
    - id: "apps.xx_invoice_pkg"
      owner: "APPS"
      name: "XX_INVOICE_PKG"
      type: "PACKAGE"
      source_path: "db/apps/packages/xx_invoice_pkg.pks"
      sha256: "<sha256>"
      selection: "EXPLICIT"
      dependencies:
        - "xxdnvgl.xx_invoice_stg"

    - id: "xxdnvgl.xx_invoice_stg"
      owner: "XXDNVGL"
      name: "XX_INVOICE_STG"
      type: "TABLE"
      source_path: "db/schemas/xxdnvgl/tables/xx_invoice_stg.sql"
      sha256: "<sha256>"
      selection: "DEPENDENCY"

  validation:
    status: "PASSED"
    warnings: []
```

Example additions for MVP1-C:

```yaml
spec:
  apply_mode: online
  requires_release: "0.0.9"
  preflight:
    - checks/adop_clean.sql
    - checks/prev_release.sql
  postflight:
    - checks/invalid_delta.sql
    - tests/smoke.sql
  rollback:
    strategy: redeploy_previous
    previous: "0.0.9"
```

The manifest must distinguish:

- **Explicitly selected objects**
- **Automatically included dependencies**
- **Objects that could not be extracted**
- **Warnings requiring human review**

---

## 9. Dependencies

### 9.1 Database dependencies

`DBA_DEPENDENCIES` can help identify dependencies between database objects. Its results should be treated as a useful technical signal, not as a complete release dependency model.

The implementation must:

- Restrict results to the approved schema scope.
- Identify dependencies outside the scope.
- Detect cycles where possible.
- Avoid automatically including Oracle-delivered objects.
- Record dependencies and their resolution status in the manifest.

### 9.2 EBS functional dependencies

Oracle database dependency views do not describe all EBS application relationships. Examples include:

- Concurrent program → executable → PL/SQL package or host program
- Concurrent program parameters → value sets
- Function → menu → responsibility
- BI Publisher data definition → concurrent program
- Flexfield → value sets and validation objects

These dependencies require explicit rules or artifact-specific extraction. They are not a commitment of MVP1 unless the corresponding artifact type is included.

### 9.3 Dependency output

A dependency must be marked as one of:

- `RESOLVED_IN_CHANGESET`
- `RESOLVED_IN_REPOSITORY`
- `EXISTS_IN_SOURCE_ENVIRONMENT`
- `UNRESOLVED`
- `EXTERNAL_ORACLE_OBJECT`

An unresolved dependency prevents the manifest from being marked fully validated. It does not trigger a deployment because MVP1-A and MVP1-B do not deploy.

---

## 10. Deployment Design (MVP1-C)

### 10.1 Deployment runner

A private GitHub Actions runner resides within the DEV environment, with access to:

- The EBS database (via SQL\*Plus or SQLcl)
- The application tier (for `adop` and `FNDLOAD`)
- The artifact registry (for downloading immutable release packages)

### 10.2 Execution flow

1. **Preflight:**
   - Verify no active or inconsistent ADOP session.
   - Confirm the current release matches `requires_release`.
   - Capture baseline of invalid objects.
   - Check available disk space.
   - Back up current definitions of objects to be changed.

2. **Execution:**
   - Iterate through manifest steps in order.
   - Connect as the schema specified in each step.
   - Execute editioned objects via `adop` phases.
   - Execute noneditioned objects directly with appropriate locking.
   - Stop on first error; do not continue to subsequent steps.

3. **Post-deployment:**
   - Recompile invalid objects.
   - Compare `USER_ERRORS` against baseline; fail on new errors.
   - Run smoke tests.
   - Record `SUCCESS` or `FAILED` in `XX_DEPLOY_HISTORY`.

### 10.3 Rollback

Rollback is implemented as redeployment of the previous release:

1. The previous release artifact is fetched from the registry.
2. The backup captured during preflight is applied first, to restore objects not present in the previous release.
3. The previous release manifest is executed.
4. Post-deployment validation is repeated.
5. History is recorded as `ROLLED_BACK`.

### 10.4 Deployment history tables

```sql
CREATE TABLE xxcust.xx_deploy_history (
  deploy_id        NUMBER GENERATED ALWAYS AS IDENTITY,
  release_version  VARCHAR2(50)  NOT NULL,
  manifest_sha256  VARCHAR2(64)  NOT NULL,
  package_sha256   VARCHAR2(64),
  environment      VARCHAR2(30)  NOT NULL,
  status           VARCHAR2(20)  NOT NULL,
  started_at       TIMESTAMP DEFAULT SYSTIMESTAMP,
  finished_at      TIMESTAMP,
  deployed_by      VARCHAR2(100),
  error_message    VARCHAR2(4000),
  CONSTRAINT xx_deploy_history_ck1
    CHECK (status IN ('STARTED', 'SUCCESS', 'FAILED', 'ROLLED_BACK'))
);

CREATE TABLE xxcust.xx_deploy_step_history (
  step_id       NUMBER GENERATED ALWAYS AS IDENTITY,
  deploy_id     NUMBER        NOT NULL,
  seq           NUMBER        NOT NULL,
  connect_user  VARCHAR2(30)  NOT NULL,
  file_name     VARCHAR2(200) NOT NULL,
  kind          VARCHAR2(20)  NOT NULL,
  sha256        VARCHAR2(64)  NOT NULL,
  status        VARCHAR2(20)  NOT NULL,
  started_at    TIMESTAMP DEFAULT SYSTIMESTAMP,
  finished_at   TIMESTAMP,
  error_message VARCHAR2(4000)
);
```

---

## 11. User, Role, and Audit Prerequisites

### 11.1 Current findings

- Direct development sessions as `APPS` have been observed.
- Individual `DEV_*` accounts exist.
- Developer roles have broad `CREATE ANY` and `ALTER ANY` privileges.
- Unified Auditing is enabled, but existing evidence does not show adequate coverage of custom-object DDL.
- An existing DDL trigger was observed in `XXISV`; it does not establish audit coverage for other schemas.

### 11.2 Required discovery before implementation

The DBA and security teams must:

1. Identify members of `DNVGL_DEVELOPER_ROLE` and `DEVELOPER_ROLE`.
2. Determine the effective system privileges of individual developer accounts.
3. Verify whether developer accounts use proxy authentication or connect directly as `APPS`.
4. Review existing Unified Audit policies and retention.
5. Identify all schemas and object types to include in the initial allowlist.
6. Confirm the supported access method for the capture runner.

### 11.3 Target access model

For MVP1-A and MVP1-B:

- The capture component uses a dedicated, read-only database account where feasible.
- The capture account receives only the catalog and object access needed for the approved scope.
- GitHub credentials use a narrowly scoped token or GitHub App.
- Secrets are stored in the organization-approved secret manager.
- Credentials are not written to logs, manifests, command lines, or repository files.

For MVP1-C:

- Create a separate deployment identity.
- Do not use a developer account or a shared `APPS` password as the general deployment identity.
- Define minimum privileges per operation and object type.
- Keep deployment credentials separate by environment.
- Require explicit approval for any operation that changes EBS objects.

### 11.4 DDL audit

Before claiming reliable author attribution, confirm whether the database has an audit policy that captures relevant DDL events for in-scope schemas.

The audit design must be reviewed by the DBA and security team. It must define:

- Audited actions
- In-scope schemas and objects
- Required session identity attributes
- Retention period
- Access controls for audit records
- Performance and storage implications

A hash diff can identify that an object changed. It cannot, by itself, prove who made the change.

---

## 12. Security and Governance

| Area             | MVP1-A / MVP1-B control                                       | MVP1-C addition                                  |
| ---------------- | ------------------------------------------------------------- | ------------------------------------------------ |
| Database access  | Read-only capture account                                     | Least-privilege deployment account               |
| GitHub access    | Least-privilege GitHub App or token                           | Same, plus environment protection rules          |
| Secrets          | Approved enterprise secret manager                            | Separate credentials per environment             |
| Source control   | Branch protection and mandatory pull-request review           | Same                                             |
| Object selection | Change ID and explicit selection recorded                     | Same                                             |
| Audit evidence   | Snapshot metadata, hashes, capture logs, manifest, Git commit | Deployment history, step history, execution logs |
| Deployment       | No deployment                                                 | Controlled, ADOP-aware, with rollback            |

---

## 13. MVP1 CLI Interface

Proposed commands by sub-phase:

**MVP1-A:**

```bash
ebsops inventory \
  --environment dev \
  --scope rules/scope.yaml \
  --output artifacts/inventory.json

ebsops snapshot \
  --environment dev \
  --scope rules/scope.yaml \
  --label baseline-001

ebsops detect \
  --environment dev \
  --baseline baseline-001 \
  --scope rules/scope.yaml \
  --output artifacts/candidates.json

ebsops dependencies \
  --environment dev \
  --candidates artifacts/candidates.json \
  --output artifacts/dependencies.json
```

**MVP1-B:**

```bash
ebsops extract \
  --environment dev \
  --changeset changesets/CHG-20431.yaml \
  --output artifacts/source

ebsops manifest \
  --changeset changesets/CHG-20431.yaml \
  --source artifacts/source \
  --output manifests/CHG-20431.yaml

ebsops validate \
  --manifest manifests/CHG-20431.yaml

ebsops publish \
  --manifest manifests/CHG-20431.yaml \
  --source artifacts/source
```

**MVP1-C:**

```bash
ebsops deploy \
  --release 0.1.0 \
  --environment dev

ebsops verify \
  --environment dev

ebsops rollback \
  --environment dev \
  --release 0.0.9

ebsops status \
  --environment dev
```

---

## 14. GitHub Workflow

### 14.1 MVP1-A and MVP1-B

GitHub Actions validate repository content, including:

- Manifest schema
- Required fields
- File existence
- SHA-256 checksums
- Duplicate object identifiers
- Dependency references
- Disallowed object types
- Required change ID

GitHub-hosted runners must not connect directly to the EBS database.

### 14.2 MVP1-C

A private runner within the DEV environment is triggered by changes to the release branch. The workflow:

```yaml
name: deploy-dev
on:
  push:
    branches: [main]
    paths: ["envs/dev/release.yaml"]
jobs:
  deploy:
    runs-on: [self-hosted, ebs-dev]
    environment: dev
    steps:
      - uses: actions/checkout@v4
      - run: ebsops deploy --release ${{ vars.RELEASE }} --env dev
      - run: ebsops verify --env dev
```

---

## 15. Current Status: Delivered and Outstanding

### 15.1 Confirmed and Delivered

| Item                                            | Status              | Evidence / Notes                                                                                         |
| ----------------------------------------------- | ------------------- | -------------------------------------------------------------------------------------------------------- |
| Target EBS release identified                   | Confirmed           | Oracle E-Business Suite 12.2.12                                                                          |
| Database version identified                     | Confirmed           | Oracle Database 19c Enterprise Edition Extreme Performance                                               |
| DEV environment identified                      | Confirmed           | The EBS database container is reported as `DEV`                                                          |
| EBS 12.2 online-patching requirement identified | Confirmed           | `adop` is used; deployment design must account for editions and online patching                          |
| Current database session edition captured       | Confirmed           | `V_20261001_1432`; this has not yet been verified as the run edition                                     |
| Multiple custom object owners identified        | Confirmed           | Custom objects exist in `APPS` and multiple custom schemas                                               |
| Direct development sessions as `APPS` observed  | Confirmed           | Sessions from SQL Developer tooling were reported                                                        |
| Individual developer accounts identified        | Confirmed           | Multiple `DEV_*` accounts exist                                                                          |
| Broad developer privileges identified           | Confirmed           | Developer roles include `CREATE ANY` and `ALTER ANY` privileges                                          |
| Unified Auditing availability confirmed         | Confirmed           | Unified Auditing is enabled                                                                              |
| Existing audit coverage assessed as incomplete  | Preliminary finding | Available results do not demonstrate adequate DDL auditing for all in-scope custom schemas               |
| Project direction agreed                        | Confirmed           | GitHub is the target source-control platform; AIFO, Jenkins, and SVN are not part of the target solution |
| MVP1 sub-phase structure agreed                 | Confirmed           | MVP1-A (inventory and detection), MVP1-B (capture and manifest), MVP1-C (controlled DEV deployment)      |

### 15.2 Outstanding Discovery and Readiness Items

| Item                                        | Status      | Required action                                                                             | Owner                        |
| ------------------------------------------- | ----------- | ------------------------------------------------------------------------------------------- | ---------------------------- |
| Run edition identification                  | Outstanding | Query the database default edition and verify it against the EBS run edition                | DBA                          |
| ADOP operational status procedure           | Outstanding | Confirm the supported command and conditions that block a capture or deployment run         | EBS DBA                      |
| Developer role membership                   | Outstanding | Identify members of `DNVGL_DEVELOPER_ROLE` and `DEVELOPER_ROLE`                             | DBA / Security               |
| Effective privileges for developer accounts | Outstanding | Review direct grants and privileges inherited through roles                                 | DBA / Security               |
| Developer-to-APPS access model              | Outstanding | Determine whether individual accounts use proxy authentication or shared `APPS` credentials | DBA / Security               |
| DDL audit policy coverage                   | Outstanding | Review enabled Unified Audit policies and confirm coverage for approved custom schemas      | DBA / Security               |
| Audit retention and access controls         | Outstanding | Define retention, access, and review requirements for audit records                         | Security                     |
| Initial schema allowlist                    | Outstanding | Approve the schemas included in the first inventory and capture                             | EBS owner / DBA              |
| Initial object-type allowlist               | Outstanding | Approve the object types supported by the first implementation                              | EBS owner / Development      |
| Capture account                             | Outstanding | Define a read-only, least-privilege identity for inventory and extraction                   | DBA / Security               |
| Deployment account                          | Outstanding | Define a least-privilege identity for MVP1-C deployment operations                          | DBA / Security               |
| Snapshot storage                            | Outstanding | Choose the approved storage for baselines, snapshot metadata, and logs                      | Architecture / Operations    |
| GitHub organization and repositories        | Outstanding | Confirm organization, repository ownership, branch protection, and integration identity     | GitHub administrators        |
| Secret-management integration               | Outstanding | Select the approved secret manager and GitHub integration method                            | Security / Platform          |
| Object extraction and normalization rules   | Outstanding | Define and test extraction and normalization per supported object type                      | Development / DBA            |
| Dependency scope                            | Outstanding | Define which database dependencies are resolved automatically and which require review      | Development / DBA            |
| Change-selection interface                  | Outstanding | Decide whether MVP1-B uses a CLI change-set file or a lightweight user interface            | Product owner / Architecture |
| Private runner infrastructure               | Outstanding | Provision and register the GitHub Actions runner within the DEV environment                 | Infrastructure / Operations  |

### 15.3 MVP1 Deliverables by Sub-Phase

#### MVP1-A Deliverables

| Deliverable                   | Acceptance evidence                                                                     |
| ----------------------------- | --------------------------------------------------------------------------------------- |
| Approved initial object scope | Reviewed `scope.yaml` covering schemas, object types, and exclusions                    |
| Inventory command             | Repeatable inventory report for the approved DEV scope                                  |
| Baseline snapshot             | Stored baseline with environment, capture time, database identity, and edition metadata |
| Hash-based change detection   | Test demonstrating correct detection of a controlled object change                      |
| Candidate report              | Output identifying `NEW`, `MODIFIED`, `MISSING`, and `UNCHANGED` objects                |
| Session identification design | Documented audit policy or trigger design for future change attribution                 |
| Dependency report             | Dependencies recorded with resolution status and unresolved items surfaced              |

#### MVP1-B Deliverables

| Deliverable                        | Acceptance evidence                                                                                                  |
| ---------------------------------- | -------------------------------------------------------------------------------------------------------------------- |
| Change-set format                  | Documented format for explicitly selecting objects associated with a change                                          |
| Extraction for agreed object types | Extracted source files for the approved MVP1 object types                                                            |
| Release manifest                   | Versioned manifest containing object identity, owner, type, source path, selection origin, dependencies, and SHA-256 |
| Manifest validation                | Automated checks for schema, file presence, checksums, and dependency references                                     |
| GitHub pull-request integration    | Extracted source and manifest submitted as a reviewable pull request                                                 |
| Automated repository validation    | GitHub workflow validating the pull request without connecting to EBS                                                |
| Artifact publication               | Immutable artifact published only after pull request approval                                                        |

#### MVP1-C Deliverables

| Deliverable                     | Acceptance evidence                                                                        |
| ------------------------------- | ------------------------------------------------------------------------------------------ |
| Private deployment runner       | Registered GitHub Actions runner within DEV with EBS access                                |
| ADOP-aware deployment           | Successful deployment of editioned objects via `adop` phases                               |
| Preflight checks                | Automated verification of ADOP status, release prerequisites, and environment readiness    |
| Ordered step execution          | Steps executed in manifest order with correct schema connections                           |
| Post-deployment validation      | Recompilation, error checking, and smoke test execution                                    |
| Deployment history              | Records in `XX_DEPLOY_HISTORY` and `XX_DEPLOY_STEP_HISTORY`                                |
| Rollback                        | Successful rollback to previous release using immutable artifact                           |
| Security and operations runbook | Instructions for credentials, deployment execution, troubleshooting, and evidence handling |

### 15.4 MVP1 Exit Criteria

MVP1 is complete only when all of the following are true:

**MVP1-A:**

- The initial schema and object-type scope has been approved.
- The run edition and ADOP pre-check procedure have been verified.
- An approved, least-privilege capture identity is available.
- Repeated captures of unchanged objects produce stable hashes for the supported object types.
- A controlled change is detected and correctly classified.
- Dependency reporting identifies resolved and unresolved dependencies.
- No database deployment or DDL execution occurs.

**MVP1-B:**

- Users can explicitly select objects for a change set.
- Selected objects can be extracted and represented in a valid manifest.
- Checksums and manifest validation pass.
- A GitHub pull request is created with the extracted source and manifest.
- Capture logs and metadata are sufficient to trace the run.
- No database deployment or DDL execution occurs.

**MVP1-C:**

- A release can be deployed to DEV with full preflight and postflight checks.
- Deployment history is recorded and queryable.
- A failed deployment stops at the failing step and records the error.
- Rollback to the previous release is tested and confirmed.
- The same immutable artifact is used for deployment and rollback.

---

## 16. Risks and Mitigations

| Risk                                     | Impact                | Mitigation                                           |
| ---------------------------------------- | --------------------- | ---------------------------------------------------- |
| Developers use shared `APPS` credentials | Unreliable authorship | Improve account and audit model; do not infer author |
