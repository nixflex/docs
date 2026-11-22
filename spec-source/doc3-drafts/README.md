# DOC3 draft sources

These files are outside the published navigation and OpenAPI build. Each group can be reviewed and promoted separately. The two organisation pages use the same authored MDX format as the existing reference pages.

| Group | Customer change | Promotion condition |
|---|---|---|
| `release-a/` | Two organisation settings references, single-call request and error changes, a developer guide note and the OpenAPI changes. | The production engine and SQL implement the reviewed Release A contract. The frozen rules have passed their independent proof and the new public operations can be mapped. |
| `sc2-help/` | Dashboard ticket instructions and a developer link to the customer workflow. | The production dashboard exposes Settings → Help and the support service works for the documented roles. |
| `sc2-app/` | Navigation and support in the Nixflex phone app. | Customers have the app build with the reviewed navigation and contact sheet. |

From the docs root, run `git apply --check` with the corresponding patch paths before applying that group to a release branch. Release A uses both `release-a/contract.patch` and `release-a/pages.patch`. Keep the two `.mdx.txt` files with it. The contract patch connects these sources to the reference navigation and updates the existing OpenAPI source and inventory. Help and app each use their own `pages.patch`. Verify the actual production version and rerun the docs build, tests and link checks on the promoted content.

The active inventory covers 151 operations. Release A adds exactly two. Review the publication checks and register the two new operations in the rules map during promotion. The accompanying DOC3 report lists the exact pending rules. The private DOC2c packet belongs to the frozen docs commit.
