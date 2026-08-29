#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")"
docker build -t limen-ted-runner:v0.1 .
rm -f LIMEN_TED_EXECUTION_RECEIPT.zip
docker rm -f limen-ted-runner-instance >/dev/null 2>&1 || true
docker run --name limen-ted-runner-instance limen-ted-runner:v0.1
docker cp limen-ted-runner-instance:/work/LIMEN_TED_EXECUTION_RECEIPT.zip ./LIMEN_TED_EXECUTION_RECEIPT.zip
sha256sum LIMEN_TED_EXECUTION_RECEIPT.zip
echo "Created: $(pwd)/LIMEN_TED_EXECUTION_RECEIPT.zip"
