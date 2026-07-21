# Deployment

No public deployment is claimed for v1.0.3.

The API can run as a Node.js service with `npm ci` and `npm start`, but a public deployment requires explicit decisions for:

- authentication, tenant isolation, and abuse monitoring;
- a distributed rate limiter and session store;
- exact CORS origins and reverse-proxy trust;
- provider credentials, quotas, licensing, and egress restrictions;
- dataset licensing and update provenance;
- logs, retention, alerts, backups, and incident handling.

Keep all external flags off for the deterministic portfolio profile. Do not place real keys in the repository or release assets.
