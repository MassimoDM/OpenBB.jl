# @Author: Massimo De Mauri <massimodemauri>
# @Date:   2019-02-06T16:19:51+01:00
# @Email:  massimo.demauri@gmail.com
# @Project: OpenBB
# @Filename: OpenBB.jl
# @Last modified by:   massimo
# @Last modified time: 2019-05-01T00:44:09+02:00
# @License: apache 2.0
# @Copyright: {{copyright}}


module OpenBB

info() = print("Hey you, there are no info yet...")

# include external packages
using SparseArrays
using LinearAlgebra

# select the subsolvers to use
function withOSQP()::Bool
    return true
end
function withGUROBI()::Bool
    return true
end
function withQPALM()::Bool
    return true
end


# language interfaces
include("./problem_definition/problem_definition.jl")

# solvers
include("./branch_and_bound/BB.jl")

# some utilities
include("./utilities/numerical_utilities.jl")

# subsolvers interfaces
if withOSQP()
    include("./subsolvers_interfaces/OSQP_interface/OSQP_interface.jl")
end
if withGUROBI()
    include("./subsolvers_interfaces/GUROBI_interface/GUROBI_interface.jl")
end
if withQPALM()
    include("./subsolvers_interfaces/QPALM_interface/QPALM_interface.jl")
end

# include heuristics
include("./heuristics/heuristics.jl")


end # module
