# SpeedProof Product Notes

## Purpose

SpeedProof is a focused native macOS utility for cleaning up and translating
text with minimal context switching. It is not a general chat assistant. Its
primary loop is copy, process, review, and paste.

## Intended users

SpeedProof is designed for people who frequently write, rewrite, or translate
short work messages while moving between email, browsers, messengers, and
documents.

## Core workflows

### Background clipboard workflow

A regular `Command+C` leaves the current app in front. SpeedProof notices new
plain text, applies local safety checks, and processes eligible text in the
background.

### Intentional shortcut workflow

`Option+C` copies the current selection, brings SpeedProof forward, processes
the text, and copies the finished result back to the clipboard.

### Manual workflow

Text can be pasted or typed directly into SpeedProof. Typed text is processed
after a short pause.

## Product principles

1. Keep the copy-to-result loop fast.
2. Stay out of the way during ordinary clipboard use.
3. Make changes understandable through the final text, Error Review, and Diff
   View.
4. Stop obvious sensitive content locally before making a network request.
5. Keep all product state local except for text intentionally sent to OpenAI.
6. Feel native, compact, readable, and predictable on macOS.

## Current capabilities

- Clipboard watching and manual input.
- OpenAI Responses API integration using a user-provided key.
- Configurable translation language pair and interface language.
- Persistent Electric, Graphite, Arctic, and Evergreen color schemes.
- Neutral, Polite, Shorter, and Confident tone presets.
- Automatic Polite tone for likely messages and direct requests.
- Error Review and Diff View for English cleanup.
- Recent-item history stored in local application preferences.
- Menu bar commands and a global `Option+C` shortcut.
- Local checks for likely credentials, private keys, tokens, encoded secrets,
  and payment card numbers.
- Local skip for standalone email addresses.

## Privacy boundary

Eligible clipboard or manually entered text is sent directly to OpenAI. The app
has no SpeedProof-operated backend. Local safety checks reduce accidental
transmission of obvious secrets but cannot identify every sensitive value.

See [PRIVACY.md](PRIVACY.md) for the user-facing data-flow description.

## Technical shape

SpeedProof is written in Objective-C with AppKit and Carbon APIs. It is built by
`scripts/build_app.sh` without an Xcode project and produces
`.build/SpeedProof.app`.
