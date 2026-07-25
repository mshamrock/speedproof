# SpeedProof Chrome Extension

This branch preserves the original SpeedProof Chrome extension.

## Server configuration

`checkGrammar.php` requires the OpenAI API key to be supplied by the hosting
environment:

```text
OPENAI_API_KEY
```

Never commit a real API key or place it in `.env.example`. A production
deployment should also restrict allowed origins, authenticate requests, apply
rate limits, validate input size, and avoid exposing an unrestricted OpenAI
proxy to the public internet.

The actively developed native macOS application is available on the `main`
branch.
