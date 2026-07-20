# Troubleshooting

## Dependency install fails

Use Node.js 22+ and the committed lockfile: `npm ci`. Do not delete source or data files while clearing generated npm caches.

## Live/provider endpoint returns 503

That is expected in deterministic mode. Provider routes require an authorized key and the corresponding opt-in flag. Do not add a key merely to make a portfolio demo look live.

## Archive status is missing

The v1.0 profile does not ship a populated Chroma archive. Repository knowledge still works. Configure and build an archive only from data you may legally use, then document its provenance.

## CORS returns 403

Add the exact trusted client origin to `CORS_ORIGINS`. Wildcard origins are not the release default.

## JSON returns 413

The default request-body limit is 32 kB. Questions should be small. Raise `JSON_BODY_LIMIT` only after reviewing abuse and memory impact.

## Port is already in use

Stop the process already bound to the port or set a different `PORT`. Do not run duplicate demo servers.

## Sensitive diagnostics

Never paste real credentials, provider headers, private URLs, or personal paths into issues, screenshots, recordings, or test artifacts.
