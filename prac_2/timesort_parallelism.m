function t_inbuilt = timesort_parallelism(size)

A=rand(size, size);


tic
for i = 1:size
    A(:,i) = sort(A(:,i));
end
t_inbuilt = toc();

display("Time tacken by the sort function was " + t_inbuilt );

return;
end