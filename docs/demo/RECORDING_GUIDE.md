# Recording guide

## Preflight

```powershell
npm ci
npm verify
.\scripts\record-demo.ps1 -SmokeOnly
```

The smoke pass verifies the real terminal window can be captured before the long take.

## Full recording

```powershell
.\scripts\record-demo.ps1
```

The recorder launches a dedicated PowerShell window, starts the API with all external features off, performs real requests, runs the real test/audit commands, synthesizes narration from `NARRATION.md`, and builds the final WebM plus verification frames.

## Acceptance

- duration at least 180 seconds;
- 1280×720 VP9 video with Opus narration;
- captions, thumbnail, SHA-256, and verification JSON present;
- milestone frames show only the dedicated demo terminal;
- no credentials, personal paths, notifications, or fake provider success.
