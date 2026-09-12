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
the formalization and `VersoBlueprint` to a v4.34 revision with checked Blueprint
references and section anchors.

## Document references

Use `{bpref "label"}[]` for Blueprint nodes and `{ref "tag"}[Section title]`
for ordinary section tags. Both should point to existing targets; ordinary
Verso `ref` requires explicit link text.
It uses the section's generated slug: the source tag `sec-TT*-T*T` becomes
`sec-TT___-T___T`. Keep the source tag and raw TeX witness unchanged.

The local `CarlesonBlueprint.Equations` module gives equations their own document
targets without introducing Blueprint nodes or dependencies:

```text
{equation "source-label"}[$$`x = y`]
{ref "source-label" (domain := CarlesonBlueprint.equation)}[the displayed identity]
```

The equation role preserves the formula and provides HTML and PDF link targets.
The adjacent raw TeX witness remains unchanged. CI checks forward references,
duplicate labels, preview anchors, and the actual HTML link targets. To repeat the
Lean tests and additionally check PDF link targets, run:

```bash
lake test
lake exe vbp build --output _out/site --pdf
python3 scripts/check_built_references.py --site-dir _out/site/html-multi --tex _out/site/tex/main.tex
```
