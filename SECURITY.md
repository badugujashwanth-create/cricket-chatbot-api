# Security policy

## Supported status

Cricket Intelligence API is a local portfolio prototype. The deterministic profile requires no credentials or external network calls. No production support or response-time commitment is implied.

## Default controls

- external providers, profile enrichment, LLMs, and ingestion are disabled;
- CORS uses an explicit local-origin allowlist;
- JSON bodies default to 32 kB;
- API requests are rate-limited;
- Helmet headers are enabled and the Express signature is hidden;
- status output contains capability flags rather than secrets, endpoints, or filesystem paths;
- tests use repository/public sample questions and an ephemeral server.

## Known boundaries

There is no authentication, tenant isolation, durable session store, abuse-monitoring service, or production deployment review. Do not expose this service publicly with provider credentials or privileged data until those controls exist.

Optional provider responses can be unavailable, stale, rate-limited, differently licensed, or adversarial. Treat them as untrusted input and keep provider permissions minimal.

## Credential handling

- Keep real values in the ignored `.env` file or a secret manager.
- Commit only placeholders in `.env.example`.
- Never record environment values, headers, tokens, private URLs, or personal filesystem paths.
- Rotate any credential that was previously committed; deleting it from the current branch does not remove history.

## Reporting a vulnerability

Use GitHub private vulnerability reporting when available. Otherwise, contact the owner through a verified GitHub channel without placing secrets or exploit details in a public issue.
