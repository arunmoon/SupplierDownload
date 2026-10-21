# ZSUPPLIER Multiple Specification Excel Export Requirements

Version: 1.0  
Date: 18 October 2026  
Status: Proposed requirements for review  
Audience: Business owner, SAP PLM functional consultant, ABAP developer, frontend developer, and test team

## 1 Purpose

Extend the SAP PLM Download Data application so that a user can select multiple specifications and export one independent Excel file per specification using the existing ZSUPPLIER variant. Preserve the current single-specification output and reuse the existing export functionality wherever possible.

This document defines the required behavior and acceptance criteria. Implementation must follow a feasibility assessment and confirmation of the approach. It does not authorize changes to SAP standard objects.

## 2 Business need and current behavior

Users currently export specifications individually. The required enhancement should reduce repeated export actions while retaining a separate supplier workbook for each specification.

The reported current behavior is that exporting one specification succeeds, while selecting multiple specifications produces message `/PLMB/BA_EXP016`: “Number of selected objects is 2; variant ZSUPPLIER is not applicable”. This behavior must be reproduced in the target SAP environment before implementation.

The supplied source confirms that `/PLMI/CL_SPC_EXP_GEN_DATA_SNGL->CHECK_NUMBER_OF_OBJECTS` accepts one object and rejects multiple objects with message 016 from message class `/PLMB/BA_EXP`. The active ZSUPPLIER configuration and complete runtime call sequence still require verification.

## 3 Scope

### Included

- Multiple specification selection for ZSUPPLIER export.
- Independent use of the existing export process for each unique selected specification.
- One Excel file per successfully processed specification.
- File naming, data isolation, per-specification errors, and a clear export result.
- Verification of backend generation and browser delivery as separate capabilities.
- The smallest frontend extension necessary if existing delivery cannot handle separate files.
- Regression testing of the current single-specification process.

### Excluded

- ZIP files or any archive packaging.
- Combining specifications into one workbook.
- Modifications to SAP standard objects.
- Unrelated workbook redesign or changes to other export variants.
- Replacing the inheritance hierarchy solely on an assumed performance benefit.

## 4 Required user flow

1. The user selects one or more specifications in Download Data.
2. The user chooses ZSUPPLIER and starts the export.
3. The application validates the selection and identifies unique specification keys.
4. Each unique specification is processed independently through the supported export pipeline.
5. The application generates and initiates delivery of one Excel file for each successful specification.
6. The application reports successful generation, delivery initiation, and individual failures accurately. It must not claim that files were saved locally unless that state is observable.

The desired outcome is multiple separate downloads from one export action. If the browser or application framework requires an additional user interaction, the proposed interaction must be demonstrated and confirmed before implementation.

## 5 Functional requirements

All requirements below are proposed mandatory behavior unless explicitly identified as a decision pending confirmation.

| ID | Requirement | Acceptance evidence |
|---|---|---|
| FR01 | Accept one or more selected specifications for ZSUPPLIER through the approved extension. | One, two, and five valid selections can start processing. |
| FR02 | Process each unique specification independently. | Each output contains only the corresponding specification and its legitimately related data. |
| FR03 | Generate exactly one Excel file per successful unique specification. | Two successful unique specifications produce two files; five produce five. |
| FR04 | Preserve the existing single-specification data, workbook structure, formatting, formulas, and validations where present. | Output is compared with an approved baseline for the same input and settings. |
| FR05 | Reuse current selection settings and export parameters consistently for each specification. | Key date, selected sections, and other applicable parameters match the user request in every output. |
| FR06 | Produce filenames containing the specification ID and prevent collisions within an export request. | Files are identifiable and distinct even when display IDs or timestamps collide. |
| FR07 | Validate access for every specification using existing authorization rules. | An unauthorized specification produces no downloadable content and a meaningful failure result. |
| FR08 | Continue processing valid specifications when an individual specification fails, where the session remains usable. | A mixed selection delivers valid outputs and identifies the failed specification and reason. |
| FR09 | Process duplicate selections once per unique internal specification key. | Duplicate input keys do not cause duplicate files. |
| FR10 | Reject an empty selection gracefully. | The user receives a useful validation message without a short dump. |
| FR11 | Prevent buffered data, metadata, and custom state from leaking between specifications. | Sequential exports of materially different specifications remain isolated. |
| FR12 | Report a result for every unique specification. | Success and failure counts reconcile with the unique selection count; delivery limitations are visible. |
| FR13 | Handle browser delivery restrictions explicitly. | Supported browser testing shows separate downloads, or an agreed minimal interaction enables each file without archives. |
| FR14 | Allow an individual failed export to be retried through the existing single-specification action. | Retrying a failed specification does not require re-exporting successful ones. |

### File naming

The proposed convention is `ZSUPPLIER_<SpecificationID>_<RequestID>.<ExistingExtension>`. Preserve the current compatible Excel format, extension, and MIME type. Sanitize unsupported filename characters and add a sequence or another stable discriminator when needed. The final naming convention is subject to business confirmation.

### Error behavior

Identify the specification, processing stage, and actionable reason for an individual failure. Avoid exposing internal dumps or sensitive technical details to users. Record sufficient technical context through the existing logging or message mechanism for support. If a request-level failure makes further processing unsafe, stop and show which items completed and which remain unprocessed.

## 6 Technical requirements and constraints

### Existing class hierarchy

The supplied source shows this hierarchy:

```text
/PLMI/CL_SPC_EXP_GEN_DATA_ABS
  /PLMI/CL_SPC_EXP_GEN_DATA_SNGL
    ZCL_SPC_EXP_GEN_DATA_SPPLR
    ZCL_SPC_EXP_GEN_DATA_SPPLR2
```

`SNGL` implements two hooks declared abstract in `ABS`: `CHECK_NUMBER_OF_OBJECTS` and `CONVERT_AND_APPEND_DATA`. The conversion hook calls `/PLMB/CL_EXP_TOOLS=>CONVERT_AND_APPEND_DATA` with `IV_XSTRING_CONVERSION = ABAP_TRUE`.

Retaining `SNGL` is the preferred starting point when the pipeline processes one specification per invocation. Direct inheritance from `ABS` is permissible only when a demonstrated functional need justifies implementing both hooks in the custom class. No performance gain from that superclass change has been established.

### Components to examine

| Component | Required investigation |
|---|---|
| `ZCL_SPC_EXP_GEN_DATA_SPPLR` and `ZCL_SPC_EXP_GEN_DATA_SPPLR2` | Confirm which custom generator is active and which custom data processing must be preserved. |
| `ZCL_SPC_EXP_EXPORTING_SUPPLIER` | Confirm whether this class exists and is configured in SAP; its source is not present in the inspected project files. |
| `/PLMI/CL_SPC_EXP_GEN_DATA_SNGL` and `/PLMI/CL_SPC_EXP_GEN_DATA_ABS` | Trace validation, conversion, data generation, and buffer lifetime. |
| `/PLMB/CL_EXP_ND_EXPORTING` and `/PLMB/CL_EXP_SP` | Trace selected objects, variant execution, and output handling. |
| `/PLMB/CL_SPI_CONNECTOR` | Trace specification data access and existing authorization handling. |
| `/PLMU/CL_EXP_FRW_EVENT_EXT` | Establish the role of application events and export delivery in the actual runtime path. |
| `/PLMU/CL_EXP_EXPORT_FACTORY` and `/PLMU/CL_EXP_EXPORT_TO_EXCEL` | Verify whether these implementations participate in ZSUPPLIER execution before proposing reuse. |
| BAdI `/PLMB/EXP_GENERIC_DATA` | Verify the configured implementation and lifecycle. |
| `ZTR_SPC_EXP_META_SU` and `ZTR_SPC_EXP_MAIN_SU` | Verify active transformation usage and reuse without changes. |

The file `ZCL_SPC_EXP_GEN_DATA_SPPLR3.abap` internally declares `ZCL_SPC_EXP_GEN_DATA_SPPLR2`. Resolve the authoritative source version before development or transport preparation.

### Design constraints

- Use supported custom extension points and existing interfaces. Do not modify SAP standard code.
- Do not remove the object-count check and assume that separate downloads will result.
- Keep one specification per export invocation where feasible; verify reset or instance lifecycle behavior between invocations.
- Reuse existing transformations unchanged unless a verified incompatibility requires a documented change.
- Verify how generated content, filenames, MIME types, and delivery responses are represented.
- Avoid accumulating all generated workbook contents in memory unless measured limits justify it.
- Do not assume that the application is implemented with SAPUI5 solely because it is launched through Fiori. Establish the actual frontend and download mechanism.

## 7 Feasibility assessment required before implementation

Document the actual class and method sequence from Download Data selection to browser delivery, using runtime evidence where possible. The assessment must answer:

1. Which configured implementation validates ZSUPPLIER and rejects multiple objects?
2. How are selected specification keys and export settings passed to the generator?
3. Can the existing export pipeline be invoked independently for each selected key through a supported extension?
4. Which buffers and output state must be cleared or recreated between invocations?
5. Does the output contract support several files, or only one content payload per action?
6. What code initiates browser delivery, and can it deliver separate files in one execution?
7. What minimal frontend change is required if delivery is limited to one file?
8. Which implementation offers the fewest changes while preserving existing behavior?

Compare a custom export-class extension, a data-generator extension, and independent invocation of the existing pipeline. Evaluate standard-object impact, output handling, memory, error isolation, and frontend work. Independent invocation is a candidate design, not an established capability.

Provide method-level pseudocode only after the relevant interfaces and lifecycle are verified. Confirm the approach before implementation begins.

## 8 Nonfunctional requirements

| ID | Requirement | Verification |
|---|---|---|
| NF01 | Preserve current single-specification behavior and other variants. | Regression tests against baseline outputs and representative other variants. |
| NF02 | Keep processing time and peak memory within agreed operational limits. | Measure one, two, five, and a representative larger selection with recorded data volumes. |
| NF03 | Preserve existing specification authorization and data-access rules. | Authorized and unauthorized selection tests. |
| NF04 | Keep failures isolated where possible and prevent stale data reuse. | Mixed failures and repeated exports in the same session. |
| NF05 | Support the agreed browser and SAP environment matrix. | End-to-end tests in each supported browser and deployment configuration. |
| NF06 | Keep custom changes minimal and maintainable. | Technical review of changed objects, interfaces, and transport contents. |

Performance thresholds, maximum selection size, request timeout limits, supported browsers, and expected workbook volumes must be agreed during feasibility review. Do not claim an improvement without measurements of equivalent workloads. Use SAT or ST12 for runtime analysis and database tracing where appropriate.

## 9 Acceptance test plan

| Test | Scenario | Expected result | Requirements |
|---|---|---|---|
| AT01 | One valid specification | Existing workbook behavior is preserved; one file is delivered. | FR01–FR05, NF01 |
| AT02 | Two valid specifications | Two independent files with correct, isolated data. | FR01–FR06, FR11 |
| AT03 | Five valid specifications | Five independent files; result counts reconcile. | FR01–FR06, FR12 |
| AT04 | Invalid specification among valid ones | Valid specifications succeed; failed item and reason are reported. | FR08, FR12 |
| AT05 | Duplicate selection keys | One file per unique key. | FR09 |
| AT06 | Colliding or unsupported filename characters | Safe, identifiable, unique filenames; correct extension. | FR06 |
| AT07 | Larger representative selection | Runtime and peak memory satisfy agreed thresholds; no incomplete files. | NF02 |
| AT08 | Specifications with different sections and data volumes | No data, metadata, or custom-state carryover. | FR02, FR05, FR11 |
| AT09 | Browser multiple-download permission allowed and blocked | Separate downloads work when permitted; restrictions produce accurate user guidance. | FR13, NF05 |
| AT10 | Empty selection | Useful validation message without assertion failure or short dump. | FR10 |
| AT11 | Unauthorized specification among authorized ones | No unauthorized file content; item-level failure is reported. | FR07, NF03 |
| AT12 | Failed specification retried individually | Retry uses existing single-specification behavior successfully when the cause is resolved. | FR14 |
| AT13 | Repeated export actions in one session | No stale state, missing files, or unintended duplicate processing. | FR11, NF04 |
| AT14 | Representative other export variants | Existing behavior remains unchanged. | NF01 |

Verify files by opening them in the supported Excel client and checking workbook content and behavior against the baseline. A generated backend payload alone does not prove browser delivery. Record generation, response initiation, and observed downloaded files separately.

## 10 Decisions pending confirmation

| Decision | Proposed owner | Required outcome |
|---|---|---|
| Active ZSUPPLIER configuration and authoritative custom source | ABAP developer and SAP PLM consultant | Confirm configured classes, BAdI implementation, transformations, and deployed versions. |
| Separate browser downloads and any required interaction | Frontend developer and business owner | Demonstrate supported behavior and confirm the minimum viable user flow. |
| Continue after individual failure | Business owner | Confirm the proposed continue-and-report policy. |
| Duplicate handling and filename convention | Business owner | Confirm one file per unique internal key and the final naming convention. |
| Performance and operating limits | Technical lead and operations | Agree selection limits, timeouts, memory limits, workload, and target response times. |
| Supported SAP and browser versions | Technical lead and test team | Record the test matrix. |

## 11 Delivery and approval criteria

The feasibility deliverable must include the verified execution flow, exact restriction location, output and browser-delivery limitations, compared implementation options, and the recommended minimum-change approach.

After approach confirmation, implementation deliverables must include custom object changes, any required frontend changes, transport details, baseline comparisons, test evidence, support instructions, and a rollback procedure using the existing release process.

Release acceptance requires business approval of workbook output and user interaction, technical confirmation that SAP standard objects remain unchanged, and passing evidence for the agreed acceptance tests. Outstanding failures or operating limits must be explicitly recorded and accepted through the project release process.

## 12 Reference material

- Project brief titled “Analyze Multi-Object Supplier Excel Export”.
- Local source `PLMICL_SPC_EXP_GEN_DATA_SNGL.abap` for the single-object restriction and conversion hook.
- Local source `PLMICL_SPC_EXP_GEN_DATA_ABS.abap` for the abstract hooks and shared generator implementation.
- Custom generator sources `ZCL_SPC_EXP_GEN_DATA_SPPLR.abap`, `ZCL_SPC_EXP_GEN_DATA_SPPLR2.abap`, and `ZCL_SPC_EXP_GEN_DATA_SPPLR3.abap`.
- Export framework sources and transformations listed in Section 6, to be traced against the active SAP runtime.
