# Public OpenAPI inputs

Run `node scripts/build-public-openapi.mjs` from the docs root. Commit the generated `api-reference/public.openapi.json` with the inputs. The deployed file is a dereferenced OpenAPI 3.1 document.

- `public-operations.json` preserves the 191 historical operation numbers and the approved public allowlist. B49b test-options is retired.
- `public-overrides.json` contains the C3-audited basics, Create agent and paging contracts. Add reviewed operation contracts here as the coverage checklist advances.
- `legacy/*.json.src` are unchanged split inputs retained for reproducible bundling and historical regression tests. They are not deployable API files and do not prove current engine parity.
- The builder expands local references, filters public operations, removes provider-named documentation fields, and normalises 3.0 nullable fields to the 3.1 dialect. It does not change wire names or make undocumented aliases public.

Update COVERAGE.md in every round. Run the build script, Node tests, mint validate and mint broken-links before release. Never mark an operation complete merely because it survived bundling. All spec-source content is excluded by .mintignore.
