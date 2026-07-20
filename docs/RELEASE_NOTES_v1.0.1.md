# Cricket Intelligence API v1.0.1

This patch closes a provenance gap discovered while auditing the paired web client.

- A missing local Chroma archive now bypasses semantic-cache reads and writes instead of using an implicit current-directory database.
- Disabled profile enrichment now prevents every Wikipedia summary and wikitext request in the query service.
- Typed unavailable responses no longer claim `Vector Archive` evidence or expose an enrichment image, description, or Wikipedia URL.
- Responses expose `extra.evidence_state` and `extra.archive_evidence` so the web client can present unavailable evidence without rendering zero-value statistics as verified facts.
- The existing 4:20 walkthrough remains valid because its visible degraded response and provider boundary do not rely on the removed metadata.

The release still does not claim a populated archive, live providers, model quality, authentication, public deployment, or production scale.
