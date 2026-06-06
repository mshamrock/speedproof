# Grace AI

Grace AI is a native macOS clipboard helper built with AppKit.

When the app is running, it watches the clipboard:

1. If copied text is in Russian, it translates it to English.
2. If copied text is in English, it fixes spelling, punctuation, grammar, and phrasing.

The app shows:

- the original text;
- the transformed text;
- a large button to copy the final text back to the clipboard.
- a manual input fallback if the clipboard is empty.

## Build

```bash
./scripts/build_app.sh
```

The build script creates:

```text
.build/Grace AI.app
```

## How it works

The app polls the macOS clipboard for new text and decides the mode locally:

- Cyrillic text -> translate to English
- Latin text -> polish English

The transformation itself is sent directly to the OpenAI Responses API from inside the app.

## OpenAI API key

The easiest way now is to open the app and click the gear icon in the top-right corner. Grace AI will save your key in its local app settings on this Mac, so there are no repeated Keychain access prompts.

You can still provide the key through the environment if you prefer:

```bash
export OPENAI_API_KEY='your_api_key_here'
```

If you want the key to persist for future terminal sessions:

```bash
echo 'export OPENAI_API_KEY="your_api_key_here"' >> ~/.zshrc
source ~/.zshrc
```

## Optional overrides

Override the model used for text transformation:

```bash
export GRACE_AI_OPENAI_MODEL='gpt-5.4-nano'
```

## Notes

- The app measures processing time and shows it in the status block.
- If the copied text is neither Russian nor English, it is skipped.
- The in-app API key is stored locally in Grace AI app settings for a smoother desktop experience.
