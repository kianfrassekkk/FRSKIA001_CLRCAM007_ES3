function t_user = timetest_parallelism(size)

X=rand(size, size);

tic
spmd
    myStart = (spmdIndex - 1) * 25 + 1;
    myEnd = myStart + 24;
    for i = myStart:myEnd
        X(:,i) = BubbleSort(X(:,i));
    end
end
t_user = toc();
p.delete;

display("Time tacken by the parallelism bubble sort function was " + t_user )

return;
end
