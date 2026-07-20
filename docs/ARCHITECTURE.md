# Architecture

## Product boundary

The API converts cricket questions into typed responses for the paired web client. Its verified release path is deterministic and repository-grounded. Chroma, live cricket feeds, enrichment providers, LLMs, and ingestion are optional adapters, not prerequisites.

```text
HTTP / SSE / Socket.IO
        |
Express security boundary
  CORS · body limit · rate limit · Helmet
        |
intent gate -> entity normalization -> query service -> typed response
        |                         |
repository JSON             optional adapters
rules, terms, history       Chroma · CricAPI · Cricbuzz
records, training           ESPN · profile enrichment · LLM
```

## Main components

- `server.js`: HTTP contracts, security middleware, SSE, Socket.IO, and lifecycle.
- `llamaRouter.js`: deterministic intent routing with an optional explicitly configured LLM.
- `queryService.js`: response orchestration and stable UI payload construction.
- `knowledgeService.js`: repository JSON knowledge lookup.
- `playerMaster.js`: deterministic player alias normalization.
- `vectorIndexService.js` / `chromaService.js`: optional archive reads and honest degraded states.
- `cricApiService.js`, `espnService.js`, `playerProfileService.js`: external boundaries disabled by default.
- `workers/dailyIngestor.js`: opt-in provider ingestion; never starts by default.

## Failure behavior

- Missing repository evidence returns guidance or typed unavailable data instead of invented statistics.
- Missing provider credentials return explicit external-source errors.
- Missing Chroma data returns `missing_chroma_db` without starting a helper, reading stale semantic-cache entries, or creating cache files at an implicit path.
- Wikipedia enrichment returns immediately without a network call unless `PROFILE_ENRICHMENT_ENABLED=true` is set explicitly.
- Status responses sanitize machine paths and expose only boolean capabilities.
- Provider enrichment failures do not upgrade a local fact into a live-data claim.

## Data and state

The repository JSON files are small curated snapshots. In-memory sessions retain conversational context for one process and expire after one hour. There is no account identity or durable user data. Optional Chroma and semantic-cache state are local operator-managed data.

See [data provenance](DATA_PROVENANCE.md) and [limitations](LIMITATIONS.md).
