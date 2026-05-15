#!/bin/bash
set -euo pipefail

OUT="org.koretoggle.plasmoid"

rm -f "$OUT"
zip -r "$OUT" metadata.json contents/

echo "Built $OUT"
