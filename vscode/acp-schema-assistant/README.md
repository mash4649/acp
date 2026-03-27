# ACP Schema Assistant

ACP Schema Assistant is a minimal VS Code extension for ACP JSON artifacts.

It provides:

- JSON schema validation for ACP artifacts
- schema-driven completion for the core artifact files shipped in this package
- a packaging layout that is ready for Marketplace publishing

## Install locally

Package the extension and install the VSIX into VS Code:

```bash
cd vscode/acp-schema-assistant
npx @vscode/vsce package
code --install-extension acp-schema-assistant-0.1.0.vsix
```

## How it works

The extension ships the following ACP core schemas:

- `agreement_v1`
- `revision_v1`
- `event_v1`
- `delegation_edge_v1`

When a JSON file matches one of the `fileMatch` patterns in `package.json`, VS Code uses the corresponding schema for validation and completion.

If your file naming is different, add a `"$schema"` property that points to the packaged schema file.

## Publishing

1. Make sure `publisher` in `package.json` matches your Marketplace publisher ID.
2. Run `npx @vscode/vsce package` to create the VSIX.
3. Run `npx @vscode/vsce publish` with your Marketplace personal access token.

The package is intentionally small and declarative so it can be reviewed and published without a build step.
