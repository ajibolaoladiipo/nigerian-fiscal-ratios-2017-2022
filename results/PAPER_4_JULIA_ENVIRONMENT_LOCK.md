# Fresh Julia execution environment

**Execution date:** 10 October 2026  
**Julia:** 1.11.2  
**Operating system:** macOS 27.0.1, arm64  
**Package environment:** standard library only (`DelimitedFiles`); no external package manifest required.

The release was copied to a clean temporary directory before execution. Its 49-file manifest passed before the analysis ran. Julia directly read the approved 216-observation panel and independently produced 180 Shapley records and 648 valuation-scenario records. The subsequent R comparator matched all 180 transitions and six quantities per transition to the governing R output. The maximum absolute difference was `4.8849813083506888e-15`, below the locked `1e-10` tolerance.

Commands:

```sh
julia --project=julia julia/01_reproduce_julia_verification.jl .
Rscript scripts/02_compare_r_julia.R .
```

This confirms numerical implementation agreement only; it does not independently establish source truth, construct validity, or causal interpretation.
