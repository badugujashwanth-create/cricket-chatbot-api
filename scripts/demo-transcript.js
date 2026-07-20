const { once } = require('node:events');

process.env.NODE_ENV = 'production';
process.env.PORT = '0';
process.env.CHROMA_MODE = 'local';
process.env.CRICAPI_KEY = '';
process.env.CRICBUZZ_ENABLED = 'false';
process.env.ESPN_ENABLED = 'false';
process.env.PROFILE_ENRICHMENT_ENABLED = 'false';
process.env.ENABLE_DAILY_INGESTOR = 'false';
process.env.LLM_ENDPOINT = '';
process.env.LLM_BASE_URL = '';
process.env.OPENAI_API_KEY = '';

const { server, startServer } = require('../server');

function print(title, value) {
  console.log(`\n--- ${title} ---`);
  console.log(JSON.stringify(value, null, 2));
}

async function request(baseUrl, pathname, options = {}) {
  const response = await fetch(`${baseUrl}${pathname}`, options);
  const payload = await response.json();
  return { status: response.status, payload };
}

async function main() {
  startServer();
  if (!server.listening) await once(server, 'listening');
  const address = server.address();
  const baseUrl = `http://127.0.0.1:${address.port}`;

  console.log('Cricket Intelligence API · deterministic reviewer workflow');
  console.log('External providers, enrichment, LLMs, and ingestion are disabled.');

  const status = await request(baseUrl, '/api/status');
  print('1. Runtime boundary', {
    http_status: status.status,
    vector_status: status.payload.status,
    runtime: status.payload.runtime,
    counts: status.payload.counts
  });

  for (const [step, question] of [
    ['2. Repository rule knowledge', 'what is lbw'],
    ['3. Repository history knowledge', 'who won wc 2011'],
    ['4. Typed archive degradation', 'india team summary']
  ]) {
    const result = await request(baseUrl, '/api/query', {
      method: 'POST',
      headers: { 'content-type': 'application/json' },
      body: JSON.stringify({ question, sessionId: 'deterministic-demo' })
    });
    print(step, {
      question,
      http_status: result.status,
      type: result.payload.type,
      action: result.payload.extra?.action,
      summary: result.payload.summary
    });
  }

  const live = await request(baseUrl, '/api/cricapi/live-scores');
  print('5. Honest provider gate', {
    http_status: live.status,
    provider: live.payload.provider,
    source: live.payload.source,
    message: live.payload.message
  });

  console.log('\nWorkflow complete. Run `npm verify` for all 24 checks and the dependency audit.');
}

main()
  .catch((error) => {
    console.error('Demo failed:', error.message);
    process.exitCode = 1;
  })
  .finally(async () => {
    if (!server.listening) return;
    await new Promise((resolve) => server.close(resolve));
  });
