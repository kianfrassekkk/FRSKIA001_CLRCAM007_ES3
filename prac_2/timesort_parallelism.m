function t_inbuilt = timesort_parallelism(size)

X=rand(size, size);

tic
for i = 1:size
    X(:,i) = sort(X(:,i));
end
t_inbuilt = toc();

display("Time tacken by the sort function was " + t_inbuilt )

return;
end