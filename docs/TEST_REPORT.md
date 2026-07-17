# Test report

Audited on 2026-07-17 using the checked-out `portfolio-polish` branch on Windows.

| Command | Result | Evidence / notes |
|---|---|---|
| `npm ci` | Pass | 145 packages installed |
| `npm run test:cases` | Fail | One regression: `india team summary` returned `summary` instead of expected `team_stats`; Chroma local fallback remained available |

## Overall status

Partially verified. At least one configured check failed; the exact blocker is recorded above.

Warnings and missing checks remain limitations, even when another check passes.

