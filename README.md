# Cricket Intelligence API

[![CI](https://github.com/badugujashwanth-create/cricket-chatbot-api/actions/workflows/ci.yml/badge.svg)](https://github.com/badugujashwanth-create/cricket-chatbot-api/actions/workflows/ci.yml)

Dataset-grounded Express API for cricket questions, typed UI responses, and explicit degraded states. The default profile is deterministic and makes no provider, enrichment, LLM, or ingestion calls.

> This is a portfolio prototype over a small repository-curated snapshot. It does not guarantee live scores, exhaustive statistics, official rankings, predictions, or production availability.

## Verified workflow

```text
question
  -> deterministic intent and entity routing
  -> repository knowledge or optional local Chroma archive
  -> typed response for the paired web client
  -> explicit unavailable state when evidence or provider configuration is missing
```

The minimum reviewer path is:

1. inspect `/api/status` for the runtime and provider boundary;
2. ask `what is lbw` and receive repository-grounded knowledge;
3. ask `india team summary` and retain the typed `team` contract even when archive statistics are unavailable;
4. call the live-score endpoint without a key and receive an honest external-provider `503`;
5. run the routing and HTTP integration suites.

Run it without opening an external connection:

```powershell
npm ci
npm run demo
npm verify
```

## Current release evidence

- 19 deterministic routing/response cases;
- 5 real HTTP integration tests for status, semantic-cache isolation, knowledge, typed degradation, provider failure, CORS, headers, and request-size protection;
- zero known npm dependency vulnerabilities at the v1.0.2 candidate;
- missing local archives bypass semantic-cache reads and writes, and disabled enrichment makes no Wikipedia request;
- configurable origin allowlist, 32 kB default body limit, API rate limit, Helmet headers, and hidden Express signature;
- narrated walkthrough longer than three minutes with captions, thumbnail, checksum, and inspected frames.

See [the test report](docs/TEST_REPORT.md) for exact commands and [limitations](docs/LIMITATIONS.md) for non-claims.

## Quick start

Requirements: Node.js 22+ and npm.

```powershell
git clone https://github.com/badugujashwanth-create/cricket-chatbot-api.git
cd cricket-chatbot-api
npm ci
Copy-Item .env.example .env
npm start
```

Default URL: `http://127.0.0.1:3001` when `.env.example` is copied, otherwise port `3000`.

Example requests:

```powershell
Invoke-RestMethod http://127.0.0.1:3001/api/status

Invoke-RestMethod http://127.0.0.1:3001/api/query `
  -Method Post `
  -ContentType 'application/json' `
  -Body '{"question":"what is lbw","sessionId":"readme-demo"}'
```

## Runtime modes

### Deterministic local mode — default

- repository JSON knowledge is available;
- optional Chroma uses local mode and degrades when no archive exists;
- CricAPI, Cricbuzz, ESPN, Wikipedia/profile enrichment, LLMs, and the daily ingestor are disabled;
- `/api/status` reports `runtime.mode=deterministic_local` and never returns a local filesystem path.

### Explicit external opt-in

External services activate only through configuration. Add only the provider you are authorized to use:

```dotenv
CRICAPI_KEY=
CRICBUZZ_ENABLED=false
CRICBUZZ_RAPIDAPI_KEY=
ESPN_ENABLED=false
PROFILE_ENRICHMENT_ENABLED=false
LLM_ENDPOINT=
OPENAI_API_KEY=
ENABLE_DAILY_INGESTOR=false
RUN_DAILY_INGESTOR_ON_BOOT=false
```

Provider data can be unavailable, stale, rate-limited, subscription-gated, or differently licensed. The release does not verify those optional profiles.

## Main API surface

| Method | Endpoint | Boundary |
| --- | --- | --- |
| `GET` | `/api/status` | Safe runtime, archive, and provider capability summary |
| `GET` | `/api/about` | Archive dates/counts when a manifest exists |
| `GET` | `/api/home` | Local leaders and recent matches when archive data exists |
| `POST` | `/api/query` | Primary typed question workflow |
| `GET` | `/api/query/stream` | Server-sent-event form of the question workflow |
| `GET` | `/api/players/*`, `/api/teams/*`, `/api/matches/*` | Optional local archive views |
| `GET` | `/api/cricapi/*` | Explicit external CricAPI boundary; `503` without a key |
| `GET` | `/api/cricbuzz/player-card` | Explicit optional enrichment with local fallback |

The response contract keeps `type`, `summary`, `stats`, and `extra.action` stable for the paired [Cricket Chatbot Web](https://github.com/badugujashwanth-create/cricket-chatbot-web) client. `extra.evidence_state` and `extra.archive_evidence` distinguish verified sources from a typed unavailable response.

## Security defaults

- `CORS_ORIGINS` is an explicit comma-separated allowlist;
- JSON requests default to `32kb` maximum;
- `/api` defaults to 120 requests per 60 seconds per client;
- Helmet security headers are enabled and `X-Powered-By` is disabled;
- external services and background ingestion are off by default;
- current status responses expose capability state, not credentials, endpoints, or machine paths;
- secrets belong in ignored `.env` files or a secret manager.

This prototype has no authentication or tenant model. Do not expose it publicly with write, billing, or privileged provider credentials without an authorization design and deployment review.

## Verification

```powershell
npm test
npm audit --omit=dev
```

`npm test` runs the 19 routing cases first and then five actual HTTP checks against an ephemeral local server. CI runs the same suite and dependency audit on pull requests and `main`.

## Documentation

- [Architecture](docs/ARCHITECTURE.md)
- [Development](docs/DEVELOPMENT.md)
- [Testing](docs/TEST_REPORT.md)
- [Security](SECURITY.md)
- [Data provenance](docs/DATA_PROVENANCE.md)
- [Limitations](docs/LIMITATIONS.md)
- [Case study](docs/CASE_STUDY.md)
- [Interview guide](docs/INTERVIEW_GUIDE.md)
- [Demo evidence](docs/demo/DEMO_SCRIPT.md)
- [Troubleshooting](docs/TROUBLESHOOTING.md)

## Status

The repository is a tested local API prototype. No live-data SLA, official cricket affiliation, model accuracy, exhaustive dataset coverage, public deployment, or production-security claim is made. Licensing remains an owner decision after dataset and third-party terms are reviewed.
