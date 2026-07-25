# Privacy

SpeedProof is a local macOS application that uses the OpenAI Responses API to
transform text.

## Data sent to OpenAI

When processing is enabled, eligible plain text copied to the clipboard or
entered manually is sent directly from the Mac to OpenAI. The request also
contains instructions derived from the selected language and tone.

OpenAI handles that request according to the terms and data controls associated
with the API key supplied by the user. Review the
[OpenAI API data usage policies](https://platform.openai.com/docs/guides/your-data)
before using SpeedProof.

## Data kept on the Mac

SpeedProof stores the following locally:

- the OpenAI API key in
  `~/Library/Application Support/SpeedProof/openai_api_key.txt`;
- selected model, languages, interface language, and tone in application
  preferences;
- recent original and transformed text in application preferences.

SpeedProof does not operate a backend server and does not send analytics or
advertising identifiers.

## Local safeguards

Before making an OpenAI request, SpeedProof skips standalone email addresses
and pauses for text that resembles common credentials, API keys, private keys,
tokens, long encoded secrets, or payment card numbers.

These checks are heuristic. They may miss sensitive information or stop text
that is harmless. Do not copy confidential text while background processing is
enabled unless you are comfortable sending it to OpenAI.

## Clearing local data

The API key can be removed from SpeedProof Settings. App preferences and local
history can be cleared by removing SpeedProof's preferences through standard
macOS tools or by deleting the application data for SpeedProof.
