% Create an array X.
X = [1,2,3];
% Transfer X to the GPU.
G = gpuArray(X);
% Check that the data is on the GPU.
isgpuarray(G) % should give ans = logical 1
% Calculate the element-wise square of the array G.
GSq = G.^2; % basically tells GPU what it needs to do, must be PSMD operation
% Transfer the result GSq back to the CPU:
XSq = gather(GSq) % this gathers all the data blocks, which may have been
 % distributed between blocks of cores in ‘block memory’
% gives answer: XSq = 1×3
% 1 4 9
6
% Check that the data is not on the GPU.
isgpuarray(XSq) % should give ans = logical 0