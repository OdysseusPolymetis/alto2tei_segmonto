#!/usr/bin/env bash
set -euo pipefail

if [ "$#" -lt 2 ]; then
  echo "Usage: ./scripts/run_tei2html_v3.sh input_tei.xml output.html"
  exit 1
fi

INPUT="$1"
OUTPUT="$2"

xsltproc xsl/tei2html_robust.xsl "$INPUT" > "$OUTPUT"
echo "HTML généré dans: $OUTPUT"
