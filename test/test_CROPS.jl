using Changepoints, Base.Test

println("Running CROPS tests...")

n = 1000;        # Number of samples
λ = 100;         # Frequencey of changes
pen = (1.1, 6.1)

function test_CROPS(segment_cost::Function , n::Int64, pen::Tuple{Real,Real})
    out = CROPS(segment_cost, n, pen)
    for (i, β) in enumerate(out["penalty"])
        #println("i=$i, β=$β")
        cps, cost = PELT(segment_cost, n; pen=β)
        @test_approx_eq_eps out["constrained"][i] (cost-(length(cps)-1)*β) 1e-3
    end
end

########################
# Normal mean segments #
########################

μ, σ = Normal(0.0, 10.0), 1.0
sample, cps = @changepoint_sampler n λ Normal(μ, σ)
segment_cost = NormalMeanSegment(sample);
#test_CROPS(segment_cost, n, pen)
out=@PELT sample Normal(?,σ) pen[1] pen[2]

# num,cons = Int[], Float64[]
# for (i, β) in enumerate(out["penalty"])
#     #println("i=$i, β=$β")
#     cps, cost = PELT(segment_cost, n; pen=β)
#     push!(num, length(cps))
#     push!(cons, cost-(length(cps)-1)*β)
# end

# cons'
# out["constrained"]'


#######################
# Normal var segments #
#######################
μ, σ = 1.0, Uniform(2.0, 15.0)
sample, cps = @changepoint_sampler n λ Normal(μ, σ)
seg_costs = NormalVarSegment(sample, μ)
test_CROPS(seg_costs, n, pen)
@PELT sample Normal(μ, ?) pen[1] pen[2]

############################
# Exponential changepoints #
############################
μ = Uniform(0.0, 10.0)
sample, cps = @changepoint_sampler n λ Exponential(μ)
seg_costs = ExponentialSegment(sample)
CROPS(seg_costs, n, pen)
@PELT sample Exponential(?) pen[1] pen[2]

########################
# Poisson changepoints #
########################
μ = Uniform(0.0, 10.0)
sample, cps = @changepoint_sampler n λ Poisson(μ)
seg_costs = PoissonSegment(sample)
CROPS(seg_costs, n, pen)
@PELT sample Poisson(?) pen[1] pen[2]
