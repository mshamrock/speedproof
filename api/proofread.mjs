const MAX_TEXT_LENGTH = 4000;
const RATE_LIMIT_WINDOW_MS = 60_000;
const RATE_LIMIT_REQUESTS = 8;
const requestBuckets = new Map();

const SENSITIVE_PATTERNS = [
  /-----BEGIN [A-Z ]*PRIVATE KEY-----/i,
  /\bsk-(?:proj-)?[A-Za-z0-9_-]{20,}\b/,
  /\b(?:gh[opusr]_[A-Za-z0-9]{20,}|AKIA[0-9A-Z]{16})\b/,
  /\b(?:bearer|authorization)\s*[:=]\s*[A-Za-z0-9._~+/=-]{16,}/i,
  /\b(?:password|passwd|secret|api[_ -]?key)\s*[:=]\s*\S{8,}/i,
];

function json(body, status = 200, extraHeaders = {}) {
  return Response.json(body, {
    status,
    headers: {
      'Cache-Control': 'no-store',
      'X-Content-Type-Options': 'nosniff',
      ...extraHeaders,
    },
  });
}

function requestIP(request) {
  const forwarded = request.headers.get('x-forwarded-for') || '';
  return forwarded.split(',')[0].trim() || request.headers.get('x-real-ip') || 'unknown';
}

export function isRateLimited(ip, now = Date.now()) {
  const bucket = requestBuckets.get(ip);
  if (!bucket || now - bucket.startedAt >= RATE_LIMIT_WINDOW_MS) {
    requestBuckets.set(ip, { count: 1, startedAt: now });
    return false;
  }

  bucket.count += 1;
  return bucket.count > RATE_LIMIT_REQUESTS;
}

export function sensitiveTextReason(text) {
  const trimmed = text.trim();
  if (/^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(trimmed)) {
    return 'a standalone email address';
  }

  if (SENSITIVE_PATTERNS.some((pattern) => pattern.test(trimmed))) {
    return 'a possible credential or secret';
  }

  const digits = trimmed.replace(/[^0-9]/g, '');
  if (digits.length >= 13 && digits.length <= 19 && /^(?:\d[ -]?){13,19}$/.test(trimmed)) {
    return 'a possible payment card number';
  }

  return '';
}

export function responseText(payload) {
  if (typeof payload?.output_text === 'string') {
    return payload.output_text.trim();
  }

  const parts = [];
  for (const item of payload?.output || []) {
    for (const content of item?.content || []) {
      if (typeof content?.text === 'string') parts.push(content.text);
    }
  }
  return parts.join('\n').trim();
}

function isSameOrigin(request) {
  const origin = request.headers.get('origin');
  if (!origin) return true;

  try {
    return new URL(origin).host === new URL(request.url).host;
  } catch {
    return false;
  }
}

export async function POST(request) {
  if (!isSameOrigin(request)) {
    return json({ error: 'This endpoint only accepts requests from SpeedProof.' }, 403);
  }

  const ip = requestIP(request);
  if (isRateLimited(ip)) {
    return json(
      { error: 'Too many requests. Please wait a minute and try again.' },
      429,
      { 'Retry-After': '60' },
    );
  }

  let body;
  try {
    body = await request.json();
  } catch {
    return json({ error: 'Send a valid JSON request.' }, 400);
  }

  const text = typeof body?.text === 'string' ? body.text.trim() : '';
  if (!text) {
    return json({ error: 'Paste or type some text first.' }, 400);
  }
  if (text.length > MAX_TEXT_LENGTH) {
    return json({ error: `Keep the text under ${MAX_TEXT_LENGTH.toLocaleString('en-US')} characters.` }, 400);
  }

  const sensitiveReason = sensitiveTextReason(text);
  if (sensitiveReason) {
    return json({ error: `This looks like ${sensitiveReason}, so SpeedProof did not process it.` }, 400);
  }

  const apiKey = process.env.OPENAI_API_KEY?.trim();
  if (!apiKey) {
    return json({ error: 'The online proofreader is not configured yet. Please try again later.' }, 503);
  }

  let openAIResponse;
  try {
    openAIResponse = await fetch('https://api.openai.com/v1/responses', {
      method: 'POST',
      headers: {
        Authorization: `Bearer ${apiKey}`,
        'Content-Type': 'application/json',
      },
      body: JSON.stringify({
        model: process.env.SPEEDPROOF_WEB_MODEL?.trim() || 'gpt-5-mini',
        instructions: [
          'You are SpeedProof, a precise proofreading utility.',
          'Correct spelling, punctuation, grammar, clarity, and awkward phrasing.',
          'Preserve the original meaning, language, formatting, names, links, and level of formality.',
          'Do not translate, explain, summarize, add facts, or wrap the answer in quotes or Markdown.',
          'Return only the corrected text. If the text is already correct, return it unchanged.',
        ].join(' '),
        input: text,
        max_output_tokens: 1600,
        store: false,
      }),
      signal: AbortSignal.timeout(25_000),
    });
  } catch (error) {
    const timedOut = error?.name === 'TimeoutError';
    return json({
      error: timedOut
        ? 'Proofreading took too long. Please try a shorter text.'
        : 'SpeedProof could not reach the language service. Please try again.',
    }, 502);
  }

  if (!openAIResponse.ok) {
    console.error('OpenAI proofreading request failed', openAIResponse.status);
    return json({ error: 'SpeedProof could not process the text. Please try again.' }, 502);
  }

  let payload;
  try {
    payload = await openAIResponse.json();
  } catch {
    return json({ error: 'SpeedProof received an unreadable response. Please try again.' }, 502);
  }

  const result = responseText(payload);
  if (!result) {
    return json({ error: 'SpeedProof did not receive corrected text. Please try again.' }, 502);
  }

  return json({ result });
}

