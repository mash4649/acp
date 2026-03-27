# Conformant Implementation Registry

This document describes the ACP conformant implementation registry published as a static website.

## Purpose

The registry provides a public, traceable list of certification claims and evidence links.

## Registry Artifacts

- Machine-readable source: `docs/registry/implementations.json`
- Published page: `docs/registry/index.html`
- Renderer: `scripts/render_conformance_registry.sh`

## Render Command

```bash
./scripts/render_conformance_registry.sh
```

You can also pass custom input/output paths:

```bash
./scripts/render_conformance_registry.sh /path/to/implementations.json /path/to/index.html
```

## Entry Model

Each registry entry includes:

- implementation ID and display name
- maintainer
- certification level (`L1`, `L2`, `L3`)
- status (`active`, `revoked`, `suspended`, `expired`)
- self-authored marker
- profile coverage
- evidence links (report + suite manifest)
- issue/renewal dates

## KPI Note

Self-authored entries are listed for transparency, but they do not count toward the roadmap KPI for external conformant implementations.

