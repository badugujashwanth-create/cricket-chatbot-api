# Project Improvement Plan

## Current state

The API grounds answers in local cricket data and now has 19 regression cases covering routing, normalization, status, validation, startup, and degraded behavior.

## Findings

- **Works:** deterministic route selection, player/team normalization paths, invalid-input handling, unsupported-query behavior, and tested degraded mode.
- **Does not / missing:** complete dataset provenance/coverage, exhaustive statistical calculations, and a populated optional archive path.
- **UX / architecture:** backend boundaries are clear; evidence should accompany every computed statistic consumed by the frontend.
- **Testing / security:** regression suite is meaningful. Abuse/rate behavior, large-query bounds, and a broader statistical oracle remain gaps.
- **Performance / docs / demo:** representative latency is not benchmarked. Demo is good but cannot prove questions outside the dataset.

## Recommendations

### Critical

- Never allow language-model output to invent unsupported statistics.
- Keep all 19 route/degraded regression cases green and preserve explicit unsupported responses.

### High value

- Add provenance metadata and golden calculations for the most common comparison/leaderboard queries.
- Add request-size/rate protections if deployed publicly.

### Optional

- Expand datasets only with documented licensing and provenance.

## Delivery constraints

- **Priority:** accuracy and evidence; **complexity:** medium; **dependencies:** local datasets and current API stack.
- **Acceptance:** tested calculations match fixtures, unsupported questions fail honestly, startup/build checks pass, and provenance is visible.
- **Excluded:** live score scraping, invented facts, and broad generative sports commentary.
