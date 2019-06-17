# @Author: Massimo De Mauri <massimo>
# @Date:   2019-02-19T22:28:53+01:00
# @Email:  massimo.demauri@gmail.com
# @Filename: QPALM_setup.jl
# @Last modified by:   massimo
# @Last modified time: 2019-06-14T14:42:00+02:00
# @License: apache 2.0
# @Copyright: {{copyright}}



# this function creates an QPALM.Model representing the given CvxQproblem
function setup(problem::Problem,settings::QPALMsettings;bb_primalTolerance::Float64=Inf,bb_timeLimit=Inf)::QPALMworkspace

    # reformat the settings for QPALM
    settings_dict = Dict{Symbol,Any}()
    for field in fieldnames(QPALMsettings)
        settings_dict[field] = getfield(settings,field)
    end

    # overwrite the osqp setting depending on the branch and bound settings
    settings_dict[:eps_prim_inf] = min(settings_dict[:eps_prim_inf],bb_primalTolerance)

    if bb_timeLimit < Inf
        if settings_dict[:timeLimit] == 0.
            settings_dict[:timeLimit] = bb_timeLimit
        else
            settings_dict[:timeLimit] = min(settings_dict[:timeLimit],bb_timeLimit)
        end
    end

    nVars = length(problem.varSet.loBs)


    # check the objective function
    if problem.objFun isa NullObjectiveFunction
        Q = spzeros(nVars,nVars)
        L = zeros(nVars)
    elseif problem.objFun isa LinearObjective
        Q = spzeros(nVars,nVars)
        L = problem.objFun.L
    elseif problem.objFun isa QuadraticObjective
        Q = sparse(problem.objFun.Q)
        L = problem.objFun.L
    else
        @error "QPALM cannot deal with the given objective function"
    end

    # check the constraint set
    if problem.cnsSet isa NullConstraintSet
        # adapt the constraint set to accomodate for variables bounds
        A = zeros((0,length(problem.varSet.loBs)))
        cnsLoBs = Float64[]
        cnsUpBs = Float64[]

    elseif problem.cnsSet isa LinearConstraintSet
        # adapt the constraint set to accomodate for variables bounds
        A = sparse(problem.cnsSet.A)
        cnsLoBs = copy(problem.cnsSet.loBs)
        cnsUpBs = copy(problem.cnsSet.upBs)
    else
        @error "QPALM cannot deal with the given constraint set"
    end


    # create the subsolver QPALMworkspace
    model = QPALM.Model()
    if length(problem.varSet.loBs) > 0
        QPALM.setup!(model;Q=Q,
                          q=L,
                          A=vcat(speye(length(problem.varSet.loBs)),sparse(A)),
                          bmin=vcat(problem.varSet.loBs,cnsLoBs),
                          bmax=vcat(problem.varSet.upBs,cnsUpBs),
                          settings_dict...)
    end

    return QPALMworkspace(copy(Q),copy(L),
                     copy(A),copy(cnsLoBs),copy(cnsUpBs),
                     copy(problem.varSet.loBs),copy(problem.varSet.upBs),
                     model,settings)
end