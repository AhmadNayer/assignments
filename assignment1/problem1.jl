using PyPlot
using FileIO

# load and return the given image
function loadimage()

  return imread("a1p1.png")
end

# save the image as a .jld2 file
function savefile(img::Array{Float32,3})
save("a1p1.jld2",Dict("img" => img)) # You have to pass the variable as a dict to save
end

# load and return the .jld2 file
function loadfile()
  return load("a1p1.jld2")["img"]
end

# create and return a horizontally mirrored image
function mirrorhorizontal(img::Array{Float32,3})
	mirror = img
	 for i=1:225 # 225 is half of the width
       		tmp = mirror[:,450-i+1,:]
       		mirror[:,450-i+1,:]=mirror[:,i,:]
       		mirror[:,i,:]=tmp
       end
  return mirror
end

# display the normal and the mirrored image in one plot
function showimages(img1::Array{Float32,3}, img2::Array{Float32,3})
  subplot(1,2,1)
	imshow(img1)
subplot(1,2,2)
imshow(img2)
show()
end

#= Problem 1
Load and Display =#

function problem1()
  img1 = loadimage()
  savefile(img1)
  img2 = loadfile()
  img2 = mirrorhorizontal(img2)
  showimages(img1, img2)
end
