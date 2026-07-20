# Test report

Verified on 20 July 2026 from the `product-completion-2026` release candidate.

| Command | Result | Evidence |
| --- | --- | --- |
| `npm ci` | Pass | Lockfile installation completed |
| `npm run test:cases` | Pass | 19 deterministic routing and response cases; missing Chroma short-circuits without a helper subprocess |
| `npm run test:integration` | Pass | 5 real HTTP tests against an ephemeral local server |
| `npm test` | Pass | 24 total configured checks |
| `npm audit --omit=dev` | Pass | Zero known vulnerabilities in the complete runtime dependency tree |
| `gitleaks stdin` on the staged release diff | Pass | No leaks found |
| `gitleaks git . --redact` | Pass | No leaks found across 18 existing commits |

## HTTP coverage

The integration suite verifies:

- deterministic `/api/status` capability evidence with no local paths;
- Helmet headers and removal of `X-Powered-By`;
- repository-grounded LBW knowledge;
- typed India-team degradation when archive statistics are absent;
- empty-question `400` and unconfigured live-provider `503`;
- denied and allowed CORS origins;
- oversized JSON `413`.

## Intentional limitations

The suite does not claim optional live providers, a populated Chroma archive, model quality, Socket.IO scale, multi-process session consistency, authentication, or public infrastructure. Those remain separate authorization and environment gates.
