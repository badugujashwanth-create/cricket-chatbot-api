# Test report

Verified on 21 July 2026 from the `fix/player-unavailable-copy-v1.0.2` release candidate.

| Command | Result | Evidence |
| --- | --- | --- |
| `npm ci` | Pass | Lockfile installation completed |
| `npm run test:cases` | Pass | 19 deterministic routing and response cases; missing Chroma short-circuits without a helper subprocess |
| `npm run test:integration` | Pass | 5 real HTTP tests against an ephemeral local server, including missing-archive cache isolation, provenance, and enrichment isolation |
| `npm test` | Pass | 24 total configured checks |
| `npm audit --omit=dev` | Pass | Zero known vulnerabilities in the complete runtime dependency tree |
| `gitleaks stdin` on the staged release diff | Pass | No leaks found |
| `gitleaks git . --redact` | Pass | No leaks found across the complete reachable history |

## HTTP coverage

The integration suite verifies:

- deterministic `/api/status` capability evidence with no local paths;
- missing-archive semantic-cache isolation through the degraded team-response regression;
- Helmet headers and removal of `X-Powered-By`;
- repository-grounded LBW knowledge;
- typed India-team degradation with no archive label, image, description, or Wikipedia metadata when the archive and enrichment are disabled;
- typed player degradation that does not promise disabled live or fallback enrichment;
- empty-question `400` and unconfigured live-provider `503`;
- denied and allowed CORS origins;
- oversized JSON `413`.

## Intentional limitations

The suite does not claim optional live providers, a populated Chroma archive, model quality, Socket.IO scale, multi-process session consistency, authentication, or public infrastructure. Those remain separate authorization and environment gates.
