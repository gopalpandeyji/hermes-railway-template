#!/bin/sh
set -e

python3 - <<'PY'
from pathlib import Path

# Patch mini_swe_runner.py
p = Path("/opt/hermes/mini_swe_runner.py")
s = p.read_text()

if '"max_tokens": 1200' not in s:
    old = '"tools": self.tools, "timeout": 300.0}'
    new = '"tools": self.tools, "timeout": 300.0, "max_tokens": 1200}'
    if old not in s:
        raise SystemExit("mini_swe_runner.py: expected code not found")
    s = s.replace(old, new, 1)
    p.write_text(s)

# Patch trajectory_compressor.py
p = Path("/opt/hermes/trajectory_compressor.py")
s = p.read_text()

old = '"max_tokens": cfg.summary_target_tokens * 2'
new = '"max_tokens": 1200'

if old in s:
    s = s.replace(old, new, 1)
elif '"max_tokens": 1200' not in s:
    raise SystemExit("trajectory_compressor.py: expected code not found")

p.write_text(s)

print("max_tokens patch applied successfully")
PY
