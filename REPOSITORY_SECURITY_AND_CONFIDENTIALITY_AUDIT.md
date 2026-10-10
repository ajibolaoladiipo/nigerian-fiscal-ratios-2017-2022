# Repository confidentiality and integrity audit

**Audit date:** 10 October 2026  
**Scope:** staged six-year release directory and its local Git history.

## Results

- No Word manuscripts, manuscript file names, private worklogs, reviewer correspondence, raw source PDFs/workbooks, credentials, tokens, or machine metadata were found in the staged release.
- The local Git history begins with the staged release and contains two release-preparation commits only. No sensitive prior history is present in this repository.
- The repository has no configured remote. It has not been pushed, published, or assigned a DOI.
- The package uses relative paths. The public R and Julia workflows do not depend on private macOS paths.
- The release checksum manifest contains 49 checksummed files before the Phase IX Julia outputs and workflow additions; refresh it before any deposit.

## Remaining controls

1. Confirm source/derived-data redistribution conditions before setting repository visibility to public.
2. Keep the repository private while PB&F double-anonymous review arrangements are unresolved.
3. Add the actual remote and archival identifier only after user authorization.
4. Re-run this scan and regenerate checksums immediately before deposit.
