# Development guide

## Purpose

Natural-language cricket query API backed by curated datasets, optional live providers, Chroma retrieval, and Socket.IO updates.

## Prerequisites

Node.js 22+, Express, Socket.IO, ChromaDB client, optional Ollama and cricket data providers.

## Install

```powershell
npm ci
```

## Run

```powershell
npm start
```

## Verify

- Tests: `npm run test:cases`
- Build: `Not applicable (interpreted Node.js service)`

See [TEST_REPORT.md](TEST_REPORT.md) for the latest audited results. Copy example environment files instead of committing real values. Generated dependencies, caches, logs, databases, and build output must remain untracked.

