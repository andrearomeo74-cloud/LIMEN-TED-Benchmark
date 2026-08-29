#!/usr/bin/env bash
set -u

cd /work
rm -rf LIMEN_TED_v0.2_WAVE1_EXEC output
mkdir -p output

UNZIP_RC=0
unzip -q LIMEN_TED_v0.2_WAVE1_EXEC.zip || UNZIP_RC=$?

RUN_RC=999
ANALYZER_PRESENT=false

if [ "$UNZIP_RC" -eq 0 ] && [ -d LIMEN_TED_v0.2_WAVE1_EXEC ]; then
  cd LIMEN_TED_v0.2_WAVE1_EXEC
  RUN_RC=0
  bash run_wave1.sh || RUN_RC=$?

  if [ -f WAVE1_ORACLE_RESULT.json ]; then
    cp WAVE1_ORACLE_RESULT.json /work/output/
    ANALYZER_PRESENT=true
  fi

  if [ -f PREREGISTERED_WAVE1_LEDGER.json ]; then
    cp PREREGISTERED_WAVE1_LEDGER.json /work/output/
  fi

  if [ -f STATIC_BUILD_REPORT.json ]; then
    cp STATIC_BUILD_REPORT.json /work/output/
  fi

  if [ -f SOURCE_PROVENANCE.json ]; then
    cp SOURCE_PROVENANCE.json /work/output/
  fi

  if [ -d work/svrl ]; then
    mkdir -p /work/output/svrl
    cp work/svrl/*.svrl /work/output/svrl/ 2>/dev/null || true
  fi

  mkdir -p /work/output/xml
  cp candidates/xml/*.xml /work/output/xml/ 2>/dev/null || true
  cp baseline/FROZEN_BASELINE.xml /work/output/xml/ 2>/dev/null || true

  cd /work
fi

python3 - <<'PY'
from pathlib import Path
import json
import hashlib
import platform
import subprocess
import datetime

out = Path("/work/output")
out.mkdir(exist_ok=True)

def sha(p):
    return hashlib.sha256(Path(p).read_bytes()).hexdigest()

def cmd(args, stderr=False):
    try:
        r = subprocess.run(
            args,
            capture_output=True,
            text=True,
            timeout=30
        )
        return (r.stderr if stderr else r.stdout).strip()
    except Exception as e:
        return f"UNAVAILABLE: {type(e).__name__}: {e}"

env = {
    "execution_timestamp_utc":
        datetime.datetime.now(datetime.timezone.utc).isoformat(),
    "platform": platform.platform(),
    "python": platform.python_version(),
    "java": cmd(["java", "-version"], stderr=True),
    "maven": cmd(["mvn", "-version"]),
    "sdk_tag": "1.13.3",
    "phase": "eforms-16",
    "validator": "ph-schematron-pure 8.0.3",
    "input_package_sha256": {
        "LIMEN_TED_v0.2_WAVE1_EXEC.zip":
            sha("/work/LIMEN_TED_v0.2_WAVE1_EXEC.zip")
    }
}

(out / "EXECUTION_ENVIRONMENT.json").write_text(
    json.dumps(env, indent=2),
    encoding="utf-8"
)
PY

cat > /work/output/EXECUTION_STATUS.json <<EOF
{
  "unzip_exit_code": $UNZIP_RC,
  "run_wave1_exit_code": $RUN_RC,
  "analyzer_result_present": $ANALYZER_PRESENT
}
EOF

cd /work/output

python3 - <<'PY'
from pathlib import Path
import hashlib
import json

root = Path(".")
m = {}

for p in sorted(root.rglob("*")):
    if p.is_file() and p.name != "SHA256SUMS.json":
        m[str(p)] = hashlib.sha256(p.read_bytes()).hexdigest()

Path("SHA256SUMS.json").write_text(
    json.dumps(m, indent=2),
    encoding="utf-8"
)
PY

zip -qr /work/LIMEN_TED_v0.2_WAVE1_EXECUTION_RECEIPT.zip .

echo
echo "=================================================="
echo "LIMEN-TED v0.2 WAVE 1 EXECUTION COMPLETE"
echo "=================================================="
echo "unzip exit code: $UNZIP_RC"
echo "run_wave1.sh exit code: $RUN_RC"
echo "analyzer result present: $ANALYZER_PRESENT"
echo "Receipt: /work/LIMEN_TED_v0.2_WAVE1_EXECUTION_RECEIPT.zip"
echo "=================================================="

exit 0
