#!/usr/bin/env julia
# Independent Julia verification. Reads the approved component panel, never the
# R Shapley output, and re-computes every permitted accounting result.
using DelimitedFiles

root = isempty(ARGS) ? pwd() : abspath(ARGS[1])
input = joinpath(root, "data", "derived", "PAPER_4_2017_2022_APPROVED_FISCAL_PANEL.csv")
raw = readdlm(input, ',', Any, '\n')
header = string.(raw[1, :]); ix = Dict(h => i for (i,h) in enumerate(header))
rows = raw[2:end, :]
fnum(x) = x isa Number ? Float64(x) : parse(Float64, string(x))
orders = [["D","E","e","Y"], ["D","E","Y","e"], ["D","e","E","Y"], ["D","e","Y","E"], ["D","Y","E","e"], ["D","Y","e","E"], ["E","D","e","Y"], ["E","D","Y","e"], ["E","e","D","Y"], ["E","e","Y","D"], ["E","Y","D","e"], ["E","Y","e","D"], ["e","D","E","Y"], ["e","D","Y","E"], ["e","E","D","Y"], ["e","E","Y","D"], ["e","Y","D","E"], ["e","Y","E","D"], ["Y","D","E","e"], ["Y","D","e","E"], ["Y","E","D","e"], ["Y","E","e","D"], ["Y","e","D","E"], ["Y","e","E","D"]]
q(v) = (v["D"] + v["e"] * v["E"] / 1e9) / v["Y"]
function shapley(old, new)
    ans = Dict(k => 0.0 for k in ("D","E","e","Y"))
    for ord in orders
        cur = copy(old); prior = q(cur)
        for k in ord
            cur[k] = new[k]; now = q(cur); ans[k] += now-prior; prior=now
        end
    end
    Dict(k => ans[k]/length(orders) for k in keys(ans))
end
data = [(state=string(r[ix["state"]]), year=Int(fnum(r[ix["year"]])), D=fnum(r[ix["domestic_debt_nbn"]]), E=fnum(r[ix["external_debt_usd"]]), e=fnum(r[ix["ngn_per_usd"]]), Y=fnum(r[ix["revenue_denominator_nbn"]])) for r in eachrow(rows)]
bykey = Dict((r.state,r.year)=>r for r in data)
mkpath(joinpath(root,"results"))
out = joinpath(root,"results","PAPER_4_PHASE_VIIB_JULIA_SHAPLEY.csv")
open(out,"w") do io
    println(io,"state,start_year,end_year,domestic_stock_contribution,external_usd_stock_contribution,valuation_contribution,revenue_denominator_contribution,actual_ratio_change,reconstructed_ratio_change,absolute_identity_difference,identity_pass")
    for year in 2017:2021, state in sort(unique(x.state for x in data))
        oldr=bykey[(state,year)]; newr=bykey[(state,year+1)]
        old=Dict("D"=>oldr.D,"E"=>oldr.E,"e"=>oldr.e,"Y"=>oldr.Y); new=Dict("D"=>newr.D,"E"=>newr.E,"e"=>newr.e,"Y"=>newr.Y)
        s=shapley(old,new); actual=q(new)-q(old); recon=sum(values(s)); err=abs(actual-recon)
        println(io,join([state,year,year+1,s["D"],s["E"],s["e"],s["Y"],actual,recon,err,err<=1e-10],","))
    end
end
# Counterfactual valuation outputs, independently recomputed from components.
vout=joinpath(root,"results","PAPER_4_PHASE_VIIB_JULIA_VALUATION.csv")
open(vout,"w") do io
    println(io,"scenario,year,state,scenario_external_exposure,scenario_combined_exposure")
    for scenario in ("common_2022_rate","2021_lower_rounding","2021_upper_rounding"), r in data
        rate = scenario=="common_2022_rate" ? 448.08 : (scenario=="2021_lower_rounding" && r.year==2021 ? 412.985 : (scenario=="2021_upper_rounding" && r.year==2021 ? 412.995 : r.e))
        ext=rate*r.E/1e9/r.Y; comb=r.D/r.Y+ext
        println(io,join([scenario,r.year,r.state,ext,comb],","))
    end
end
println("Julia independently wrote 180 Shapley records and 648 valuation records.")
