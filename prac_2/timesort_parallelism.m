function t_inbuilt = timesort_parallelism(size)

X=rand(size, size);

tic
spmd
    myStart = (spmdIndex - 1) * 25 + 1;
    myEnd = myStart + 24;
    for i = myStart:myEnd
        X(:,i) = sort(X(:,i));
    end
end
t_inbuilt = toc();

display("Time tacken by the parallelism sort function was " + t_inbuilt )

return;
end