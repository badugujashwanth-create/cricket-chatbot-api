const assert = require('node:assert/strict');
const { after, before, test } = require('node:test');
const { once } = require('node:events');

process.env.NODE_ENV = 'test';
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
process.env.CORS_ORIGINS = 'http://127.0.0.1:5173';
process.env.JSON_BODY_LIMIT = '32kb';
process.env.RATE_LIMIT_MAX = '100';

const { server, startServer } = require('../server');

let baseUrl = '';

before(async () => {
  startServer();
  if (!server.listening) await once(server, 'listening');
  const address = server.address();
  baseUrl = `http://127.0.0.1:${address.port}`;
});

after(async () => {
  if (!server.listening) return;
  await new Promise((resolve, reject) => {
    server.close((error) => (error ? reject(error) : resolve()));
  });
});

async function request(pathname, options = {}) {
  return fetch(`${baseUrl}${pathname}`, options);
}

test('status exposes deterministic boundaries without local filesystem paths', async () => {
  const response = await request('/api/status');
  assert.equal(response.status, 200);
  assert.equal(response.headers.get('x-powered-by'), null);
  assert.equal(response.headers.get('x-content-type-options'), 'nosniff');

  const payload = await response.json();
  assert.equal(payload.runtime.mode, 'deterministic_local');
  assert.equal(payload.runtime.dataset_boundary, 'repository_curated_snapshot');
  assert.equal(payload.runtime.live_scores_guaranteed, false);
  assert.deepEqual(payload.runtime.providers, {
    cricapi: false,
    cricbuzz: false,
    espn: false,
    profile_enrichment: false,
    local_llm: false,
    openai: false,
    daily_ingestor: false
  });
  assert.equal(Object.hasOwn(payload, 'db_dir'), false);
  assert.doesNotMatch(JSON.stringify(payload), /[A-Z]:\\\\|\/home\//i);
});

test('repository knowledge returns typed evidence without external providers', async () => {
  const response = await request('/api/query', {
    method: 'POST',
    headers: { 'content-type': 'application/json' },
    body: JSON.stringify({ question: 'what is lbw', sessionId: 'integration-demo' })
  });
  assert.equal(response.status, 200);
  const payload = await response.json();
  assert.equal(payload.type, 'record');
  assert.equal(payload.extra.action, 'general_knowledge');
  assert.match(payload.summary, /leg before wicket|lbw/i);
});

test('recognized team query preserves its typed degraded contract', async () => {
  const response = await request('/api/query', {
    method: 'POST',
    headers: { 'content-type': 'application/json' },
    body: JSON.stringify({ question: 'india team summary', sessionId: 'integration-demo' })
  });
  assert.equal(response.status, 200);
  const payload = await response.json();
  assert.equal(payload.type, 'team');
  assert.equal(payload.extra.action, 'team_stats');
  assert.match(payload.summary, /india|unavailable|dataset/i);
  assert.equal(payload.image, '');
  assert.equal(payload.extra.evidence_state, 'unavailable');
  assert.equal(payload.extra.archive_evidence, false);
  assert.deepEqual(payload.extra.sources || [], []);
  assert.equal(Object.hasOwn(payload.extra, 'team_description'), false);
  assert.equal(Object.hasOwn(payload.extra.entities.team, 'wikipedia_url'), false);
  assert.equal(Object.hasOwn(payload.extra.entities.team, 'image_url'), false);

  const playerResponse = await request('/api/query', {
    method: 'POST',
    headers: { 'content-type': 'application/json' },
    body: JSON.stringify({ question: 'Who is Virat Kohli?', sessionId: 'integration-player-demo' })
  });
  assert.equal(playerResponse.status, 200);
  const playerPayload = await playerResponse.json();
  assert.equal(playerPayload.type, 'player');
  assert.equal(playerPayload.extra.action, 'player_stats');
  assert.equal(playerPayload.extra.evidence_state, 'unavailable');
  assert.equal(playerPayload.extra.archive_evidence, false);
  assert.deepEqual(playerPayload.extra.sources || [], []);
  assert.match(playerPayload.summary, /unavailable in the current dataset/i);
  assert.doesNotMatch(playerPayload.summary, /will be used|fallback profile|live and fallback/i);
});

test('empty questions and unconfigured live providers fail honestly', async () => {
  const emptyResponse = await request('/api/query', {
    method: 'POST',
    headers: { 'content-type': 'application/json' },
    body: JSON.stringify({ question: '' })
  });
  assert.equal(emptyResponse.status, 400);

  const liveResponse = await request('/api/cricapi/live-scores');
  assert.equal(liveResponse.status, 503);
  const livePayload = await liveResponse.json();
  assert.equal(livePayload.provider, 'cricapi');
  assert.equal(livePayload.source, 'external');
});

test('CORS and request-size protections reject unsafe requests', async () => {
  const deniedOrigin = await request('/api/status', {
    headers: { origin: 'https://untrusted.example' }
  });
  assert.equal(deniedOrigin.status, 403);

  const allowedOrigin = await request('/api/status', {
    headers: { origin: 'http://127.0.0.1:5173' }
  });
  assert.equal(allowedOrigin.status, 200);
  assert.equal(allowedOrigin.headers.get('access-control-allow-origin'), 'http://127.0.0.1:5173');

  const oversized = await request('/api/query', {
    method: 'POST',
    headers: { 'content-type': 'application/json' },
    body: JSON.stringify({ question: 'x'.repeat(40 * 1024) })
  });
  assert.equal(oversized.status, 413);
});
