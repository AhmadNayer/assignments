using Images
using PyPlot
using Test
using LinearAlgebra
using FileIO

# Transform from Cartesian to homogeneous coordinates
function cart2hom(points::Array{Float64,2})
  points_hom = [points; ones(1,size(points,2))]
  return points_hom::Array{Float64,2}
end


# Transform from homogeneous to Cartesian coordinates
function hom2cart(points::Array{Float64,2})
  points_tmp =  zeros(size(points))
if points[end,1] != 0
  for i=1:size(points_tmp,2)
    points_tmp[:,i] = points[:,i]/points[end,i]
  end

  points_cart = points_tmp[1:end-1,:]
else points_cart = points[1:end-1,:]
end
  return points_cart::Array{Float64,2}
end


# Translation by v
function gettranslation(v::Array{Float64,1})
  T = zeros(size(v,1),1)
  T[:,1] = v
  return T::Array{Float64,2}
end

# Rotation of d degrees around x axis
function getxrotation(d::Int)
  Rx = [1 0 0; 0 cos(d) -sin(d); 0 sin(d) cos(d)]
  return Rx::Array{Float64,2}
end

# Rotation of d degrees around y axis
function getyrotation(d::Int)
    Ry = [cos(d) 0 sin(d); 0 1 0;  -sin(d) 0 cos(d)]
  return Ry::Array{Float64,2}
end

# Rotation of d degrees around z axis
function getzrotation(d::Int)
    Rz = [cos(d) -sin(d) 0; sin(d) cos(d) 0; 0 0 1]
  return Rz::Array{Float64,2}
end


# Central projection matrix (including camera intrinsics)
# K: Camera -> Image coordinates
function getcentralprojection(principal::Array{Int,1}, focal::Int)
  #K = [focal 0 principal[1] 0; 0 focal principal[2] 0; 0 0 1 0]
  K = zeros(3,4)
  K[1,1] = K[2,2] = focal
  K[3,3] = 1
  K[1,3] = principal[1]
  K[2,3] = principal[2]
  return K::Array{Float64,2}
end


# Return full projection matrix P and full model transformation matrix M
# P: World -> Image coordinates
# M: World -> Camera coordinates
# both matrices are for homogeneous coordinates
function getfullprojection(T::Array{Float64,2},Rx::Array{Float64,2},Ry::Array{Float64,2},Rz::Array{Float64,2},V::Array{Float64,2})
  R = Rx * Ry * Rz
  P = V[1:3,1:3] * [R T]
  M = [R T ; [0 0 0 1]]
  return P::Array{Float64,2},M::Array{Float64,2}
end



# Load 2D points
function loadpoints()
  points = load("obj2d.jld2")["x"]
  return points::Array{Float64,2}
end


# Load z-coordinates
function loadz()
  z = load("zs.jld2")["Z"]
  return z::Array{Float64,2}
end


# Invert just the central projection P of 2d points *P2d* with z-coordinates *z*
# Image -> homogeneous Camera coordinates
function invertprojection(P::Array{Float64,2}, P2d::Array{Float64,2}, z::Array{Float64,2})
  hP2d = cart2hom(P2d)
  P3d = ones(4,size(hP2d,2))
  for i =1:size(hP2d,2)
    P3d[:,i] = P \ hP2d[:,i]
  end
  P3d = P3d[1:3,:] .* z
  return P3d::Array{Float64,2}
end


# Invert just the model transformation of the 3D points *P3d*
# Camera -> homogeneous World coordinates
# A: extrinsic camera matrix
function inverttransformation(A::Array{Float64,2}, P3d::Array{Float64,2})
  P3d = cart2hom(P3d)
  X=ones(size(P3d))
  for i=1:size(P3d,2)
    X[:,i] = A \ P3d[:,i]
  end
  return X::Array{Float64,2}
end


# Plot 2D points
function displaypoints2d(points::Array{Float64,2})
  figure()
  plot(points)
  return gcf()::Figure
end

# Plot 3D points
function displaypoints3d(points::Array{Float64,2})
  figure()
  plot(points)
  return gcf()::Figure
end

# Apply full projection matrix *C* to 3D points *X*
# World -> Image Coordinates
function projectpoints(P::Array{Float64,2}, X::Array{Float64,2})
  hX = cart2hom(X)
  hP2d = zeros(3,size(X,2))
  for i=1:size(X,2)
    hP2d[:,i] = P * hX[:,i]
  end
  P2d = hom2cart(hP2d)
  return P2d::Array{Float64,2}
end



#= Problem 3
Projective Transformation =#

function problem3()
  # parameters
  t               = [6.7; -10; 4.2]
  principal_point = [9; -7]
  focal_length    = 8

  # model transformations
  T = gettranslation(t)
  Ry = getyrotation(-45)
  Rx = getxrotation(120)
  Rz = getzrotation(-10)

  # central projection including camera intrinsics
  K = getcentralprojection(principal_point,focal_length)

  # full projection and model matrix
  P,M = getfullprojection(T,Rx,Ry,Rz,K)

  # load data and plot it
  points = loadpoints()
  displaypoints2d(points)

  # reconstruct 3d scene
  z = loadz()
  Xt = invertprojection(K,points,z) # Image -> hom. Camera
  Xh = inverttransformation(M,Xt) # hom. Camera -> homogeneous World

  worldpoints = hom2cart(Xh)
  displaypoints3d(worldpoints)

  # reproject points : inhom. World -> Image
  points2 = projectpoints(P,worldpoints)
  displaypoints2d(points2)

  @test points ≈ points2
  return
end
