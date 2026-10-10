#!/usr/bin/env Rscript
# Governing Phase VII-B R workflow. No causal modelling is performed.
options(stringsAsFactors = FALSE)
args <- commandArgs(trailingOnly=TRUE)
root <- if (length(args)) args[[1]] else "."
root <- normalizePath(root, mustWork=TRUE)
out <- function(x) file.path(root,"results",x)
read_csv <- function(x) read.csv(x, check.names=FALSE, na.strings=c("","NA"))
key <- function(x) { z <- gsub("[^a-z]","",tolower(x)); sub("^nassarawa$","nasarawa",z) }
states <- c("Abia","Adamawa","Akwa Ibom","Anambra","Bauchi","Bayelsa","Benue","Borno","Cross River","Delta","Ebonyi","Edo","Ekiti","Enugu","Gombe","Imo","Jigawa","Kaduna","Kano","Katsina","Kebbi","Kogi","Kwara","Lagos","Nasarawa","Niger","Ogun","Ondo","Osun","Oyo","Plateau","Rivers","Sokoto","Taraba","Yobe","Zamfara")
rates <- data.frame(year=2017:2022, ngn_per_usd=c(306,307,326,381,412.99,448.08), valuation_status=c("PRIOR_PHASE_HISTORICAL_CONVENTION","EXPLICIT_DMO_CONVENTION","DMO_DOCUMENTED_AND_SOURCE_CONSISTENT","EXPLICIT_DMO_CONVENTION","SOURCE_CONSISTENT_INFERENCE_FROM_MATCHED_DMO_NATIONAL_TOTALS","PRIOR_PHASE_HISTORICAL_CONVENTION"))

# The release begins from the approved, source-audited component panel. Original
# DMO/NBS files are not redistributed; their persistent links and checksums are in
# data/documentation. This script independently recreates every public analysis.
panel <- read_csv(file.path(root,"data","derived","PAPER_4_2017_2022_APPROVED_FISCAL_PANEL.csv"))
message(sprintf("Panel diagnostic: %d rows; %s", nrow(panel), paste(names(table(panel$year)), as.integer(table(panel$year)), collapse=", ")))
if (any(!panel$panel_eligibility)) print(panel[!panel$panel_eligibility,c("state","year","igr_ngn","faac_ngn","domestic_debt_ngn","external_debt_usd","ngn_per_usd")])
stopifnot(nrow(panel)==216,length(unique(paste(panel$state_key,panel$year)))==216,all(panel$panel_eligibility))
write.csv(panel,out("PAPER_4_2017_2022_APPROVED_FISCAL_PANEL.csv"),row.names=FALSE)

# Construct indicators and assert the approved identity.
ind <- panel; ind$own_source_revenue_share<-ind$igr_nbn/ind$revenue_denominator_nbn; ind$domestic_debt_exposure<-ind$domestic_debt_nbn/ind$revenue_denominator_nbn; ind$external_debt_exposure<-ind$external_debt_nbn/ind$revenue_denominator_nbn; ind$combined_debt_exposure<-ind$combined_debt_nbn/ind$revenue_denominator_nbn; ind$combined_identity_gap<-ind$combined_debt_exposure-ind$domestic_debt_exposure-ind$external_debt_exposure; ind$combined_identity_pass<-abs(ind$combined_identity_gap)<=1e-12; stopifnot(all(ind$combined_identity_pass)); write.csv(ind,out("PAPER_4_2017_2022_FISCAL_INDICATORS.csv"),row.names=FALSE)
measures <- c("own_source_revenue_share","domestic_debt_exposure","external_debt_exposure","combined_debt_exposure")
summ <- function(x,y,m,num,den) data.frame(year=y,measure=m,n=length(x),mean=mean(x),median=median(x),sd=sd(x),iqr=IQR(x),minimum=min(x),maximum=max(x),ratio_of_aggregates=sum(num)/sum(den))
desc <- do.call(rbind,lapply(split(ind,ind$year),function(d) do.call(rbind,lapply(measures,function(m){num<-switch(m,own_source_revenue_share=d$igr_nbn,domestic_debt_exposure=d$domestic_debt_nbn,external_debt_exposure=d$external_debt_nbn,combined_debt_exposure=d$combined_debt_nbn);summ(d[[m]],d$year[1],m,num,d$revenue_denominator_nbn)}))))
write.csv(desc,out("PAPER_4_2017_2022_DESCRIPTIVE_RESULTS.csv"),row.names=FALSE)
corout <- do.call(rbind,lapply(split(ind,ind$year),function(d){z<-cor(d[,measures]); x<-as.data.frame(as.table(z)); names(x)<-c("measure_a","measure_b","pearson_correlation"); cbind(year=d$year[1],x)})); write.csv(corout,out("PAPER_4_2017_2022_COMPONENT_DEPENDENCE.csv"),row.names=FALSE)

# Rank persistence and state rank transitions.
comparisons <- rbind(data.frame(start=2017:2021,end=2018:2022,comparison="consecutive"),data.frame(start=c(2017,2017,2018),end=c(2020,2022,2021),comparison="prespecified_long_interval")); ranks<-list(); ii<-1
for(j in seq_len(nrow(comparisons))) for(m in measures){a<-ind[ind$year==comparisons$start[j],c("state",m)];b<-ind[ind$year==comparisons$end[j],c("state",m)];names(a)[2]<-"a";names(b)[2]<-"b";z<-merge(a,b,by="state");z$rs<-rank(-z$a);z$re<-rank(-z$b);z$disp<-abs(z$rs-z$re);q<-function(x) cut(x,breaks=quantile(x,seq(0,1,.25),type=1),include.lowest=TRUE,labels=FALSE);z$qs<-q(z$rs);z$qe<-q(z$re);ranks[[ii]]<-data.frame(record_type="pair_summary",measure=m,start_year=comparisons$start[j],end_year=comparisons$end[j],comparison=comparisons$comparison[j],state=NA,n=nrow(z),spearman=cor(z$a,z$b,method="spearman"),median_absolute_displacement=median(z$disp),maximum_absolute_displacement=max(z$disp),quartile_changes=sum(z$qs!=z$qe),rank_start=NA,rank_end=NA,absolute_rank_displacement=NA,quartile_start=NA,quartile_end=NA);ii<-ii+1;ranks[[ii]]<-data.frame(record_type="state_transition",measure=m,start_year=comparisons$start[j],end_year=comparisons$end[j],comparison=comparisons$comparison[j],state=z$state,n=NA,spearman=NA,median_absolute_displacement=NA,maximum_absolute_displacement=NA,quartile_changes=NA,rank_start=z$rs,rank_end=z$re,absolute_rank_displacement=z$disp,quartile_start=z$qs,quartile_end=z$qe);ii<-ii+1}
write.csv(do.call(rbind,ranks),out("PAPER_4_2017_2022_RANKING_DIAGNOSTICS.csv"),row.names=FALSE)

# Exact Shapley accounting: all 24 orderings of D, E, e, and Y.
perms <- function(x) if(length(x)==1) list(x) else unlist(lapply(seq_along(x),function(i)lapply(perms(x[-i]),function(p)c(x[i],p))),recursive=FALSE)
orders<-perms(c("D","E","e","Y")); qfun<-function(v)(v[["D"]]+v[["e"]]*v[["E"]]/1e9)/v[["Y"]]
shapley <- function(old,new){ans<-setNames(rep(0,4),names(old));for(o in orders){cur<-old;prior<-qfun(cur);for(k in o){cur[[k]]<-new[[k]];now<-qfun(cur);ans[[k]]<-ans[[k]]+now-prior;prior<-now}};ans/length(orders)}
sh<-list();ii<-1;for(y in 2017:2021){a<-ind[ind$year==y,];b<-ind[ind$year==y+1,];z<-merge(a,b,by="state",suffixes=c("_old","_new"));for(k in seq_len(nrow(z))){old<-c(D=z$domestic_debt_nbn_old[k],E=z$external_debt_usd_old[k],e=z$ngn_per_usd_old[k],Y=z$revenue_denominator_nbn_old[k]);new<-c(D=z$domestic_debt_nbn_new[k],E=z$external_debt_usd_new[k],e=z$ngn_per_usd_new[k],Y=z$revenue_denominator_nbn_new[k]);s<-shapley(old,new);actual<-qfun(new)-qfun(old);recon<-sum(s);sh[[ii]]<-data.frame(state=z$state[k],start_year=y,end_year=y+1,domestic_stock_contribution=s["D"],external_usd_stock_contribution=s["E"],valuation_contribution=s["e"],revenue_denominator_contribution=s["Y"],actual_ratio_change=actual,reconstructed_ratio_change=recon,absolute_identity_difference=abs(actual-recon),relative_identity_difference=abs(actual-recon)/max(abs(actual),1e-15),identity_pass=abs(actual-recon)<=1e-10);ii<-ii+1}}
sh<-do.call(rbind,sh);stopifnot(nrow(sh)==180,all(sh$identity_pass));write.csv(sh,out("PAPER_4_2017_2022_SHAPLEY_DECOMPOSITION.csv"),row.names=FALSE)

# Prespecified valuation and source-date sensitivity outputs.
rankx<-function(x)rank(-x);sens<-list();ii<-1;for(sc in c("common_2022_rate","2021_lower_rounding","2021_upper_rounding")){d<-ind;e<-d$ngn_per_usd;if(sc=="common_2022_rate")e[]<-448.08;if(sc=="2021_lower_rounding")e[d$year==2021]<-412.985;if(sc=="2021_upper_rounding")e[d$year==2021]<-412.995;ext<-e*d$external_debt_usd/1e9/d$revenue_denominator_nbn;comb<-d$domestic_debt_exposure+ext;for(y in 2017:2022){q<-d$year==y;sens[[ii]]<-data.frame(scenario=sc,year=y,state=d$state[q],baseline_external_exposure=d$external_debt_exposure[q],scenario_external_exposure=ext[q],baseline_combined_exposure=d$combined_debt_exposure[q],scenario_combined_exposure=comb[q],baseline_rank=rankx(d$combined_debt_exposure[q]),scenario_rank=rankx(comb[q]),absolute_rank_displacement=abs(rankx(d$combined_debt_exposure[q])-rankx(comb[q])));ii<-ii+1}}
write.csv(do.call(rbind,sens),out("PAPER_4_2017_2022_VALUATION_SENSITIVITY.csv"),row.names=FALSE)
dateout<-do.call(rbind,lapply(split(ind,ind$year),function(d)do.call(rbind,lapply(c("full_sample","domestic_common_date_only"),function(g){x<-if(g=="full_sample")d else d[d$domestic_common_date,];data.frame(year=d$year[1],sample=g,n=nrow(x),mean_combined_exposure=mean(x$combined_debt_exposure),median_combined_exposure=median(x$combined_debt_exposure),mean_domestic_exposure=mean(x$domestic_debt_exposure),mean_external_exposure=mean(x$external_debt_exposure),qualified_source_date_observations=sum(d$source_date_qualified))}))))
write.csv(dateout,out("PAPER_4_2017_2022_REPORTING_DATE_SENSITIVITY.csv"),row.names=FALSE)
writeLines(c("# Phase VII-B source and variable dictionary","","`igr_ngn`: verified annual NBS internally generated revenue.","`faac_ngn`: verified January--December state-government net-FAAC disbursements.","`two_component_revenue_ngn`: IGR plus state-government net FAAC only.","`domestic_debt_ngn`: official DMO domestic debt stock; `external_debt_usd`: official DMO external stock before valuation.","All ratios are descriptive stock-to-two-component-annual-revenue quantities."),out("PAPER_4_PHASE_VIIB_SOURCE_AND_VARIABLE_DICTIONARY.md"))
writeLines(c("# Phase VII-B analytical eligibility report","",sprintf("The approved panel contains %d state-year observations: %d states in each of six years.",nrow(panel),length(states)),"All 216 rows pass the protocol's component-coverage rule. Source-date qualifications remain flags, not repairs."),out("PAPER_4_PHASE_VIIB_ANALYTICAL_ELIGIBILITY_REPORT.md"))
writeLines(c("# Phase VII-B source-to-result audit","","The panel uses prior verified 2017/2022 NBS and DMO audits, Phase VII-A2 NBS outputs for 2018--2021, and the Phase VII-A3 DMO component concordance. No inherited FAAC or BudgIT values enter it.","All indicators and outputs are generated by `scripts/09_run_phase_viib_analysis.R`."),out("PAPER_4_PHASE_VIIB_SOURCE_TO_RESULT_AUDIT.md"))
dir.create(out("phase_viib_outputs"),showWarnings=FALSE);writeLines(capture.output(sessionInfo()),out("phase_viib_outputs/R_sessionInfo.txt"));message("Phase VII-B R workflow completed: 216 panel rows, 180 Shapley transitions.")
