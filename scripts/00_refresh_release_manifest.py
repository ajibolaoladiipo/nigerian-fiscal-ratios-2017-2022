#!/usr/bin/env python3
"""Refresh checksums for committed release files, excluding the manifest.

The manifest is an input-integrity check. It must not include locally generated
verification outputs: a clean GitHub Actions checkout creates those only after
the input check has passed. Git's tracked-file list is therefore the release
boundary rather than the current directory contents.
"""
from pathlib import Path
import hashlib
import json
import subprocess

root = Path(__file__).resolve().parents[1]
manifest_path = root / "RELEASE_CHECKSUM_MANIFEST.json"
tracked = subprocess.run(
    ["git", "-C", str(root), "ls-files", "-z"],
    check=True,
    capture_output=True,
).stdout.decode().split("\0")
records = []
for relative in sorted(p for p in tracked if p and p != manifest_path.name):
    path = root / relative
    if not path.is_file():
        raise FileNotFoundError(f"Tracked release file is absent: {relative}")
    records.append({
        "file": relative,
        "sha256": hashlib.sha256(path.read_bytes()).hexdigest(),
        "bytes": path.stat().st_size,
    })
manifest_path.write_text(json.dumps(records, indent=2) + "\n")
print(f"Wrote checksums for {len(records)} release files.")
