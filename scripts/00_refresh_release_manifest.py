#!/usr/bin/env python3
"""Refresh checksums for this release, excluding the manifest itself."""
from pathlib import Path
import hashlib
import json

root = Path(__file__).resolve().parents[1]
manifest_path = root / "RELEASE_CHECKSUM_MANIFEST.json"
records = []
for path in sorted(p for p in root.rglob("*") if p.is_file() and p != manifest_path and ".git" not in p.parts):
    records.append({
        "file": str(path.relative_to(root)),
        "sha256": hashlib.sha256(path.read_bytes()).hexdigest(),
        "bytes": path.stat().st_size,
    })
manifest_path.write_text(json.dumps(records, indent=2) + "\n")
print(f"Wrote checksums for {len(records)} release files.")
