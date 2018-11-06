#Ahmad Nayer, Fatih Bostanci
#2925714

using Images
using PyPlot

# Create 3x3 derivative filters in x and y direction
function createfilters()
dx= [-0.5 0 0.5]                      #x-derivative using central differences
dy= [-0.5 0 0.5]'                     #y-derivative using central differences
ygau = 1.14*[ 0.239 0.443 0.239]'     # gaussian kernel in x-direction  : (1/sigma*(2*pi).^1/2)*exp(-(X.^2)/(2*sigma.^2)) with normalizing factor
xgau = 1.14*[0.239 0.443 0.239]       # gaussian kernel in y-direction : (1/sigma*(2*pi).^1/2)*exp(-(Y.^2)/(2*sigma.^2)) with normalizing factor
fx = ygau*dx                          # 3*3 x-filter
fy = dy* xgau                         # 3*3 y-filter
#fx is basically fy'
return fx::Array{Float64,2}, fy::Array{Float64,2}
end

# Apply derivate filters to an image and return the derivative images
function filterimage(I::Array{Float32,2},fx::Array{Float64,2},fy::Array{Float64,2})

Ix=imfilter(I,fx,"replicate")     #filter image "I" using xderivative filter
Iy=imfilter(I,fy,"replicate")     ##filter image "I" using yderivative filter
  return Ix::Array{Float64,2},Iy::Array{Float64,2}
end


# Apply thresholding on the gradient magnitudes to detect edges
function detectedges(Ix::Array{Float64,2},Iy::Array{Float64,2}, thr::Float64)
mag= sqrt(Ix.^2 +Iy.^2) #magnitude of the gradient
mag[mag .< thr] =0     #find indices where magnitude is less then threshold and put it to zero
edges= mag               #these are the edges
  return edges::Array{Float64,2}
end


# Apply non-maximum-suppression
function nonmaxsupp(edges::Array{Float64,2},Ix::Array{Float64,2},Iy::Array{Float64,2})

orient=atan(Iy./Ix) #orientation of gradient
  ori=padarray(orient,(1,1),(1,1),"reflect")
  L=size(orient)
  for m in 2:L[1]-1
    for n in 2:L[2]-1
      if (ori[m,n]<=pi/8)&&(ori[m,n]>-pi/8)&&(edges[m,n]<max(edges[m,n-1],edges[m,n+1]))
        edges[m,n]=0
      elseif ((ori[m,n]>3*pi/8)||(ori[m,n]<=-3*pi/8))&&(edges[m,n]<max(edges[m-1,n],edges[m+1,n]))
        edges[m,n]=0
      elseif (ori[m,n]<=3*pi/8)&&(ori[m,n]>pi/8)&&(edges[m,n]<max(edges[m-1,n-1],edges[m+1,n+1]))
        edges[m,n]=0
      elseif (ori[m,n]>-3*pi/8)&&(ori[m,n]<=-pi/8)&&(edges[m,n]<max(edges[m+1,n-1],edges[m-1,n+1]))
        edges[m,n]=0
      end
    end
  end
  return edges::Array{Float64,2}
  end

#= Problem 4
Image Filtering and Edge Detection =#

function problem4()

  # load image
  img = PyPlot.imread("a1p4.png")

  # create filters
  fx, fy = createfilters()

  # filter image
  imgx, imgy = filterimage(img, fx, fy)

  # show filter results
  figure()
  subplot(121)
  imshow(imgx, "gray", interpolation="none")
  title("x derivative")
  axis("off")
  subplot(122)
  imshow(imgy, "gray", interpolation="none")
  title("y derivative")
  axis("off")
  gcf()

  # show gradient magnitude
  figure()
  imshow(sqrt.(imgx.^2 + imgy.^2),"gray", interpolation="none")
  axis("off")
  title("Derivative magnitude")
  gcf()

  # threshold derivative
  threshold = 38. / 255.
  edges = detectedges(imgx,imgy,threshold)
  figure()
  imshow(edges.>0, "gray", interpolation="none")
  axis("off")
  title("Binary edges")
  gcf()

  # non maximum suppression
  edges2 = nonmaxsupp(edges,imgx,imgy)
  figure()
  imshow(edges2,"gray", interpolation="none")
  axis("off")
  title("Non-maximum suppression")
  gcf()
  return
end
