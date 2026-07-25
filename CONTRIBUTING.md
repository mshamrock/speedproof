# Contributing

Thanks for helping improve SpeedProof.

## Before opening an issue

- Check existing issues for the same problem.
- Include the macOS version and the steps that reproduce the issue.
- Remove clipboard content, API keys, personal information, and confidential
  text from screenshots and logs.
- Use the private process in `SECURITY.md` for vulnerabilities.

## Local development

Requirements:

- macOS 13 or newer
- Xcode Command Line Tools

Build and open the app:

```bash
./scripts/build_app.sh
open ".build/SpeedProof.app"
```

The app can use an API key entered in Settings or the `OPENAI_API_KEY`
environment variable. Never add a real key to source files, fixtures, issues,
or commits.

## Pull requests

- Keep each pull request focused on one behavior or improvement.
- Follow the existing Objective-C/AppKit patterns.
- Preserve the background clipboard and `Option+C` workflows.
- Test the normal clipboard flow, manual input, language switching, copy
  feedback, menu bar actions, and window resizing when relevant.
- Run `./scripts/build_app.sh` before submitting.
- Update README or privacy documentation when behavior or data flow changes.
