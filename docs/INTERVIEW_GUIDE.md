# Interview guide

## One-minute explanation

Cricket Intelligence API is an Express service designed around evidence boundaries. It classifies questions and returns stable response types for a React client. Repository knowledge works offline; optional archives, providers, enrichment, and LLMs are explicit adapters. When data is missing, the API preserves useful UI contracts but says the statistics are unavailable.

## Useful deep dives

- Why provider flags and credentials are separate.
- How typed degradation avoids both UI breakage and invented data.
- Why status output exposes booleans but not endpoints or filesystem paths.
- How the missing-Chroma regression became a true short-circuit.
- Why curated fixtures need item-level provenance before broader claims.

## Trade-offs

- In-memory rate/session controls are simple and local but not multi-instance infrastructure.
- Disabling enrichment reduces visual richness but makes the release deterministic and private.
- A small verified workflow is more credible than claiming comprehensive cricket intelligence.
