# Narration

Cricket Intelligence API is a dataset-grounded Express prototype. Its goal is not to sound knowledgeable about every match. Its goal is to make the evidence boundary visible. This walkthrough uses the default deterministic profile. No provider key, enrichment service, local model, cloud model, or background ingestor is enabled.

The status endpoint is the first reviewer checkpoint. It reports a repository-curated snapshot, confirms that live scores are not guaranteed, and exposes only boolean capability flags. The optional Chroma archive is absent in this release. Notice that the response does not reveal a database directory, provider endpoint, credential, or personal machine path.

The first question asks what L B W means. The router identifies repository knowledge and returns a stable record response. The answer comes from the checked-in rules snapshot. This proves the local question path without presenting a model-generated sentence or an external provider result.

The second question asks who won the 2011 World Cup. The history fixture supplies the answer that India beat Sri Lanka in Mumbai. This is a selected educational fact from a small curated snapshot. It is not evidence that the repository contains every tournament, scorecard, or current record.

Next, the reviewer asks for an India team summary. The response intentionally preserves the team and team-stats contract expected by the paired React client. Because the verified archive contains no team statistics, the summary says that those values are unavailable. Preserving the UI contract does not justify inventing runs, wins, rankings, or percentages.

The live-score endpoint is an explicit external boundary. With no authorized CricAPI key, it returns HTTP 503 and labels the provider and source. The release does not hide that state behind sample live scores. Cricbuzz, ESPN, Wikipedia profile enrichment, L L M routing, and daily ingestion follow the same opt-in principle.

The HTTP boundary also matters. An untrusted browser origin is denied, an oversized JSON question is rejected, Helmet adds response headers, and the Express signature is disabled. These controls reduce obvious portfolio-demo risk, but they are not a substitute for authentication, tenant isolation, distributed abuse protection, or a production review.

Verification combines nineteen deterministic routing and response cases with five real HTTP tests against an ephemeral server. The tests cover status evidence, repository knowledge, typed degradation, honest provider failure, allowed and denied origins, security headers, and the request-body limit. The runtime dependency audit reports zero known vulnerabilities.

Architecturally, Express fronts the deterministic intent router and query service. Repository JSON is the verified evidence source. Chroma, providers, profile enrichment, language models, Socket I O updates, and ingestion are separate adapters. A missing Chroma path now stops before a Python helper is launched, making degraded mode faster and quieter.

The remaining limitations are deliberate and visible. Data items do not yet have item-level citations or a completed redistribution-license review. The release has no populated archive, no verified live-provider profile, no model-quality claim, no public deployment, and no production-security claim. Version one proves a reproducible local workflow and the discipline to say when evidence is missing.

That is the recruiter story: deterministic behavior, stable contracts, guarded integrations, meaningful automated evidence, and honest scope. The paired web client will be verified separately against this API contract before the portfolio and profile are synchronized again.
