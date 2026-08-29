#!/usr/bin/env bash
set -euo pipefail

cd /work

rm -rf LIMEN_TED_SEXTPAIR_EXEC_v0.1
rm -rf LIMEN_TED_FREEZE_RECEIPT_PROTOCOL_v0.1
rm -rf output

unzip -q LIMEN_TED_SEXTPAIR_EXEC_v0.1.zip
unzip -q LIMEN_TED_FREEZE_RECEIPT_PROTOCOL_v0.1.zip

cd LIMEN_TED_SEXTPAIR_EXEC_v0.1

RUN_RC=0
bash run_all.sh || RUN_RC=$?

mkdir -p /work/output

cp work/xml/BT106_VALID.xml work/xml/BT106_MUTANT.xml \
   work/xml/BT19_VALID.xml work/xml/BT19_MUTANT.xml \
   work/xml/BT95_VALID.xml work/xml/BT95_MUTANT.xml \
   work/xml/BT50_VALID.xml work/xml/BT50_MUTANT.xml \
   work/xml/BT51_VALID.xml work/xml/BT51_MUTANT.xml \
   work/xml/BT57_VALID.xml work/xml/BT57_MUTANT.xml \
   /work/output/

if [ -d work/svrl ]; then
  cp work/svrl/*.svrl /work/output/ || true
fi

if [ -f work/FREEZE_RESULT.json ]; then
  cp work/FREEZE_RESULT.json /work/output/SEXTPAIR_FREEZE_RESULT.json
fi

if [ -f work/PREPARE_REPORT.json ]; then
  cp work/PREPARE_REPORT.json /work/output/
fi

cd /work

VERIFY_RC=0
python3 \
  LIMEN_TED_FREEZE_RECEIPT_PROTOCOL_v0.1/verify_receipt.py \
  /work/output || VERIFY_RC=$?

python3 - <<'PY'
from pathlib import Path
import hashlib
import json
import platform
import subprocess
import datetime

out = Path("/work/output")

def sha(path):
    return hashlib.sha256(path.read_bytes()).hexdigest()

environment = {
    "execution_timestamp_utc":
        datetime.datetime.now(datetime.timezone.utc).isoformat(),
    "platform": platform.platform(),
    "python": platform.python_version(),
    "java":
        subprocess.run(
            ["java", "-version"],
            capture_output=True,
            text=True
        ).stderr.strip(),
    "maven":
        subprocess.run(
            ["mvn", "-version"],
            capture_output=True,
            text=True
        ).stdout.strip(),
    "sdk_tag": "1.13.3",
    "phase": "eforms-16",
    "validator": "ph-schematron-pure 8.0.3",
    "input_package_sha256": {
        "LIMEN_TED_SEXTPAIR_EXEC_v0.1.zip":
            sha(Path("/work/LIMEN_TED_SEXTPAIR_EXEC_v0.1.zip")),
        "LIMEN_TED_FREEZE_RECEIPT_PROTOCOL_v0.1.zip":
            sha(Path("/work/LIMEN_TED_FREEZE_RECEIPT_PROTOCOL_v0.1.zip"))
    },
    "output_files_sha256": {
        p.name: sha(p)
        for p in sorted(out.iterdir())
        if p.is_file()
    }
}

(out / "EXECUTION_ENVIRONMENT.json").write_text(
    json.dumps(environment, indent=2),
    encoding="utf-8"
)
PY

cd /work/output

sha256sum * > SHA256SUMS.txt

zip -qr /work/LIMEN_TED_EXECUTION_RECEIPT.zip .

echo
echo "=============================================="
echo "LIMEN-TED EXECUTION COMPLETE"
echo "=============================================="
echo "run_all.sh exit code: $RUN_RC"
echo "receipt verifier exit code: $VERIFY_RC"
echo
echo "Artifact:"
echo "/work/LIMEN_TED_EXECUTION_RECEIPT.zip"
echo "=============================================="

exit 0
