# Data provenance

## Repository-curated snapshot

`data/*.json` and `player_master.json` are small hand-curated educational fixtures containing cricket terminology, simplified rules, equipment/training guidance, selected historical winners, selected records, and player aliases.

The current files do not contain item-level source URLs, a verified update pipeline, or a documented redistribution license. They must therefore be treated as a portfolio snapshot—not an authoritative, exhaustive, current, or commercially reusable dataset.

## Safe uses

- deterministic routing and response demonstrations;
- UI contract testing;
- common terminology explanations;
- honest unavailable/degraded states.

## Unsupported uses

- live match state or schedules;
- official rankings;
- exhaustive player/team statistics;
- betting, fantasy, selection, or financial decisions;
- research benchmarks or model-quality claims;
- redistribution without a separate rights review.

Before expanding the snapshot, record an authoritative source, retrieval date, applicable terms, transformation, and test expectation for every item.
