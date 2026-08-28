# Carleson Blueprint

[![Blueprint Pages](https://github.com/ejgallego/verso-carleson/actions/workflows/blueprint.yml/badge.svg)](https://github.com/ejgallego/verso-carleson/actions/workflows/blueprint.yml)

Verso Blueprint port of the Carleson Blueprint. The upstream formalization is
carried locally as the [`Carleson`](Carleson/) submodule.

Blueprint: <https://ejgallego.github.io/verso-carleson/>
Upstream blueprint repository:
[fpvandoorn/carleson](https://github.com/fpvandoorn/carleson)

This repo follows the upstream blueprint strictly and translates its source
markup language to Verso with the help of AI. Credit for the original blueprint
and formalization belongs to the upstream project.

## Build the Blueprint site

```bash
bash ./scripts/ci-pages.sh
```

The harness command checks the dependency cache before running
`lake exe vbp build --output _out/site`.

This repository follows the shared
[`tools/verso-harness`](tools/verso-harness/) workflow. The root
[`lean-toolchain`](lean-toolchain) selects Lean v4.34.0-rc2. The root
[`lakefile.lean`](lakefile.lean) pins mathlib to the RC2 revision selected by
the formalization and `VersoBlueprint` to the matching v4.34 release branch.
