# Privacy

SpeedProof includes a local macOS application and a minimal online proofreader.
Both use the OpenAI Responses API to transform text, but their data paths are
different.

## Native app data sent to OpenAI

When processing is enabled, eligible plain text copied to the clipboard or
entered manually is sent directly from the Mac to OpenAI. The request also
contains instructions derived from the selected language and tone.

OpenAI handles that request according to the terms and data controls associated
with the API key supplied by the user. Review the
[OpenAI API data usage policies](https://platform.openai.com/docs/guides/your-data)
before using SpeedProof.

## Online proofreader data sent to OpenAI

Text submitted at `speedproof.mshamil.com` is relayed through a serverless
SpeedProof endpoint and sent to OpenAI for proofreading. The endpoint exists so
the website's service API key is never exposed to the browser. SpeedProof does
not intentionally store submitted source text or corrected results.

The online proofreader limits input length, rate-limits repeated requests, and
rejects some text that resembles standalone email addresses, credentials,
private keys, tokens, or payment card numbers. These checks are safeguards, not
a guarantee. Do not submit confidential information.

## Data kept on the Mac

SpeedProof stores the following locally:

- the OpenAI API key in
  `~/Library/Application Support/SpeedProof/openai_api_key.txt`;
- selected model, languages, interface language, and tone in application
  preferences;
- recent original and transformed text in application preferences.

The local app does not send analytics or advertising identifiers.

## Website analytics

The public website uses Google Analytics to understand aggregate page usage and
feature interactions. SpeedProof does not include submitted proofreader text in
analytics events. Google may process standard web request information according
to its own terms and privacy policies.

## Local safeguards

Before making an OpenAI request, the native app and online proofreader skip standalone email addresses
and pauses for text that resembles common credentials, API keys, private keys,
tokens, long encoded secrets, or payment card numbers.

These checks are heuristic. They may miss sensitive information or stop text
that is harmless. Do not copy confidential text while background processing is
enabled unless you are comfortable sending it to OpenAI.

## Clearing local data

The API key can be removed from SpeedProof Settings. App preferences and local
history can be cleared by removing SpeedProof's preferences through standard
macOS tools or by deleting the application data for SpeedProof.
