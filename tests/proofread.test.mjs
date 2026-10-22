import assert from 'node:assert/strict';
import test from 'node:test';

import { POST, responseText, sensitiveTextReason } from '../api/proofread.mjs';

test('extracts direct and nested Responses API text', () => {
  assert.equal(responseText({ output_text: ' Corrected. ' }), 'Corrected.');
  assert.equal(responseText({ output: [{ content: [{ text: 'Corrected.' }] }] }), 'Corrected.');
});

test('blocks standalone emails and likely credentials', () => {
  assert.equal(sensitiveTextReason('person@example.com'), 'a standalone email address');
  assert.equal(sensitiveTextReason('api_key=super-secret-value'), 'a possible credential or secret');
  assert.equal(sensitiveTextReason('Please email person@example.com tomorrow.'), '');
});

test('validates empty input before requiring an API key', async () => {
  const request = new Request('https://speedproof.mshamil.com/api/proofread', {
    method: 'POST',
    headers: { 'content-type': 'application/json', origin: 'https://speedproof.mshamil.com' },
    body: JSON.stringify({ text: '   ' }),
  });
  const response = await POST(request);

  assert.equal(response.status, 400);
  assert.deepEqual(await response.json(), { error: 'Paste or type some text first.' });
});

test('rejects cross-origin browser requests', async () => {
  const request = new Request('https://speedproof.mshamil.com/api/proofread', {
    method: 'POST',
    headers: { 'content-type': 'application/json', origin: 'https://example.com' },
    body: JSON.stringify({ text: 'hello' }),
  });
  const response = await POST(request);

  assert.equal(response.status, 403);
});
