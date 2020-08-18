######################################################################################################################
# This file does a two-stage optimization of NICE (with and without revenue recycling) and saves the results. Users
# can change some of the core model parameters and optimization settings.
######################################################################################################################

# Load required Julia packages.
using NLopt

# Load RICE+AIR source code.
include("MimiNICE_recycle_time_varying.jl")

# ------------------------------------------------------------------------------------------------
# NICE + REVENUE RECYCLING PARAMETERS TO CHANGE
# ------------------------------------------------------------------------------------------------

# Pure rate of time preference.
ρ =  0.015

# Elasticity of marginal utility of consumption.
η =  1.5

# Income elasticity of climate damages (1 = proportional to income, -1 = inversely proportional to income).
damage_elasticity = 1.0

# Share of recycled carbon tax revenue that each region-quintile pair receives (row = region, column = quintile)
recycle_share = ones(12,5) .* 0.2

# Should the time-varying elasticity values only change across the range of GDP values from the studies?
# true = limit calculations to study gdp range, false = allow calculations for 0 to +Inf GDP.
bound_gdp_elasticity = false

# Quintile income distribution scenario (options = "constant", "lessInequality", "moreInequality", "SSP1", "SSP2", "SSP3", "SSP4", or "SSP5")
quintile_income_scenario = "constant"

# Do you also want to perform a reference case optimization run (with no revenue recycling)?
run_reference_case = true

# Name of folder to store your results in (a folder will be created with this name).
results_folder = "base_case"

# run and SAVE, or just run
save_results = true

# ------------------------------------------------------------------------------------------------
# CHOICES ABOUT YOUR ANALYSIS & OPTIMZATION
# ------------------------------------------------------------------------------------------------

# Number of 10-year timesteps to find optimal carbon tax for (after which model assumes full decarbonization).
n_objectives = 45

# Global optimization algorithm (:symbol) used for initial result. See options at http://ab-initio.mit.edu/wiki/index.php/NLopt_Algorithms
global_opt_algorithm = :GN_DIRECT_L

# Local optimization algorithm (:symbol) used to "polish" global optimum solution.
local_opt_algorithm = :LN_SBPLX

# Maximum time in seconds to run global optimization (in case optimization does not converge).
global_stop_time = 600

# Maximum time in seconds to run local optimization (in case optimization does not converge).
local_stop_time = 300

# Relative tolerance criteria for global optimization convergence (will stop if |Δf| / |f| < tolerance from one iteration to the next.)
global_tolerance = 1e-8

# Relative tolerance criteria for global optimization convergence (will stop if |Δf| / |f| < tolerance from one iteration to the next.)
local_tolerance = 1e-12

# ------------------------------------------------------------------------------------------------
# RUN EVERYTHING & SAVE KEY RESULTS
# ------------------------------------------------------------------------------------------------

# model parameters not controlled above are set in this file
include("instantiate_model_in_interface.jl")

# optimization takes place in this file
include("optimize_recycle.jl")

# reset parameters and optimize reference
include("instantiate_model_in_interface.jl")  # this might be redundant, but just making sure 
include("optimize_reference.jl")

# eta=2 and rho=0.1%
ρ =  0.001; η =  2
results_folder = "eta_2_rho_01"
include("instantiate_model_in_interface.jl")
include("optimize_recycle.jl")
include("instantiate_model_in_interface.jl")
include("optimize_reference.jl")

# xi=0.5
ρ =  0.015; η =  1.5
damage_elasticity = 0.5
results_folder = "damage_elasticity_05"
include("instantiate_model_in_interface.jl")
include("optimize_recycle.jl")
include("instantiate_model_in_interface.jl")
include("optimize_reference.jl")

# xi= -1
damage_elasticity = -1.0
results_folder = "damage_elasticity_neg1"
include("instantiate_model_in_interface.jl")
include("optimize_recycle.jl")
include("instantiate_model_in_interface.jl")
include("optimize_reference.jl")

# bounded GDP in elasticity regression
damage_elasticity = 1.0
bound_gdp_elasticity = true
results_folder = "bounded_GDP"
include("instantiate_model_in_interface.jl")
include("optimize_recycle.jl")
include("instantiate_model_in_interface.jl")
include("optimize_reference.jl")

# bottom quintile gets 40% of revenue and rest get 15% each
bound_gdp_elasticity = false
recycle_share = [ones(12,1) .* 0.4 ones(12,4) * 0.15]
results_folder = "bottom_recycle_40"
include("instantiate_model_in_interface.jl")
include("optimize_recycle.jl")

# no tax revenue recycled to the bottom quintile
recycle_share = [ones(12,1) .* 0.0 ones(12,4) * 0.25]
results_folder = "no_recycling_for_bottom_quintile"
include("instantiate_model_in_interface.jl")
include("optimize_recycle.jl")

# all revenue to the bottom two quintiles 
recycle_share = [ones(12,2) .* 0.5 ones(12,3) * 0.0]
results_folder = "all_revenue_to_bottom_2_quintile"
include("instantiate_model_in_interface.jl")
include("optimize_recycle.jl")

# 30% of tax revenue is the administrative cost
recycle_share = ones(12,5) .* 0.2 .* 0.7
results_folder = "admin_burden_70_percent_tax"
include("instantiate_model_in_interface.jl")
include("optimize_recycle.jl")

# no climate damages
recycle_share = ones(12,5) .* 0.2
results_folder = "no_climate_damages"
include("instantiate_model_in_interface.jl")
set_param!(nice, :sealeveldamages, :slrmultiplier, bau_model[:sealeveldamages,:slrmultiplier] .* 0)
set_param!(nice, :damages, :a1, bau_model[:damages,:a1] .* 0)
set_param!(nice, :damages, :a2, bau_model[:damages,:a2] .* 0)
include("optimize_recycle.jl")
include("instantiate_model_in_interface.jl")
set_param!(nice, :sealeveldamages, :slrmultiplier, bau_model[:sealeveldamages,:slrmultiplier] .* 0)
set_param!(nice, :damages, :a1, bau_model[:damages,:a1] .* 0)
set_param!(nice, :damages, :a2, bau_model[:damages,:a2] .* 0)
include("optimize_reference.jl")

# double conventional damages (normal slr damages)
results_folder = "double_climate_damages"
include("instantiate_model_in_interface.jl")
set_param!(nice, :damages, :a1, bau_model[:damages,:a1] .* 2)
set_param!(nice, :damages, :a2, bau_model[:damages,:a2] .* 2)
include("optimize_recycle.jl")
include("instantiate_model_in_interface.jl")
set_param!(nice, :damages, :a1, bau_model[:damages,:a1] .* 2)
set_param!(nice, :damages, :a2, bau_model[:damages,:a2] .* 2)
include("optimize_reference.jl")

# double conventional damages (normal slr damages) + xi = -1
damage_elasticity = -1.0
results_folder = "double_climate_damages_elasticity_neg_1"
include("instantiate_model_in_interface.jl")
set_param!(nice, :damages, :a1, bau_model[:damages,:a1] .* 2)
set_param!(nice, :damages, :a2, bau_model[:damages,:a2] .* 2)
include("optimize_recycle.jl")
include("instantiate_model_in_interface.jl")
set_param!(nice, :damages, :a1, bau_model[:damages,:a1] .* 2)
set_param!(nice, :damages, :a2, bau_model[:damages,:a2] .* 2)
include("optimize_reference.jl")

# the inequality projections
damage_elasticity = 1
quintile_income_scenario = "lessInequality"
results_folder = "time_varying_consumption_shares_"*quintile_income_scenario
include("instantiate_model_in_interface.jl")
include("optimize_recycle.jl")
include("instantiate_model_in_interface.jl")
include("optimize_reference.jl")

quintile_income_scenario = "moreInequality"
results_folder = "time_varying_consumption_shares_"*quintile_income_scenario
include("instantiate_model_in_interface.jl")
include("optimize_recycle.jl")
include("instantiate_model_in_interface.jl")
include("optimize_reference.jl")

quintile_income_scenario = "SSP1"
results_folder = "time_varying_consumption_shares_"*quintile_income_scenario
include("instantiate_model_in_interface.jl")
include("optimize_recycle.jl")
include("instantiate_model_in_interface.jl")
include("optimize_reference.jl")

quintile_income_scenario = "SSP2"
results_folder = "time_varying_consumption_shares_"*quintile_income_scenario
include("instantiate_model_in_interface.jl")
include("optimize_recycle.jl")
include("instantiate_model_in_interface.jl")
include("optimize_reference.jl")

quintile_income_scenario = "SSP3"
results_folder = "time_varying_consumption_shares_"*quintile_income_scenario
include("instantiate_model_in_interface.jl")
include("optimize_recycle.jl")
include("instantiate_model_in_interface.jl")
include("optimize_reference.jl")

quintile_income_scenario = "SSP4"
results_folder = "time_varying_consumption_shares_"*quintile_income_scenario
include("instantiate_model_in_interface.jl")
include("optimize_recycle.jl")
include("instantiate_model_in_interface.jl")
include("optimize_reference.jl")

quintile_income_scenario = "SSP5"
results_folder = "time_varying_consumption_shares_"*quintile_income_scenario
include("instantiate_model_in_interface.jl")
include("optimize_recycle.jl")
include("instantiate_model_in_interface.jl")
include("optimize_reference.jl")

# only more basic consumption share studies
quintile_income_scenario = "constant"
results_folder = "expenditure_share_based_studies"
include("instantiate_model_in_interface.jl")
meta_intercept, meta_slope = meta_regression(elasticity_studies[elasticity_studies.Type .== "Direct",:])
set_param!(nice, :nice_recycle, :elasticity_intercept, meta_intercept)
set_param!(nice, :nice_recycle, :elasticity_slope, meta_slope)
include("optimize_recycle.jl")
include("instantiate_model_in_interface.jl")
meta_intercept, meta_slope = meta_regression(elasticity_studies[elasticity_studies.Type .== "Direct",:])
set_param!(nice, :nice_recycle, :elasticity_intercept, meta_intercept)
set_param!(nice, :nice_recycle, :elasticity_slope, meta_slope)
include("optimize_reference.jl")

# CGE and Input-output studies
results_folder = "CGE_IO_studies"
include("instantiate_model_in_interface.jl")
meta_intercept, meta_slope = meta_regression(elasticity_studies[elasticity_studies.Type .!= "Direct",:])
set_param!(nice, :nice_recycle, :elasticity_intercept, meta_intercept)
set_param!(nice, :nice_recycle, :elasticity_slope, meta_slope)
include("optimize_recycle.jl")
include("instantiate_model_in_interface.jl")
meta_intercept, meta_slope = meta_regression(elasticity_studies[elasticity_studies.Type .!= "Direct",:])
set_param!(nice, :nice_recycle, :elasticity_intercept, meta_intercept)
set_param!(nice, :nice_recycle, :elasticity_slope, meta_slope)
include("optimize_reference.jl")

##################################################################################
##  this is the finicky one

# optimal global recycling
# must change nice_revenue_recycling_component_time_varying.jl
# insert 
#	end 
#	pctax = sum(v.tax_revenue[t,:]) / sum(p.regional_population[t,:]) / 1e9
#	for r in d.regions
#	v.pc_tax_revenue[t,r] = pctax
# just before before temp_C,

include("MimiNICE_recycle_time_varying.jl")
recycle_share = ones(12,5) .* 0.2
results_folder = "optimal_equal_global_recycling"
include("instantiate_model_in_interface.jl")
include("optimize_recycle.jl")


############################################################################################################################################

# Add iterative optimzation with FAIR (code slightly separate from above model runs because it requires different models/functions).
using MimiFAIR13, Interpolations

# Reset model parameters to default values.
ρ = 0.015
η = 1.5
damage_elasticity = 1.0
recycle_share = ones(12,5) .* 0.2
bound_gdp_elasticity = false
quintile_income_scenario = "constant"

# Reset optimization parameters to default values (note FAIR optimziation just uses a local optimization due to computational burden of iterative approach).
run_reference_case = true
n_objectives = 45
n_fair_loops = 4
local_opt_algorithm = :LN_SBPLX
local_stop_time = 800
local_tolerance = 1e-11
results_folder = "FAIR_climate_model"

# Initialize BAU and base version of NICE with revenue recucling.
include("instantiate_model_in_interface.jl")

# Create an instance of FAIR used in optimzation and assign it exogenous forcing scenario from NICE.
fair_opt = create_fair_for_opt()
set_param!(fair_opt, :total_rf, :F_exogenous, interpolate_to_annual(bau_model[:radiativeforcing, :forcoth], 10))

# Calculate indices from NICE corresponding to FAIR annual years
nice_decadal_indices = findall((in)(collect(2005:10:2595)), (collect(2005:2595)))

#--------------------------------------------------------------------------#
#------ Carry out optimization for NICE+FAIR with revenue recycling. ------#
#--------------------------------------------------------------------------#

# Create NICE+FAIR with Revenue Recycling objective function with user-specified settings.
fair_recycle_objective = construct_fair_recycle_objective(nice, n_fair_loops, revenue_recycling = true)

# Set upper and lower bounds for global CO₂ tax (upper bound = maximum RICE backstop prices).
upper_bound = maximum(rice_backstop_prices, dims=2)[2:(n_objectives+1)]

# Create an NLopt optimization object for local optimization.
fair_recycle_opt = Opt(local_opt_algorithm, n_objectives)

# Set upper and lower bounds for global CO₂ tax (upper bound = maximum RICE backstop prices).
lower_bounds!(fair_recycle_opt, zeros(n_objectives))
upper_bounds!(fair_recycle_opt, upper_bound)

# Set maximum run time.
maxtime!(fair_recycle_opt, local_stop_time)

# Set convergence tolerance.
ftol_rel!(fair_recycle_opt, local_tolerance)

# Set objective function.
max_objective!(fair_recycle_opt, (x, grad) -> fair_recycle_objective(x))

# Optimize model using local optimization algorithm.
fair_recycle_max_welfare, fair_recycle_opt_tax, fair_recycle_convergence = optimize(fair_recycle_opt, upper_bound .* 0.1)

# ----- Run Model Under Optimal Policy and Save Results ----- #

# Get optimal regional CO₂ mitigation rates from final optimal tax.
fair_recycle_full_opt_tax, fair_recycle_opt_regional_mitigation = mu_from_tax(fair_recycle_opt_tax, rice_backstop_prices)

# Run NICE model under optimal policy.
set_param!(nice, :emissions, :MIU, fair_recycle_opt_regional_mitigation)
set_param!(nice, :nice_recycle, :global_carbon_tax, fair_recycle_full_opt_tax)
run(nice)

# Now itrate through optimal policy version using FAIR.
for loops = 1:n_fair_loops

    # Run FAIR with annualized NICE CO₂ emissions to calculate temperature.
    set_param!(fair_opt, :co2_cycle, :E, interpolate_to_annual(nice[:emissions, :E], 10))
    run(fair_opt)

    # Set FAIR temperature projections in NICE.
    set_param!(nice, :sealevelrise, :TATM, fair_opt[:temperature, :T][nice_decadal_indices])
    set_param!(nice, :damages, :TATM, fair_opt[:temperature, :T][nice_decadal_indices])
    run(nice)
end

# Save results (set global optimzation tax to -9999.99 because only doing local optimization).
save_nice_recycle_results(nice, bau_model, fair_recycle_full_opt_tax, ones(length(fair_recycle_full_opt_tax)) .* -9999.99, output_directory, revenue_recycling=true)

#-----------------------------------------------------------------------------#
#------ Carry out optimization for NICE+FAIR without revenue recycling. ------#
#-----------------------------------------------------------------------------#

# Create NICE+FAIR reference objective function with user-specified settings.
fair_reference_objective = construct_fair_recycle_objective(nice, n_fair_loops, revenue_recycling = false)

# Create an NLopt optimization object for local optimization.
fair_reference_opt = Opt(local_opt_algorithm, n_objectives)

# Set upper and lower bounds for global CO₂ tax (upper bound = maximum RICE backstop prices).
lower_bounds!(fair_reference_opt, zeros(n_objectives))
upper_bounds!(fair_reference_opt, upper_bound)

# Set maximum run time.
maxtime!(fair_reference_opt, local_stop_time)

# Set convergence tolerance.
ftol_rel!(fair_reference_opt, local_tolerance)

# Set objective function.
max_objective!(fair_reference_opt, (x, grad) -> fair_reference_objective(x))

# Optimize model using local optimization algorithm.
fair_reference_max_welfare, fair_reference_opt_tax, fair_reference_convergence = optimize(fair_reference_opt, upper_bound .* 0.1)

# ----- Run Model Under Optimal Policy and Save Results ----- #

# Get optimal regional CO₂ mitigation rates from final optimal tax.
fair_reference_full_opt_tax, fair_reference_opt_regional_mitigation = mu_from_tax(fair_reference_opt_tax, rice_backstop_prices)

# Run NICE model under optimal policy.
set_param!(nice, :emissions, :MIU, fair_reference_opt_regional_mitigation)
set_param!(nice, :nice_recycle, :global_carbon_tax, fair_reference_full_opt_tax)
run(nice)

# Now itrate through optimal policy version using FAIR.
for loops = 1:n_fair_loops

    # Run FAIR with annualized NICE CO₂ emissions to calculate temperature.
    set_param!(fair_opt, :co2_cycle, :E, interpolate_to_annual(nice[:emissions, :E], 10))
    run(fair_opt)

    # Set FAIR temperature projections in NICE.
    set_param!(nice, :sealevelrise, :TATM, fair_opt[:temperature, :T][nice_decadal_indices])
    set_param!(nice, :damages, :TATM, fair_opt[:temperature, :T][nice_decadal_indices])
    run(nice)
end

# Save results (set global optimzation tax to -9999.99 because only doing local optimization).
save_nice_recycle_results(nice, bau_model, fair_reference_full_opt_tax, ones(length(fair_recycle_full_opt_tax)) .* -9999.99, output_directory, revenue_recycling=false)
