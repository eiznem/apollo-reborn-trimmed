# Trimmed Apollo Reborn GLASS

This repository automatically downloads the latest stable full **GLASS** IPA from
[`Apollo-Reborn/Apollo-Reborn`](https://github.com/Apollo-Reborn/Apollo-Reborn), keeps only:

- `Apollofari.appex` — **Open in Apollo (Manual Fallback)** for Safari
- `OpenInUIExtension.appex` — **Open in Apollo** from the share sheet

It removes Apollo's intents, widgets, notification content/service extensions, and
`ApollofariLegacy.appex`. The result uses three App IDs when SideStore signs the main app and
the two retained extensions.

## Setup

1. Create a GitHub repository named `apollo-reborn-trimmed` under `eiznem`.
2. Add these files to its default `main` branch.
3. In **Settings → Actions → General → Workflow permissions**, select **Read and write permissions**.
4. Open **Actions → Publish trimmed Apollo Reborn GLASS → Run workflow** once.
5. After it succeeds, add this source URL in SideStore:

   `https://raw.githubusercontent.com/eiznem/apollo-reborn-trimmed/main/sidestore-source.json`

The workflow checks daily at 09:23 UTC. It publishes only when the upstream stable release tag
has changed, so repeated scheduled runs do not create duplicates. No secrets are required; it
uses the repository's built-in `GITHUB_TOKEN`.

## Safety behavior

The trimmer identifies the two retained extensions by their full bundle identifiers and exits
without publishing if either disappears or if the output does not contain exactly two `.appex`
bundles. This intentionally turns an upstream rename into a visible failed workflow instead of
silently publishing a broken IPA.

## Notes

- This is a repackaging workflow, not an Apple code-signing workflow. SideStore performs signing.
- The upstream project and Apollo's original licensing/terms still apply. Keep the repository
  private if you do not want the derivative IPA publicly accessible; private release downloads
  are not suitable as a normal SideStore source URL.
- `ApollofariLegacy.appex` is a separate legacy Safari fallback and is intentionally removed to
  keep the total at three App IDs.
