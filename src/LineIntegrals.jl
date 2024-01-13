module LineIntegrals
    using LinearAlgebra
    using Meshes
    using QuadGK

    include("structs.jl")
    export SurfacePathSegment, SurfaceTrajectory

    include("integrate.jl")
    export integrate

    include("utils.jl")
    export derivative
end
