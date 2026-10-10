# Nigerian state fiscal-ratio replication materials, 2017–2022

This is the public computational companion to *What Do Nigerian State Fiscal Ratios Measure? A Source-Audited Assessment of Revenue Composition and Debt Exposure*. It reproduces the study's descriptive fiscal-measurement analysis for 36 Nigerian states from 2017 through 2022. It contains no manuscript drafts, private worklogs, private correspondence, or inherited legacy debt field.

## What is included

- The approved 216-observation derived component panel and indicator file.
- Reproducible R analysis for the descriptive, ranking, valuation, reporting-date, and exact four-factor Shapley accounting outputs.
- An independent Julia implementation of the Shapley and valuation calculations, plus an R comparison script.
- Derived results, figures, source-link/checksum documentation, and source-to-result audit records.

## What is not included

Original DMO and NBS files are not redistributed here. They remain the publications of their respective government publishers. The documentation directory records their file identities, checksums, official locations, reporting qualifications, and row-level source references needed to retrieve and inspect them. This package is a reproducible analysis release, not a redistribution of those original documents.

## Reproduce the R analysis

From the repository root, run:

```sh
Rscript scripts/01_reproduce_r_analysis.R .
```

The script reads the approved component panel in `data/derived/` and overwrites the generated files in `results/`. It uses base R only. The substantive measures are descriptive: own-source-revenue share within a stated two-component aggregate, domestic debt exposure, external debt exposure, and combined debt exposure. No result estimates fiscal solvency, government performance, general state capacity, or causal effects.

## Independent Julia verification

With Julia installed, run:

```sh
julia julia/01_reproduce_julia_verification.jl .
Rscript scripts/02_compare_r_julia.R .
```

Julia reads the approved component panel directly; it does not read R contribution results. The R comparison applies the pre-specified absolute tolerance of `1e-10` to 180 state-transition Shapley records. Cross-language agreement checks calculation implementation, not source authenticity or construct validity.

## Data definitions and cautions

The revenue denominator is `IGR + annual state-government net FAAC disbursements`, a two-component annual revenue aggregate, rather than verified total state revenue. Debt-to-revenue measures are debt-stock-to-annual-two-component-revenue quantities. External debt remains available in U.S. dollars and is converted only with the documented annual source-supported convention. The 2021 rate is a source-consistent inference from matched DMO national totals, not an expressly published conversion rule. Source dates, provisional status, and non-December domestic debt reports remain visible in the derived panel and documentation.

The final six-year design is a documented amendment to the earlier three-snapshot research design. Its final protocol was locked before the redesigned ratio analysis.

## Release status

This local package passed its R clean-package calculation check. A public persistent archive/DOI must be created before journal submission. See `RELEASE_STATUS.md`, `DATA_ACCESS.md`, and `REPRODUCIBILITY.md`.
