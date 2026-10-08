#!/usr/bin/env bash
set -euo pipefail

# Consumer-owned regression checks retained when the shared CI is regenerated.
lake test
python3 scripts/check_built_references.py --site-dir _out/site/html-multi
