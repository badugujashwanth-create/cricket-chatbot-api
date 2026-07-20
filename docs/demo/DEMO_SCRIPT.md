# Cricket Intelligence API demo script

**Target length:** 4:15

**Format:** real PowerShell and HTTP/API workflow

**Data:** repository-curated public cricket examples; no accounts, credentials, or external calls

## Walkthrough

1. **0:00–0:25 — Product and boundary:** identify the question-to-evidence problem and show deterministic mode.
2. **0:25–0:55 — Runtime status:** show archive state and every provider flag as false.
3. **0:55–1:25 — Rule knowledge:** submit `what is lbw` and inspect the typed local answer.
4. **1:25–1:55 — History knowledge:** submit `who won wc 2011` from the curated snapshot.
5. **1:55–2:25 — Typed degradation:** submit `india team summary`; retain `team/team_stats` while saying statistics are unavailable.
6. **2:25–2:50 — External gate:** call live scores and show the explicit CricAPI `503`.
7. **2:50–3:15 — HTTP security:** demonstrate denied CORS and oversized-body responses.
8. **3:15–3:45 — Verification:** run 19 routing cases, 5 HTTP tests, and the npm audit.
9. **3:45–4:15 — Architecture and limits:** summarize adapter boundaries, provenance debt, and non-claims.

Do not show `.env`, provider headers, personal paths, notifications, private URLs, or invented success states.
