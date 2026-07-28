---
name: release-prep
description: "Use when preparing a module release, including version updates in docs, compatibility matrix updates, release note updates, and running make-based documentation generation. Triggers on: release prep, prepare release, cut release, update release notes, compatibility update."
---

# Release Preparation

## Goal
Prepare a release by applying required version/documentation updates and regenerating module documentation.

## Inputs
- Release version (example: v1.1.0)
- Terraform compatibility for the release (example: >=1.3.0)
- Release note bullets for the new version

## Steps
1. Update the docs header compatibility row in docs/HEADER.md.
   - Set Module version to the release version.
   - Set Terraform version to the declared compatibility.
2. Update the compatibility matrix in COMPATIBILITY.md.
   - Add or update the release version entry at the top of the table.
   - Keep table formatting consistent with existing entries.
3. Update RELEASE_NOTES.md.
   - Add a new section for the release if missing.
   - Add concise bullets describing user-visible changes.
4. Regenerate documentation.
   - Run: make gen_module_docs
5. Validate.
   - Review git diff for only intended changes.
   - Ensure generated README files are updated and formatting is clean.

## Output Checklist
- docs/HEADER.md reflects the release version and Terraform compatibility.
- COMPATIBILITY.md contains a correct entry for the release.
- RELEASE_NOTES.md includes clear notes for the release.
- make gen_module_docs completed successfully.
