# Julia environment

The independent implementation uses only Julia's standard-library `DelimitedFiles` module. No third-party package is resolved or required, so a package `Manifest.toml` is not applicable.

The fresh release reproduction was executed on 10 October 2026 with Julia 1.11.2 on macOS arm64 using:

```sh
julia julia/01_reproduce_julia_verification.jl .
Rscript scripts/02_compare_r_julia.R .
```

The Julia script reads `data/derived/PAPER_4_2017_2022_APPROVED_FISCAL_PANEL.csv` directly, independently recomputes all 24-ordering Shapley allocations for 180 state transitions, and writes its results to `results/`. It does not read R Shapley contribution columns.
