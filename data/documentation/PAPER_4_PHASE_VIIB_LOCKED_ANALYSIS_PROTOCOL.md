# Paper 4 Phase VII-B locked analysis protocol

**Version:** VII-B v01  
**Date:** 10 October 2026  
**Scope:** 36 Nigerian states, 2017--2022, inclusive  
**Status:** Registered before Phase VII-B calculations

## Analytical population and eligibility

The governing population is the 36 Nigerian states in each calendar reference
year from 2017 through 2022. FCT remains in raw DMO extraction only. An
observation is eligible only when it has a verified NBS IGR value, a verified
annual state-government net-FAAC value, a DMO domestic stock, a DMO external
stock in US dollars, and the year-specific valuation convention below. No
missing values will be imputed.

The denominator is the two-component annual aggregate \(Y=IGR+F\), where
\(F\) is January--December state-government `Total Net Amount` FAAC
disbursement. It is not called total state-government revenue.

## Measures and units

All naira values are converted to naira billions only after source verification.
External debt stays in US dollars in the approved panel and is converted for
ratio construction using \(e\), the naira-per-dollar convention. The four
primary descriptive measures are:

\[
IGR/Y, \qquad D/Y, \qquad eE/Y, \qquad (D+eE)/Y.
\]

They respectively describe own-source-revenue composition, domestic debt stock
relative to the stated annual aggregate, externally valued debt stock relative
to it, and combined reported debt stock relative to it. None is a measure of
state capacity, performance, solvency, or debt-service pressure.

## Valuation baseline

The fixed primary conventions are 306.00 (2017), 307.00 (2018), 326.00 (2019),
381.00 (2020), 412.99 (2021), and 448.08 (2022) naira per US dollar. The 2021
rate is source-consistent and inferred from matched DMO national aggregates,
not a directly printed conversion rule. The 2019 NGN360 reference is retained
only as a rejected candidate, not a sensitivity baseline.

## Source qualifications and restrictions

DMO component schedules are provisional. Domestic source-date exceptions remain
in the data. The main analysis uses all source-verified observations and
reports a date-comparable restriction that excludes a state in a year when its
domestic stock is not dated 31 December. No value is revised, interpolated, or
treated as a uniform year-end observation when the source says otherwise.

## Confirmatory calculations

1. Annual mean, median, standard deviation, interquartile range, minimum,
   maximum, and component shares, separately for each primary measure.
2. Consecutive and prespecified longer-interval Spearman rank correlations;
   absolute rank displacement; and quartile transitions. Each comparison uses
   its common eligible state set, with average ranks for ties and quartiles
   calculated within that same set.
3. Annual Pearson correlations among the four fiscal measures, labelled as
   descriptive shared-denominator associations.
4. Exact four-factor Shapley accounting for each eligible consecutive state
   transition using all 24 factor orderings for \(D,E,e,Y\). Contributions sum
   to \(Q_{t+1}-Q_t\), where \(Q=(D+eE)/Y\). The maximum expected record count
   is 180. The absolute identity tolerance is \(10^{-10}\).
5. Valuation sensitivity: a common 2022 valuation rate and a bounded 2021
   precision check of 412.985--412.995, both explicitly counterfactual.
6. Reporting-date sensitivity: full sample versus a common-date restriction.
   Any difference is interpreted as a joint consequence of source-date
   comparability and changed sample membership.

## Exhibits and interpretation limits

The Phase VII-B reports will use machine-readable tables and restrained figures.
Mean ratios, median ratios, and ratios of aggregates are never treated as the
same quantity. Shapley allocations are mathematical accounting contributions,
not causal explanations. Currency valuation is not borrowing. Rank stability is
not construct validation.

## Deviation control and verification

R is the governing implementation. Julia must separately recompute the
per-transition Shapley and valuation outputs from approved-panel inputs, rather
than consuming R contribution columns. Any deviation is recorded in the
numerical discrepancy log. The protocol checksum is retained with the run log.
