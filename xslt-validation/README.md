Supplier transformation optimization
====================================

Only ZTR_SPC_EXP_MAIN_SU.xsl was edited. original.xsl is the exact working-file
snapshot taken before these changes, including the user's pre-existing edits.
Neither standard include, the metadata include, nor any ABAP was changed.

Changes
-------

1. An XSLT 1.0 source-document key groups exact allowed-list strings. A global
   temporary tree calculates the existing recursive unique count once per
   distinct string. The public count template uses that cache, with the old
   algorithm as fallback for lists absent from the input. No token normalization,
   ordering, blank handling, hidden cells, or validation references were changed.
   This replaces repeated counting, not source-cell generation/deduplication.
2. Output-row counting now uses count(filtered rows) * visible field count.
   Its suppression predicate is copied from the previous recursive implementation,
   including normalize-space semantics. This removes recursive node-set slicing
   and accumulation when calculating validation offsets.

Both use XSLT 1.0 constructs. Temporary-tree navigation is already used throughout
the existing SAP transformation. No EXSLT dependency was added to production.
Activation and execution on SAP S/4HANA 2022 remain to be verified there.

Dependency review and remaining suspects
--------------------------------------

The main transformation includes ZTR_SPC_EXP_META_SU, /PLMU/TR_SPC_EXP_STYLES,
and /PLMU/TR_SPC_EXP_UTIL; those contain no further include/import statements.
STYLES supplies literal styles. UTIL supplies recursive string replacement,
group searches, and get_distinct, which only removes adjacent equal values.
Replacing get_distinct with general deduplication would change its semantics.

Other possible costs remain: filtering all property rows for each property,
metadata scans per field, backward metadata searches for group data, repeated
visible-field counting, recursive validation traversal, recursive maximum-column
traversal, and allowed-list deduplication for every emitted row. The one-sheet
branch scans //input:Table and performs nested metadata-node matching. Some
general-data templates are inactive in the current supplier path. Static presence
of a scan does not establish its contribution to the SAT total.

Identical hidden lists remain duplicated across rows. Sharing them was deferred
because it would alter hidden worksheet contents and require explicit source-row
mapping for every validation. Current references remain exactly unchanged.
The count cache itself adds a source scan, a key index, and temporary-tree memory;
it may offer little benefit for inputs with few repeated lists. Its lookups scan
distinct cached strings, so many unique lists can remain expensive. Neither the
original 12-second cause nor a speedup has been established.

Validation
----------

Run from the workspace: python xslt-validation/compare.py
Requires lxml (installed locally into .xslt-validation-deps).

The harness expands the three repository includes, makes inherited Excel namespace
declarations explicit in memory, fixes the dynamic output method to XML, replaces
SAP temporary-tree navigation with libxslt node-set navigation, and stubs SAP
rcp:format/pattern/pattern_desc. These adaptations affect only the harness.
Consequently this is differential regression evidence, not SAP runtime validation,
actual formatting validation, or Excel certification.

All 10 comparisons are byte-identical: four supplied files plus a focused fixture,
each with validation enabled and disabled. results.json records results.
The supplied files generated zero validations; cv_file.xml contains no encoded
allowed lists. The working*.xml files appear to be output workbooks, so their
re-transformation provides limited input coverage. dropdown-fixture.xml supplies
actual INSTANCES metadata and data and generates 16 validations when enabled.
It covers exact repeated lists across properties, normalized duplicate tokens,
empty/single/multiple lists, interior/trailing empty tokens, blanks, codes,
unlisted current values, technical hidden fields, suppressed VAT/description
rows, and a folder offset. Full byte comparison includes dropdown references,
styles, helper cells, widths, order, and emitted defaults in this environment.

SAP and Excel follow-up
----------------------

1. Keep a copy of the baseline transformation in a test system. Activate the
   optimized main transformation with unchanged standard and metadata includes.
2. Capture the actual cv_file immediately before CALL TRANSFORMATION for the
   specification and selections used in the reported trace, particularly an
   export containing allowed-value metadata. Run both transformations on that
   identical XML with identical parameters. Compare complete workbook XML;
   allow only serialization differences after checking they are immaterial.
3. Open both outputs in the same Excel version. Check for repair prompts, sheet
   layout, formats, blank/default cells, dropdown ordering, allowed/invalid entry
   behavior, and each validation's hidden source range. Include dates, numbers,
   rich text, non-ASCII text and line breaks to exercise real SAP formatting.
4. Rerun SAT using the same specification, property-tree/download selections,
   user, language, output options, trace settings and application server. Perform
   one warm-up and several measured runs for each version, alternating versions
   if possible. Record CALL TRANSFORMATION gross/net elapsed time and total
   download time, plus output size, row count and validation count. Compare
   medians and ranges; separate first-run compilation effects from warmed runs.
5. Investigate remaining suspects only if the measured trace still identifies
   transformation cost. No SAP timing was available during this change.
