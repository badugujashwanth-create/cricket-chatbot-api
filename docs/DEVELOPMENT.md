# Development guide

## Prerequisites

- Node.js 22+
- npm
- PowerShell only for the supplied local demo/recording helpers

Python, Chroma, cricket-provider accounts, and LLMs are not required for the verified deterministic profile.

## Install and run

```powershell
npm ci
Copy-Item .env.example .env
npm start
```

Keep the external feature flags off unless you are authorized to test that provider. Never commit `.env`, local databases, logs, captures, or credentials.

## Verify

```powershell
npm run test:cases
npm run test:integration
npm audit --omit=dev
```

Use `npm verify` for the combined gate. The Node service has no compile step; startup and real HTTP requests are verified by the integration suite.

## Demo

```powershell
npm run demo
```

The script starts an ephemeral server, performs the real deterministic reviewer flow, prints sanitized evidence, and closes the server.

See [the test report](TEST_REPORT.md), [architecture](ARCHITECTURE.md), and [data provenance](DATA_PROVENANCE.md).
