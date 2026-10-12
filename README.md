# SpeedProof

SpeedProof is a native macOS utility that improves and translates text directly
from the clipboard.

**Website and download:** [speedproof-umber.vercel.app](https://speedproof-umber.vercel.app)

It can work quietly in the background after a regular copy, process the
currently selected text with `Option+C`, or wait and paste the finished result
back with `Option+V`. The app sends eligible text directly
to the OpenAI Responses API using the API key supplied by the user.

## Highlights

- Native AppKit interface for macOS 13 and newer.
- Background clipboard processing without stealing focus.
- A contextual **Paste** button can return to the app where regular
  `Command+C` was pressed and replace the original selection.
- `Option+C` copies the current selection, opens SpeedProof, processes the
  text, and places the result back on the clipboard.
- `Option+V` keeps the current app in front, waits for processing to finish,
  copies the result, and replaces the selected text automatically.
- Manual text input with automatic processing after a short pause.
- Configurable source and target languages.
- Four persistent color schemes: Electric, Graphite, Arctic, and Evergreen.
- Tone presets: Neutral, Polite, Shorter, and Confident.
- Automatic Polite tone for text that looks like a message or email.
- Error Review and Diff View for English cleanup.
- Local processing history and menu bar controls.
- Local checks that pause processing for likely credentials, private keys,
  tokens, encoded secrets, and payment card numbers.
- Standalone email addresses are ignored.

## Requirements

- macOS 13 Ventura or newer
- Xcode Command Line Tools
- An OpenAI API key

Install the command line tools if needed:

```bash
xcode-select --install
```

## Build and run

```bash
git clone https://github.com/mshamrock/speedproof.git
cd speedproof
./scripts/setup_local_signing.sh
./scripts/build_app.sh
open ".build/SpeedProof.app"
```

The build script compiles the Objective-C/AppKit source, creates the application
bundle at `.build/SpeedProof.app`, copies the icon and metadata, and signs the
local build. A personal signing identity named `SpeedProof Local` is used when
available; otherwise the app receives an ad hoc signature. The signing setup is
a one-time step that gives local rebuilds a stable identity, so macOS can retain
Accessibility permission for Copy & Paste.

To create a reproducible public build without accessing the local signing
keychain, use:

```bash
SPEEDPROOF_USE_LOCAL_SIGNING=0 ./scripts/build_app.sh
```

The generated application is a universal macOS binary for Apple Silicon and
Intel Macs.

Because local builds are not notarized, macOS may ask you to confirm that you
want to open the app.

## Configure the API key

Open SpeedProof and select the settings button in the top-right corner. Add your
OpenAI API key and select a model.

The app stores the key in:

```text
~/Library/Application Support/SpeedProof/openai_api_key.txt
```

The file is created with permissions that restrict access to the current macOS
user. You may use an environment variable instead:

```bash
export OPENAI_API_KEY='your_api_key_here'
```

Never commit an API key, paste one into an issue, or include one in logs.

## Optional model override

The model can be selected in Settings or overridden for a local run:

```bash
export SPEEDPROOF_OPENAI_MODEL='your-model-id'
```

## How clipboard processing works

1. SpeedProof watches for new plain text on the macOS clipboard.
2. Obvious standalone email addresses and likely sensitive values are stopped
   locally.
3. Eligible text is sent to the OpenAI Responses API with the selected
   language and tone instructions.
4. SpeedProof remembers the originating app so the finished text can replace
   the original selection with **Paste**.
5. The original text, final text, review, diff, timing, and recent items remain
   available in the local app interface.

The sensitive-text checks are safeguards, not a guarantee. Review the
[privacy notes](PRIVACY.md) before enabling background clipboard processing.

## Project structure

```text
Sources/SpeedProof/main.m       AppKit app and OpenAI integration
Resources/Info.plist            Application bundle metadata
Resources/SpeedProof.icns       Application icon
scripts/build_app.sh            Local build and signing
scripts/setup_local_signing.sh  One-time stable local signing setup
scripts/generate_app_icon.py    Icon asset generator
```

SpeedProof intentionally has no backend server. OpenAI requests are sent
directly from the Mac using the user's API key.

## Contributing

Bug reports and focused pull requests are welcome. Read
[CONTRIBUTING.md](CONTRIBUTING.md) before submitting changes. Please report
security issues through the process in [SECURITY.md](SECURITY.md), not in a
public issue.

## License

SpeedProof is available under the [MIT License](LICENSE).
