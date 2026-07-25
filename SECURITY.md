# Security Policy

## Reporting a vulnerability

Please do not open a public issue for a suspected vulnerability or include
credentials, clipboard contents, or personal information in a report.

Use GitHub's private vulnerability reporting for this repository:

1. Open the repository's **Security** tab.
2. Select **Report a vulnerability**.
3. Describe the affected version, reproduction steps, and expected impact.

If private vulnerability reporting is not enabled, open a public issue that
contains no sensitive details and asks the maintainer for a private contact
channel.

## Scope

Security reports are especially useful for:

- accidental transmission of text that should be stopped locally;
- exposure or insecure handling of an OpenAI API key;
- clipboard data leakage;
- unsafe global shortcut behavior;
- unintended storage of private text;
- network requests to destinations other than OpenAI.

Do not include a real API key or confidential source text in a proof of concept.
