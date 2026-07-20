# Case study

## Problem

Cricket assistants can sound confident while mixing stale provider data, partial archives, and generated statistics. The product needed a demonstrable path where evidence and failure state are visible.

## Intervention

The v1.0 work made the default runtime network-free, exposed provider capability flags, kept typed UI contracts during degradation, and added real HTTP checks for security and response boundaries. A missing archive now short-circuits before any Python helper is launched.

## Outcome

The release candidate passes 19 routing cases and 5 HTTP integration tests with zero known npm vulnerabilities. Reviewers can reproduce a rules answer, a historical answer, a typed unavailable team response, and an external-provider `503` without credentials.

## Honest boundary

The result proves deterministic routing, contracts, and failure behavior. It does not prove live accuracy, exhaustive statistics, provider reliability, model quality, public scale, or data licensing.
