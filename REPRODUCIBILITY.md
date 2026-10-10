# Reproducibility guide

## Requirements

- R (the R workflow uses base R functions only).
- Julia for the optional independent implementation; no external Julia packages are required.

## Execution order

1. Verify the package contents against `RELEASE_CHECKSUM_MANIFEST.json`.
2. Run `Rscript scripts/01_reproduce_r_analysis.R .`.
3. If Julia is available, run `julia julia/01_reproduce_julia_verification.jl .`.
4. Run `Rscript scripts/02_compare_r_julia.R .`.
5. Inspect the numerical discrepancy file. All 180 comparisons must pass the absolute tolerance of `1e-10`.

The R workflow writes analytical files only under `results/`. It never writes to the derived input panel or documentation directory.

## Expected checks

- 216 eligible state-year observations: 36 states by six years.
- 180 consecutive state-transition Shapley records.
- Exact identity: combined exposure equals domestic plus external exposure for each eligible observation.
- Exact accounting reconstruction within `1e-10` for every Shapley transition.

The archived runtime records under `logs/` document the original validated computational environment. A fresh environment may differ in incidental printing or file timestamps but must meet the numerical checks above.
