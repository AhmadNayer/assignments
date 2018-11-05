#Name: Ahmad Nayer, Fatih Bostanci
#Matrikulation No: 2925714,

using Images  # Basic image processing functions
using PyPlot  # Plotting and image loading
using FileIO  # Functions for loading and storing data in the ".jld2" format
using ImageView #imshow usage


# Load the image from the provided .jld2 file
function loaddata()

path = "imagedata.jld2"
data= load(path,"data")
return data::Array{Float64,2}
end


# Separate the image data into three images (one for each color channel),
# filling up all unknown values with 0
function separatechannels(data::Array{Float64,2})
r= zeros(size(data))
g= zeros(size(data))
b=zeros(size(data))
g[1:2:end,2:2:end]=data[1:2:end,2:2:end]
r[1:2:end,1:2:end]=data[1:2:end,1:2:end]
r[2:2:end,2:2:end]=data[2:2:end,2:2:end]
b[2:2:end,1:2:end]=data[2:2:end,1:2:end]
return r::Array{Float64,2},g::Array{Float64,2},b::Array{Float64,2}
end


# Combine three color channels into a single image
function makeimage(r::Array{Float64,2},g::Array{Float64,2},b::Array{Float64,2})
#concatinate along three dimensions
  image=cat(3,r,g,b)
  return image::Array{Float64,3}
end


# Interpolate missing color values using bilinear interpolation
function interpolate(r::Array{Float64,2},g::Array{Float64,2},b::Array{Float64,2})

  rbfilter=[0.25 0.5 0.25; 0.5 1 0.5; 0.25 0.5 0.25]
  gfilter=[0 0.25 0; 0.25 1 0.25; 0 0.25 0]
  r= imfilter(r, rbfilter, "reflect")
  g= imfilter(g, gfilter, "reflect")
  b= imfilter(b, rbfilter, "reflect")
#concatinate along three dimension
  image=cat(3,r,g,b)
  return image::Array{Float64,3}
end

# Display two images in a single figure window
function displayimages(img1::Array{Float64,3}, img2::Array{Float64,3})
  figure()
  subplot(1,2,1)
  imshow(img1)
  axis("off")
  subplot(1,2,2)
  imshow(img2)
  axis("off")

end

#= Problem 2
Bayer Interpolation =#

function problem2()
  # load raw data
  data = loaddata()
  # separate data
  r,g,b = separatechannels(data)
  # merge raw pattern
  img1 = makeimage(r,g,b)
  # interpolate
  img2 = interpolate(r,g,b)
  # display images
  displayimages(img1, img2)
  return
end
