# Cricket Intelligence API architecture

Natural-language cricket query API backed by curated datasets, optional live providers, Chroma retrieval, and Socket.IO updates.

## System view

```mermaid
flowchart LR
  N0[Client] --> N1
  N1[Express API] --> N2
  N2[Query parser and intent gate] --> N3
  N3[Dataset/provider services] --> N4
  N4[Chroma/Ollama (optional)]
```

## Component boundaries

- **Client:** initiates the primary workflow.
- **Express API:** owns one stage of the request or interaction flow.
- **Query parser and intent gate:** owns one stage of the request or interaction flow.
- **Dataset/provider services:** owns one stage of the request or interaction flow.
- **Chroma/Ollama (optional):** provides the terminal integration or persistence boundary.

## Runtime and trust boundaries

A Chroma server, local helper, or provider credentials may be needed for enhanced retrieval; the current regression assertion is unresolved. Inputs crossing a network, filesystem, provider, or database boundary should be validated and logged without sensitive values. Optional integrations must fail clearly rather than being presented as successful.

## Technology

Node.js 22+, Express, Socket.IO, ChromaDB client, optional Ollama and cricket data providers.

