# Test report

Audited on 2026-07-17 using the checked-out `portfolio-polish` branch on Windows.

| Command | Result | Evidence / notes |
|---|---|---|
| `npm ci` | Pass | 145 packages installed |
| `npm run test:cases` | Pass | Nineteen routing/response query cases and the degraded-vector path passed in 6.5 seconds after missing-database short-circuiting was added |
| Route enumeration | Pass | 19 API routes plus the non-API frontend catch-all were found in `server.js` |
| Production startup | Pass | Express started with `NODE_ENV=production` and the optional daily ingestor disabled for the smoke check |
| `GET /api/status` | Pass | HTTP 200; optional vector status accurately reported `missing` |
| `POST /api/query` with `india team summary` | Pass | HTTP 200; frontend-compatible `type=team` and `extra.action=team_stats` |
| Empty `POST /api/query` | Pass | HTTP 400 with a non-empty guidance summary |

## Overall status

Verified for routing and degraded operation. A recognized team query now preserves its typed `team_stats` contract when the optional archive is empty instead of being downgraded to a generic summary.

The configured suite treats Chroma archive records as optional: it verifies that the loader returns an array and runs record-level assertions only when records exist. The current archive contains zero documents. The installed Python Chroma helper also reports a missing compiled `pydantic_core` module, so rebuilding the optional archive requires repairing that local Python environment and supplying the external dataset.

Warnings and missing checks remain limitations, even when another check passes.
