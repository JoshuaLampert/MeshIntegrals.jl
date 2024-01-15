using LineIntegrals
using Meshes
using QuadQK
using Unitful
using Test

################################################################################
#                             Tests -- Integrals
################################################################################

@testset "Integrate" begin
    # Points on unit circle at axes
    pt_e = Point( 1.0,  0.0, 0.0)
    pt_n = Point( 0.0,  1.0, 0.0)
    pt_w = Point(-1.0,  0.0, 0.0)
    pt_s = Point( 0.0, -1.0, 0.0)

    # Line segments oriented CCW between points
    seg_ne = Segment(pt_e, pt_n)
    seg_nw = Segment(pt_n, pt_w)
    seg_sw = Segment(pt_w, pt_s)
    seg_se = Segment(pt_s, pt_e)

    # Rectangular trajectory CCW around the four points
    rect_traj_segs = [seg_ne, seg_nw, seg_sw, seg_se]
    rect_traj_ring = Ring(pt_e, pt_n, pt_w, pt_s)
    rect_traj_rope = Rope(pt_e, pt_n, pt_w, pt_s, pt_e)

    # Approximately circular trajectory CCW around the unit circle
    unit_circle = BezierCurve(
        [Point(cos(t), sin(t), 0.0) for t in range(0, 2pi, length=361)]
    )

    @testset "QuadGK Methods" begin
        # QuadGK.quadgk(f, ::Meshes.Segment)
        @test quadgk(f, seg_ne)[1] ≈ sqrt(2)

        # QuadGK.quadgk(f, ::Meshes.BezierCurve)
        @test isapprox(quadgk(f, unit_circle)[1], 2pi; atol=0.15)
    end

    @testset "Caught Errors" begin
        # Catch wrong method signature: f(x,y,z) vs f(::Point)
        fvec(x,y,z) = x*y*z
        @test_throws ErrorException integral(fvec, seg_ne)          # Meshes.Segment
        @test_throws ErrorException integral(fvec, rect_traj_segs)  # Vector{::Meshes.Segment}
        @test_throws ErrorException integral(fvec, rect_traj_ring)  # Meshes.Ring
        @test_throws ErrorException integral(fvec, rect_traj_rope)  # Meshes.Rope
        @test_throws ErrorException integral(fvec, unit_circle)     # Meshes.BezierCurve
    end

    @testset "Scalar-Valued Functions" begin
        f(::Point{Dim,T}) where {Dim,T} = 1.0
        @test integral(f, seg_ne) ≈ sqrt(2)                         # Meshes.Segment
        @test integral(f, rect_traj_segs) ≈ 4sqrt(2)                # Vector{::Meshes.Segment}
        @test integral(f, rect_traj_ring) ≈ 4sqrt(2)                # Meshes.Ring
        @test integral(f, rect_traj_rope) ≈ 4sqrt(2)                # Meshes.Rope
        @test isapprox(integral(f, unit_circle), 2pi; atol=0.15)    # Meshes.BezierCurve
    end

    @testset "Vector-Valued Functions" begin
        f(::Point{Dim,T}) where {Dim,T} = [1.0, 1.0, 1.0]
        @test integral(f, seg_ne) ≈ [sqrt(2), sqrt(2), sqrt(2)]                # Meshes.Segment
        @test integral(f, rect_traj_segs) ≈ 4 .* [sqrt(2), sqrt(2), sqrt(2)]   # Vector{::Meshes.Segment}
        @test integral(f, rect_traj_ring) ≈ 4 .* [sqrt(2), sqrt(2), sqrt(2)]   # Meshes.Ring
        @test integral(f, rect_traj_rope) ≈ 4 .* [sqrt(2), sqrt(2), sqrt(2)]   # Meshes.Rope
        @test isapprox(integral(f, unit_circle), [2π, 2π, 2π]; atol=0.15)      # Meshes.BezierCurve
    end
end

@testset "Integrate Unitful" begin
    # Points on unit circle at axes
    pt_e = Point( 1.0u"m",  0.0u"m", 0.0u"m")
    pt_n = Point( 0.0u"m",  1.0u"m", 0.0u"m")
    pt_w = Point(-1.0u"m",  0.0u"m", 0.0u"m")
    pt_s = Point( 0.0u"m", -1.0u"m", 0.0u"m")

    # Line segments oriented CCW between points
    seg_ne = Segment(pt_e, pt_n)
    seg_nw = Segment(pt_n, pt_w)
    seg_sw = Segment(pt_w, pt_s)
    seg_se = Segment(pt_s, pt_e)

    # Rectangular trajectory CCW around the four points
    rect_traj_segs = [seg_ne, seg_nw, seg_sw, seg_se]
    rect_traj_ring = Ring(pt_e, pt_n, pt_w, pt_s)
    rect_traj_rope = Rope(pt_e, pt_n, pt_w, pt_s, pt_e)

    # Approximately circular trajectory CCW around the unit-meter circle
    unit_circle = BezierCurve(
        [Point(cos(t)*u"m", sin(t)*u"m", 0.0u"m") for t in range(0, 2pi, length=361)]
    )

    @testset "Scalar-Valued Functions" begin
        f(::Point{Dim,T}) where {Dim,T} = 1.0u"Ω/m"
        @test integral(f, seg_ne) ≈ sqrt(2)*u"Ω"                            # Meshes.Segment
        @test integral(f, rect_traj_segs) ≈ 4sqrt(2)*u"Ω"                   # Vector{::Meshes.Segment}
        @test integral(f, rect_traj_ring) ≈ 4sqrt(2)*u"Ω"                   # Meshes.Ring
        @test integral(f, rect_traj_rope) ≈ 4sqrt(2)*u"Ω"                   # Meshes.Rope
        @test isapprox(integral(f, unit_circle), 2π*u"Ω"; atol=0.15u"Ω")    # Meshes.BezierCurve
    end

    @testset "Vector-Valued Functions" begin
        f(::Point{Dim,T}) where {Dim,T} = [1.0u"Ω/m", 1.0u"Ω/m", 1.0u"Ω/m"]
        @test integral(f, seg_ne) ≈ [sqrt(2), sqrt(2), sqrt(2)] .* u"Ω"                  # Meshes.Segment
        @test integral(f, rect_traj_segs)  ≈ 4 .* [sqrt(2), sqrt(2), sqrt(2)] .* u"Ω"    # Vector{::Meshes.Segment}
        @test integral(f, rect_traj_ring) ≈ 4 .* [sqrt(2), sqrt(2), sqrt(2)] .* u"Ω"     # Meshes.Ring
        @test integral(f, rect_traj_rope) ≈ 4 .* [sqrt(2), sqrt(2), sqrt(2)] .* u"Ω"     # Meshes.Rope
        @test isapprox(integral(f, unit_circle), [2π, 2π, 2π] .* u"Ω"; atol=0.15u"Ω")    # Meshes.BezierCurve
    end
end
